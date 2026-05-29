// modules/fastqc/fastqc.nf

process RUN_FASTQC {
    tag "QC on: ${fastq_files[0].simpleName}"
    
    // Dejamos declarado el contenedor oficial de FastQC para el futuro
    container 'biocontainers/fastqc:v0.11.9_cv8'
    
    // Queremos que los reportes HTML se guarden en la carpeta de resultados
    publishDir "${params.outdir}/reports/fastqc", mode: 'copy'

    input:
    // Este proceso recibe una pareja de archivos FastQ (R1 y R2)
    path fastq_files

    output:
    // Generará archivos .html (gráficos) y .zip (datos)
    path "*.{html,zip}", emit: qc_files

    script:
    """
    # Ejecutamos fastqc sobre ambos archivos a la vez
    fastqc ${fastq_files[0]} ${fastq_files[1]}
    """
}