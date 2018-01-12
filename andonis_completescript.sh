#!/bin/bash

#######if multiple fastq files, use script below. if only one file for each direction, skip fancy part
#######not sure which of following scripts is correct

# REFERENCE="ref/AgamP4.fa"
# READ1=$3
# READ2=$4

# I=0

# DIR="G3/reads/gamb55"

# ls $DIR/*.fastq | grep '_1' | while read F
# do
    
# 	echo $F

#     # let I=I+1
#     R=`echo $F | sed 's/_1/_2/'`
   	
#     echo $R

#     echo "bwa mem -t 8 $REFERENCE ${F} ${R} > G3/reads/gamb55/aln_$I.sam"
#     ./bwa mem -t 8 $REFERENCE ${F} ${R} > Sample_C12_17/s2_aln_$I.sam
#     #samtools view -bu Sample_C12_17/s2_aln_$I.sam | samtools sort - > Sample_C12_17/${F:15}.sorted.bam
# done

#ls $DIR/*.sam | while read F
#do
#    let I=I+1
#    R=`echo $F | sed 's/R1/R2/'`
   
   # echo "bwa mem -t 8 $REFERENCE ${F} ${R} > aln_$I.sam"
    #./bwa mem -t 8 $REFERENCE ${F} ${R} > s2_aln_$I.sam
   
	#echo ${F%.*};
#	samtools view -bu $F | samtools sort - > ${F%.*}.sorted.bam
#done

###merge the bam files together
#samtools merge -b bamlist.txt -@ 8 C12_17.bam

# find $BAM_DIR -name '*.bam' | {
#     read firstbam
#     samtools view -h "$firstbam"
#     while read bam; do
#         samtools view "$bam"
#     done
# } | samtools view -ubS - | samtools sort - merged
# samtools index merged.bam
# ls -l merged.bam merged.bam.bai

###merge the bam files together
#samtools merge -b bamlist.txt -@ 8 C12_17.bam


#########################################################
### can do this if there are no separate fastq files, but only one for forward and one for reverse
###piped directly into samtools to create the BAM file, then go straight to picard markduplicates and samtools index
### first align gambiae from parental cross to reference genome
#bwa mem -t 8 ref/AgamP4.fa G3/reads/gamb55/SRR5923955_1.fastq G3/reads/gamb55/SRR5923955_2.fastq | samtools sort -@8 -O BAM -o G3/gamb55.bam -

### mark duplicates of parental gambiae and index the bam file
#$JAVA_PATH/
#java -jar picard.jar MarkDuplicates INPUT=G3/gamb55/gamb55.bam OUTPUT=G3/gamb55/gamb55.dedup.bam METRICS_FILE=G3/gamb55/metrics.txt
#samtools index G3/gamb55/gamb55.dedup.bam

### add or replace read groups for parental gambiae
#java -jar picard.jar AddOrReplaceReadGroups I=G3/gamb55/gamb55.dedup.bam O=G3/gamb55/gamb55.rg.bam RGID=G3/gamb55 RGLB=lib1 RGPL=illumina RGPU=unit1 RGSM=gamb55

### index bam file
#samtools index G3/gamb55/gamb55.rg.bam

###variant calling relative to reference genome
#java -jar GenomeAnalysisTK.jar -R ref/AgamP4.fa -T HaplotypeCaller -nct 8 -I G3/gamb55/gamb55.rg.bam --emitRefConfidence GVCF -o G3/gamb55/gamb55.raw.snps.indels.g.vcf 

### genotype the vcf
#java -jar GenomeAnalysisTK.jar -T GenotypeGVCFs --variant G3/gamb55/gamb55.raw.snps.indels.g.vcf -R ref/AgamP4.fa -o G3/gamb66/gamb66.raw.snps.indels.vcf

####need to remove heterozygous SNPs, indels and anything on the sex chromosomes
#remove indels from vcf file
#vcftools --vcf G3/gamb55/gamb55.raw.snps.indels.vcf --remove-indels --recode --recode-INFO-all --out G3/gamb55/gamb55.raw.snps

#keep only homozygous SNPs
#bcftools view -g hom -o G3/gamb55/gamb55.raw.snps.recode.homo.vcf G3/gamb55/gamb55.raw.snps.recode.vcf

#remove anything from sex chromosomes
#first find chromosome names
#grep ">" G3/gamb55/gamb55.raw.snps.recode.homo.vcf
### edit names of chromosomes below as needed
#vcftools --vcf G3/gamb55/gamb55.raw.snps.recode.homo.vcf --chr 2R --chr 3R --chr 2L --chr 3L --recode --recode-INFO-all --out G3/gamb55/gamb55.raw.snps.recode.homo.autosomes
#check only autosomal sites kept
#cut -f1 G3/gamb55/gamb55.raw.snps.recode.homo.autosomes.recode.vcf | sort | uniq > autosomes.txt
#subl autosomes.txt

