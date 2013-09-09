package App::Power::App;
use Moo;
use MooX::late;
use MooX::Options;

use Path::Tiny qw(path);
use Path::Iterator::Rule;

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

sub execute {
	my ($self) = @_;

	my $data = $self->data;

	if (not $data->{file}) {
		$self->_error("No file selected");
		return;
	}

	if (not -e $data->{file}) {
		$self->_error("Selected file '$data->{file}' does not exist.");
		return;
	}

	$self->clean_screen;

	if (-d $data->{file}) {
		my $rule = Path::Iterator::Rule->new;
		if (@{ $data->{glob_include} }) {
			$rule->name(@{ $data->{glob_include} });
		}

		# TODO check the validity of the size_limit format
		if ($data->{set_size_limit} and $data->{size_limit}) {
			$rule->size($data->{size_limit});
		}
		my $it = $rule->iter($data->{file});
		#my $it = path($data->{file})->iterator;
		while (my $file = $it->()) {
			$self->process_file($file);
		}
	} else {
			$self->process_file($data->{file});
	}
}

sub process_file {
	my ($self, $file) = @_;

	my $data = $self->data;
	my $regex = $data->{regex} // '';

	$self->print_str("$file\n\n");

	if (open my $fh, '<', $file) {
		# TODO: Async read using Prima::File!
		while (my $line = <$fh>) {
			if ($line =~ /$regex/) {
				next if $data->{result_selector} ne 'Lines';
				$self->print_str("$line\n"); # TODO why do we have to add extra newlines?
			}
		}
		close $fh;
	} else {
		$self->_error("Could not open file '%s'. Error: '%s'", $data->{file}, $!);
	}
}


1;

