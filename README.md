# FASTQ Quality Control
#### An evaluation of publicly available software and best of breed pipeline
###### Ameni Alsaydi & Shazeda Omar
----
### Aim
The aim of this project is to compare publicly available software applications and libraries for processing quality control metrics on FASTQ files and from this comparison, develop a software pipeline.
### Background
**What is a FASTQ file? Where does it come from? Who uses them?**
  
  To analyze information encoded in an organisms’ DNA, researchers must sequence their genomes. Using sequencing platforms, DNA is fragmented into reads and sequenced; producing a FASTQ file to store the set of sequencing reads.  A FASTQ file is a text-based format for storing both biological sequences and their corresponding quality scores. The files are made up of 4 lines which hold the sequence ID and an optional description, sequence of nucleotides, a “+” symbol and occasionally, the same ID and sequence description, and the quality score of each nucleotide; in that order. The quality score represents the probability of a sequencing error at each nucleotide position. Using special ASCII characters lets a single symbol encode for the quality score, allowing a one to one correspondence between each nucleotide on line 2 and each score on line 4. FASTQ files, are often used by bioinformaticians in health/medical research institutes, hospitals or anyone interested in genomic data analysis. Functional analyses include RNA-seq, Chip-seq, Variant Calling and much more. 

**Why do we need quality control? Doesn't the sequencer give quality control?**

  Quality control is important to reduce low-quality reads, contaminants and set up quality control parameters in sequencing. Quality control can be performed to analyze the quality of DNA sequencing, single-nucleotide polymorphism (SNP) detection, rate of false-positive SNP calls or insertion size, exome sequencing alignment and mapping. The sequenced data passes through a quality check where the reads are pre-processed which allows trimming, adapter removal and low-quality reads filtering. 

  Sequencers produce FASTQ files with a quality score using Phred quality score and ASCII to calculate accuracy of the probability of corresponding base calls. The FASTQ files are further analyzed using the FASTQC program or Sequence Analysis Viewer (SAV) to conduct a quality control on the sequence after a run.  

**Why is QC of Big Data different to QC of say an Excel spreadsheet?**

Data quality refers to the methodical approach, policies and processes by which an organization manages the accuracy, validity, timeliness, completeness, uniqueness, and consistency of its data. Quality control methodologies differ from Big Data to Excel spreadsheets.

Size is a significant differentiator where big data is larger than excel spreadsheets. Although quality control testing is required regardless of size, using a variety of methods on Big Data may provide better results. 

Method: Quality control on data in an excel sheet requires additional steps than performing quality control on big data. In an excel spreadsheet some steps include, naming original files and ensuring the data is stored. Excel spreadsheets is dependent on creating separate files such as a readMe file to keep track of manipulations of data. Quality control on big data requires less steps and information is easily accessed, edited or transmitted to other systems. 

Technology: Big data can be conveniently analyzed using many programming languages and software whereas the data in an excel sheet is limited to specific programs.

**Illumina BaseSpace**

The Illumina BaseSpace software can directly analyze data from sequencers such as “HiSeq, NextSeq, MiSeq, and MiniSeq systems.” Some features of Illumina BaseSpace are “Integrated Run Setup and Monitoring, Streamlined Data Management and Storage and Simplified Data Analysis.” The Integrated Run Setup and Monitoring allows the user to run and monitor the data from any location. The Streamlined Data Management and Storage enables the upscaling or downscaling of the data to meet storage demands while the Simplified Data Analysis performs assist in data analysis using the Illumina workflow apps. 

Unlike most programs, BaseSpace’s unique feature allows data to be edited simultaneously by Illumina workflow apps. Using these apps for analysis generates information about alignment, variants and assist in the conversion of base call files (.bcl) to FASTQ files. The Fastqc app available on Illumina BaseSpace requires the data to be uploaded in the app. In contrary to the Fastqc program, the focus includes high throughput sequencing of data. Backspace has a significant role in monitoring the sequencer rather focusing on data accuracy resulting in an emphasis on the quality control of reads. 

### CODE
```
#!/bin/bash -l
#File: qc.sh

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
    -h,  --help             This help message
    -i,  --fastq-input      The input fastq (required)
    -p,  --program          The Program (fastqc, fastp or fastx)
"
}

# If the environment variable is set (eg. by qsub) then set the value here
# If the command line argument is set below, it will overwrite
fastq_input=$INPUT;
program=$PROGRAM;

# get the command line argument values
until [ -z "$1" ]; do

    case "$1" in
    -h | --help)
        print_usage
        exit 0;;
    -i | --fastq-input)
        fastq_input=$2
        shift 2;;
    -p | --program)
        program=$2
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

echo -e "Value of program is ${program}" | tee -a $logfile;


# SET PROGRAM PATH TO VARIABLE

if [ $program = "fastqc"  ]; then
        PATH_TO_PROGRAM='/scratch001/software/fastqc/fastqc'
elif [ $program = "fastp"  ]; then
        PATH_TO_PROGRAM='/scratch001/software/fastp'
elif  [ $program = "fastx"  ]; then
        export LD_LIBRARY_PATH=$FASTX_TOOLKIT_HOME/lib${LD_LIBRARY_PATH+:$LD_LIBRARY_PATH}
        PATH_TO_PROGRAM='/softlib/exe/x86_64/pkg/fastx_toolkit/0.0.13.2/gcc4_64_libgtextutils-0.6.1/bin/fastx_quality_stats' # fastx_quality_stats specific
else
echo -e "Program not found" | tee -a $logfile;
fi

# SET ARGUMENTS TO VARIABLE

if [ $program = "fastqc"  ]; then
        ARG=''
elif [ $program = "fastp"  ]; then
        ARG='-i'
elif  [ $program = "fastx"  ]; then
        ARG='-Q 33 -i'
fi


# CHECK FASTQ INPUT [FILE OR DIRECTORY] AND RUN PROGRAM 

echo -e "Running Program" | tee -a $logfile;
if [ -d $fastq_input ]; then
        echo -e "- directory found..." | tee -a $logfile;
    for sample in `ls $fastq_input`;
    do
        cmd="${PATH_TO_PROGRAM} ${ARG} ${fastq_input}/${sample}";
                echo "- $cmd" | tee -a $logfile;
                eval $cmd;
    done
elif [ -f $fastq_input ]; then
        echo -e "- single file found..." | tee -a $logfile;
    cmd="${PATH_TO_PROGRAM} ${ARG} ${fastq_input}";
        echo "- command: $cmd" | tee -a $logfile;
        eval $cmd;
fi
```

### FASTQC
* Version used and release date
* Link to official site
* Brief description
* Pros and cons table

### FASTX-Toolkit
* Version used and release date
* Link to official site
* Brief description
* Pros and cons table

### fastp
* Version used and release date
* Link to official site
* Brief description
* Pros and cons table

### Comparsion Tables
* system requirements (eg column headers: FASTQC, FASTX-Toolkit, fastp; rows headers: Architecture, OS, RAM)
* features (eg column headers: FASTQC, FASTX-Toolkit, fastp; each row header is a feature)
* run times (eg column headers: FASTQC, FASTX-Toolkit, fastp; rows headers 100MB File, 1GB File, 10GB File)

### Conclusion
