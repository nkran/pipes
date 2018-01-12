#!/bin/bash

DIR=$1
REFERENCE=$2
READ1=$3
READ2=$4

ls $DIR/*.fastq | grep $READ1 | while read F
do
    R=`echo $READ1 | sed 's/$READ1/$READ2/'`
    echo "bwa mem -t 16 $REFERENCE ${F} ${R} > ${F%%.*}.sam"
    # samtools view -bu ${F%%.*}.sam | samtools sort - > ${F%%.*}.sorted.bam
done

# find $BAM_DIR -name '*.bam' | {
#     read firstbam
#     samtools view -h "$firstbam"
#     while read bam; do
#         samtools view "$bam"
#     done
# } | samtools view -ubS - | samtools sort - merged
# samtools index merged.bam
# ls -l merged.bam merged.bam.bai



F=`ls reads/*.fastq | grep _1 | tr "\n" ","`
R=`ls reads/*.fastq | grep _2 | tr "\n" ","`

echo $F
echo $R

hisat2 -x | samtools view -Sbo sample.bam -
