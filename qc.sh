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
    -o,  --output           The output location (file or directory)
"
}

# If the environment variable is set (eg. by qsub) then set the value here
# If the command line argument is set below, it will overwrite
fastq_input=$INPUT;
program=$PROGRAM;
output=$OUTPUT;

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
    -o | --output)
        output=$2
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

# SET INPUT FLAG TO VARIABLE

if [ $program = "fastqc"  ]; then
        IN_ARG=''
elif [ $program = "fastp"  ]; then
        IN_ARG='-i'
elif  [ $program = "fastx"  ]; then
        IN_ARG='-Q 33 -i'
fi

# SET OUTPUT FLAG TO VARIABLE
OUT_ARG='-o' 
#echo -e "Creating output directory" | tee -a $logfile;
#cmd="mkdir ${output}";
#echo "- command: $cmd" | tee -a $logfile;
#eval $cmd;

# SET PROGRAM PATH TO VARIABLE

if [ $program = "fastqc"  ]; then
        PATH_TO_PROGRAM='/scratch001/software/fastqc/fastqc'
        mkdir "${output}"
elif [ $program = "fastp"  ]; then
        PATH_TO_PROGRAM='/scratch001/software/fastp'
        mkdir "${output}"
elif  [ $program = "fastx"  ]; then
        export LD_LIBRARY_PATH=$FASTX_TOOLKIT_HOME/lib${LD_LIBRARY_PATH+:$LD_LIBRARY_PATH}
        PATH_TO_PROGRAM='/softlib/exe/x86_64/pkg/fastx_toolkit/0.0.13.2/gcc4_64_libgtextutils-0.6.1/bin/fastx_quality_stats' # fastx_quality_stats specific
else
echo -e "Program not found" | tee -a $logfile;
fi


# CHECK FASTQ INPUT [FILE OR DIRECTORY] AND RUN PROGRAM 

echo -e "Running Program" | tee -a $logfile;
if [ -d $fastq_input ]; then
        echo -e "- directory found..." | tee -a $logfile;
    for sample in `ls $fastq_input`;
    do
        if [ $program = "fastp"  ]; then
                cd ${output}
                cmd="${PATH_TO_PROGRAM} ${IN_ARG} ../${fastq_input}/${sample}"
                echo "- command: $cmd" | tee -a $logfile;
                eval $cmd;
                cd ../
        else  
        cmd="${PATH_TO_PROGRAM} ${IN_ARG} ${fastq_input}/${sample} ${OUT_ARG} ${output}";
        echo "- $cmd" | tee -a $logfile;
        eval $cmd;
fi
    done
elif [ -f $fastq_input ]; then
       if [ $program = "fastp"  ]; then
              cd ${output}
              cmd="${PATH_TO_PROGRAM} ${IN_ARG} ../${fastq_input}"
              echo "- command: $cmd" | tee -a $logfile;
              eval $cmd;
              cd ../
        else
        echo -e "- single file found..." | tee -a $logfile;
    cmd="${PATH_TO_PROGRAM} ${IN_ARG} ${fastq_input} ${OUT_ARG} ${output}";
        echo "- command: $cmd" | tee -a $logfile;
        eval $cmd;
        fi
fi

 
