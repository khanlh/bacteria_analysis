# ONT Long-read Bacterial Identification Pipeline
## Flye → Medaka → QUAST → Prokka → GTDB-Tk → Abricate → Bakta

Pipeline này thực hiện phân tích giải trình tự Oxford Nanopore (ONT) để định danh vi khuẩn.
Bao gồm các bước lọc dữ liệu, lắp ráp, polishing, đánh giá chất lượng, annotation và phân loại vi khuẩn.

---

# ✨ Tính năng chính
- Lọc long-read bằng **NanoFilt**  
- Lắp ráp de novo bằng **Flye**  
- Polishing ONT assembly bằng **Medaka**  
- Kiểm tra chất lượng genome bằng **QUAST**  
- Annotation bằng **Prokka** và **Bakta**  
- Phân loại hệ thống học bằng **GTDB-Tk**  
- Tìm gene kháng thuốc / độc lực bằng **Abricate**  
- Chạy được trên Linux, HPC, Docker, Singularity, Conda

---

# 1. Các công cụ sử dụng

| Tool | Chức năng | Link |
|------|-----------|------|
| **NanoFilt** | Lọc đọc ONT | https://github.com/wdecoster/nanofilt |
| **Flye** | Genome assembly | https://github.com/fenderglass/Flye |
| **Medaka** | Polishing bằng mô hình NN | https://github.com/nanoporetech/medaka |
| **QUAST** | Đánh giá chất lượng assembly | https://github.com/ablab/quast |
| **Prokka** | Annotation Bacteria nhanh | https://github.com/tseemann/prokka |
| **GTDB-Tk** | Taxonomy theo GTDB | https://github.com/Ecogenomics/GTDBTk |
| **Abricate** | AMR/VF screening | https://github.com/tseemann/abricate |
| **Bakta** | Annotation nâng cao | https://github.com/oschwengers/bakta |

---

# 2. Input & Output

## 📥 Input:
- FASTQ hoặc FASTQ.GZ ONT reads  
- Nextflow params:  
  - `--reads` – file FASTQ đầu vào  
  - `--outdir` – thư mục kết quả  
  - `--threads` – số CPU  
  - `--medaka_model` – model polishing  

## 📤 Output:
```
results/
 ├── nanofilt/        # Reads sau lọc
 ├── flye/            # Assembly thô
 ├── medaka/          # Assembly polished
 ├── quast/           # Đánh giá chất lượng genome
 ├── prokka/          # Annotation vi khuẩn
 ├── gtdbtk/          # Phân loại GTDB
 ├── abricate/        # AMR/virulence genes
 └── bakta/           # Annotation nâng cao
```

---

# 3. Cách chạy pipeline

## Chạy bằng Conda
```
nextflow run main.nf   --reads data/sample.fastq.gz   --outdir results   -profile conda
```

## Chạy bằng Docker
```
nextflow run main.nf   --reads data/sample.fastq.gz   --outdir results   -profile docker
```

## Chạy trên HPC (SLURM)
```
nextflow run main.nf   --reads sample.fastq.gz   --outdir results   -profile slurm
```

---

# 4. Các bước pipeline

## 1️⃣ NanoFilt – lọc đọc ONT
- Lọc bằng quality & length  
- Mặc định dùng: `-q 10 -l 1000`  
Output: `filtered.fastq`

## 2️⃣ Flye – lắp ráp genome
- Assembly phù hợp long-read  
Output: `assembly.fasta`

## 3️⃣ Medaka – polishing
- Neural network polishing  
Output: `consensus.fasta`

## 4️⃣ QUAST – đánh giá assembly
- Thống kê N50, GC, số contig, completeness  

## 5️⃣ Prokka – Bacterial annotation
- Xuất: GFF, GBK, FAA, FFN, TSV  

## 6️⃣ GTDB-Tk – taxonomy classification
- Theo GTDB release  
Output: `classification.tsv`

## 7️⃣ Abricate – AMR & virulence genes
- DB: card, vfdb, resfinder, plasmidfinder…  

## 8️⃣ Bakta – annotation nâng cao
- Xuất JSON + GBK chuẩn publish  

---

# 5. Cấu trúc repo gợi ý
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

---

# 6. Gợi ý mở rộng pipeline
- Thêm **CheckM** hoặc **BUSCO** để đánh giá completeness  
- Thêm **Trycycler** nếu có nhiều tập ONT reads  
- Thêm **Kmer-based species check** (Kraken2, Centrifuge)  
- Xuất báo cáo HTML tổng hợp  

---

# 7. Giấy phép
MIT License hoặc GPL (tuỳ bạn chọn)

---

# 8. Tác giả
Người phát triển: *Your Name Here*  
Liên hệ: email@example.com

---

# 🎉 Kết luận
Pipeline ONT này giúp tự động hóa toàn bộ quá trình: **long-read → assembly → polishing → annotation → bacterial identification**, phù hợp nghiên cứu vi sinh, y sinh và môi trường.
