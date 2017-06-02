#!/usr/bin/perl
use strict;
use Getopt::Long; 
use Pod::Usage ();
use POSIX;

=head1 NAME

EasyCircosScript

=head1 SYNOPSIS

Use:
perl EazyCircosScript.pl --type|T <RNA|circRNA> --kary|K <genome name> --fai|F <fasta index file> --chrIndex|I <chromosome Name Index> --samples|S <sample name> --cov|C <path to coverage file> --plotPath|P <path to plot Circos>

=head1 DESCRIPTION

A Perl Program designed for generating configuration scripts for ploting circos.

=head1 AUTHOR

Yiyin Zhang

=head1 COPYRIGHT

Copyright 2016 Yiyin Zhang, all rights reserved.

This script is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This script is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this script; if not, write to the Free Software Foundation,
Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
=cut

my $help;
my $kary;
my $samples;
my $fai;
my $covList;
my $plotCircosPath;
my $chrIndex;
my $type;

GetOptions
(
	'fai|F=s'  => \$fai,
	'kary|K=s'  => \$kary,
	'samples|S=s' =>\$samples,
	'cov|C=s' =>\$covList,
	'plotPath|P=s' =>\$plotCircosPath,
	'chrIndex|I=s' =>\$chrIndex,
	'type|T=s' =>\$type,
	'help' => \$help,
);

Pod::Usage::pod2usage(-verbose =>1)if($help);

unless(defined($samples))
{
	Pod::Usage::pod2usage(-exitstatus => 2);
}

sub coverage
{
	(my $kary, my $plotCircosPath, my $sampleName) = @_;
	my $colour = ['red', 'vlorange', 'yellow', 'green', 'blue', 'purple'];
	my $outer = ["0.85", "0.73", "0.61", "0.49", "0.37", "0.25"];
	my $inner = ["0.75", "0.63", "0.51", "0.39", "0.27", "0.15"];
	my @first6elements;
	if(@$sampleName >= 6)
	{
		$first6elements[0] = $$sampleName[0];
		$first6elements[1] = $$sampleName[1];
		$first6elements[2] = $$sampleName[2];
		$first6elements[3] = $$sampleName[3];
		$first6elements[4] = $$sampleName[4];
		$first6elements[5] = $$sampleName[5];
		shift @$sampleName;
		shift @$sampleName;
		shift @$sampleName;
		shift @$sampleName;
		shift @$sampleName;
		shift @$sampleName;
		if (@$sampleName != 0)
		{
			&coverage($kary, $plotCircosPath, $sampleName);
		}
	}
	else
	{
		@first6elements = @$sampleName;
	}
	my $lineFir6Element = join("_", @first6elements);
	my $fileName = "$lineFir6Element"."_coverage.conf";
	open(OUT, ">$plotCircosPath/circos_coverage/$fileName")||die $!;
	print OUT "show_scatter   = yes\nshow_line      = yes\nshow_histogram = yes\nshow_heatmap   = yes\nshow_tile      = yes\nshow_highlight = yes\nshow_link      = yes\nshow_text      = yes\nuse_rules      = yes\n\n<<include colors_fonts_patterns.conf>>\n\n<<include ideogram.conf>>\n<<include ticks.conf>>\n\n<image>\n<<include etc/image.conf>>\n</image>\n\nkaryotype         = $plotCircosPath/circos_coverage/$kary.genome.txt\nchromosomes_units = 1000000\nchromosomes_display_default = yes\n<plots>\nshow = no\n";
	my $i = 0;
	foreach my $sample(@first6elements)
	{
		print OUT "<plot>\nshow         = conf(show_histogram)\ntype         = histogram\nfile         = $plotCircosPath/circos_coverage/$sample.out.cov\norientation  = out\nthickness    = 1\ncolor        = $$colour[$i]\nfill_under   = yes\nfill_color   = $$colour[$i]\nr0           = $$outer[$i]r\nr1           = $$inner[$i]r\nmax_gap      = 5u\nz = 10\n</plot>\n";
		$i += 1;
	}
	print OUT "<plot>\nshow         = conf(show_text)\ntype = text\nfile = $plotCircosPath/circos_coverage/${lineFir6Element}_sample_name\n\nlabel_font = bold\nlabel_size = 30p\nr0         = 0.05r\nr1         = 0.25r\nshow_links = no\n\n</plot>\n\n</plots>\n\n<<include etc/housekeeping.conf>>\n";
	close OUT;
}

