package App::Power::Perl;
use Moo;

use Prima qw(Application Buttons InputLine Label);


sub run {
	my ($self) = @_;

	my $w = Prima::MainWindow->new(
		menuItems => [
			[ '~File' => [
					[ '~Exit', 'Alt-X', '@X', sub { exit } ],
				]
			],
		],
		text   => 'Power Perl',
		size   => [400, 400],
		#origin => [0, 100],  # left, bottom, at least on OSX it defaults to the left top corner
	);
	
	$w->insert( Label =>
		text   => 'URL',
		origin => [0, 300],
	);
	
	my $input = $w->insert( InputLine =>
		text        => '',
		origin      => [50, 300],
		#centered    => 1,
		width       => 300,
	#	firstChar   => 10,
		#alignment   => ta::Center,
		#font        => { size => 18, },
		#growMode    => gm::GrowHiX,
		#buffered    => 1,
		borderWidth => 3,
		#autoSelect  => 0,
	);
	
	
	my $btn = $w->insert( Button =>
		origin   => [50,180],
		text     => 'Run', 
		pressed  => 0,
		onClick  => sub {
			my $self = shift;
			#say 'Button pressed ' . $input->text;
		},
	);
	
	Prima->run;
}


1;


