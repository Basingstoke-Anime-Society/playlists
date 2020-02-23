#!/usr/bin/perl
use strict;
use warnings;
#use diagnostics;
require Encode;
use File::Copy;
use File::Path;


require "bassettings.pl";
#our $local_basepath_cyg;
#our $remote_targetpath_cyg;

our $origin = "D:\Anime"
our $destination = "C:\Users\marcu\Google Drive\Anime Society Playlists"



our $do_dropbox;
our $weekname;

# subroutine to copy a file
sub CopyFile {

	my ($fromfile, $tofile, $second) = @_;
		
	my $copyfromfile = $fromfile;
	$copyfromfile =~ s/\\/\//g;
	$copyfromfile =~ s/[Cc]:\//\/cygdrive\/c\//;
	$copyfromfile =~ s/[Dd]:\//\/cygdrive\/d\//;
	
	# if the original file isn't there, give up
	unless (-e $copyfromfile) {
		# print "Missing file: $copyfromfile\n";
		return;
	}
	
	my $copytofile = $tofile;
	$copytofile =~ s/\\/\//g;
	$copytofile =~ s/Z:/\/cygdrive\/z/;
	
	my $filenamebase = $fromfile;
	my $extension = "";
	if ($fromfile =~ m/^(.*)\.(\w+)$/) {
		$filenamebase = $1;
		$extension = $2;
		$extension = lc($extension);
		# print "$extension\n";
	}
	
	# make the directory for it if necessary
	my $copytopath = $copytofile;
	$copytopath =~ s/\/[^\/]+$//;
	unless (-e $copytopath) {
		print "Making directory $copytopath\n";
		mkpath($copytopath) or die "Failed to create directory: $!";
	}
	
	#  report the file name
	print "$tofile";
	
	# if this is an AVISynth file, also copy any associated files
	if ($extension eq "avs") {
		print("\n");
		local $/ = "\n";
		open (AVISYNTH, "<$copyfromfile");
		open (AVISYNTHTO, ">$copytofile");
		for (<AVISYNTH>) {
			my $line = $_;
			chomp($line);
			# print "[avs] $line\n";
			if ($line =~ m/^(.*)(AVISource|DirectShowSource)\(\"(.*)"\)(.*)$/i) {
				my $pre = $1;
				my $command = $2;
				my $srcfile = $3;
				my $post = $4;
				# keep the named src file as relative address if necessary
				my $linkto = $srcfile;
				$linkto =~ s/[Cc]:[\\\/]Users[\\\/]Marcus[\\\/]Documents/Z:/g;
				# if this is a relative address, prepend the path to it
				unless ($srcfile =~ m/\\/) {
					my $frompath = $fromfile;
					$frompath =~ s/[^\\]+$//;
					$srcfile = $frompath . $srcfile;
				}
				my $copyto = $srcfile;
				$copyto =~ s/[Cc]:[\\\/]Users[\\\/]Marcus[\\\/]Documents/Z:/g;
				&CopyFile($srcfile, $copyto);
				print AVISYNTHTO "$pre$command(\"$linkto\")$post";
			} else {
				print AVISYNTHTO "$line\n";
			}
		}
		close (AVISYNTH);
		close (AVISYNTHTO);
	} else {
		# copy the file
		my $exists = -e $copytofile;
		if ($exists) {
			my $copytolen = -s $copytofile;
			my $copyfromlen = -s $copyfromfile;
			if ($copytolen != $copyfromlen) {
				$exists = 0;
			}
		}
		unless ($exists) {
			if (-e $copyfromfile) {
				unless ($copytofile eq $copyfromfile){
					print("\n");
					copy($copyfromfile, $copytofile) or die "Failed to copy: $!";
				} else {
					print(" (bad name)\n");
				}
			} else {
				print(" (not found)\n");
			}
		} else {
			print(" (exists)\n");
		}
	}
	
	# also copy any subtitle files
	unless ($second) {
		my $assfile = "$filenamebase.ass";
		my $subfile = "$filenamebase.sub";
		my $idxfile = "$filenamebase.idx";
		
		my $assfileto = $assfile;
		$assfileto =~ s/[Cc]:[\\\/]Users[\\\/]Marcus[\\\/]Documents/Z:/g;
		&CopyFile($assfile, $assfileto, 1);
	
		my $subfileto = $subfile;
		$subfileto =~ s/[Cc]:[\\\/]Users[\\\/]Marcus[\\\/]Documents/Z:/g;
		&CopyFile($subfile, $subfileto, 1);
	
		my $idxfileto = $idxfile;
		$idxfileto =~ s/[Cc]:[\\\/]Users[\\\/]Marcus[\\\/]Documents/Z:/g;
		&CopyFile($idxfile, $idxfileto, 1);
	}

	# if enabled, also copy to Dropbox
	if ($do_dropbox && ($fromfile =~ m/[\\\/]Anime[\\\/]/) && !($tofile =~ m/Dropbox/) && !($fromfile =~ m/Playlists[\\\/]Titles/)) {
		my $dropbox_file = $fromfile;
		$dropbox_file =~ s/[Cc]:[\\\/]Users[\\\/]Marcus[\\\/]Documents([\\\/]Anime)?/\/cygdrive\/z\/Dropbox\/$weekname/g;
		$dropbox_file =~ s/\\/\//g;

		$dropbox_file =~ m/^(.*)[\\\/]/;
		my $dropbox_folder = $1;
		unless (-e $dropbox_folder) {
			print("Dropbox: Making directory $dropbox_folder\n");
			mkpath($dropbox_folder) or die "Failed to create directory: $!";
		}

		print("Dropbox: $dropbox_file\n");
		&CopyFile($fromfile, $dropbox_file);
	}
}


