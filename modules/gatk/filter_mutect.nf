// modules/gatk/filter_mutect.nf

process FILTER_SOMATIC_VARIANTS {
    tag "Filtering: ${patient_id}"
    
    container 'broadinstitute/gatk:4.5.0.0'
    
    publishDir "${params.outdir}/variants/filtered", mode: 'copy'

    input:
    val patient_id
    path raw_vcf
    path raw_tbi
    path reference
    path ref_indices

    output:
    // El output final del pipeline: el VCF filtrado y listo para interpretar
    path "${patient_id}_mutect2_filtered.vcf.gz"      , emit: vcf
    path "${patient_id}_mutect2_filtered.vcf.gz.tbi"  , emit: tbi

    script:
    """
    # FilterMutectCalls analiza las anotaciones estadísticas internas que Mutect2 dejó en el VCF
    gatk --java-options "-Xmx4g" FilterMutectCalls \\
        -R $reference \\
        -V $raw_vcf \\
        -O ${patient_id}_mutect2_filtered.vcf.gz
    """
}