#!/usr/bin/perl

# matrix_directionality.pl
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

# utility script for calculating the directionality for each bidirectional loci
# over each library given the minus strand expression (argument 1) and plus strand expression
# (argument 2) starting at a specified column (argument 3)

use strict;

open(ONE, $ARGV[0]) or die;
open(TWO, $ARGV[1]) or die;
my $datastart = $ARGV[2];

my @fields1 = ();
my @fields2 = ();
my $line;

while (<ONE>)
{
	chomp;
	@fields1 = split(/\t/, $_);
	$line = <TWO>;
	chomp($line);
	@fields2 = split(/\t/, $line);

	for (my $i=$datastart; $i<@fields1; $i++)
	{
		$fields1[$i] = (($fields1[$i] eq "NA") || ($fields1[$i] + $fields2[$i]) == 0) ? "NA" : ($fields1[$i] - $fields2[$i]) / ($fields1[$i] + $fields2[$i]);
	}
	print $fields1[$datastart];
	for (my $i=($datastart+1); $i<@fields1; $i++)
	{
		print "\t".$fields1[$i];
	}
	print "\n";
}
close(ONE);
close(TWO);
