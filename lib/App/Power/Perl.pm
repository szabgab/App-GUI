package App::Power::Perl;
use 5.010;
use Moo;
use MooX::late;

use Prima qw(Application Buttons InputLine Label MsgBox FileDialog Edit);

our $VERSION = 0.01;

has output => (isa => 'Prima::Edit', is => 'rw');
has code   => (isa => 'HashRef', is => 'rw', default => sub { {} } );

my $welcome = <<"END_WELCOME";
Welcome to the Power Perl v$VERSION

Select a text file using Editor/Select file
and the press the "Run" button.
END_WELCOME

sub run {
	my ($self) = @_;

	my $w = Prima::MainWindow->new(
		menuItems => [
			[ '~File' => [
					[ '~Exit', 'Alt-X', '@X', sub { exit } ],
				],
			],
			[ '~Editor' => [
					[ 'Select File', sub { $self->select_file(@_) } ],
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

	$self->output( $w->insert( Edit =>
		pack => { fill => 'both', expand => 1, },
		readOnly => 1,
		text => $welcome,
	));
	
#	$w->insert( Label =>
#		text   => 'URL',
#		origin => [0, 300],
#	);
#	
#	my $input = $w->insert( InputLine =>
#		text        => '',
#		origin      => [50, 300],
#		#centered    => 1,
#		width       => 300,
#	#	firstChar   => 10,
#		#alignment   => ta::Center,
#		#font        => { size => 18, },
#		#growMode    => gm::GrowHiX,
#		#buffered    => 1,
#		borderWidth => 3,
#		#autoSelect  => 0,
#	);
	
	my $btn = $w->insert( Button =>
		origin   => [0, 0],
		text     => 'Run', 
		pressed  => 0,
		onClick  => sub { $self->run_pressed(@_) },
	);
	
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
		$self->code->{file} = $open->fileName;
	}
}


sub show_about {
	my ($main, $c) = @_;
	Prima::MsgBox::message_box( 'About Power Perl',
		"Power Perl v$VERSION\nHacked together by Gabor Szabo in 2013.", mb::Ok);
}

sub run_pressed {
	my ($self, $button) = @_;

	my $code = $self->code;
	if ($code->{file}) {
		if (open my $fh, '<', $code->{file}) {
			my $output = $self->output;
			$output->text('');
			# TODO: Async read?
			while (my $line = <$fh>) {
				$output->insert_text($line . "\n"); # TODO why do we have to add extra newlines?
			}
			close $fh;
		} else {
			$self->_error("Could not open file '%s'. Error: '%s'", $code->{file}, $!);
		}
	} else {
		$self->_error("No file selected");
	}
}

sub _error {
	my ($self, $format, @args) = @_;
	my $msg = sprintf($format, @args);
	say $msg;
}

1;


