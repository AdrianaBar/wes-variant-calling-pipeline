# Somatic WES Variant Calling Pipeline (GATK Best Practices)

[![Nextflow](https://img.shields.io/badge/Nextflow-%E2%89%A523.04-23aa62.svg)](https://www.nextflow.io/)
[![Docker](https://img.shields.io/badge/Container-Docker%20%7C%20Singularity-blue.svg)](https://www.docker.com/)
[![Genomics](https://img.shields.io/badge/Design-Tumor%2FNormal-important.svg)]()

An automated, highly scalable, and production-ready Whole Exome Sequencing (WES) bioinformatic pipeline for **Somatic Variant Calling** in cancer genomics. Built with **Nextflow DSL2** and fully containerized for absolute reproducibility.

## 🧬 Oncological Rationale & Workflow

In translational oncology, detecting low-frequency somatic mutations requires separating constitutional variants from true tumor drivers. This pipeline processes paired samples (Tumor/Matched Normal) from the same patient, applying the **GATK4 Best Practices** to eliminate sequencing artifacts, PCR duplicates, and germline background.

```text
       [Tumor FASTQ]            [Normal FASTQ]
             │                         │
             ▼                         ▼
         (FastQC)                  (FastQC)
             │                         │
             ▼                         ▼
         (BWA-MEM)                 (BWA-MEM)  <── [GRCh38 Reference]
             │                         │
             ▼                         ▼
     (Samtools Sort)           (Samtools Sort)
             │                         │
             ▼                         ▼
    (MarkDuplicates)          (MarkDuplicates)
             │                         │
             └───────────┬─────────────┘
                         │  (BAMs matched pairs)
                         ▼
                  (GATK4 Mutect2)
                         │
                         ▼  [Raw VCF]
              (FilterMutectCalls)
                         │
                         ▼  [Filtered VCF]
                  (SnpEff ClinVar)
                         │
                         ▼
          [Annotated Somatic Variants]
          
          
          
          
KEY STAGES:

1 Quality Control: Raw read assessment via FastQC.

2 Alignment & Sorting: Coordinated mapping against GRCh38 using BWA-MEM and coordinate-sorting via Samtools.

3 PCR De-duplication: Marking amplification artifacts using Picard/GATK MarkDuplicates to prevent false-positive variant allele frequencies (VAF).

4 Somatic Variant Calling: High-sensitivity calling via GATK4 Mutect2 utilizing the matched normal sample as a baseline.

5 Statistical Filtering: Stringent artifact and contamination filtering using FilterMutectCalls.

6 Functional Annotation: Clinical and functional characterization via SnpEff (integrated with GRCh38 genomic effects).



INFRASTRUCTURE & REQUIREMENTS

The architecture is fully decoupled from the underlying hardware. Tool dependencies are managed via independent BioContainers per process.

  - Orchestrator: Nextflow (>= 23.04)

  - Containers: Docker Desktop (Local) or Singularity/Apptainer (HPC Environments)

  - Reference Genome: Human GRCh38 (Broad Institute Bundle)
  


QUICK START & CONFIGURATION

The pipeline profile mechanism allows switching between deployment environments without modifying the core codebase.

  1. Configuration (nextflow.config)
    Parameters are managed via config/params.yaml. Resource allocation is dynamic to prevent local CPU/RAM bottlenecking.

  2. Execution
    To run the pipeline locally utilizing Docker containers:
        nextflow run main.nf -profile docker
    
    To deploy the exact same pipeline in an institutional HPC cluster utilizing Singularity:
        nextflow run main.nf -profile singularity
   
        

PROJECT STRUCTURE

  wes-variant-calling-pipeline/
  ├── config/                 # Pipeline parameters and dataset IDs
  │   └── params.yaml
  ├── modules/                # Decoupled Nextflow DSL2 process modules
  │   ├── bwa/
  │   ├── fastqc/
  │   └── gatk/
  ├── main.nf                 # Main workflow orchestrator
  └── nextflow.config         # Global environmental profiles
    
    
    
AUTHOR

  - Adriana Bareas Bou - Bioinformatics Scientist/Omics Data Analyst
  