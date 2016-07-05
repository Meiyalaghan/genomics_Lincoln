#!/bin/bash

## Script to map original reads back onto the newly assembled genome, for viewing in a browser and as a sanity check

# Make a bowtie2 index for the newly assembled genome
mkdir -p index;

bowtie2-build assembly/contigs.fa index/Vp;

# Map just the paired-end reads separated by ~310bp
# Note that we don't change the defaults of the expected minimum and maximum insert size
mkdir -p mapping;

bowtie2 -x index/Vp -1 raw/PE310_L.fastq.gz -2 raw/PE310_R.fastq.gz --minins 0 --maxins 500 -S mapping/PE310.sam;

# Map just the paired-end reads separated by ~2000bp
# Note that we change the defaults of the expected minimum and maximum insert size
bowtie2 -x index/Vp -1 raw/MP2000_L.fastq.gz -2 raw/MP2000_R.fastq.gz --minins 1700 --maxins 2700 -S mapping/MP2000.sam;

# Map just the paired-end reads separated by ~5000bp
bowtie2 -x index/Vp -1 raw/MP5000_L.fastq.gz -2 raw/MP5000_R.fastq.gz --minins 3000 --maxins 3800 -S mapping/MP5000.sam;

# Merge all the mappings together.. option commented out for now.

#samtools merge merged.sam PE310.sam MP2000.sam MP5000.sam

# Convert to BAM and sort
for var in PE310 MP2000 MP5000;
	do

	samtools view -bS mapping/${var}.sam |samtools sort - mapping/${var};
	samtools index mapping/${var}.bam
	rm mapping/${var}.sam
done;

igv -g assembly/contigs.fa mapping/PE310.bam,mapping/MP2000.bam,mapping/MP5000.bam,annotation/Vp_augustus.gff3



