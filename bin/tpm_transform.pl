#!/usr/bin/perl -w

# tpm_transform.pl
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

# utility script for transforming the counts in a matrix (argument 1) into TPMs (tag per millions) according to the read counts given in a file (argument 2)

use strict;

open(MFILE, $ARGV[0]) or die;
open(CFILE, $ARGV[1]) or die;
my $datastart = $ARGV[2];

## Precalculate tpm multiplicand
my @tpm = ();
my $tpm = 0;
my $count;

while (<CFILE>)
{
	chomp;
	$tpm = (1e6) / $_;
    push(@tpm, $tpm);
}
close(CFILE);

my @fields = ();
## Transform each tagcount per TC to tpm
my $line = "";
while (<MFILE>)
{
    chomp;
    @fields = split(/\t/, $_);
    for (my $i = $datastart; $i < $datastart + @tpm; $i++)
    {
		$fields[$i] = $tpm[$i-$datastart] != 0 ? $fields[$i] * $tpm[$i-$datastart] : "NA";
    }
	print $fields[$datastart];
	for (my $i=($datastart+1); $i<@fields; $i++)
	{
		print "\t".$fields[$i];
	}
	print "\n";
}
close(MFILE);
