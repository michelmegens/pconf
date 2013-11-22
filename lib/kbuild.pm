#!/usr/bin/perl -w

package kbuild;

use strict;
use warnings;
use IO::File;
use Cwd 'abs_path';
use File::Basename;
use PConf::Util;

use Data::Dumper;

use Exporter 'import';
our $VERSION = '1.00';
our @EXPORT = qw(kbuild_gen kbuild_gen_extra kbuild_add_option kbuild_add_ah_option);

use constant AH_TEMPLATE => 'templates/autoheader.in';
use constant KBUILD_TEMPLATE => 'templates/kbuild.in';

my $AH_TEMPLATE_IDENTIFIER = '@AH_DATA@';

# forward decl's

sub kbuild_gen_ah($$);
sub kbuild_add_option(\@$$);
sub kbuild_add_ah_option(\@$$);
sub kbuild_gen($);
sub kbuild_gen_extra($\@$\@);
sub kbuild_gen_ah($$);

#
# kbuild_add_option(@array, $option, $value)
#
sub kbuild_add_option(\@$$)
{
	my $arr_ref = $_[0]; # ref to the array
	my $option = $_[1];
	my $type = $_[2];

	push($arr_ref, "CONFIG_$option=$type\n");
}

#
# kbuild_add_ah_option(@array, $option, $value)
#
sub kbuild_add_ah_option(\@$$)
{
	my $arr_ref = $_[0]; # ref to the array.
	my $option = $_[1];
	my $value = $_[2];;

	push($arr_ref, "#define CONFIG_$option $value\n");
}

#
# kbuild_gen($kbuild_input)
#
sub kbuild_gen($)
{
	my $kbuild_file = $_[0];

	
}

#
# gen_kbuild($conf_out, @config_data, $ah_file, @autoheader_data)
#
sub kbuild_gen_extra($\@$\@)
{
	my ($conf_out, $conf_data_ref, $ah_file, $ah_data_ref) = @_;
	my @config_data = @{$conf_data_ref};
	my @ah_data = @{$ah_data_ref};

	#kbuild data
	my $kbuild_prefix = "#\n# DO NOT EDIT - generated by PConf.\n#\n\n";

	my $kfd = IO::File->new($conf_out, O_WRONLY | O_CREAT | O_TRUNC)
				or die 'Couldn\'t open the specified output file!';
	my $cfd = IO::File->new($conf_out, O_WRONLY | O_CREAT | O_TRUNC)
				or die 'Couldn\'t open the specified output file!';

	# print the .config file
	print $cfd $kbuild_prefix;
	print $cfd @config_data;

	# generate the autoheader file.
	kbuild_gen_ah($ah_file, pconf_array_to_string(@ah_data)); # ref, since we're in a lib.
	
	# close files and done!
	$kfd->close;
	$cfd->close;
}

#
# kbuild_gen_ah($ah_output, $ah_data)
#
sub kbuild_gen_ah($$)
{
	my ($ah_output, $ah_data) = @_;
	my $ah_input_file = dirname(abs_path($0)) . "/" . AH_TEMPLATE;
	
	my $afd = IO::File->new($ah_output, O_WRONLY | O_CREAT | O_TRUNC)
				or die 'Couldn\'t open the specified output file!';
	my $ah_in = IO::File->new($ah_input_file, O_RDONLY)
				or die "Can't open the specified input file: $ah_input_file!";

	my @ah_data_array = <$ah_in>;

	foreach my $line (@ah_data_array) {
		$line =~ s/$AH_TEMPLATE_IDENTIFIER/$ah_data/g;
	}

	print $afd @ah_data_array;

	$ah_in->close;
	$afd->close;
}

"1";
