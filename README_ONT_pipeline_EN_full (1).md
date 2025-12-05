# ONT Long-read Bacterial Identification Pipeline
NanoFilt → Filtlong → Flye → Medaka → QUAST → Prokka → Kraken2 → Abricate → Bakta  
(+ optional GTDB-Tk for high-resolution taxonomy)

This pipeline performs bacterial genome reconstruction and taxonomic identification from Oxford Nanopore Technologies (ONT) long-read sequencing data. It includes read filtering (quality + subsampling), genome assembly, polishing, quality assessment, annotation, **taxonomic classification using Kraken2 by default**, and antimicrobial/virulence gene detection.  
**GTDB-Tk is supported as an optional, higher-resolution taxonomy module, but its database is very large and not ideal for lightweight or frequently repeated runs.**

The workflow is implemented using Nextflow, enabling reproducibility, scalability, and portability across local machines, HPC clusters, Conda environments, Docker, and Singularity.

---

## 1. Features

- Read preprocessing and quality filtering using **NanoFilt**  
- Read subsampling / enrichment of best reads using **Filtlong**  
- Long-read genome assembly with Flye  
- Assembly polishing using Medaka  
- Assembly quality evaluation with QUAST  
- Bacterial genome annotation with Prokka and Bakta  
- **Primary taxonomic assignment using Kraken2 (default)**  
- **Optional high-resolution taxonomic classification using GTDB-Tk** (requires very large DB)  
- Detection of antimicrobial resistance (AMR) and virulence genes using Abricate  
- Modular and fully containerized execution  
- Reproducible and portable Nextflow workflow  

---

## 2. Tools Used in the Pipeline

| Tool      | Purpose                                         | Database Requirements                                                                                 | URL |
|-----------|-------------------------------------------------|------------------------------------------------------------------------------------------------------|-----|
| NanoFilt  | Long-read filtering by quality/length           | None                                                                                                 | https://github.com/wdecoster/nanofilt |
| Filtlong  | Long-read subsampling / enrichment of best reads| None                                                                                                 | https://github.com/rrwick/Filtlong |
| Flye      | Long-read genome assembly                       | None                                                                                                 | https://github.com/fenderglass/Flye |
| Medaka    | Assembly polishing                              | ONT model file (bundled with installation)                                                           | https://github.com/nanoporetech/medaka |
| QUAST     | Assembly quality assessment                     | Optional reference genome                                                                            | https://github.com/ablab/quast |
| Prokka    | Bacterial genome annotation                     | Bundled Prokka DB or custom DB                                                                      | https://github.com/tseemann/prokka |
| Kraken2   | **Primary taxonomic classification**            | Kraken2 database (Standard / MiniKraken2 / custom; ~16–20 GB for smaller DBs)                        | https://github.com/DerrickWood/kraken2 |
| GTDB-Tk   | Optional high-resolution taxonomy               | **GTDB Reference Database (80–200+ GB)** downloaded separately                                       | https://github.com/Ecogenomics/GTDBTk |
| Abricate  | AMR & virulence gene screening                  | CARD / VFDB / ResFinder, etc.                                                                        | https://github.com/tseemann/abricate |
| Bakta     | High-quality bacterial annotation               | Bakta reference database                                                                             | https://github.com/oschwengers/bakta |

---

## Database Notes

### Kraken2 Database (recommended default)

Options:
- **MiniKraken2 (16–20 GB)** → easiest to download & reuse  
- Standard Kraken2 DB (50–70 GB)  
- Custom DB (user selected genomes)

Example:
```bash
KRAKEN2_DB=/path/to/kraken2_db
```

### GTDB-Tk Database (optional)

- Very large: **80–200+ GB**  
- Only recommended when high-resolution taxonomy is required  
- Must be mounted into Docker/Singularity container  

Example:
```bash
export GTDBTK_DATA_PATH="/path/to/gtdb"
```

### Bakta Database

Downloaded separately from Zenodo.

### Abricate Databases

Install with:
```bash
abricate --setupdb
```

---

## 3. Input and Output

### Input

- ONT FASTQ or FASTQ.GZ  
- Required Nextflow parameters:
  - `--reads`  
  - `--outdir`  
  - `--threads`  
  - `--tax_method kraken2|gtdbtk` (kraken2 default)

### Output Structure (Kraken2 mode)

```bash
results/
 ├── nanofilt/     # NanoFilt-filtered reads
 ├── filtlong/     # Filtlong-filtered/subsampled reads
 ├── flye/
 ├── medaka/
 ├── quast/
 ├── prokka/
 ├── kraken2/
 ├── abricate/
 └── bakta/
```

Optional GTDB-Tk output:

```bash
results/gtdbtk/
```

---

