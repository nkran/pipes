#!/bin/bash

for b in alignments/*.bam
do

	# Sort both alignments
	samtools sort ${b:11:5}.discordants.unsorted.bam ${b:11:5}.discordants
	samtools sort ${b:11:5}.splitters.unsorted.bam ${b:11:5}.splitters
done
