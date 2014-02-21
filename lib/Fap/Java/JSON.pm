package Fap::Java::JSON;
use Fap;
use base qw(Fap);
use JSON::XS;
use Inline (
	JAVA=>"STUDY",
	DIRECTORY=>Fap->path_to("res/data/inline"),
	J2SDK=>"/usr/java/latest",
        EXTRA_JAVA_ARGS=>" -cp ".Fap->build_java_classpath(),
	STUDY=>[qw(
		org.json.JSONObject
		org.json.JSONArray
	)],
);
use Inline::Java qw(coerce);

sub encode {
	my ($class,$object) = @_;

	my $jsont = JSON::XS->new->encode($object);
	my $json = $class->java("org.json.JSONObject")->new($jsont);
	return $json;
}

sub decode {
	my ($class,$object) = @_;

	return JSON::XS->new->decode($object->toString());
}
				



1;
