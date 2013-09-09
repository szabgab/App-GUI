package App::Power::CLI;
use Moo;
use MooX::late;

use JSON::Tiny;
use Path::Tiny qw(path);

extends 'App::Power::App';

has data => (is => 'rw', isa => 'HashRef', default => sub { {} } );

our $VERSION = 0.01;


# TODO option file   should be required => 1 for CLI

sub run {
	my ($self) = @_;

	$self->load_file;
	$self->execute;

	my $regex = $self->data->{regex};
	my $root  = $self->data->{file};

	if (open my $fh, '<', $root) {
		while (my $line = <$fh>) {
			if ($line =~ /$regex/) {
				print $line;
			}
		}
		close $fh;
	}
}

sub print_str {
	my ($self, $str) = @_;

	print $str;
}


sub set_data {
	my ($self, $data) = @_;
	$self->data($data);
}

sub _error {
	my ($self, $format, @args) = @_;
	printf STDERR $format, @args;
}
sub clean_screen {
	my ($self) = @_;
	print "\n" x 5;
}


1;

