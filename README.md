# ONT Long-read Bacterial Identification Pipeline
NanoFilt → Filtlong → Flye → Medaka → QUAST → Prokka → Kraken2 → Abricate → Bakta  
(+ optional GTDB-Tk for high-resolution taxonomy)

This pipeline performs bacterial genome reconstruction and taxonomic identification from Oxford Nanopore Technologies (ONT) long-read sequencing data. It includes read filtering (quality + subsampling), genome assembly, polishing, quality assessment, annotation, **taxonomic classification using Kraken2 by default**, and antimicrobial/virulence gene detection.  
**GTDB-Tk is supported as an optional, higher-resolution taxonomy module, but its database is very large and not ideal for lightweight or frequently repeated runs.**

(… content truncated for brevity in this example …)
