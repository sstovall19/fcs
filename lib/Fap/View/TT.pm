package Fap::View::TT;
use strict;
use Template;
use Fap;

sub new {
    my ( $class, %args ) = @_;

    my $self = bless {
        output => "",
        error  => undef,
    }, $class;

    $args{additional_options} ||= {};
    $args{paths}||=[];

    $self->{engine} = Template->new( {
            POST_CHOMP   => 1,
            TRIM         => 1,
            PRE_CHOMP    => 1,
            INCLUDE_PATH => [map { ( $_ =~ /^\// ) ? $_ : Fap->path_to("$_") } @{$args{paths}||()} , Fap->path_to("templates/tt")],
            RECURSIVE    => 1,
       	    COMPILE_DIR  => Fap->path_to("res/data/template_cache"),
            %{ $args{additional_options} || () },
        } );

    return $self;
}
sub add_paths {
	my ($self,@paths) = @_;
}

sub process {
    my ( $self, $template, $vars ) = @_;

    my $out;
    $self->{engine}->process( $template, $vars, \$out );
    $self->{error} = $self->{engine}->error();
    return $out||$self->{error};
}

1;
__DATA__
