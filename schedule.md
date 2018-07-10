# Schedule
## Getting started with git and wget
  1. Log into carmel.pbtech through pascal.med.cornell.edu with ssh, create a new directory for internship, check out the qcpipeline project with git
  1. Explore the [Pubshare](http://abc.med.cornell.edu/pubshare) site
  1. Read about wget and use it to download some FASTQ files into your `/scracthBulk/` directory of carmel
  1. Read about Homebrew and install it on your Mac
  1. Using Homebrew, install wget on your Mac
  1. Choose a small FASTQ file on Pubshare and use wget to download it on your mac
## FASTQ & BAM files
  1. Read about what a FASTQ file is
  1. Read about what BAM and BAI files are
  1. Find a small BAM file on Pubshare
  1. Use wget to download it to your Mac
  1. Read about IGV
  1. Install IGV on your Mac
  1. Open the BAM file on your Mac with IGV
  1. Using IGV view the reads at different coordinates, view some areas of high and low coverage
## FASTQC  
  1. Download FASTQC on your mac
  1. Run FASTQC on your mac
  1. Open the FASTQC results in your browser and use Google to try to understand the different parts
  1. Divide the different parts of the FASTQC results report between you, write a few notes on your assigned parts and then together, meet with Piali to explain to her what each part of the report means and why it's important.
  1. Run FASTQC on carmel via the command line
    
    ```
    $ ssh pascal.med.cornell.edu
    $ ssh carmel.pbtech
    $ cd /scratchBulk/<username>
    $ mkdir fastqc_testing
    $ cd fastqc_testing
    $ slchoose fastqc 0.10.1 java # this loads the FASTQC program into your environment
    The following commands were executed:
    export FASTQC_HOME=/softlib/exe/all/pkg/fastqc/0.10.1/java
    alias fastqc='$FASTQC_HOME/fastqc'
    $ fastqc -o . external_demux_180206_M05686_0007_000000000-D3K2T__uid11426/Project_EC-SC-4602/Sample_kp1-12/kp1-12_S1_L001_R1_001.fastq.gz
    $ ls
    $ less kp1-12_S1_L001_R1_001_fastqc/fastqc_data.txt
    ```
  1. Write a Bash script on Carmel that takes a path to a FASTQ dataset and runs FASTQC for all samples (one at a time), eg:
    
    ```
      $ cd /scratchBulk/<username>
      $ bash fastqc_wrapper.sh /scratchBulk/sij2003/test_data/external_demux_180206_M05686_0007_000000000-D3K2T__uid11426
      - Copying data from input path
      - Found 5 samples
      - Running FASTQC on Project_EC-SC-4602/Sample_kp1-12
      etc
    ```
  1. Start adding to the Background of the Project README.md
## BaseSpace
  1. Read about Illumina BaseSpace
  1. Login to Illumina BaseSpace (ask Piali for login details)
  1. Look at the QC for a couple of runs and read the help to try understand them
  1. How are we going to compare FASTQC vs Base Space? Start list of features to compare
  
