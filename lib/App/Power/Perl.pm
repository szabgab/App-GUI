package App::Power::Perl;
use 5.010;

use Moo;
use MooX::late;
use JSON::Tiny;
use Path::Tiny qw(path);

use Prima qw(
	Application
	Buttons
	Edit
	FileDialog
	InputLine
	Label
	MsgBox
);

our $VERSION = 0.01;

my $FORMAT = 1;

has file   => (is => 'rw', isa => 'Str');

has output => (is => 'rw', isa => 'Prima::Edit');
has root   => (is => 'rw', isa => 'Prima::InputLine');
has regex  => (is => 'rw', isa => 'Prima::InputLine');

my $welcome = <<"END_WELCOME";
Welcome to the Power Perl v$VERSION

Select a text file using Editor/Select file
and the press the "Run" button.
END_WELCOME

sub run {
	my ($self) = @_;

	my $main = Prima::MainWindow->new(
		menuItems => [
			[ '~File' => [
					[ '~Open', 'Ctrl-O', '@O', sub { $self->open_file(@_) } ],
					[ '~Save', 'Ctrl-S', '@S', sub { $self->save_file(@_) } ],
					[ 'Save As',               sub { $self->save_file_as(@_) } ],
					[],
					[ '~Exit', 'Alt-X',  '@X', sub { exit } ],
				],
			],
			[ '~Editor' => [
					[ 'Select File',  sub { $self->select_file(@_) } ],
					#[ 'Filter lines', sub { $self->enter_filter(@_) } ],
				],
			],
			[],
			[ '~Help' => [
					[ '~About', \&show_about ],
				],	
			],
		],
		text   => 'Power Perl',
		size   => [1000, 800], # width, height
		#origin => [0, 100],  # left, bottom, at least on OSX it defaults to the left top corner
	);

	my $top = $main->insert( Widget =>
		pack => { side => 'top', fill => 'x', padx => 0, pady => 0},
		backColor => cl::White,
		height => 45,

	);

	$top->insert( Label =>
		text   => 'File:',
		pack => { side => 'left', padx => 0, pady => 0},
		#origin => [0, 0],
	);

	$self->root( $top->insert( InputLine =>
		text        => '',
		pack => { side => 'left',  padx => 0, pady => 0},
		#origin      => [0, 0],
		#centered    => 1,
		width       => 300,
	#	firstChar   => 10,
		#alignment   => ta::Center,
		#font        => { size => 18, },
		#growMode    => gm::GrowHiX,
		#buffered    => 1,
		borderWidth => 3,
		#autoSelect  => 0,
	));

	$top->insert( Label =>
		text   => 'Regex:',
		pack => { side => 'left', padx => 0, pady => 0},
	);

	$self->regex( $top->insert( InputLine =>
		text        => '',
		pack => { side => 'left',  padx => 0, pady => 0},
		#origin      => [0, 0],
		#centered    => 1,
		width       => 300,
	#	firstChar   => 10,
		#alignment   => ta::Center,
		#font        => { size => 18, },
		#growMode    => gm::GrowHiX,
		#buffered    => 1,
		borderWidth => 3,
		#autoSelect  => 0,
	));

	my $btn = $top->insert( Button =>
		pack => { side => 'left',  padx => 0, pady => 0},
#		origin   => [0, 0],
		text     => 'Run', 
		pressed  => 0,
		onClick  => sub { $self->run_pressed(@_) },
	);
	# TODO how can we set the height of the $top based on the height of the button in it?
	# which was 36 on OSX
	# $top->height($btn->height + 5);
	
	
	$self->output( $main->insert( Edit =>
		pack => { side => 'bottom', fill => 'both', expand => 1, },
		readOnly => 1,
		text => $welcome,
	));
	

	Prima->run;
}

