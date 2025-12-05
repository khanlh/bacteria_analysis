# ONT Long-read Bacterial Identification Pipeline
Flye → Medaka → QUAST → Prokka → GTDB-Tk → Abricate → Bakta

This pipeline performs bacterial genome reconstruction and taxonomic identification from Oxford Nanopore Technologies (ONT) long-read sequencing data. It includes read filtering, genome assembly, polishing, quality assessment, annotation, taxonomic classification, and antimicrobial/virulence gene detection.

The workflow is implemented using Nextflow, enabling reproducibility, scalability, and portability across local machines, HPC clusters, Conda environments, Docker, and Singularity.

## 1. Features

- Read preprocessing using NanoFilt
- Long-read genome assembly with Flye
- Assembly polishing using Medaka
- Assembly quality evaluation with QUAST
- Bacterial genome annotation with Prokka and Bakta
- Taxonomic assignment using GTDB-Tk (GTDB reference database required)
- Detection of antimicrobial resistance (AMR) and virulence genes using Abricate
- Modular and fully containerized execution
- Reproducible and portable Nextflow workflow

## 2. Tools Used in the Pipeline

| Tool      | Purpose                                 | Database Requirements                                                           | URL |
|-----------|-----------------------------------------|----------------------------------------------------------------------------------|-----|
| NanoFilt  | Long-read filtering                     | None                                                                             | https://github.com/wdecoster/nanofilt |
| Flye      | Long-read genome assembly               | None                                                                             | https://github.com/fenderglass/Flye |
| Medaka    | Assembly polishing                      | ONT model file (bundled with installation)                                       | https://github.com/nanoporetech/medaka |
| QUAST     | Assembly quality assessment             | Optional reference genome                                                        | https://github.com/ablab/quast |
| Prokka    | Bacterial genome annotation             | Bundled Prokka DB or custom DB                                                  | https://github.com/tseemann/prokka |
| GTDB-Tk   | Taxonomic classification                | GTDB Reference Database (Release 214/220 etc.) must be downloaded separately     | https://github.com/Ecogenomics/GTDBTk |
| Abricate  | AMR & virulence gene screening          | CARD, VFDB, ResFinder, etc. via `abricate --setupdb`                             | https://github.com/tseemann/abricate |
| Bakta     | High-quality bacterial annotation       | Bakta reference database                                                         | https://github.com/oschwengers/bakta |

### Important Database Notes

1. GTDB-Tk Database  
Download from: https://data.gtdb.ecogenomic.org/  
Export path:  
```
export GTDBTK_DATA_PATH=/path/to/gtdb/
```

2. Bakta Database  
Download from Zenodo (search “Bakta database”):  
https://zenodo.org/communities/bakta  
Path example:  
```
bakta_db=/path/to/bakta/db
```

3. Abricate Databases  
Install all bundled DBs:  
```
abricate --setupdb
```

4. Medaka Models  
Model files bundled with installation; choose correct model for ONT kit/flowcell.

## 3. Input and Output

### Input
- ONT FASTQ or FASTQ.GZ file
- Nextflow parameters:
  - `--reads`: path to ONT reads
  - `--outdir`: output directory
  - `--threads`: number of CPU threads
  - `--medaka_model`: Medaka model name

### Output Structure

```
results/
 ├── nanofilt/          Filtered reads
 ├── flye/              Assembly output (assembly.fasta)
 ├── medaka/            Polished assembly (consensus.fasta)
 ├── quast/             Quality assessment
 ├── prokka/            Annotation files (GFF, GBK, FAA, FFN, TSV)
 ├── gtdbtk/            Taxonomic classification
 ├── abricate/          AMR & virulence screening
 └── bakta/             High-quality annotation
```

## 4. Pipeline Execution

### Docker
```
nextflow run main.nf --reads sample.fastq.gz --outdir results -profile docker
```

## 5. Pipeline Steps Overview

### Step 1: NanoFilt
Read filtering based on quality and length (`-q 10 -l 1000`).  
Output: filtered.fastq

### Step 2: Flye
Long-read genome assembly.  
Output: assembly.fasta

### Step 3: Medaka
Neural network polishing.  
Output: consensus.fasta

### Step 4: QUAST
Quality assessment (N50, GC%, contigs, genome size).

### Step 5: Prokka
Rapid bacterial annotation.

### Step 6: GTDB-Tk
Taxonomy assignment using GTDB.

### Step 7: Abricate
AMR and virulence gene detection.

### Step 8: Bakta
High-quality annotation in GBK and JSON formats.

## 6. Recommended Repository Structure

```
longread-ont-bacterial-id/
 ├── main.nf
 ├── nextflow.config
 ├── conf/
 │    └── profiles.config
 ├── envs/
 │    ├── nanofilt.yml
 │    ├── flye.yml
 │    ├── medaka.yml
 │    ├── prokka.yml
 │    ├── gtdbtk.yml
 │    ├── abricate.yml
 │    └── bakta.yml
 ├── bin/
 └── README.md
```

## 7. Recommendations for Extension

- Add CheckM or BUSCO for genome completeness evaluation  
- Add Trycycler for multi-assembly optimization  
- Add Kraken2 or Centrifuge for additional species confirmation  
- Add automated HTML summary reporting  
- Add unit testing for reproducibility checks  

## 8. License
MIT License or GPL (choose based on project requirements)

## 9. Maintainer
Your Name  
your.email@example.com
