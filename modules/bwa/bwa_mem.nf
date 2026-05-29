// modules/bwa/bwa_mem.nf

process ALIGN_READS {
    tag "Aligning: $sample_id"
    
    // Contenedor que incluye BWA y Samtools juntos
    container 'biocontainers/mulled-v2-fe80ae45001e7e4d65408b1b2b3588f6afcee11a:86646bda2ac2cce84ab6829990b7936a28ee989a-0'
    
    publishDir "${params.outdir}/alignment", mode: 'copy'

    input:
    // Pasamos una tupla con el ID de la muestra y sus dos archivos FASTQ
    tuple val(sample_id), path(reads)
    path reference       // El FASTA del genoma
    path ref_indices     // Todos los archivos de índice (.amb, .ann, .bwt, etc.)

    output:
    // Emitimos el archivo BAM ordenado y su índice .bai
    tuple val(sample_id), path("${sample_id}_sorted.bam"), emit: bam
    path "${sample_id}_sorted.bam.bai"                   , emit: bai

    script:
    """
    # 1. Alineamos con BWA-MEM añadiendo el Read Group (RG), obligatorio para GATK
    # 2. Redirigimos la salida a 'samtools sort' para ahorrar espacio en disco usando un pipe (|)
    bwa mem -t ${task.cpus} \\
        -R "@RG\\tID:${sample_id}\\tLB:WES\\tPL:ILLUMINA\\tSM:${sample_id}" \\
        $reference \\
        ${reads[0]} ${reads[1]} | \\
        samtools sort -@ ${task.cpus} -o ${sample_id}_sorted.bam -
    
    # 3. Indexamos el BAM resultante (crea el archivo .bam.bai)
    samtools index ${sample_id}_sorted.bam
    """
}