#!/usr/bin/perl
# take fasta file as first parameter and string as second parameter
# this is to retrieve from a fasta file that is not a blastdb (or has bad headers)
# This will be memory intensive for a big database

use strict;
use warnings;
use Getopt::Long;

## USAGE STATEMENT
if (!defined($ARGV[0]) or $ARGV[0] eq 'help') {
die ("
Program: retrieve_from_fasta (retrieve sequences from FASTA file)
Version: 2014-09-16 (EJR)

Usage:   retrieve_from_fasta [options] FASTA_FILE

    -f file             retrieve list of sequences matching lines in a file
    -s string           retrieve all sequences containing stringin header

");
}
my $file_name = '';
my $string = '';

GetOptions (
            'f=s'           => \$file_name,
            's=s'           => \$string,
            );


# READ IN FASTA
my %fasta;
my $header;
while (my $line = <>) {
    chomp $line;
    if ($line =~ /^\>/) {
        $header = $line;
        $header =~ s/>//;
        $header =~ s/(.+?) .*/$1/;
        $fasta{"$header"}{'full'} = $line;
    } else {
        $fasta{"$header"}{'seq'} .= $line;
    }
}

#SEARCH FOR SINGLE STRING
if ($string) {
    foreach my $header (keys %fasta) {
        if ($header =~ /$string/) {
            print $fasta{"$header"}{'full'}, "\n";
            $fasta{"$header"}{'seq'} =~ s/(.{1,80})/$1\n/g;
            print $fasta{"$header"}{'seq'};
        }
    }
    exit(0);
}

#SEARCH FOR FILE OF STRINGS
my %list;
if ($file_name) {
    open(LIST, "$file_name") or die "Cannot open file:$!\n";
    while (my $line = <LIST>) {
        chomp $line;
        $list{$line} = 1;
    }

    foreach my $header (keys %fasta) {
        foreach my $item (keys %list) {
            if ($fasta{"$header"}{'full'} =~ /$item/) {
                print $fasta{"$header"}{'full'}, "\n";
                $fasta{"$header"}{'seq'} =~ s/(.{1,80})/$1\n/g;
                print $fasta{"$header"}{'seq'};
            }
        }
                #unless (defined($fasta{$item}{'full'})){print STDERR $item,"\n"}
                #print $fasta{$item}{'full'}, "\n";
                #$fasta{$item}{'seq'} =~ s/(.{1,80})/$1\n/g;
                #print $fasta{$item}{'seq'};
    }

    exit(0);
}

exit(0);
