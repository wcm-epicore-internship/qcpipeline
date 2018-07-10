# FASTQ Quality Control
#### An evaluation of publicly available software and best of breed pipeline
###### Ameni Alsaydi & Shazeda Omar
----
### Aim
The aim of this project is to compare publicly available software applications and libraries for processing quality control metrics on FASTQ files and from this comparison, develop a software pipeline.
### Background
* What is a FASTQ file? Where does it come from? Who uses them?
* Why do we need quality control? Doesn't the sequencer give quality control?

  Quality control is important to reduce low-quality reads, contaminants and set up quality control parameters in sequencing. Quality control can be performed to analyze the quality of DNA sequencing, single-nucleotide polymorphism (SNP) detection, rate of false-positive SNP calls or insertion size, exome sequencing alignment and mapping. The sequenced data passes through a quality check where the reads are pre-processed which allows trimming, adapter removal and low-quality reads filtering. 

  Sequencers produce FASTQ files with a quality score using Phred quality score and ASCII to calculate accuracy of the probability of corresponding base calls. The FASTQ files are further analyzed using the FASTQC program or Sequence Analysis Viewer (SAV) to conduct a quality control on the sequence after a run.  

* Why is QC of Big Data different to QC of say an Excel spreadsheet?
