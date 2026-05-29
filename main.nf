#!/usr/bin/env nextflow

// Activamos la sintaxis DSL2 
nextflow.enable.dsl=2

// 1. IMPORTAMOS LOS MÓDULOS 
include { DOWNLOAD_SRA_TUMOR; DOWNLOAD_SRA_NORMAL } from './modules/download_sra.nf'
include { RUN_FASTQC as FASTQC_TUMOR; RUN_FASTQC as FASTQC_NORMAL } from './modules/fastqc/fastqc.nf'

// 2. EL WORKFLOW PRINCIPAL 
workflow {
    
    // Creamos canales de Nextflow a partir de los códigos SRR del archivo params.yaml
    ch_tumor_id  = Channel.of(params.dataset.tumor_sra)
    ch_normal_id = Channel.of(params.dataset.normal_sra)

    // Lanzamos los procesos de descarga en paralelo
    DOWNLOAD_SRA_TUMOR(ch_tumor_id)
    DOWNLOAD_SRA_NORMAL(ch_normal_id)
    
    // Paso 2: Control de Calidad (Conectamos la salida .fastq de las descargas)
    FASTQC_TUMOR(DOWNLOAD_SRA_TUMOR.out.fastq)
    FASTQC_NORMAL(DOWNLOAD_SRA_NORMAL.out.fastq)
}