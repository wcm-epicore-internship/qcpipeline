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
    
    ```bash
    $ ssh pascal.med.cornell.edu
    $ ssh carmel.pbtech
    $ cd /scratchBulk/${USER}
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
    
    Test dataset path: `/scratchBulk/sij2003/test_data/external_demux_180206_M05686_0007_000000000-D3K2T__uid11426/Project_EC-SC-4602/`
    
    ```bash
      $ cd /scratchBulk/${USER}
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

## FASTX Toolkit
1. Read about fastx_collapser and fastx_quality_stats
1. Run locally or on carmel with FASTQ test data
  ```
    slchoose fastx_toolkit 0.0.13.2 gcc4_64_libgtextutils-0.6.1
    fastx_quality_stats
    fastx_collapser
  ```

## fastp
1. Read about [fastp](https://github.com/OpenGene/fastp)
1. Download and run on epicore08 (see "download binary") section

## SGE
1. Read about "Sun Grid Engine" (also called "SGE" or "Oracle Grid Engine")
1. Create a new directory for "sge_test" on epicore08:/scratch001/<user name>
1. Create a new file qsub_test.sh below
  ```
    #!/bin/bash -l
    #$ -pe smp 1
    #$ -l h_vmem=1G
    #$ -cwd
    echo "Hello World" > hello.txt
  ```
1. Then submit it to the queue and check it's there
  ```
    qsub -cwd -q aladdin.q@epicore08.pbtech qsub_test.sh
    qstat -f -u "*" -q aladdin.q@epicore08.pbtech
  ``` 
1. Once it's run check for "hello.txt" and view the contents
1. Lookup what the "-pe smp" "-l h_vmem" "-cwd" params do [here](https://github.com/BIMSBbioinfo/intro2UnixandSGE/blob/master/sun_grid_engine_for_beginners/how_to_submit_a_job_using_qsub.md)
1. Find out how long it took to run
  ```
    qacct -j <job number>
  ``` 
  

## Run-time comparisons
1. To compare how long each program takes to run, we need to start with a good set of test data:
* We want 3 FASTQ files: approx 100MB, approx 1GB and approx 10GB
* Download a FASTQ that's >10GB on Pubshare to epicore08 scratch
* Extract all the *.fastq.gz files
* Use the linux tail and cat command to create 3 files roughly 100MB, 1GB and 10GB (see below for naming)
* Create the `qc.sh` script below
  ```
  #!/bin/bash -l
  #$ -pe smp 1
  #$ -l h_vmem=1G
  # The lines above are for qsub

  # Create a log file
  # The command "| tee -a $logfile" below writes the output to the log file 
  logfile="qc_log.txt";
  touch $logfile;

  # Print out the usage options
  print_usage() {
  echo "Usage: $(basename $0)
      -h   --help             This help message
      -i,  --fastq-input      The input fastq (required)
      -s,  --something-else   Another param
  "
  }

  # If the environment variable is set (eg. by qsub) then set the value here
  # If the command line argument is set below, it will overwrite
  fastq_input=$INPUT;
  something_else='';

  # get the command line argument values
  until [ -z "$1" ]; do
      case "$1" in
      -h | --help)
          print_usage
          exit 0;;
      -i | --fastq-input)
          fastq_input=$2
          shift 2;;
      -s | --something-else)
          something_else=$2
          shift 2;;
      --)  #End of all options
          shift
          break;;
      -*)
          echo -e "Invalid option ($1)." | tee -a $logfile;
          exit 1;;

      *)
          break;;
    esac
  done

  echo -e "Value of fastq_input is ${fastq_input}" | tee -a $logfile;
  echo -e "Value of something_else is ${something_else}" | tee -a $logfile;

  if [ -z "$fastq_input" ]; then
      echo -e "fastq input must be specified" | tee -a $logfile;
      exit 1;
  fi


  echo -e "Lets check the file exists...." | tee -a $logfile;
  if [ -e $fastq_input ]; then
      echo -e "Yes it does" | tee -a $logfile;
  else
      echo -e "No it does not, exiting" | tee -a $logfile;
      exit 1;
  fi
  ```
* Run the following commands and compare the output. When you run the qsub, look at the output in the "qc_log.txt" file
  ```
  $ bash qc.sh
  $ bash qc.sh hello
  $ bash qc.sh -i hello
  $ bash qc.sh -i /path/to/a/file
  $ qsub -cwd -q aladdin.q@epicore08.pbtech -v INPUT=/path/to/a/file qc.sh
  ```
* Modify the script for the following
  1. accept another anrgument -p or --program that can be fastqc, fastp or fastx - make this variable also accept the environment variable $PROGRAM (the same way $INPUT does)
  1. depending on what prgram is selected, run the program against the input
  1. allow input to be a directory of fastq files or a single file
  1. if the input is a directory, run the program for all of the fastq files in the directory
* run the following qsubs
  ```
    qsub -cwd -q aladdin.q@epicore08.pbtech -N "FASTQC 100 MB" -v INPUT=qc_test_100mb.fastq -v PROGRAM=fastqc qc.sh
    qsub -cwd -q aladdin.q@epicore08.pbtech -N "FASTQC 1 GB" -v INPUT=qc_test_1gb.fastq -v PROGRAM=fastqc qc.sh
    qsub -cwd -q aladdin.q@epicore08.pbtech -N "FASTQC 10 GB" -v INPUT=qc_test_10gb.fastq -v PROGRAM=fastqc qc.sh
  ```
  ```
    qsub -cwd -q aladdin.q@epicore08.pbtech -N "FASTX 100 MB" -v INPUT=qc_test_100mb.fastq -v PROGRAM=fastx qc.sh
    qsub -cwd -q aladdin.q@epicore08.pbtech -N "FASTX 1 GB" -v INPUT=qc_test_1gb.fastq -v PROGRAM=fastx qc.sh
    qsub -cwd -q aladdin.q@epicore08.pbtech -N "FASTX 10 GB" -v INPUT=qc_test_10gb.fastq -v PROGRAM=fastx qc.sh
  ```
  ```
    qsub -cwd -q aladdin.q@epicore08.pbtech -N "FASTP 100 MB" -v INPUT=qc_test_100mb.fastq -v PROGRAM=fastp qc.sh
    qsub -cwd -q aladdin.q@epicore08.pbtech -N "FASTP 1 GB" -v INPUT=qc_test_1gb.fastq -v PROGRAM=fastp qc.sh
    qsub -cwd -q aladdin.q@epicore08.pbtech -N "FASTP 10 GB" -v INPUT=qc_test_10gb.fastq -v PROGRAM=fastp qc.sh
  ```
* Use qacct to get the run time statistics as above
* Document in README.md

  
