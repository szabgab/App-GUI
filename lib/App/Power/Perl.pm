package App::Power::Perl;
use 5.010;

use Data::Dumper qw(Dumper);
use Moo;
use MooX::late;

extends 'App::Power::App';

use JSON::Tiny;
use Path::Tiny qw(path);

use Prima::noARGV; # to allow MooX::Options to handle @ARGV
use Prima qw(
	Application
	Buttons
	ComboBox
	Edit
	FileDialog
	InputLine
	Label
	MsgBox
);

our $VERSION = 0.01;

has output => (is => 'rw', isa => 'Prima::Edit');
has root   => (is => 'rw', isa => 'Prima::InputLine');
has regex  => (is => 'rw', isa => 'Prima::InputLine');
has result_selector => (is => 'rw', isa => 'Prima::ComboBox' );
has glob_include => (is => 'rw', isa => 'Prima::Edit' );
has set_size_limit => (is => 'rw', isa => 'Prima::CheckBox' );
has size_limit     => (is => 'rw', isa => 'Prima::InputLine');

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
		pack => { side => 'left', padx => 0, pady => 0 },
	);

	$self->regex( $top->insert( InputLine =>
		text        => '',
		pack => { side => 'left',  padx => 0, pady => 0 },
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

	$self->result_selector( $top->insert( 'ComboBox',
		text   => 'Files',
		items  => ['Files', 'Lines'],
		pack   => { side => 'left', padx => 0, pady => 0 },
		#style    => cs::DropDown,
	));
	$self->result_selector->style(cs::DropDown);


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


	my $top2 = $main->insert( Widget =>
		pack => { side => 'top', fill => 'x', padx => 0, pady => 0},
		backColor => cl::White,
		height => 90,
	);

	$self->glob_include( $top2->insert( Edit =>
		pack     => { side => 'left' },
		text     => '',
		readOnly => 0,
	));

	$self->set_size_limit( $top2->insert( CheckBox =>
		pack       => { side => 'left' },
		text       => 'Size limit',
		#backColor  => cl::White,
		selectable => 1,
		onClick    => sub {
			my ($checkbox) = @_;
			$self->size_limit->enabled( $checkbox->checked );
		},
	));

	$self->size_limit( $top2->insert( InputLine =>
		text        => '',
		pack        => { side => 'left',  padx => 0, pady => 0 },
		width       => 80,
		borderWidth => 3,
		enabled     => 0,
	));

	$self->output( $main->insert( Edit =>
		pack => { side => 'bottom', fill => 'both', expand => 1, },
		readOnly => 1,
		text => $welcome,
	));

	if ($self->file) {
		$self->load_file;
	}

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

sub clean_screen {
	my ($self) = @_;
	$self->output->text('');
}

sub run_pressed {
	my ($self, $button) = @_;
	$self->execute;
}

sub print_str {
	my ($self, $str) = @_;

	my $output = $self->output;
	$output->cursor_cend;
	$output->insert_text($str);
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
		$self->file($open->fileName);
		$self->load_file;
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
		my $data = $self->data;
		my $bytes = $json->encode( $data );
		if (open my $fh, '>:encoding(UTF-8)', $file) {
			print $fh $bytes;
			close $fh;
		}
	}
}


# collect all the configurable parameters from the GUI
#    to save in a file
#    or to use for a 'run'
sub data {
	my ($self) = @_;

	my %data = ( format => $self->FORMAT );
	$data{file} = $self->root->text;
	$data{regex} = $self->regex->text;
	$data{result_selector} = $self->result_selector->text;

	my $glob_include    = $self->glob_include->text;
	if ($glob_include and $glob_include =~ /\S/) {
		$data{glob_include} = [ grep { length } map { s/^\s+|\s+$//g; $_ } split /\n/, $glob_include ];
	} else {
		$data{glob_include} = [];
	}

	$data{set_size_limit} = $self->set_size_limit->checked ? 1 : 0;
	$data{size_limit} = $self->size_limit->text;

	return \%data;
}

sub set_data {
	my ($self, $data) = @_;

	$self->regex->text($data->{regex});
	$self->root->text($data->{file});
	$self->result_selector->text($data->{result_selector});
	$self->glob_include->text( join "\n", @{ $data->{glob_include} // [] } );
	$self->set_size_limit->checked( $data->{set_size_limit} );
	$self->size_limit->text( $data->{size_limit} );
	$self->size_limit->enabled( $data->{set_size_limit} );
}

1;


