#!/usr/bin/perl

# bed12_merge_pairs_dynamic.pl
#
# Robin Andersson (2014)
# andersson.robin@gmail.com
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# Utility script for merging pairs in a bed file (argument 1) that shares the same tag clusters

use strict;
use POSIX;
use List::Util qw[min max];

open(IN,$ARGV[0]) or die;

my @fields = ();
my $m;
my $p;
my %minusstart = ();
my %minusend = ();
my %plusstart = ();
my %plusend = ();
my %minustpm = ();
my %plustpm = ();

## Build hashes that holds the coordinates of TCs in pairs
my $line = <IN>;
chomp($line);
@fields = split(/\t/,$line);
$m = $fields[4];
$p = $fields[10];
$minusstart{$fields[3]} = $fields[1];
$plusstart{$fields[9]} = $fields[7];
$minusend{$fields[3]} = $fields[2];
$plusend{$fields[9]} = $fields[8];
$minustpm{$fields[3]} = $fields[4];
$plustpm{$fields[9]} = $fields[10];

my $chrom = $fields[0];

my $mstart;
my $mend;
my $pstart;
my $pend;
my @minuses = ();
my @pluses = ();

## Go through inferred pairs and merge if sharing the same tag cluster
while (<IN>)
{
	chomp;
	@fields = split(/\t/,$_);

	## Already observed tag cluster
	if (exists($minusstart{$fields[3]}) || exists($plusstart{$fields[9]}))
	{
		$m = max($m, $fields[4]);
		$p = max($p, $fields[10]);
		$minusstart{$fields[3]} = $fields[1];
		$plusstart{$fields[9]} = $fields[7];
		$minusend{$fields[3]} = $fields[2];
		$plusend{$fields[9]} = $fields[8];
		$minustpm{$fields[3]} = $fields[4];
		$plustpm{$fields[9]} = $fields[10];
	}
	## New tag cluster
	else
	{
		@minuses = keys %minusstart;
		@pluses = keys %plusstart;
		$mstart = $minusstart{$minuses[0]};
		$mend = $minusend{$minuses[0]};
		$pstart = $plusstart{$pluses[0]};
		$pend = $plusend{$pluses[0]};
		foreach my $key (@minuses)
		{
			$mstart = min($mstart, $minusstart{$key});
			$mend = max($mend, $minusend{$key});
		}
		foreach my $key (@pluses)
		{
			$pstart = min($pstart, $plusstart{$key});
			$pend = max($pend, $plusend{$key});
		}
		if ($pstart >= $mend)
		{
			my $center = floor(0.5*($mend-1+$pstart));
			print $chrom."\t".$mstart."\t".$pend."\t.\t".min($m,$p)."\t.\t".$center."\t".($center+1)."\t0,0,0\t2\t".($mend-$mstart).",".($pend-$pstart)."\t0,".($pstart-$mstart)."\n";
		}
		else
		{
			## Change mend, pstart, p, m
			my @mkeyssorted = sort { $minusend{$b} <=> $minusend{$a} } @minuses;
			my @pkeyssorted = sort { $plusstart{$a} <=> $plusstart{$b} } @pluses;
			while ($pstart < $mend)
			{
				my $prm = 0;
				my $mrm = 0;

				if ($minustpm{$mkeyssorted[0]} > $plustpm{$pkeyssorted[0]})
				{
					$prm = 1;
					if (@pkeyssorted < 2)
					{
						$prm = 0;
						if (@mkeyssorted > 1)
						{
							$mrm = 1;
						}
					}
				}
				else
				{
					$mrm = 1;
					if (@mkeyssorted < 2)
					{
						$mrm = 0;
						if (@pkeyssorted > 1)
						{
							$prm = 1;
						}
					}
				}

				## DEBUG, should not happen
				if (!$mrm && !$prm)
				{
					print STDERR $mstart."\t".$mend."\t".$pstart."\t".$pend."\n";
					last;
				}
				
				if ($prm)
				{
					##Change pstart, p
					$pstart = $plusstart{$pkeyssorted[1]};
					my $tmpp = $plustpm{$pkeyssorted[0]};
					my $tmp = shift(@pkeyssorted);
					if ($tmpp == $p)
					{
						$p = 0;
						foreach my $key (@pkeyssorted)
						{
							$p = max($p, $plustpm{$key});
						}
					}
				}
				
				if ($mrm)
				{
					## Change mend, m
					$mend = $minusend{$mkeyssorted[1]};
					my $tmpm = $minustpm{$mkeyssorted[0]};
					my $tmp = shift(@mkeyssorted);
					if ($tmpm == $m)
					{
						$m = 0;
						foreach my $key (@mkeyssorted)
						{
							$m = max($m, $minustpm{$key});
						}
					}
				}
			}
			my $center = floor(0.5*($mend-1+$pstart));
			print $chrom."\t".$mstart."\t".$pend."\t.\t".min($p,$m)."\t.\t".$center."\t".($center+1)."\t0,0,0\t2\t".($mend-$mstart).",".($pend-$pstart)."\t0,".($pstart-$mstart)."\n";
		}
		$m = $fields[4];
		$p = $fields[10];
		$chrom = $fields[0];
		%minusstart = ();
		%plusstart = ();
		%minusend = ();
		%plusend = ();
		$minusstart{$fields[3]} = $fields[1];
		$plusstart{$fields[9]} = $fields[7];
		$minusend{$fields[3]} = $fields[2];
		$plusend{$fields[9]} = $fields[8];
		$minustpm{$fields[3]} = $fields[4];
		$plustpm{$fields[9]} = $fields[10];
	}
}
@minuses = keys %minusstart;
@pluses = keys %plusstart;
$mstart = $minusstart{$minuses[0]};
$mend = $minusend{$minuses[0]};
$pstart = $plusstart{$pluses[0]};
$pend = $plusend{$pluses[0]};
foreach my $key (@minuses)
{
	$mstart = min($mstart, $minusstart{$key});
	$mend = max($mend, $minusend{$key});
}
foreach my $key (@pluses)
{
	$pstart = min($pstart, $plusstart{$key});
	$pend = max($pend, $plusend{$key});
}
if ($pstart >= $mend)
{
	my $center = floor(0.5*($mend-1+$pstart));
	print $chrom."\t".$mstart."\t".$pend."\t.\t".min($m,$p)."\t.\t".$center."\t".($center+1)."\t0,0,0\t2\t".($mend-$mstart).",".($pend-$pstart)."\t0,".($pstart-$mstart)."\n";
}
else
{
	## Change mend, pstart, p, m
	my @mkeyssorted = sort { $minusend{$b} <=> $minusend{$a} } @minuses;
	my @pkeyssorted = sort { $plusstart{$a} <=> $plusstart{$b} } @pluses;
	while ($pstart < $mend)
	{
		my $prm = 0;
		my $mrm = 0;
		
		if ($minustpm{$mkeyssorted[0]} > $plustpm{$pkeyssorted[0]})
		{
			$prm = 1;
			if (@pkeyssorted < 2)
			{
				$prm = 0;
				if (@mkeyssorted > 1)
				{
					$mrm = 1;
				}
			}
		}
		else
		{
			$mrm = 1;
			if (@mkeyssorted < 2)
			{
				$mrm = 0;
				if (@pkeyssorted > 1)
				{
					$prm = 1;
				}
			}
		}
		
		if (!$mrm && !$prm)
		{
			print STDERR $mstart."\t".$mend."\t".$pstart."\t".$pend."\n";
			last;
		}
		
		if ($prm)
		{
			##Change pstart, p
			$pstart = $plusstart{$pkeyssorted[1]};
			my $tmpp = $plustpm{$pkeyssorted[0]};
			my $tmp = shift(@pkeyssorted);
			if ($tmpp == $p)
			{
				$p = 0;
				foreach my $key (@pkeyssorted)
				{
					$p = max($p, $plustpm{$key});
				}
			}
		}
		
		if ($mrm)
		{
			## Change mend, m
			$mend = $minusend{$mkeyssorted[1]};
			my $tmpm = $minustpm{$mkeyssorted[0]};
			my $tmp = shift(@mkeyssorted);
			if ($tmpm == $m)
			{
				$m = 0;
				foreach my $key (@mkeyssorted)
				{
					$m = max($m, $minustpm{$key});
				}
			}
		}
	}
	my $center = floor(0.5*($mend-1+$pstart));
	print $chrom."\t".$mstart."\t".$pend."\t.\t".min($p,$m)."\t.\t".$center."\t".($center+1)."\t0,0,0\t2\t".($mend-$mstart).",".($pend-$pstart)."\t0,".($pstart-$mstart)."\n";	
}

close(IN);
