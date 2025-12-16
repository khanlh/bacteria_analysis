Downloading sequencing data from NCBI SRA (using wget)

The raw sequencing data used in this pipeline can be downloaded directly from the NCBI SRA FTP server using wget.
For example, the run SRR31210304 can be downloaded as follows:

      wget https://sra-download.ncbi.nlm.nih.gov/traces/sra43/SRR/031/SRR31210304/SRR31210304.sra

After downloading the .sra file, convert it to FASTQ format using SRA Toolkit:

      fasterq-dump SRR31210304.sra --threads 8
      gzip SRR31210304.fastq

The resulting FASTQ file can be used directly as input for the pipeline.



nextflow run main.nf \
  -profile docker \
  --reads sample.fastq.gz \
  --outdir results \
  --threads 100 \
  --gtdbtk_db /usr/GTDB-Tk/release220 \
  --bakta_db /data/for_others/bakta_db/db-light \
  --bakta_vfdb /data/for_others/bakta_vfdb/VFDB_setB_pro_bakta.fas
