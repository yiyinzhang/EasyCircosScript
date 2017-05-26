EasyCircosScript
===

1. Introduction
---

    This Perl script is designed for generate configuration files of plotting circos automatically in the processing of NGS data. In particular, It can just plot the coverage plot for mapping of NGS reads in this version now. And I will add more fuctions to the program to make it can adapt to more types of circos plots, such as gene fusion plot, miRNA circos cirocs plot and etc.

2. Data required
---
    You need the genome coverage files which is the output of Bedtools, its format is as follow:

		1	67100001	67200000	0
		1	134200001	134300000	5655

    You also need the fai file of the genome build you use as a reference genome.

3. Usage
    perl EazyCircosScript.pl --kary|K <genome name> --fai|F <fasta index file> --samples|S <sample name> --cov|C <path to coverage file> --plotPath|P <path to plot Circos>

	
