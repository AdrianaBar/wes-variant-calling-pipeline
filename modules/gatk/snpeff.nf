// modules/gatk/snpeff.nf

process ANNOTATE_VARIANTS {
    tag "Annotating: ${patient_id}"
    
    // Contenedor oficial de SnpEff (BioContainers)
    container 'biocontainers/snpeff:5.2--hdfd78af_1'
    
    publishDir "${params.outdir}/variants/annotated", mode: 'copy'

    input:
    val patient_id
    path filtered_vcf
    path filtered_tbi

    output:
    // El Santo Grial: el VCF final con toda la información clínica añadida
    path "${patient_id}_mutect2_annotated.vcf"     , emit: vcf
    path "${patient_id}_snpeff_summary.html"       , emit: report

    script:
    """
    # Ejecutamos SnpEff utilizando la base de datos del genoma humano hg38
    # El flag -Xmx4g asigna la memoria necesaria a la máquina virtual de Java
    snpeff -Xmx4g GRCh38.105 \\
        $filtered_vcf \\
        > ${patient_id}_mutect2_annotated.vcf \\
        -csvStats ${patient_id}_snpeff_stats.csv \\
        -stats ${patient_id}_snpeff_summary.html
    """
}