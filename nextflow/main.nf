nextflow.enable.dsl=2

/*
 * Nextflow pipeline converted from pipeline.sh
 * Tools: NanoFilt → Flye → Medaka → QUAST → Prokka → GTDB-Tk → Abricate → Bakta
 * Logic and parameters are kept consistent with the original Bash script.
 */

params.reads      = params.reads ?: null
params.outdir     = params.outdir ?: "results"
params.threads    = params.threads ?: 100

params.gtdbtk_db  = params.gtdbtk_db ?: "/usr/GTDB-Tk/release220"
params.bakta_db   = params.bakta_db  ?: "/data/for_others/bakta_db/db-light"
params.bakta_vfdb = params.bakta_vfdb ?: "/data/for_others/bakta_vfdb/VFDB_setB_pro_bakta.fas"

workflow {

    if ( !params.reads ) {
        error "Missing --reads"
    }

    reads_ch = Channel.fromPath(params.reads)

    nfilt   = NANOFILT(reads_ch)
    flye    = FLYE(nfilt.out)
    medaka  = MEDAKA(nfilt.out, flye.out)
    QUAST(medaka.out)
    PROKKA(medaka.out)
    GTDBTK(medaka.out)
    ABRICATE(medaka.out)
    BAKTA(medaka.out)
}

/*********************************
 * Processes
 *********************************/

process NANOFILT {
    publishDir "${params.outdir}/nanofilt", mode: 'copy'
    input:
      path reads
    output:
      path "filtered.fastq", emit: out
    script:
    "zcat ${reads} | NanoFilt -q 10 -l 1000 > filtered.fastq"
}

process FLYE {
    publishDir "${params.outdir}/flye", mode: 'copy'
    cpus params.threads
    input:
      path reads
    output:
      path "assembly.fasta", emit: out
    script:
    "flye --nano-raw ${reads} --out-dir flye_out --threads ${task.cpus} && cp flye_out/assembly.fasta assembly.fasta"
}

process MEDAKA {
    publishDir "${params.outdir}/medaka", mode: 'copy'
    cpus params.threads
    input:
      path reads
      path asm
    output:
      path "consensus.fasta", emit: out
    script:
    "medaka_consensus -i ${reads} -d ${asm} -o medaka_out -t ${task.cpus} && cp medaka_out/consensus.fasta consensus.fasta"
}

process QUAST {
    publishDir "${params.outdir}/quast", mode: 'copy'
    input:
      path fasta
    output:
      directory "quast"
    script:
    "quast ${fasta} -o quast"
}

process PROKKA {
    publishDir "${params.outdir}/prokka", mode: 'copy'
    cpus params.threads
    input:
      path fasta
    output:
      directory "prokka"
    script:
    "prokka --outdir prokka --prefix genome --kingdom Bacteria --cpus ${task.cpus} ${fasta} --force"
}

process GTDBTK {
    publishDir "${params.outdir}/gtdbtk", mode: 'copy'
    cpus params.threads
    input:
      path fasta
    output:
      directory "gtdbtk"
    script:
    "export GTDBTK_DATA_PATH=${params.gtdbtk_db} && mkdir genomes && cp ${fasta} genomes/consensus.fasta && gtdbtk classify_wf --genome_dir genomes --extension fasta --out_dir gtdbtk --cpus ${task.cpus} --skip_ani_screen"
}

process ABRICATE {
    publishDir "${params.outdir}/abricate", mode: 'copy'
    input:
      path fasta
    output:
      path "abricate_card.tsv"
    script:
    "abricate --db custom_card ${fasta} > abricate_card.tsv"
}

process BAKTA {
    publishDir "${params.outdir}/bakta", mode: 'copy'
    cpus 8
    input:
      path fasta
    output:
      directory "bakta"
    script:
    "bakta --db ${params.bakta_db} --proteins ${params.bakta_vfdb} --output bakta --threads ${task.cpus} --skip-trna --force ${fasta}"
}
