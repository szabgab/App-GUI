package App::Power::App;
use Moo;
use MooX::late;
use MooX::Options;

use Path::Tiny qw(path);

has FORMAT => (is => 'ro', default => 1);

option file   => (is => 'rw', isa => 'Str', format => 's');

sub load_file {
	my ($self) = @_;

	my $file = $self->file;

	my $json  = JSON::Tiny->new;

	my $code = $json->decode(path($file)->slurp);
	# TODO we should probably check if all the parts of the
	# format are correct (e.g. the regext is eval-able etc.)
	# We might also want to make some security checks here!
	if (not defined $code->{format} or $code->{format} ne $self->FORMAT) {
		$self->_error('Invalid format');
		return;
	}

	$self->set_data($code);
}


1;

