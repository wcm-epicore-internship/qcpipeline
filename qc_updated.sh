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
    -i,  --fastq-input      The input fastq (single fastq or a directory of fastq files)
    -p,  --program          The program (fastqc, fastp or fastx)
    -o,  --output           The output location (directory-will be created)
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

#Separating the file name from the extension and directories for later output file naming

#$fastq_input has the input path
input_filename=$(basename -- ${fastq_input}) # file name with extension 
input_filename_no_exten=${input_filename%.*} # file name without extension


#Output the help page when mandatory fields are not provided (input, program, output)

if [ -z "$fastq_input" ]; then
    echo -e "ERROR: fastq input must be specified" | tee -a $logfile;
    print_usage
    exit 1;
else
    echo -e "Value of fastq_input: ${fastq_input}" | tee -a $logfile;
fi

echo -e "Checking if the file exists..." | tee -a $logfile;
if [ -e $fastq_input ]; then
    echo -e "Yes it does" | tee -a $logfile;
else
    echo -e "File $fastq_input does not. Exiting program" | tee -a $logfile;
    exit 1;
fi

if [ -z "$program" ]; then
    echo -e "ERROR: program must be specified" | tee -a $logfile;
    print_usage
    exit 1;
else  
    echo -e "Program selected: ${program}" | tee -a $logfile;
fi

if [ -z "$output" ]; then
    echo -e "ERROR: output must be specified" | tee -a $logfile;
    print_usage
    exit 1;
elif [ -d "$output" ]; then 
    echo -e "ERROR: Output directory, '${output}', already exists, please select a different output location."
    exit 1;
else
    echo -e "Output location: ${output}" | tee -a $logfile;
fi

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

# Make output directory

mkdir "${output}"

# CHECK FASTQ INPUT [FILE OR DIRECTORY] AND RUN PROGRAM 


if [ -d $fastq_input ]; then
        echo -e "Fastq directory found. Running Program" | tee -a $logfile;
    for sample in `ls $fastq_input`;
    do
        #$fastq_input/sample has the input path
        sample_name=$(basename -- ${fastq_input}/${sample}) # with extension 
        sample_name_no_exten=${sample_name%.*} # file name without extension
        echo "====Starting ${program} anaylsis on filename ${sample_name}: `date '+%Y-%m-%d %H:%M:%S'`===="
        if [ $program = "fastp"  ]; then
                cd ${output}
                cmd="${PATH_TO_PROGRAM} ${IN_ARG} ../${fastq_input}/${sample} -j ${sample_name_no_exten}.json -h ${sample_name_no_exten}.html"
                echo "- command: $cmd" | tee -a $logfile
                eval $cmd;
                cd ../
        elif [ $program = "fastqc"  ]; then  
                cmd="${PATH_TO_PROGRAM} ${IN_ARG} ${fastq_input}/${sample} ${OUT_ARG} ${output}"; #this commmand works fine for fastqc
                echo "- $cmd" | tee -a $logfile;
                eval $cmd;
       elif [ $program = "fastx"  ]; then
                cmd="${PATH_TO_PROGRAM} ${IN_ARG} ${fastq_input}/${sample} ${OUT_ARG} ${output}/${sample_name_no_exten}.txt";
                echo "- $cmd" | tee -a $logfile;
                eval $cmd;
fi
    echo "====Finished ${program} analysis on filename ${sample_name}: `date '+%Y-%m-%d %H:%M:%S'`===="
    done 
#single fastq file:

elif [ -f $fastq_input ]; then
       echo "====Starting ${program} anaylsis on filename ${input_filename}: `date '+%Y-%m-%d %H:%M:%S'`===="
       echo -e "Single file found. Running Program." | tee -a $logfile;
       if [ $program = "fastp"  ]; then
              cd ${output}
              cmd="${PATH_TO_PROGRAM} ${IN_ARG} ../${fastq_input}"
              echo "- command: $cmd" | tee -a $logfile;
              eval $cmd;
              cd ../
       elif [ $program = "fastx"  ]; then
              cmd="${PATH_TO_PROGRAM} ${IN_ARG} ${fastq_input} ${OUT_ARG} ${output}/${input_filename_no_exten}.txt";
              echo "- command: $cmd" | tee -a $logfile;
              eval $cmd;
       elif [ $program = "fastqc"  ]; then        
              cmd="${PATH_TO_PROGRAM} ${IN_ARG} ${fastq_input} ${OUT_ARG} ${output}";
              echo "- command: $cmd" | tee -a $logfile;
              eval $cmd;
       fi
echo "====Finished ${program} anaylsis on filename ${input_filename}: `date '+%Y-%m-%d %H:%M:%S'`===="
fi

 
