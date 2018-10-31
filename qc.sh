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
    -o,  --output           The output location (a directory that will be created)
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

if [ ! -z "$output" ]; then # if output is specified. 
    mkdir "${output}"
    echo -e "Output location: ${output}" | tee -a $logfile;
   
 #create default output directory
    case $program in 
    fastqc)
        mkdir ${output}/fastqc_output
        out_location=${output}/fastqc_output
        ;;
    fastp)
        mkdir ${output}/fastp_output
        out_location=${output}/fastp_output
        ;;
    fastx)
        mkdir ${output}/fastx_output
        out_location=${output}/fastx_output
        ;;
    esac
else
    #create default output directory
    case $program in 
    fastqc)
        mkdir fastqc_output
        out_location=fastqc_output
        ;;
    fastp)
        mkdir fastp_output
        out_location=fastp_output
        ;;
    fastx)
        mkdir fastx_output
        out_location=fastx_output
        ;;
    esac
fi

#Separating the file name from the extension and directories for later output file naming

#$fastq_input has the input path
input_filename=$(basename -- ${fastq_input}) # file name with extension 
input_filename_no_exten=${input_filename%.*} # file name without extension

# SET INPUT FLAG TO VARIABLE

case $program in 
fastqc)
    IN_ARG=''
    ;;
fastp)
    IN_ARG='-i'
    ;;
fastx)
    IN_ARG='-Q 33 -i'
    ;;      
esac

# SET OUTPUT FLAG TO VARIABLE
OUT_ARG='-o' 

# SET PROGRAM PATH TO VARIABLE

case $program in 
fastqc)
    PATH_TO_PROGRAM='/scratch001/software/fastqc/fastqc'
    ;;
fastp) 
    PATH_TO_PROGRAM='/scratch001/software/fastp'
    ;;
fastx)
    export LD_LIBRARY_PATH=$FASTX_TOOLKIT_HOME/lib${LD_LIBRARY_PATH+:$LD_LIBRARY_PATH}
    PATH_TO_PROGRAM='/softlib/exe/x86_64/pkg/fastx_toolkit/0.0.13.2/gcc4_64_libgtextutils-0.6.1/bin/fastx_quality_stats' # fastx_quality_stats specific
    ;;      
*)
    echo -e "Program not found" | tee -a $logfile;
    print_usage  
    exit 1;
    ;;
esac 



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
        case ${program} in 
        fastp)
            cd ${out_location}
            cmd="${PATH_TO_PROGRAM} ${IN_ARG} /${fastq_input}/${sample} -j ${sample_name_no_exten}.json -h ${sample_name_no_exten}.html"
            echo "- command: $cmd" | tee -a $logfile
            eval $cmd;
            cd ../
            ;; 
        fastqc)
            cmd="${PATH_TO_PROGRAM} ${IN_ARG} ${fastq_input}/${sample} ${OUT_ARG} ${out_location}"; #this commmand works fine for fastqc
            echo "- $cmd" | tee -a $logfile;
            eval $cmd;
            ;;
        fastx)
            cmd="${PATH_TO_PROGRAM} ${IN_ARG} ${fastq_input}/${sample} ${OUT_ARG} ${out_location}/${sample_name_no_exten}.txt";
            echo "- $cmd" | tee -a $logfile;
            eval $cmd;
            ;;
        esac

    echo "====Finished ${program} analysis on filename ${sample_name}: `date '+%Y-%m-%d %H:%M:%S'`===="
    done 

#single fastq file:

elif [ -f $fastq_input ]; then
       echo "====Starting ${program} anaylsis on filename ${input_filename}: `date '+%Y-%m-%d %H:%M:%S'`===="
       echo -e "Single file found. Running Program." | tee -a $logfile;
       case ${program} in
       fastp)
           cd ${out_location}
           cmd="${PATH_TO_PROGRAM} ${IN_ARG} ${fastq_input}" #is this an issue for other other users. 
           echo "- command: $cmd" | tee -a $logfile;
           eval $cmd;
           cd ../../
           ;;
       fastx)
           cmd="${PATH_TO_PROGRAM} ${IN_ARG} ${fastq_input} ${OUT_ARG} ${out_location}/${input_filename_no_exten}.txt";
           echo "- command: $cmd" | tee -a $logfile;
           eval $cmd;
           ;;
       fastqc)        
            cmd="${PATH_TO_PROGRAM} ${IN_ARG} ${fastq_input} ${OUT_ARG} ${out_location}";
            echo "- command: $cmd" | tee -a $logfile;
            eval $cmd;
            ;; 
       esac
echo "====Finished ${program} anaylsis on filename ${input_filename}: `date '+%Y-%m-%d %H:%M:%S'`===="

fi

 
