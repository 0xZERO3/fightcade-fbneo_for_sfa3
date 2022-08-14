#!/usr/bin/perl -w

use strict;


my $Argv_OutFile;
my $Infile;
my $OutfileLoaders;
my $OutfileBuffers;

# Process command line arguments
for ( my $i = 0; $i < scalar @ARGV; $i++ ) {{

	# Output file
	if ( $ARGV[$i] =~ /^-o/i ) {
		if ( $ARGV[$i] =~ /^-o$/i ) {
			$i++;
			if ( $i < scalar @ARGV ) {
				$Argv_OutFile = $ARGV[$i];
			}
		} else {
			$ARGV[$i] =~ /(?<=-o)(.*)/i;
			$Argv_OutFile = $1;
		}
		next;
	}

	# Input file
	$Infile = $ARGV[$i];
}}

unless ( $Infile and $Argv_OutFile ) {
	die "Usage: $0 <input file> -o <output file>\n\n";
}

$OutfileLoaders = $Argv_OutFile . "_loaders.h";
$OutfileBuffers = $Argv_OutFile . "_buffers.h";

open( OUTFILELOADERS, ">$OutfileLoaders" ) or die "\nError: Couldn't open OUTPUT file $OutfileLoaders: $!";
open( OUTFILEBUFFERS, ">$OutfileBuffers" ) or die "\nError: Couldn't open OUTPUT file $OutfileBuffers: $!";

print "Generating $OutfileBuffers & $OutfileLoaders...\n";

# Generate optimized loaders and a buffers with the function names


my $infname;
my $gamename;
my $binbuf;
my $buffer;

chdir($Infile);
my @inffiles    = glob "*.inf";

foreach $infname (@inffiles) {
	$gamename = $infname;
	$gamename =~ s/\.inf$//;
	
	open( INFILE, $infname ) or die "\nError: Couldn't open INPUT file $Infile: $!";
	binmode(INFILE);
	my $size = -s $infname;
	$buffer = "";
	while(read(INFILE, $binbuf, 1)){
		$buffer = $buffer . sprintf("0x%02X, ",unpack("C",$binbuf));
	}
	$buffer =~ s/, $//;
	
	print OUTFILELOADERS "{\"detector\\\\" . $infname . "\", buffer_" . $gamename . ", " . $size . "},\n";
	print OUTFILEBUFFERS "unsigned char " . "buffer_" . $gamename . "[] = {" . $buffer . "};\n";
}

close( OUTFILELOADERS );
close( OUTFILEBUFFERS );
close( INFILE );
