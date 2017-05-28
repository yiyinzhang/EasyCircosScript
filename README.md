# EasyCircosScript

## 1. Introduction
When I was processing the data of next-generation of sequencing and visualizing the coverage of the genome by Circos, the configuration files of circos was annoyed. I had to write the configuration files manually. So I wrote this Perl script in order to simplify it. So it can generate the configuration files automatically. At this moment, this Perl script can only output the configuraion files of NGS's reads coverage of genome for the visualization of the traditional RNA-seq and circRNAseq.

## 2. Data required
You need the genome coverage files whose format is as follow:

		1	67100001	67200000	0
		1	134200001	134300000	5655

The first colomn is the id of chromosome. The second colomn is the start point of a 10K interval, and the third colomn is the end point of it. the forth colomn is the number of reads in this interval. You can use another Perl script which I'll upload to Github later to produce the coverage file of each sample through its BAM file and genome fasta index file(\*fai).

## 3. Usage
	perl EazyCircosScript.pl --type|T <RNA|miRNA> --kary|K <genome name> --fai|F <fasta index file> --chrIndex|I <chromosome Name Index> --samples|S <sample name> --cov|C <path to coverage file> --plotPath|P <path to plot Circos>

--type|T <RNA|miRNA> : A required parameter. Choose the type of Circos plot.
--kary|K <genome name> : A required parameter. Type the genome assembly build name. eg. hg38, GRCm38, etc.
--fai|F  <fasta index file> : A required parameter. The absolute path of \*fai file of the genome.
--chrIndex|I <chromosome Name Index> : An optional parameter. If the chromosome name of the genome is not normal for some genome fasta files you downloaded from NCBI, like NC_XXXXXX.X. You can make a chromosome index file, whose first and second colomns are the original chromosome name and its normal names, like 1, 2, 3, ..., X, Y
--samples|S <sample name> : A required parameter. Type the sample names, like "sample1 sample2 ..."
--cov|C <path to coverage file> : A required parameter. The path of coverage file.
--plotPath|P <path to plot Circos> : A required parameter. The path you want to generate the Circos plot.