# open a file in the Playlists folder with the given name
my $filename = $ARGV[0];
my $fullfilename = "/cygdrive/d/Anime/Playlists/$filename";
$weekname = $filename;
$weekname =~ s/\.zpl//;
print("Week of $weekname\n");
print("$fullfilename\n");
open(PLAYLIST, "<$fullfilename");
# discard the first two bytes as they contain the UCS-2 BOM
read(PLAYLIST, my $nothing, 2);
# read the rest of the file as UCS-2 little-endian
binmode(PLAYLIST, ":encoding(ucs2le)");

# make the target file for it to write into
unless (-e "/cygdrive/z/Anime") {
	mkpath("/cygdrive/z/Anime") or die "Failed to create directory: $!";
}
unless (-e "/cygdrive/z/Anime/Playlists") {
	mkpath("/cygdrive/z/Anime/Playlists") or die "Failed to create directory: $!";
}
$filename =~ /(.*).zpl/;
open (ZPLAYLIST, ">/cygdrive/z/Anime/Playlists/$1.zpl");
open (MPLAYLIST, ">/cygdrive/z/$1.m3u");

print MPLAYLIST "#EXTM3U\n";

# read the lines of the file
$/ = "\r\n";  # it's a windows file being read under Cygwin, so we need to remove the other half of the newline from end of the entry
my $fromfile = "";
my $tofile = "";
my $dur = 0;
while (<PLAYLIST>) {
	my $line = $_;
	chomp($line);
	# chop($line);
	print "line: " . $line . "\n";
	if ($line =~ m/^nm=(.*)$/) {
		$fromfile = $1;
		$fromfile =~ s/C:\\Users\\Marcus\\Documents/D:/;
		$tofile = $fromfile;
		$tofile =~ s/C:\\Users\\Marcus\\Documents/Z:/;
		$tofile =~ s/D:/Z:/;
		print "found nm: " . $fromfile . "\n";
	} elsif ($line =~ /^dr=(\d+)$/) {
		$dur = $1;
		print ZPLAYLIST "$line\n";
		print "found dr: " . $dur . "\n";
	} elsif ($line eq "br!") {
		print "found br: " . $fromfile . "\n";
		unless ($fromfile eq "") {
			print "COPY $fromfile -> $tofile\n";
			# write the replacement line to the playlist
			$fromfile =~ m/[\\\/]([^\\\/]+)(\.[^\\\/.]*)?$/;
			my $name = $1;
			$name =~ s/\s*-\s*/ /;
			print ZPLAYLIST "nm=$tofile\n";
			print ZPLAYLIST "$line\n";
			print MPLAYLIST "#EXTINF:$dur,$name\n";
			print MPLAYLIST "$tofile\n";
			&CopyFile($fromfile, $tofile);
			
			$fromfile = "";
			$tofile = "";
			$dur = 0;
		} else {
			print "Skipping entry!\n";
		}
	} else {
		print ZPLAYLIST "$line\n";
		print "Unknown line!\n";
	}
}

close (PLAYLIST);
close (ZPLAYLIST);
close (MPLAYLIST);
print "done\n";