sub select_file {
	my ($self, $main, $c) = @_;

	my $open = Prima::OpenDialog-> new(
		text => 'Select a file',   # the title of the window
		filter => [
			['All' => '*'],
			['Perl modules' => '*.pm'],
		],
		# TODO: The button should not read 'Open' but 'Select'
	);

	# Experiement to creat a button that is like an OpenDialog but
	# say 'Select' instead of 'Open'
	#my $open = Prima::FileDialog-> new(
	#	text => 'Select a file',   # the title of the window
	#	openMode => 1,
	#	filter => [
	#		['Perl modules' => '*.pm'],
	#		['All' => '*']
	#	],
	#	multiSelect => 1,
	#);
	if ($open->execute) {
		#say "File selected " . $open->fileName;
		$self->root->text( $open->fileName );
	}
}


sub show_about {
	my ($main, $c) = @_;
	Prima::MsgBox::message_box( 'About Power Perl',
		"Power Perl v$VERSION\nHacked together by Gabor Szabo in 2013.", mb::Ok);
}

sub run_pressed {
	my ($self, $button) = @_;

	my $file = $self->root->text;
	if ($file) {
		if (open my $fh, '<', $file) {
			my $regex = $self->regex->text // '';
			my $output = $self->output;
			$output->text('');
			# TODO: Async read?
			while (my $line = <$fh>) {
				if ($line =~ /$regex/) {
					$output->insert_text($line . "\n"); # TODO why do we have to add extra newlines?
				}
			}
			close $fh;
		} else {
			$self->_error("Could not open file '%s'. Error: '%s'", $file, $!);
		}
	} else {
		$self->_error("No file selected");
	}
}

#sub enter_filter {
#	my ($self, $main, $c) = @_;
#
#	my $regex = $self->code->{regex} // '';
#	while (1) {
#		$regex = Prima::MsgBox::input_box( 'Enter Perl regex', 'Filter:', $regex);
#		if (defined $regex) {
#			eval "qr/$regex/";
#			if ($@) {
#				$self->_error("Invalid regex $@");
#			} else {
#				last;
#			}
#		} else {
#			last;
#		}
#	}
#	if (defined $regex) {
#		$self->code->{regex} = $regex;
#	}
#}

sub _error {
	my ($self, $format, @args) = @_;

	my $msg = sprintf($format, @args);
	#say $msg;
	Prima::MsgBox::message_box( 'Error', $msg, mb::Ok);
}

sub open_file {
	my ($self) = @_;

	my $open = Prima::OpenDialog-> new(
		filter => [
			['PP JSON' => '*.json'],
			['All' => '*'],
		],
	);

	if ($open->execute) {
		$self->_load_file($open->fileName);
		$self->file($open->fileName);
	}
}

sub _load_file {
	my ($self, $file) = @_;

	my $json  = JSON::Tiny->new;

	my $code = $json->decode(path($file)->slurp);
	# TODO we should probably check if all the parts of the
	# format are correct (e.g. the regext is eval-able etc.)
	# We might also want to make some security checks here!
	if (defined $code->{format} and $code->{format} eq $FORMAT) {
		$self->regex->text($code->{regex});
		$self->root->text($code->{file});
	} else {
		$self->_error('Invalid format');
	}
}

sub _get_file {
	my ($self) = @_;

	my $save = Prima::SaveDialog-> new(
		filter => [
			['PP JSON' => '*.json'],
			['All' => '*'],
		],
	);

	if ($save->execute) {
		$self->file($save->fileName);
	}
}

sub save_file_as {
	my ($self) = @_;

	$self->_get_file;

	$self->save_file;
}

sub save_file {
	my ($self) = @_;

	my $file = $self->file;

	if (not $file) {
		$self->_get_file;
		$file = $self->file;
	}

	if ($file) {
		my $json  = JSON::Tiny->new;
		my $code = { format => $FORMAT };
		$code->{file} = $self->root->text;
		$code->{regex} = $self->regex->text;
		my $bytes = $json->encode( $code );
		if (open my $fh, '>:encoding(UTF-8)', $file) {
			print $fh $bytes;
			close $fh;
		}
	}
}

1;


