// modules/download_sra.nf

process DOWNLOAD_SRA_TUMOR {
    // Tag profesional para ver qué muestra se está procesando en la terminal
    tag "Downloading Tumor: $sra_id"
    
    // SELECCIÓN DE INFRAESTRUCTURA (Opción 1): Usamos un contenedor oficial de BioContainers
    container 'biocontainers/sra-tools:v3.0.7_cv1'
    
    // Definimos dónde queremos que guarde el resultado final en nuestro PC
    publishDir "${params.outdir}/fastq/tumor", mode: 'copy'

    input:
    val sra_id

    output:
    // Un exoma paired-end genera dos archivos FASTQ (.1.fastq.gz y .2.fastq.gz)
    path "${sra_id}_*.fastq.gz", emit: fastq

    script:
    """
    # El comando fasterq-dump descarga los datos crudos desde los servidores de la NCBI
    fasterq-dump --split-files $sra_id
    
    # Comprimimos al vuelo en .gz para no saturar el disco (Estándar bioinformático)
    gzip ${sra_id}_1.fastq
    gzip ${sra_id}_2.fastq
    """
}

process DOWNLOAD_SRA_NORMAL {
    tag "Downloading Normal: $sra_id"
    container 'biocontainers/sra-tools:v3.0.7_cv1'
    publishDir "${params.outdir}/fastq/normal", mode: 'copy'

    input:
    val sra_id

    output:
    path "${sra_id}_*.fastq.gz", emit: fastq

    script:
    """
    fasterq-dump --split-files $sra_id
    gzip ${sra_id}_1.fastq
    gzip ${sra_id}_2.fastq
    """
}