#### create pseudo-reference sequence
#java -jar GenomeAnalysisTK.jar -T FastaAlternateReferenceMaker -R ref/AgamP4.fa -o G3/gamb55/gamb55pseudoref.fa -V G3/gamb55/gamb55.raw.snps.recode.homo.autosomes.recode.vcf 

#### index the pseudo reference genome
#bwa index G3/gamb55/gamb55pseudoref.fa
#samtools faidx G3/gamb55/gamb55pseudoref.fa
#java -jar picard.jar CreateSequenceDictionary R=G3/gamb55/gamb55pseudoref.fa O=G3/gamb55/gamb55pseudoref.dict

################ parental arabiensis

###align reads to pseudoreference genome of parental gambiae

# REFERENCE="G3/gamb55/gamb55pseudoref.fa"
# READ1=$3
# READ2=$4

# I=0

# DIR="Sample_C12_17/fastq"

# ls $DIR/*.fastq.gz | grep 'R1' | while read F
# do
    
# 	echo $F

#      let I=I+1
#     R=`echo $F | sed 's/R1/R2/'`
   	
#     echo $R

    #echo "bwa mem -t 8 $REFERENCE ${F} ${R} > aln_$I.sam"
   #  ./bwa mem -t 8 $REFERENCE ${F} ${R} > Sample_C12_17/sam/aln_$I.sam
#        samtools view -bu Sample_C12_17/sam/aln_$I.sam | samtools sort - > Sample_C12_17/sam/aln_$I.sorted.bam
 #done

###merge the bam files together
#ls Sample_C12_17/sam/*.bam > bamlist.txt
#samtools merge -b bamlist.txt -@ 8 Sample_C12_17/sam/C12_17.bam

### mark duplicates and index the bam file
#$JAVA_PATH/
#java -jar picard.jar MarkDuplicates INPUT=Sample_C12_17/sam/C12_17.bam OUTPUT=Sample_C12_17/sam/C12_17.dedup.bam METRICS_FILE=Sample_C12_17/sam/metrics.txt
#samtools index Sample_C12_17/sam/C12_17.dedup.bam

### add or replace read groups
#java -jar picard.jar AddOrReplaceReadGroups I=Sample_C12_17/sam/C12_17.dedup.bam O=Sample_C12_17/sam/C12_17.rg.bam RGID=Sample_C12_17 RGLB=lib1 RGPL=illumina RGPU=unit1 RGSM=C12_17

### index bam file
#samtools index Sample_C12_17/sam/C12_17.rg.bam

###variant calling relative to pseudoreference genome
#java -jar GenomeAnalysisTK.jar -R G3/gamb55/gamb55pseudoref.fa -T HaplotypeCaller -nct 8 -I Sample_C12_17/sam/C12_17.rg.bam --emitRefConfidence GVCF -o Sample_C12_17/sam/C12_17.raw.snps.indels.g.vcf 

### genotype the vcf
#java -jar GenomeAnalysisTK.jar -T GenotypeGVCFs --variant Sample_C12_17/sam/C12_17.raw.snps.indels.g.vcf -R G3/gamb55/gamb55pseudoref.fa -o Sample_C12_17/sam/C12_17.raw.snps.indels.vcf

####need to remove heterozygous SNPs, indels and anything on the sex chromosomes
#remove indels from vcf file
#vcftools --vcf Sample_C12_17/sam/C12_17.raw.snps.indels.vcf --remove-indels --recode --recode-INFO-all --out Sample_C12_17/sam/C12_17.raw.snps

#keep only homozygous SNPs
#bcftools view -g hom -o Sample_C12_17/sam/C12_17.raw.snps.recode.homo.vcf Sample_C12_17/sam/C12_17.raw.snps.recode.vcf

#check only homozygous SNPs left in vcf file
#head -n 300 Sample_C12_17/sam/C12_17.raw.snps.recode.homo.vcf

#remove anything from sex chromosomes
#command to get list of chromosome names (reference names will be same as in VCF file)
#grep ">" G3/gamb55/gamb55pseudoref.fa

### edit names of chromosomes below as needed
#vcftools --vcf Sample_C12_17/sam/C12_17.raw.snps.recode.homo.vcf --chr 1 --chr 2 --chr 3 --chr 5 --recode --recode-INFO-all --out Sample_C12_17/sam/C12_17.raw.snps.recode.homo.autosomes
###check only autosomal sites kept
#cut -f1 Sample_C12_17/sam/C12_17.raw.snps.recode.homo.autosomes.recode.vcf | sort | uniq > Sample_C12_17/sam/chromnames.txt

#vcf file now contains only our list of markers, SNPs that will be heterozygous in the F1 hybrid females


