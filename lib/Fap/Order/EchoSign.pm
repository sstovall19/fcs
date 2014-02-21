package Fap::Order::EchoSign;
BEGIN {
	use Fap;
	$ENV{CLASSPATH} = Fap->build_java_classpath;
};
use strict;
use base qw(Fap);
use Fap::Java::JSON;
use Inline (
        JAVA=>Fap->path_to("src/java/core-fsp/src/com/fonality/perl/EchoSign.java"),
	DIRECTORY=>Fap->path_to("res/data/inline"),
        J2SDK=>"/usr/java/latest",
	SHARED_JVM=>1,
        NAME=>"EchoSign",
        EXTRA_JAVA_ARGS=>" -cp ".Fap->build_java_classpath(),
        AUTOSTUDY=>1,
	STUDY=>[qw(java.util.HashMap org.json.JSONObject)],
);

sub send {
	my ($class,$order_group_id) = @_;
	my $ob = $class->java("com.fonality.perl.EchoSign")->new($order_group_id)->sendAgreement();
	return Fap::Java::JSON->decode($ob);
}

sub retrieve {
	my ($class,$order_group_id) = @_;
        my $ob = $class->java("com.fonality.perl.EchoSign")->new($order_group_id)->retrieveAgreement();
	return Fap::Java::JSON->decode($ob);
}






1;
