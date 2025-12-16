#!/bin/bash

# ==========================================================
# PIPELINE WGS LONG-READ (ONT) → Assembly → Annotation
# Tools: NanoFilt → Flye → Medaka → Quast → Prokka → GTDB-Tk → Abricate → Bakta
#
# Usage:
#   bash pipeline.sh <input_reads.fastq.gz> <output_root_dir>
# ==========================================================

# -------------------------
# Input
# -------------------------
INPUT_READS="$1"
OUTPUT_ROOT="$2"

if [ -z "$INPUT_READS" ] || [ -z "$OUTPUT_ROOT" ]; then
  echo "Usage: bash pipeline.sh <reads.fastq.gz> <output_root_dir>"
  exit 1
fi

echo "Input reads: $INPUT_READS"
echo "Output root: $OUTPUT_ROOT"
mkdir -p "$OUTPUT_ROOT"

# -------------------------
# 1. NanoFilt - Filter long reads
# -------------------------
source /data/conda_envs/nanofilt-env/bin/activate
mkdir -p "$OUTPUT_ROOT/nanofilt"

zcat "$INPUT_READS" | NanoFilt -q 10 -l 1000 > "$OUTPUT_ROOT/nanofilt/filtered.fastq"

echo "NanoFilt completed"

# -------------------------
# 2. Flye - Genome assembly
# -------------------------
mkdir -p "$OUTPUT_ROOT/flye"

/usr/Flye/bin/flye \
  --nano-raw "$OUTPUT_ROOT/nanofilt/filtered.fastq" \
  --out-dir "$OUTPUT_ROOT/flye" \
  --threads 100

ASSEMBLY="$OUTPUT_ROOT/flye/assembly.fasta"

echo "Flye assembly completed"

# -------------------------
# 3. Medaka - Polishing
# -------------------------
mkdir -p "$OUTPUT_ROOT/medaka"

source /data/conda_envs/medaka-env/bin/activate
medaka_consensus \
  -i "$OUTPUT_ROOT/nanofilt/filtered.fastq" \
  -d "$ASSEMBLY" \
  -o "$OUTPUT_ROOT/medaka" \
  -t 100

POLISHED="$OUTPUT_ROOT/medaka/consensus.fasta"

echo "Medaka polishing completed"

# -------------------------
# 4. Quast - Assembly quality assessment
# -------------------------
mkdir -p "$OUTPUT_ROOT/quast"

source /data/conda_envs/quast-env/bin/activate
quast "$POLISHED" -o "$OUTPUT_ROOT/quast"

echo "QUAST completed"

# -------------------------
# 5. Prokka - Genome annotation
# -------------------------
mkdir -p "$OUTPUT_ROOT/prokka"

source /data/conda_envs/prokka-env/bin/activate
prokka \
  --outdir "$OUTPUT_ROOT/prokka" \
  --prefix genome \
  --kingdom Bacteria \
  --cpus 100 \
  "$POLISHED" \
  --force

echo "Prokka annotation completed"

# -------------------------
# 6. GTDB-Tk - Taxonomy classification
# -------------------------
mkdir -p "$OUTPUT_ROOT/gtdbtk"

export GTDBTK_DATA_PATH=/usr/GTDB-Tk/release220/

gtdbtk classify_wf \
  --genome_dir "$OUTPUT_ROOT/medaka" \
  --extension fasta \
  --out_dir "$OUTPUT_ROOT/gtdbtk" \
  --cpus 100 \
  --skip_ani_screen

echo "GTDB-Tk classification completed"

# -------------------------
# 7. Abricate - AMR / virulence genes
# -------------------------
mkdir -p "$OUTPUT_ROOT/abricate"

source /data/conda_envs/abricate-env/bin/activate
abricate \
  --db custom_card \
  #-- mincov 50 \
  #-- minid 55 \
  "$POLISHED" \
  > "$OUTPUT_ROOT/abricate/abricate_card.tsv"

echo "Abricate completed"

# -------------------------
# 8. Bakta - Genome annotation
# -------------------------
mkdir -p "$OUTPUT_ROOT/bakta"

source /data/conda_envs/bakta-env/bin/activate
bakta \
  --db /data/for_others/bakta_db/db-light/ \
  --proteins /data/for_others/bakta_vfdb/VFDB_setB_pro_bakta.fas \
  --output "$OUTPUT_ROOT/bakta" \
  --threads 8 \
  --skip-trna \
  --force \
  "$POLISHED"

echo "Bakta annotation completed"

echo "Pipeline finished successfully"

