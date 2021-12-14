#!/bin/sh

SAMPLES=(S_11 S_15)
SAMPLE_NAME=${SAMPLES[$PBS_ARRAY_INDEX]}.merged

SLOTS=16

REFERENCE=$TMPDIR/ref/AgamP4.fa
DBSNP=$TMPDIR/ref/dbSNP.vcf

# echo "Mark Duplicates"
# picard MarkDuplicates \
#       I=${SAMPLE_NAME}.bam \
#       O=${SAMPLE_NAME}.dedup.bam \
#       M=${SAMPLE_NAME}.marked_dup_metrics.txt

# echo "Sort bam"
# samtools sort -@${SLOTS} -o ${SAMPLE_NAME}.dedup.sorted.bam ${SAMPLE_NAME}.dedup.bam

# cp $TMPDIR/${SAMPLE_NAME}.dedup.sorted.bam $WORK/pooled_ot/bam_preprocessing/

# echo "Create sequence dictionary"
# picard CreateSequenceDictionary R=$REFERENCE O=AgamP4.dict

#  -- Update RG -------------------------------------------------------------------------------------------------------
# echo "Update RG"
# picard AddOrReplaceReadGroups I=${SAMPLE_NAME}.dedup.sorted.bam O=${SAMPLE_NAME}.dedup.sorted.rg.bam RGID=OT_S${PBS_ARRAY_INDEX} RGLB=LIB_S${PBS_ARRAY_INDEX} RGPL=ILLUMINA_OT_S${PBS_ARRAY_INDEX} RGPU=UNIT_S${PBS_ARRAY_INDEX} RGSM=OT_S${PBS_ARRAY_INDEX} &> log_S${PBS_ARRAY_INDEX}_RG.txt
samtools index ${SAMPLE_NAME}.dedup.sorted.rg.bam
# cp $TMPDIR/log_S${PBS_ARRAY_INDEX}_RG.txt $WORK/pooled_ot/log/


# #  -- IndelRealign ----------------------------------------------------------------------------------------------------
# echo "Create target interval for Indelrealigner"
gatk -T RealignerTargetCreator -R $REFERENCE -I ${SAMPLE_NAME}.dedup.sorted.rg.bam -o forIndelRealigner.intervals &> f_log_S${PBS_ARRAY_INDEX}_RealignerTargetCreator.txt
cp $TMPDIR/log_S${PBS_ARRAY_INDEX}_RealignerTargetCreator.txt $WORK/pooled_ot/log/


# echo "GATK Indel Realignment"
gatk -T IndelRealigner -R $REFERENCE -I ${SAMPLE_NAME}.dedup.sorted.rg.bam --targetIntervals forIndelRealigner.intervals -o realigned.bam &> f_log_S${PBS_ARRAY_INDEX}_IndelRealigner.txt
cp $TMPDIR/realigned.bam $WORK/pooled_ot/bam_preprocessing/${SAMPLE_NAME}.realigned.bam
mv realigned.bam ${SAMPLE_NAME}.realigned.bam
cp $TMPDIR/log_S${PBS_ARRAY_INDEX}_IndelRealigner.txt $WORK/pooled_ot/log/


#  -- BaseRecalibrator ------------------------------------------------------------------------------------------------
echo "GATK Base Recalibration"

# picard SortVcf \
#     I=$DBSNP \
#     O=$TMPDIR/ref/dbSNP.reordered.vcf \
#     SEQUENCE_DICTIONARY=$TMPDIR/AgamP4.dict

# cp $TMPDIR/ref/dbSNP.reordered.vcf $WORK/pooled_ot/ref/

samtools index ${SAMPLE_NAME}.realigned.bam

gatk -T BaseRecalibrator -R $REFERENCE -I ${SAMPLE_NAME}.realigned.bam --knownSites $TMPDIR/ref/dbSNP.reorder.vcf -nct $SLOTS -o S${PBS_ARRAY_INDEX}_recal_data.table &> f_log_S${PBS_ARRAY_INDEX}_BQSR.txt
cp $TMPDIR/log_S${PBS_ARRAY_INDEX}_BQSR.txt $WORK/pooled_ot/log/
cp S${PBS_ARRAY_INDEX}_recal_data.table $WORK/pooled_ot/bam_preprocessing/

# echo "Generate Recalibrated bam"
gatk -T PrintReads -R $REFERENCE -I ${SAMPLE_NAME}.realigned.bam -BQSR S${PBS_ARRAY_INDEX}_recal_data.table -o ${SAMPLE_NAME}.realigned.bqsrCal.bam &> f_log_S${PBS_ARRAY_INDEX}_PrintReads.txt
cp $TMPDIR/${SAMPLE_NAME}.realigned.bqsrCal.bam $WORK/pooled_ot/bam_preprocessing/
cp $TMPDIR/log_S${PBS_ARRAY_INDEX}_PrintReads.txt $WORK/pooled_ot/log/


# echo "Calculating statistics"
# samtools flagstat ${SAMPLE_NAME}.realigned.bqsrCal.bam > ${SAMPLE_NAME}.realigned.bqsrCal.report.txt
samtools index ${SAMPLE_NAME}.realigned.bqsrCal.bam
cp $TMPDIR/${SAMPLE_NAME}.realigned.bqsrCal.bam $WORK/pooled_ot/bam_preprocessing/

#  -- HaplotypeCaller .------------------------------------------------------------------------------------------------
# echo "Haplotype caller"
# gatk -T HaplotypeCaller \
#      -R $REFERENCE \
#      -I ${SAMPLE_NAME}.realigned.bqsrCal.bam \
#      -nct $SLOTS \
#      --dbsnp $TMPDIR/ref/dbSNP.reorder.vcf \
#      --emitRefConfidence GVCF \
#      -o $SAMPLE_NAME.raw.snps.indels.g.vcf |& tee $WORK/pooled_ot/log/log_S${SAMPLE_NAME}_HC.txt

# cp $TMPDIR/$SAMPLE_NAME.raw.snps.indels.g.vcf $WORK/pooled_ot/gVCFs/
# cp $TMPDIR/${SAMPLE_NAME}.realigned.bqsrCal.bam.bai $WORK/pooled_ot/bam_preprocessing/

# # Copy files
# cp $TMPDIR/${SAMPLE_NAME}.realigned.bqsrCal.report.txt $WORK/pooled_ot/bam_preprocessing/
# cp $TMPDIR/${SAMPLE_NAME}.marked_dup_metrics.txt $WORK/pooled_ot/bam_preprocessing/