############### backcross gambiae

### align reads to pseudoreference genome, sort into bam file
#bwa mem -t 8 G3/gamb55/gamb55pseudoref.fa G3/reads/gamb66/SRR5923966_1.fastq G3/reads/gamb66/SRR5923966_2.fastq | samtools sort -@8 -O BAM -o G3/gamb66.bam -

### mark duplicates and index bam file
#java -jar picard.jar MarkDuplicates INPUT=G3/gamb66/gamb66.bam OUTPUT=G3/gamb66/gamb66.dedup.bam METRICS_FILE=G3/gamb66/metrics.txt
#samtools index G3/gamb66/gamb66.dedup.bam

### add or replace read groups
#java -jar picard.jar AddOrReplaceReadGroups I=G3/gamb66/gamb66.dedup.bam O=G3/gamb66/gamb66.rg.bam RGID=G3/gamb66 RGLB=lib1 RGPL=illumina RGPU=unit1 RGSM=gamb66

### index bam file
#samtools index G3/gamb66/gamb66.rg.bam

###variant calling relative to pseudoreference genome
#java -jar GenomeAnalysisTK.jar -R G3/gamb55/gamb55pseudoref.fa -T HaplotypeCaller -nct 8 -I G3/gamb66/gamb66.rg.bam --emitRefConfidence GVCF -o G3/gamb66/gamb66.raw.snps.indels.g.vcf

### genotype vcf
#java -jar GenomeAnalysisTK.jar -T GenotypeGVCFs --variant G3/gamb66/gamb66.raw.snps.indels.g.vcf -R G3/gamb55/gamb55pseudoref.fa -o G3/gamb66/gamb66.raw.snps.indels.vcf  

#now need to make sure that none of the loci we selected as markers between the parental cross are listed in this VCF as SNPs
#remove indels first
#vcftools --vcf G3/gamb66/gamb66.raw.snps.indels.vcf --remove-indels --recode --recode-INFO-all --out G3/gamb66/gamb66.raw.snps

#not removing any heterozygous SNPs here, I need all of them

#remove anything not on autosomes
#vcftools --vcf G3/gamb66/gamb66.raw.snps.recode.vcf --chr 1 --chr 2 --chr 3 --chr 5 --recode --recode-INFO-all --out G3/gamb66/gamb66.raw.snps.recode.autosomes
###check only autosomal sites kept
#cut -f1 G3/gamb66/gamb66.raw.snps.recode.autosomes.recode.vcf | sort | uniq > G3/gamb66/chromnames.txt


#################### finalising marker list
#last step in creating the marker list is comparing the VCF files of the parental arabiensis and the backcross gambiae
#we want to exclude all common loci, meaning any SNPs left between the parental arabiensis and gambiae are specific to them, and the backcross gambiae matches the parental gambiae at all of the loci in this vcf

#extract locations from vcf of backcross gambiae
#head -n 300 G3/gamb66/gamb66.raw.snps.recode.autosomes.recode.vcf

#need first 2 columns of vcf (chromosome name and position)
#awk '{print $1"\t"$2 }' G3/gamb66/gamb66.raw.snps.recode.autosomes.recode.vcf > G3/gamb66/data_positions.txt
#!!!!!!!!!!!!!!!!!!!!!!manually go to the file and delete the header !!!!!!!!!!!!!!!!!!!!!!!!!!!!!

#filter locations out of final marker vcf
#vcftools --vcf Sample_C12_17/sam/C12_17.raw.snps.recode.homo.autosomes.recode.vcf --exclude-positions G3/gamb66/data_positions.txt --recode --recode-INFO-all --out Sample_C12_17/sam/markerlist


####### open together the first two, and find the first SNP position that has been removed in the creation of the marker list
####### then look at backcross gambiae, and check that the 'removed'SNP is present, while the kept one is not there
#head -n 300 Sample_C12_17/sam/markerlist.recode.vcf
#head -n 300 Sample_C12_17/sam/C12_17.raw.snps.recode.homo.autosomes.recode.vcf > Sample_C12_17/sam/temp.txt
#head -n 300 G3/gamb66/gamb66.raw.snps.recode.autosomes.recode.vcf


### plot SNP density along chromosomes
#calculate SNP density (in this case in 10kb sliding window invrements)
#vcftools --vcf Sample_C12_17/sam/markerlist.recode.vcf --SNPdensity 10000 --out Sample_C12_17/sam/snpdensity

#convert tabs to commas so you can save the snpden file as a csv
#tr '\t' ',' < Sample_C12_17/sam/snpdensity.snpden > Sample_C12_17/sam/snpdensitycomma.snpden

#convert snpden file to csv
cat Sample_C12_17/sam/snpdensitycomma.snpden > Sample_C12_17/sam/snpdensity.csv



