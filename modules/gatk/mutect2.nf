// modules/gatk/mutect2.nf

process CALL_SOMATIC_VARIANTS {
    tag "Mutect2: ${patient_id}"
    
    container 'broadinstitute/gatk:4.5.0.0'
    
    publishDir "${params.outdir}/variants", mode: 'copy'

    input:
    val patient_id
    val tumor_id
    val normal_id
    path tumor_bam
    path tumor_bai
    path normal_bam
    path normal_bai
    path reference
    path ref_indices // Incluye el .fai y el .dict obligatorios para GATK

    output:
    // Emitimos el VCF crudo con las mutaciones somáticas detectadas
    path "${patient_id}_mutect2_raw.vcf.gz"      , emit: vcf
    path "${patient_id}_mutect2_raw.vcf.gz.tbi"  , emit: tbi

    script:
    """
    # Ejecutamos Mutect2 en modo Tumor-Normal Matched Pair
    gatk --java-options "-Xmx4g" Mutect2 \\
        -R $reference \\
        -I $tumor_bam \\
        -I $normal_bam \\
        -tumor $tumor_id \\
        -normal $normal_id \\
        -O ${patient_id}_mutect2_raw.vcf.gz
    """
}