## 4. Pipeline Execution


### Docker

```bash
nextflow run main.nf   --reads sample.fastq.gz   --outdir results   --tax_method kraken2   -profile docker   --kraken2_db /path/to/kraken2_db   --bakta_db /path/to/bakta_db   --gtdbtk_db /path/to/gtdbtk_db
```

---

## 5. Pipeline Steps Overview

### Step 1 — NanoFilt  

Filter raw ONT reads by quality and length (e.g. `-q 10 -l 1000`).  
Generates a cleaned FASTQ file with low-quality and very short reads removed.

**Output:**  
- `nanofilt.fastq` in `results/nanofilt/`

---

### Step 2 — Filtlong  

Subsample / enrich highest-quality reads based on read score and length.  
This step reduces total data size while keeping the most informative reads for assembly.

Typical parameters (can be customized in the pipeline):  
- `--min_length 1000`  
- `--keep_percent 90`

**Output:**  
- `filtlong.fastq` in `results/filtlong/`

---

### Step 3 — Flye  

Long-read assembly of the filtered/subsampled reads.

**Output:**  
- `assembly.fasta` in `results/flye/`

---

### Step 4 — Medaka  

ONT neural-network-based polishing of the Flye assembly.

**Output:**  
- `consensus.fasta` in `results/medaka/`

This polished assembly is used for downstream QC, annotation, and taxonomy.

---

### Step 5 — QUAST  

Assembly quality assessment, including metrics such as N50, genome size, GC content, and number of contigs.

**Output:**  
- `results/quast/quast_out/` containing HTML and text reports

---

### Step 6 — Prokka  

Rapid bacterial genome annotation based on the polished assembly.

**Outputs (in `results/prokka/prokka_out/`):**  
- `genome.gff` – annotations in GFF format  
- `genome.gbk` – GenBank file  
- `genome.faa` – predicted proteins  
- `genome.ffn` – predicted CDS nucleotide sequences  
- `genome.tbl`, `genome.txt`, etc.

---

### Step 7 — Kraken2 (default taxonomy)  

Primary taxonomic assignment using Kraken2 with a compact (~16–20 GB) database, suitable for repeated runs and limited storage environments.

**Outputs (in `results/kraken2/kraken2_out/`):**  
- `kraken2.report` – taxonomy summary per taxon  
- `kraken2.out` – per-sequence assignments  

If Kraken2 is chosen (default), GTDB-Tk is skipped unless explicitly requested.

---

### Optional Step — GTDB-Tk  

GTDB-Tk can be used instead of Kraken2 for high-resolution taxonomy, but requires a very large GTDB database (80–200+ GB).  
This step is controlled by `--tax_method gtdbtk` and is disabled by default.

**Outputs (in `results/gtdbtk/gtdbtk_out/`):**  
- GTDB-Tk classification tables  
- Log files and marker gene summaries  

Use this only when storage and computational resources are sufficient.

---

### Step 8 — Abricate  

Screen the polished assembly for AMR and virulence genes using databases such as CARD, VFDB, and others (depending on configuration).

**Output (in `results/abricate/`):**  
- `abricate_card.tsv` – tab-delimited report of detected genes using the CARD database

You can extend the pipeline to run multiple Abricate databases if needed.

---

### Step 9 — Bakta  

High-quality bacterial annotation with rich metadata and structured output, suitable for comparative genomics and submissions.

**Outputs (in `results/bakta/bakta_out/`):**  
- Annotated GenBank/EMBL-like files  
- JSON summary  
- Protein and gene feature files  

Bakta uses its own reference database (`--db /path/to/bakta_db`).

---

## 6. Recommended Repository Structure

```bash
longread-ont-bacterial-id/
 ├── main.nf
 ├── nextflow.config
 ├── conf/
 │    └── profiles.config
 ├── envs/
 │    ├── nanofilt.yml
 │    ├── filtlong.yml
 │    ├── flye.yml
 │    ├── medaka.yml
 │    ├── prokka.yml
 │    ├── kraken2.yml
 │    ├── gtdbtk.yml
 │    ├── abricate.yml
 │    └── bakta.yml
 ├── bin/
 └── README.md
```

---

## 7. Recommendations for Extension

- Add **CheckM** or **BUSCO** for genome completeness estimation  
- Add **Trycycler** for multi-assembly consensus (if multiple assemblies or sub-samplings are used)  
- Add **Krona** plots from Kraken2 output for interactive taxonomy visualization  
- Add **multi-sample support** (looping over many read files) using Nextflow channels  
- Add **HTML summary reports** combining QUAST, Kraken2, Abricate, and Bakta results  
- Add **unit tests / CI** (e.g., GitHub Actions) for basic pipeline validation and reproducibility  
