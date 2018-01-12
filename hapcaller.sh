# COUNTER=1

for f in ../aligned/*.bam;
do
    echo $f
    FNAME=${f:11:5}
    echo $FNAME
    java -jar /Users/nace/imperial/software/GenomeAnalysisTK.jar -R ../ref/AgamP4.fa -T HaplotypeCaller \
        -I $f --emitRefConfidence GVCF -L target_7280.bed -o output_$FNAME.raw.snps.indels.g.vcf

    # @RG	ID:TN1	SM:TN1
    # FNAME=${f:11:5}
    java -jar /Users/nace/imperial/software/picard.jar AddOrReplaceReadGroups \
      I=$f \
      O=$FNAME.bam \
      RGID=$FNAME \
      RGLB=lib1 \
      RGPL=illumina \
      RGPU=unit1 \
      RGSM=$FNAME

    COUNTER=$[$COUNTER+1]
done

java -jar /Users/nace/imperial/software/GenomeAnalysisTK.jar \
   -T GenotypeGVCFs \
   --variant output_TN_01.raw.snps.indels.g.vcf \
   --variant output_TN_02.raw.snps.indels.g.vcf \
   --variant output_TN_03.raw.snps.indels.g.vcf \
   --variant output_TN_04.raw.snps.indels.g.vcf \
   --variant output_TN_05.raw.snps.indels.g.vcf \
   --variant output_TN_06.raw.snps.indels.g.vcf \
   --variant output_TN_07.raw.snps.indels.g.vcf \
   --variant output_TN_08.raw.snps.indels.g.vcf \
   --variant output_TN_09.raw.snps.indels.g.vcf \
   --variant output_TN_10.raw.snps.indels.g.vcf \
   --variant output_TN_11.raw.snps.indels.g.vcf \
   --variant output_TN_12.raw.snps.indels.g.vcf \
   --variant output_TN_13.raw.snps.indels.g.vcf \
   --variant output_TN_14.raw.snps.indels.g.vcf \
   --variant output_TN_15.raw.snps.indels.g.vcf \
   --variant output_TN_16.raw.snps.indels.g.vcf \
   --variant output_TN_17.raw.snps.indels.g.vcf \
   --variant output_TN_18.raw.snps.indels.g.vcf \
   --variant output_TN_19.raw.snps.indels.g.vcf \
   --variant output_TN_20.raw.snps.indels.g.vcf \
   --variant output_TN_21.raw.snps.indels.g.vcf \
   --variant output_TN_22.raw.snps.indels.g.vcf \
   --variant output_TN_23.raw.snps.indels.g.vcf \
   --variant output_TN_24.raw.snps.indels.g.vcf \
   -R ../ref/AgamP4.fa \
   -o TN_all_output.vcf

# java -jar /Users/nace/imperial/software/GenomeAnalysisTK.jar \
#    -T CombineGVCFs \
#    -R ../ref/AgamP4.fa \
#    --variant output_TN_01.raw.snps.indels.g.vcf \
#    --variant output_TN_02.raw.snps.indels.g.vcf \
#    --variant output_TN_03.raw.snps.indels.g.vcf \
#    --variant output_TN_04.raw.snps.indels.g.vcf \
#    --variant output_TN_05.raw.snps.indels.g.vcf \
#    --variant output_TN_06.raw.snps.indels.g.vcf \
#    --variant output_TN_07.raw.snps.indels.g.vcf \
#    --variant output_TN_08.raw.snps.indels.g.vcf \
#    --variant output_TN_09.raw.snps.indels.g.vcf \
#    --variant output_TN_10.raw.snps.indels.g.vcf \
#    --variant output_TN_11.raw.snps.indels.g.vcf \
#    --variant output_TN_12.raw.snps.indels.g.vcf \
#    --variant output_TN_13.raw.snps.indels.g.vcf \
#    --variant output_TN_14.raw.snps.indels.g.vcf \
#    --variant output_TN_15.raw.snps.indels.g.vcf \
#    --variant output_TN_16.raw.snps.indels.g.vcf \
#    --variant output_TN_17.raw.snps.indels.g.vcf \
#    --variant output_TN_18.raw.snps.indels.g.vcf \
#    --variant output_TN_19.raw.snps.indels.g.vcf \
#    --variant output_TN_20.raw.snps.indels.g.vcf \
#    --variant output_TN_21.raw.snps.indels.g.vcf \
#    --variant output_TN_22.raw.snps.indels.g.vcf \
#    --variant output_TN_23.raw.snps.indels.g.vcf \
#    --variant output_TN_24.raw.snps.indels.g.vcf \
#    > cohort.g.vcf

# vcftools --vcf ../g3_snps.raw.vcf --recode-INFO-all --out target_7280 --recode --bed target_7280.bed

# ../../../../Users/nace/imperial/software/shapeit_old/shapeit --input-vcf TN_all_output.vcf -M Ag_2L_combined.map -O TN_all_07.phased --input-thr 0.51