sub sampleCoverageFile
{
	my ($sampleFile) = @_;
	foreach my $sample (@$sampleFile)
	{
		open(FILE, "$plotCircosPath/circos_coverage/${sample}.genome.cov")|| die "no ${sample}.genome.cov";
		open(OUT, ">$plotCircosPath/circos_coverage/${sample}.out.cov")||die $!;
		while(<FILE>)
		{
			chomp;
			my @data = split('\t',$_);
			if($data[0] !~ /chr/i)
			{
				$data[0] = "chr".$data[0];
			}
			$data[3] = log($data[3] + 1)/log(2);
			print OUT join("\t", @data[0..$#data], "\n");
		}
		close FILE;
		close OUT;
	}
}

sub sampleCoverageFile_circRNA
{
	my ($sampleFile) = @_;
	foreach my $sample (@$sampleFile)
	{
		open(FILE, "$plotCircosPath/circos_coverage/${sample}.cov.txt")|| die "no ${sample}.cov.txt";
		open(OUT, ">$plotCircosPath/circos_coverage/${sample}.out.cov")||die $!;
		while(<FILE>)
		{
			chomp;
			my @data = split('\t',$_);
			if($data[0] !~ /chr/i)
			{
				$data[0] = "chr".$data[0];
			}
			print OUT join("\t", @data[0..$#data], "\n");
		}
		close FILE;
		close OUT;
	}
}

sub sampleCoverageFile_index
{
	(my $index, my $sampleFile) = @_;
	my %index;
	open(INDEX, "$index")||die $!;
	while(<INDEX>)
	{
		chomp;
		my @data = split(/\t/, $_);
		if($data[1] =~ /chr/)
		{
			$index{$data[0]} = $data[1];
		}
		else
		{
			$index{$data[0]} = "chr".$data[1];
		}
	}
	close INDEX;
	foreach my $sample (@$sampleFile)
	{
		open(FILE, "$plotCircosPath/circos_coverage/${sample}.genome.cov")|| die "no ${sample}.genome.cov";
		open(OUT, ">$plotCircosPath/circos_coverage/${sample}.out.cov")||die $!;
		while(<FILE>)
		{
			chomp;
			my @data = split('\t',$_);
			if($data[0] !~ /chr/i)
			{
				if($index{$data[0]})
				{
					$data[0] = $index{$data[0]};
				}
				else
				{
					next;
				}
			}
			$data[3] = log($data[3] + 1)/log(2);
			print OUT join("\t", @data[0..$#data], "\n");
		}
		close FILE;
		close OUT;
	}
}

sub sampleCoverageFile_circRNA_index
{
	(my $index, my $sampleFile) = @_;
	my %index;
	open(INDEX, "$index")||die $!;
	while(<INDEX>)
	{
		chomp;
		my @data = split(/\t/, $_);
		if($data[1] =~ /chr/)
		{
			$index{$data[0]} = $data[1];
		}
		else
		{
			$index{$data[0]} = "chr".$data[1];
		}
	}
	close INDEX;
	foreach my $sample (@$sampleFile)
	{
		open(FILE, "$plotCircosPath/circos_coverage/${sample}.cov.txt")|| die "no ${sample}.cov.txt";
		open(OUT, ">$plotCircosPath/circos_coverage/${sample}.out.cov")||die $!;
		while(<FILE>)
		{
			chomp;
			my @data = split('\t',$_);
			if($data[0] !~ /chr/i)
			{
				if($index{$data[0]})
				{
					$data[0] = $index{$data[0]};
				}
				else
				{
					next;
				}
			}
			print OUT join("\t", @data[0..$#data], "\n");
		}
		close FILE;
		close OUT;
	}
}

sub name_conf
{
	open(GEN, "$plotCircosPath/circos_coverage/$kary.genome.txt")||die $!;
	my $tmpEnd = 0;
	my %chrStart;
	my %chrEnd;
	my %chrSpanEnd;
	my %chrSpanStart;
	while(<GEN>)
	{
		chomp;
		my @data = split(/\s/, $_);
		$chrStart{$data[2]} = $data[4] + 1;
		$chrEnd{$data[2]} = $data[5];
		$chrSpanStart{$data[2]} = $tmpEnd + 1;
		$chrSpanEnd{$data[2]} = $data[5] + $tmpEnd;
		$tmpEnd = $data[5] + $tmpEnd;
	}
	close GEN;
	my ($sampleName) = @_;
	my $colors = ['red', 'vlorange', 'yellow', 'green', 'blue', 'purple'];
	my @first6elements;
	if(@$sampleName > 5)
	{
		$first6elements[0] = $$sampleName[0];
		$first6elements[1] = $$sampleName[1];
		$first6elements[2] = $$sampleName[2];
		$first6elements[3] = $$sampleName[3];
		$first6elements[4] = $$sampleName[4];
		$first6elements[5] = $$sampleName[5];
		shift @$sampleName;
		shift @$sampleName;
		shift @$sampleName;
		shift @$sampleName;
		shift @$sampleName;
		shift @$sampleName;
		if(@$sampleName)
		{
			&name_conf($sampleName);
		}
	}
	else
	{
		@first6elements = @$sampleName;
	}
	my $sampleNum = @first6elements;
	my $span = POSIX::round($tmpEnd/$sampleNum);
	my @labelChr;
	my @pos;
	my @chunk;
	for(my $i = 1; $i < $tmpEnd; $i = $i+$span)
	{
		push(@chunk, $i);
	}
	foreach my $i(@chunk)
	{
		foreach my $ky(keys %chrSpanEnd)
		{
			if($i<=$chrSpanEnd{$ky} && $i>=$chrSpanStart{$ky})
			{
				push (@labelChr, $ky);
				push (@pos, $i - $chrSpanStart{$ky});
			}
		}
	}
	
	my $lineFir6Element = join("_", @first6elements);
	my $fileName = "$lineFir6Element"."_sample_name";
	open(OUT, ">$plotCircosPath/circos_coverage/$fileName")||die $!;
	for(my $i = 0; $i < @first6elements; $i++)
	{
		my $startPnt = $pos[$i];
		my $endPnt = $pos[$i] + 100000;
		print OUT "$labelChr[$i]\t$startPnt\t$endPnt\t$first6elements[$i]\tcolor=$$colors[$i]\n";
	}
	close OUT;
}

sub name_conf_circRNA
{
	open(GEN, "$plotCircosPath/circos_coverage/$kary.genome.txt")||die $!;
	my $tmpEnd = 0;
	my %chrStart;
	my %chrEnd;
	my %chrSpanEnd;
	my %chrSpanStart;
	while(<GEN>)
	{
		chomp;
		my @data = split(/\s/, $_);
		$chrStart{$data[2]} = $data[4] + 1;
		$chrEnd{$data[2]} = $data[5];
		$chrSpanStart{$data[2]} = $tmpEnd + 1;
		$chrSpanEnd{$data[2]} = $data[5] + $tmpEnd;
		$tmpEnd = $data[5] + $tmpEnd;
	}
	close GEN;
	my ($sampleName) = @_;
	my $colors = ['vlorange', 'vlyellow', 'vlgreen', 'vlblue'];
	my @first6elements;
	if(@$sampleName > 3)
	{
		$first6elements[0] = $$sampleName[0];
		$first6elements[1] = $$sampleName[1];
		$first6elements[2] = $$sampleName[2];
		$first6elements[3] = $$sampleName[3];
		shift @$sampleName;
		shift @$sampleName;
		shift @$sampleName;
		shift @$sampleName;
		if(@$sampleName)
		{
			&name_conf_circRNA($sampleName);
		}
	}
	else
	{
		@first6elements = @$sampleName;
	}
	my $sampleNum = @first6elements;
	my $span = POSIX::round($tmpEnd/$sampleNum);
	my @labelChr;
	my @pos;
	my @chunk;
	for(my $i = 1; $i < $tmpEnd; $i = $i+$span)
	{
		push(@chunk, $i);
	}
	foreach my $i(@chunk)
	{
		foreach my $ky(keys %chrSpanEnd)
		{
			if($i<=$chrSpanEnd{$ky} && $i>=$chrSpanStart{$ky})
			{
				push (@labelChr, $ky);
				push (@pos, $i - $chrSpanStart{$ky});
			}
		}
	}
	
	my $lineFir6Element = join("_", @first6elements);
	my $fileName = "$lineFir6Element"."_sample_name";
	open(OUT, ">$plotCircosPath/circos_coverage/$fileName")||die $!;
	for(my $i = 0; $i < @first6elements; $i++)
	{
		my $startPnt = $pos[$i];
		my $endPnt = $pos[$i] + 100000;
		print OUT "$labelChr[$i]\t$startPnt\t$endPnt\t$first6elements[$i]\tcolor=$$colors[$i]\n";
	}
	close OUT;
}

sub other_scripts
{
	open(BANDS, ">$plotCircosPath/circos_coverage/bands.conf")||die $!;
	print BANDS "show_bands            = yes\nfill_bands            = yes\nband_stroke_thickness = 2\nband_stroke_color     = white\nband_transparency     = 3\n";
	close BANDS;
	open(POS, ">$plotCircosPath/circos_coverage/ideogram.position.conf")|| die $!;
	print POS "radius           = 0.90r\nthickness        = 30p\nfill             = yes\nfill_color       = black\nstroke_thickness = 2\nstroke_color     = black\n";
	close POS;
	open(TICKS, ">$plotCircosPath/circos_coverage/ticks.conf")||die $!;
	print TICKS "show_ticks          = yes\nshow_tick_labels    = yes\n\n<ticks>\ntick_separation      = 5p\nlabel_separation     = 5p\nradius               = dims(ideogram,radius_outer)\nmultiplier           = 1e-6\ncolor          = black\nsize           = 20p\nthickness      = 1p\nlabel_offset   = 5p\nformat         = %d\n\n<tick>\nspacing        = 1u\nshow_label     = no\nlabel_size     = 16p\n</tick>\n\n<tick>\nspacing        = 5u\nshow_label     = no\nlabel_size     = 18p\n</tick>\n\n<tick>\nspacing        = 10u\nshow_label     = no\nlabel_size     = 20p\n</tick>\n\n<tick>\nspacing        = 20u\nshow_label     = yes\nlabel_size     = 24p\n</tick>\n\n</ticks>\n";
	close TICKS;
	open(LABEL, ">$plotCircosPath/circos_coverage/ideogram.label.conf")||die $!;
	print LABEL "show_label       = yes\nlabel_font       = default\nlabel_radius     = dims(image,radius) - 75p\n\nlabel_size       = 30\nlabel_parallel   = yes\nlabel_case       = lower\nlabel_format     = eval(sprintf(\"chr%s\",var(label)))\n";
	close LABEL;
	open(IDEO, ">$plotCircosPath/circos_coverage/ideogram.conf")||die $!;
	print IDEO "<ideogram>\n\n<spacing>\ndefault = 0.005r\nbreak   = 0.5r\n\naxis_break_at_edge = yes\naxis_break         = yes\naxis_break_style   = 2\n\n<break_style 1>\nstroke_color = black\nfill_color   = blue\nthickness    = 0.25r\nstroke_thickness = 2\n</break>\n\n<break_style 2>\nstroke_color     = black\nstroke_thickness = 2\nthickness        = 1.5r\n</break>\n\n</spacing>\n\n<<include ideogram.position.conf>>\n<<include ideogram.label.conf>>\n<<include bands.conf>>\n\n</ideogram>\n";
	close IDEO;
}

sub fai2genomeFile
{
	my ($kary) = @_;
	open(FILE, "$plotCircosPath/circos_coverage/$kary.fa.fai")||die $!;
	open(OUT, ">$plotCircosPath/circos_coverage/$kary.genome.txt")||die $!;
	my %match;
	while(<FILE>)
	{
		chomp;
		my @data=split(/\t/,$_);
		if($data[0] =~/chr(.*)/)
		{
			$match{$1}=$data[1];
		}
		else
		{
			$match{$data[0]}=$data[1];
		}
	}
	close FILE;
	my $i = 30;
	foreach my $k(sort{$a <=> $b}keys %match)
	{
		if($k =~ /[E-KOQSU-W]/)
		{
			next;
		}
		if($k =~ /scaffold/)
		{
			next;
		}
		if ($k =~ /random/)
		{
			next;
		}
		if($k =~ /M/)
		{
			print OUT "chr - chr$k $k 0 $match{$k} hue000\n";
			next;
		}
		if($k =~ /X/)
		{
			print OUT "chr - chr$k $k 0 $match{$k} hue010\n";
			next;
		}
		if($k =~ /Y/)
		{
			print OUT "chr - chr$k $k 0 $match{$k} hue020\n";
			next;
		}
		print OUT "chr - chr$k $k 0 $match{$k} ";
		printf OUT "hue%03d\n", $i;
		$i += 10;
	}
	close OUT;
}

sub fai2norm
{
	(my $index, my $plotCircosPath, my $fai) = @_;
	my %index;
	open(INDEX, "$index")||die $!;
	while(<INDEX>)
	{
		chomp;
		my @data = split(/\t/, $_);
		if($data[1] =~ /chr/)
		{
			$index{$data[0]} = $data[1];
		}
		else
		{
			$index{$data[0]} = "chr".$data[1];
		}
	}
	close INDEX;
	open(IN, "$fai")||die $!;
	open(OUT, ">$plotCircosPath/circos_coverage/$kary.fa.fai")||die $!;
	while(<IN>)
	{
		chomp;
		my @data = split(/\t/, $_);
		if($index{$data[0]})
		{
			$data[0] = $index{$data[0]};
			print OUT join("\t", @data[0..$#data], "\n");
		}
		else
		{
			next;
		}
	}
	close IN;
	close OUT;
}

sub coverage_circRNA
{
	(my $kary, my $plotCircosPath, my $sampleName) = @_;
	my $colour = ['vlorange', 'vlyellow', 'vlgreen', 'vlblue'];
	my $outer = ["1.00", "0.88", "0.76", "0.64"];
	my $inner = ["0.88", "0.76", "0.64", "0.52"];
	my @first6elements;
	if(@$sampleName >= 4)
	{
		$first6elements[0] = $$sampleName[0];
		$first6elements[1] = $$sampleName[1];
		$first6elements[2] = $$sampleName[2];
		$first6elements[3] = $$sampleName[3];
		shift @$sampleName;
		shift @$sampleName;
		shift @$sampleName;
		shift @$sampleName;
		if (@$sampleName != 0)
		{
			&coverage_circRNA($kary, $plotCircosPath, $sampleName);
		}
	}
	else
	{
		@first6elements = @$sampleName;
	}
	my $lineFir6Element = join("_", @first6elements);
	my $fileName = "$lineFir6Element"."_coverage.conf";
	open(OUT, ">$plotCircosPath/circos_coverage/$fileName")||die $!;
	print OUT "show_scatter = yes\nshow_line = yes\nshow_histogram = yes\nshow_heatmap = yes\nshow_tile = yes\nshow_highlight = yes\nshow_link = yes\nshow_text = yes\nuse_rules = yes\n<<include colors_fonts_patterns.conf>>\n<<include ideogram.conf>>\n<<include ticks.conf>>\n\n<image>\n<<include etc/image.conf>>\n</image>\n\nkaryotype = $plotCircosPath/circos_coverage/$kary.genome.txt\nchromosomes_units = 1000000\nchromosomes_display_default = yes\n\n<plots>\n\nshow = no\n";
	my $i = 0;
	foreach my $sample(@first6elements)
	{
		print OUT "<plot>\nshow = conf(show_histogram)\ntype = histogram\nfile = $plotCircosPath/circos_coverage/${sample}.out.cov\norientation = out\nthickness = 1\nstroke_thickness=0\nfill_under = yes\nextend_bin = no\nr0 = $$inner[$i]r\nr1 = $$outer[$i]r\nmax_gap = 5u\ncolor = $$colour[$i]\n<rules>\n<rule>\ncondition = var(id) eq \"1\"\nfill_color = $$colour[$i]\ncolor = $$colour[$i]\nz = 10\n</rule>\n<rule>\ncondition = var(id) eq \"2\"\nfill_color = red\ncolor = red\nthickness = 1\nz = 20\n</rule>\n</rules>\n</plot>\n\n";
		$i += 1;
	}
	print OUT "<plot>\nshow         = conf(show_text)\ntype = text\nfile = $plotCircosPath/circos_coverage/${lineFir6Element}_sample_name\nlabel_font = bold\nlabel_size = 30p\nr0         = 0.05r\nr1         = 0.25r\nshow_links = no\n</plot>\n</plots>\n<<include etc/housekeeping.conf>>\n";
	close OUT;
}



my @Samples = split(" ", $samples);
my $sample = \@Samples;
my @allSamples1 = @$sample;
my @allSamples2 = @$sample;
my @allSamples3 = @$sample;
if($^O eq "linux")
{
	if($type eq "RNA")
	{
		mkdir("$plotCircosPath/circos_coverage");
		if($chrIndex)
		{
			&fai2norm($chrIndex, $plotCircosPath, $fai);
			system("cp $covList/*genome.cov $plotCircosPath/circos_coverage");
			my $samples2 = \@allSamples2;
			&sampleCoverageFile_index($chrIndex, $samples2);
		}
		else
		{
			system("cp $fai $plotCircosPath/circos_coverage");
			system("mv $plotCircosPath/circos_coverage/*fai $plotCircosPath/circos_coverage/$kary.fa.fai");
			system("cp $covList/*genome.cov $plotCircosPath/circos_coverage");
			my $samples2 = \@allSamples2;
			&sampleCoverageFile($samples2);
		}
		
		my $samples1 = \@allSamples1;
		&coverage($kary, $plotCircosPath, $samples1);
		my $samples3 = \@allSamples3;
		&fai2genomeFile($kary);
		&name_conf($samples3);
		&other_scripts;
	}
	elsif($type eq "circRNA")
	{
		mkdir("$plotCircosPath/circos_coverage");
		if($chrIndex)
		{
			&fai2norm($chrIndex, $plotCircosPath, $fai);
			system("cp $covList/*cov.txt $plotCircosPath/circos_coverage");
			my $samples2 = \@allSamples2;
			&sampleCoverageFile_index_circRNA($chrIndex, $samples2);
		}
		else
		{
			system("cp $fai $plotCircosPath/circos_coverage");
			system("mv $plotCircosPath/circos_coverage/*fai $plotCircosPath/circos_coverage/$kary.fa.fai");
			system("cp $covList/*cov.txt $plotCircosPath/circos_coverage");
			my $samples2 = \@allSamples2;
			&sampleCoverageFile_circRNA($samples2);
		}
		
		my $samples1 = \@allSamples1;
		&coverage_circRNA($kary, $plotCircosPath, $samples1);
		my $samples3 = \@allSamples3;
		&fai2genomeFile($kary);
		&name_conf_circRNA($samples3);
		&other_scripts;
	}
	else
	{
		exit "Please set the type of circos plot using the flag --type|T <RNA|circRNA>.\n";
	}
}
else
{
	print "The program is suitable for Linux platform only.\n";
	exit;
}
