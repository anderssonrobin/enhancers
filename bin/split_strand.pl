#!/usr/bin/perl

# split_strand.pl
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

# Utility script for splitting a bedfile (argument 1) into two bed files (arguments 2 and 3) according to strand

use strict;

open (IN, $ARGV[0]) or die;
open (PLUS, ">$ARGV[1]") or die;
open (NEG, ">$ARGV[2]") or die;

my @fields = ();

while (<IN>)
{
	chomp;
	@fields = split(/\t/,$_);
	if ($fields[5] eq "+")
	{
		print PLUS $_."\n";
	}
	else
	{
		print NEG $_."\n";
	}
}
close(IN);
close(PLUS);
close(NEG);
