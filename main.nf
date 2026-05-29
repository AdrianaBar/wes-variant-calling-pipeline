#!/usr/bin/env nextflow

nextflow.enable.dsl=2

// 1. IMPORTAMOS LOS MÓDULOS 
include { DOWNLOAD_SRA_TUMOR; DOWNLOAD_SRA_NORMAL } from './modules/download_sra.nf'
include { RUN_FASTQC as FASTQC_TUMOR; RUN_FASTQC as FASTQC_NORMAL } from './modules/fastqc/fastqc.nf'
include { ALIGN_READS as ALIGN_TUMOR; ALIGN_READS as ALIGN_NORMAL } from './modules/bwa/bwa_mem.nf'
include { MARK_DUPLICATES as DEDUP_TUMOR; MARK_DUPLICATES as DEDUP_NORMAL } from './modules/gatk/mark_duplicates.nf'
include { CALL_SOMATIC_VARIANTS } from './modules/gatk/mutect2.nf'
include { FILTER_SOMATIC_VARIANTS } from './modules/gatk/filter_mutect.nf'

// 2. EL WORKFLOW PRINCIPAL 
workflow {
    
    // Canales para las descargas
    ch_patient_id = params.dataset.patient_id    
    ch_tumor_id  = Channel.of(params.dataset.tumor_sra)
    ch_normal_id = Channel.of(params.dataset.normal_sra)

    // Canales para la referencia (los lee desde las rutas del params.yaml)
    ch_ref       = file(params.genome_reference)
    // Buscamos todos los archivos que empiecen igual que la referencia (los índices)
    ch_indices   = Channel.fromPath("${params.genome_reference}.*").collect()

    // PASO 1: Descarga
    DOWNLOAD_SRA_TUMOR(ch_tumor_id)
    DOWNLOAD_SRA_NORMAL(ch_normal_id)
    
    // Paso 2: Control de Calidad
    FASTQC_TUMOR(DOWNLOAD_SRA_TUMOR.out.fastq)
    FASTQC_NORMAL(DOWNLOAD_SRA_NORMAL.out.fastq)

    // Preparar las tuplas [id, [fastq_1, fastq_2]] para el alineador
    ch_tumor_ready  = ch_tumor_id.zip(DOWNLOAD_SRA_TUMOR.out.fastq)
    ch_normal_ready = ch_normal_id.zip(DOWNLOAD_SRA_NORMAL.out.fastq)

    // PASO 3: Alineamiento con BWA-MEM
    ALIGN_TUMOR(ch_tumor_ready, ch_ref, ch_indices)
    ALIGN_NORMAL(ch_normal_ready, ch_ref, ch_indices)

    // PASO 4: Eliminación de Duplicados de PCR (Conectamos el .bam emitido por BWA)
    DEDUP_TUMOR(ALIGN_TUMOR.out.bam)
    DEDUP_NORMAL(ALIGN_NORMAL.out.bam)

    // PASO 5: Llamado de Variantes Somáticas (Mutect2)
    // Extraemos los elementos de las tuplas (.map) para pasárselos limpios al proceso
    CALL_SOMATIC_VARIANTS(
        ch_patient_id,
        ch_tumor_id,
        ch_normal_id,
        DEDUP_TUMOR.out.bam.map { it[1] },
        DEDUP_TUMOR.out.bai,
        DEDUP_NORMAL.out.bam.map { it[1] },
        DEDUP_NORMAL.out.bai,
        ch_ref,
        ch_indices
    )

    // PASO 6: Filtrado Estadístico (FilterMutectCalls)
    FILTER_SOMATIC_VARIANTS(
        ch_patient_id,
        CALL_SOMATIC_VARIANTS.out.vcf,
        CALL_SOMATIC_VARIANTS.out.tbi,
        ch_ref,
        ch_indices
    )
}