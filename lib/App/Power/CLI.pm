package App::Power::CLI;
use Moo;
use MooX::late;
use MooX::Options;

use JSON::Tiny;
use Path::Tiny qw(path);

our $VERSION = 0.01;

my $FORMAT = 1;

option file   => (is => 'rw', isa => 'Str', format => 's', required => 1);

sub run {
	my ($self) = @_;

	# _load_file
	my $file = $self->file;
	my $json  = JSON::Tiny->new;
	my $code = $json->decode(path($file)->slurp);
	if (not defined $code->{format} or $code->{format} ne $FORMAT) {
		$self->_error('Invalid format');
		return;
	}
	
	my $regex = $code->{regex};
	my $root  = $code->{file};

	# run_pressed
	if (open my $fh, '<', $root) {
		while (my $line = <$fh>) {
			if ($line =~ /$regex/) {
				print $line;
			}
		}
		close $fh;
	}
}

sub _error {
	my ($self, $format, @args) = @_;
	printf STDERR $format, @args;
}

1;
 
