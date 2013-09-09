package App::Power::App;
use Moo;
use MooX::late;
use MooX::Options;

option file   => (is => 'rw', isa => 'Str', format => 's');

1;

