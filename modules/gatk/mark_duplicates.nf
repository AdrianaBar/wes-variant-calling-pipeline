// modules/gatk/mark_duplicates.nf

process MARK_DUPLICATES {
    tag "Marking Dups: $sample_id"
    
    // Contenedor oficial del Broad Institute que incluye todo GATK4 y Picard
    container 'broadinstitute/gatk:4.5.0.0'
    
    publishDir "${params.outdir}/alignment/dedup", mode: 'copy'

    input:
    // Recibe el BAM ordenado del alineador
    tuple val(sample_id), path(bam)

    output:
    // Emitimos el BAM sin duplicados, su nuevo índice y las métricas de duplicación
    tuple val(sample_id), path("${sample_id}_dedup.bam"), emit: bam
    path "${sample_id}_dedup.bai"                         , emit: bai
    path "${sample_id}_metrics.txt"                       , emit: metrics

    script:
    """
    # Ejecutamos MarkDuplicates de GATK (Picard integrado)
    # Le asignamos memoria Xmx directamente al proceso de Java
    gatk --java-options "-Xmx4g" MarkDuplicates \\
        -I $bam \\
        -O ${sample_id}_dedup.bam \\
        -M ${sample_id}_metrics.txt \\
        --CREATE_INDEX true
    """
}