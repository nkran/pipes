
READS=reads/Sample_TN-24
REFERENCE=ref/AgaP4.fa
READ1="R1"
READ2="R2"

mkdir -p aln/

java -jar trimmomatic-0.30.jar PE s_1_1_sequence.txt.gz s_1_2_sequence.txt.gz \
    lane1_forward_paired.fq.gz lane1_forward_unpaired.fq.gz lane1_reverse_paired.fq.gz \
    lane1_reverse_unpaired.fq.gz ILLUMINACLIP:TruSeq3-PE.fa:2:30:10 LEADING:3 \
    TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36

ls $READS/*.fastq.gz | grep $READ1 | while read F
do
    NAME=${F##*/}       # sample.fastq.gz
    FNAME=${NAME%.*}    # sample.fastq
    SAMPLE=${FNAME%.*}  # sample

    bwa mem -t 14 $REFERENCE ${F} ${R} | samtools sort -@14 -O BAM -o aln/${FNAME}.sorted.bam -
    samtools index aln/${FNAME}.sorted.bam
done

# java -jar /bin/GTK/GenomeAnalysisTK.jar -T RealignerTargetCreator -R /seq/REFERENCE/human_18.fasta -I /output/FOO.sorted.bam  -o /output/FOO.intervals
# java -jar /bin/GTK/GenomeAnalysisTK.jar -T IndelRealigner -R /seq/REFERENCE/human_18.fasta -I /output/FOO.sorted.bam -targetIntervals /output/FOO.intervals --output /output/FOO.sorted.realigned.bam
# /bin/SAMTOOLS/samtools index /output/FOO.sorted.realigned.bam /output/FOO.sorted.realigned.bam.bai
# java -jar /bin/GTK/GenomeAnalysisTK.jar -T IndelGenotyperV2 -R /seq/REFERENCE/human_18.fasta -I /output/FOO.sorted.realigned.bam -O /output/FOO_indel.txt --verbose -o /output/FOO_indel_statistics.txt
# java -jar /bin/GTK/GenomeAnalysisTK.jar -T UnifiedGenotyper -R /seq/REFERENCE/human_18.fasta -I /output/FOO.sorted.realigned.bam -varout /output/FOO.geli.calls -vf GELI -stand_call_conf 30.0 -stand_emit_conf 10.0 -pl SOLEXA
