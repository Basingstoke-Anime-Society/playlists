#!/usr/bin/perl
use strict;
use warnings;


# the exported settings
#our $local_basepath_cyg;
#our @amv_include;
#our @amv_exclude;

our $remote_targetpath_cyg;

#our $remotepath;
#our $remotesubstitute;

our $do_dropbox = 0;


#  read settings
sub LoadSettings {
	# default settings
	my %properties;
	$properties{"remote.targetpath"} = "/mnt/z/";
	$properties{"remote.dropbox"} = "/mnt/z/Dropbox/";

	# read in standard settings
	if (-e "bas.properties") {
		open(PROPERTIES, "<bas.properties");
		while (<PROPERTIES>) {
			if ($_ =~ /([^=]+)=(.+)/) {
				$properties{$1} = $2;
			}
		}
		close(PROPERTIES);
	}
	
	#$local_basepath_cyg = $properties{"local.basepath"};
	#@amv_include = split /;/, $properties{"amv.basepath"};
	#@amv_exclude = split /;/, $properties{"amv.exclude"};
	
	$remote_targetpath_cyg = $properties{"remote.targetpath"};
	
	my $remotesettings = "${remote_targetpath_cyg}bas.properties";
	if (-e $remotesettings) {
		open(REMOTE, "<$remotesettings");
		my %remote;
		while (<REMOTE>) {
			if ($_ =~ /([^=]+)=(.+)/) {
				$remote{$1} = $2;
			}
		}
		close(REMOTE);
		
		# read in remote settings
	}*/
}

LoadSettings();

sub ReadPlaylist {
	my ($playlistpath) = @_;
}

sub win2cyg {
	my ($path) = @_;
	$path =~ s/^(\w):/\/cygdrive\/\l$1/;
	return $path;
}

sub cyg2win {
	my ($path) = @_;
	$path =~ s/^\/cygdrive\/(\w)/\u$1:/;
	return $path;
}


1;