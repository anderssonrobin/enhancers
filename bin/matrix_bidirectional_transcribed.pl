#!/usr/bin/perl

# matrix_bidirectional_transcribed.pl
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

# utility script taking two expression matrices (arguments 1 and 2) and a start column (argument 3)
# that checks if a bidirectional loci is bidirectionally transcribed in at least one library

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

	my $hit = 0;
	for (my $i=$datastart; $i<@fields1; $i++)
	{
		next if ($fields1[$i] eq "NA" || $fields2[$i] eq "NA");
		if ($fields1[$i] > 0 && $fields2[$i] > 0)
		{
			$hit = 1;
			last;
		}
	}
	if ($hit)
	{
		print "1\n";
	}
	else
	{
		print "0\n";
	}
}
close(ONE);
close(TWO);
