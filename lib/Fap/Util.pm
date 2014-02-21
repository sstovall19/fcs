package Fap::Util;

use strict;
use Cwd;
use Fap::Model::Fcs;
use Fap;
use List::Util qw(shuffle);
use Deep::Encode;

=head2 strip_nasties

[Not exported] 

strip_nasties: This is the core input validation routine. All validation of user and system supplied input should be run through here.
               It functions by removing any 'bad' characters out of a string, by applying a whitelist or blacklist policy depending on the mode used. 
               This means that you supply the input string (e.g. a param value from Apache) and specify a type as listed below.
               For example, if we have a 'name' field, then we only need to accept alpha characters and perhaps one or two punctuation characters.
               Please use the most restrictive mode possible for a given input string, by only allowing what is necessary.
               Exercise caution when using the 'reverse' mode or contact security for guidance.
               Please use the mode which bests describes the input type. Use default if you're not sure.
               Also consider setting a max length.
               UTF-8 support is built into certain types.

  Args (in list format): txt, [type], [replacement character]
  Args (in hash format): txt, type, repl (replacement character), length, pat, reverse, allow_non_printable_characters

	Basic args:
	txt     = The text to be cleaned
	repl    = The character to replace found characters with. Defaults to underscore ('_'). Must by only one character.
	type    = The type of data that we are validating.
		
                Current types supported (* Denotes UTF-8 Support)
                
                Whitelist Types (Only these characters are accepted)
                        
                        default           => '-a-zA-Z0-9_.@'            #Used if no type is specified. UTF-8 supported.
                        alphanumeric      => 'a-zA-z0-9'                #UTF-8 supported.
                        form_name         => 'a-zA-Z0-9 #.,'            #UTF-8 supported.
                        form_companyname  => 'a-zA-Z0-9&. @\''          #UTF-8 supported.
                        form_postal_code  => 'a-zA-Z0-9 '
                        form_phone_number => '-+0-9 ()'
                        form_cc_number    => '0-9 '
                        comments          => '0-9a-zA-Z\-\:\_.\t '
                        email_address     => '-a-zA-Z0-9_.@'            #UTF-8 supported.
                        server_id         => '0-9'                      #Max length = 6
                        numbers           => '0-9'                      #UTF-8 supported.
                        letters           => 'a-zA-Z'                   #UTF-8 supported.
                        ip                => '0-9.'
                        musicfile         => '-a-zA-Z0-9_.'
                        price             => '-0-9,.'
                        text              => 'a-zA-Z0-9 .@,\'?!%&'
                        url               => '-a-zA-Z0-9:/&=.'
                        filepath          => 'a-zA-Z0-9\/_.\-\:\t '     #Further protection is necessary here to stop directory traversal attacks. Consult security.


                Blacklist Types (Only these characters are rejected - USE WITH CAUTION!)
                        html              => '<>&"\''
                        sql               => '-";\''                    # Please do not rely on this for adequate sql injection prevention (use a whitelist type above)
                        asterisk          => '<>&"\'\[\]\(\)\/'         # things NOT allowed in asterisk
                        filename          => '\/:"'<>'
 

	Advanced args:
	pat      = PLEASE AVOID. Specify your own pattern. If you do not find a suitable type above, contact security.
                   If this arg is used, your pattern will be put inside a regular expression character class.
                
	length   = The maximum length of text to return. Anything less than or equal to zero is "infinite". Default is -1 (infinite).
		   Zero also means infinite because a zero length return is useless/meaningless.
	
        collapse = Replace multiple bad instances in a row with a single replacement character instead of multiple.
	
        reverse  = PLEASE AVOID. Boolean value; Setting this to true makes anything matched get destroyed (ie blacklist). 
                   Defaults to zero, destroying things that do not match (ie whitelist).
	
        allow_non_printable_characters = boolean value; by default non-printable characters are stripped. Setting this to false is asking for a headache!

  Returns: clean_text

  Examples in list format:
	Fap::Util::strip_nasties($text);
	Fap::Util::strip_nasties($email, 'email_address');
	Fap::Util::strip_nasties($url, 'url', '&');

  Examples in hash format:
	Fap::Util::strip_nasties({ txt => $text });
	Fap::Util::strip_nasties({ txt => $sql, type => 'sql', repl => '' });
	Fap::Util::strip_nasties({ txt => $sid, type => 'server_id', length => 6 });
	Fap::Util::strip_nasties({ txt => $hex, pat => '0-9a-fA-F', reverse => 0, collapse => 1 });

=cut

##############################################################################
# strip_nasties: Core input validation routine. Removes 'bad' characters out of a string, by applying a whitelist or blacklist policy depending on the mode used.
#
#    Args (in list format): txt, [type], [replacement character]
#    Args (in hash format): txt, type, repl (replacement character), length, pat, reverse, allow_non_printable_characters
#
#	Basic args:
#	txt     = The text to be cleaned.
#	repl    = The character to replace found characters with. Defaults to underscore ('_'). Must by only one character.
#	type    = The type of data that we are validating. SEE ABOVE FOR OPTIONS.
#
#       Advanced args:
#       pat      = Send in your own pattern! Keep in mind your pattern will be put inside a regular expression character class.
#                  Use with caution and consult security.
#       length   = the maximum length of text to return. Anything less than or equal to zero is "infinite". Default is -1 (infinite).
#                               Zero also means infinite because a zero length return is useless/meaningless.
#       collapse = replace multiple bad instances in a row with a single replacement character instead of multiple.
#       reverse  = boolean value; Setting this to true makes anything matched get destroyed (ie blacklist).
#                  Defaults to zero, destroying things that do not match (ie whitelist)
#       allow_non_printable_characters = boolean value; by default non-printable characters are stripped. Setting this to false is asking for a headache!
#
# Returns: clean_text
##############################################################################
sub strip_nasties {
    my ( %arg, $txt, $type );

    # UTF-8 Support for alphbetic type categories
    my @utf8_letters = (
        '\p{Lu}',           # Unicode Character Category 'Letter, Uppercase'
        '\p{Ll}',           # Unicode Character Category 'Letter, Lowercase'
        '\p{Lo}',           # Unicode Character Category 'Letter, Other'
        '\p{InKatakana}'    # Unicode Block 'Katakana' FROM U+30A0 TO U+30FF
    );

    # UTF-8 support for numeric type categories
    my @utf8_numbers = (
        '\p{Nd}'            # Unicode Character Category 'Number, Decimal Digit'
    );

    my %types = (

        # Whitelist Types (Only these characters are accepted)
        default           => '-a-zA-Z0-9_.@' . join( '',   @utf8_letters, @utf8_numbers ),
        alphanumeric      => 'a-zA-z0-9' . join( '',       @utf8_letters, @utf8_numbers ),
        form_name         => 'a-zA-Z0-9 #.,' . join( '',   @utf8_letters, @utf8_numbers ),
        form_companyname  => 'a-zA-Z0-9&. @\'' . join( '', @utf8_letters, @utf8_numbers ),
        form_postal_code  => 'a-zA-Z0-9 ',
        form_phone_number => '-+0-9 ()',
        form_cc_number    => '0-9 ',
        comments          => '0-9a-zA-Z\-\:\_.\t ',
        email_address     => '-a-zA-Z0-9_.@' . join( '',   @utf8_letters, @utf8_numbers ),
        server_id         => '0-9',
        numbers   => '0-9' . join( '',    @utf8_numbers ),
        letters   => 'a-zA-Z' . join( '', @utf8_letters ),
        ip        => '0-9.',
        musicfile => '-a-zA-Z0-9_.',
        price     => '-0-9,.',
        text      => 'a-zA-Z0-9 .@,\'?!%&',
        url       => '-a-zA-Z0-9:/&=.',
        filepath  => 'a-zA-Z0-9\/_.\-\:\t ', #Further protection is necessary here to stop directory traversal attacks. Consult security.

        # Blacklist Types (Only these characters are rejected - use with caution)
        html     => '<>&"\'',
        sql      => '-";\'',               # Please do not rely on this for adequate sql injection prevention (use a whitelist type above)
        asterisk => '<>&"\'\[\]\(\)\/',    # things NOT allowed in asterisk
        filename => '\/:"\'<>'
    );

    # By doing it this way we're fully backward compatible; and the list version is easier for most purposes.
    if ( ref( $_[0] ) eq 'HASH' ) {
        %arg = %{ +shift };
    } else {

        # By allowing the type to be passed, if the type is passed we require some value for txt.
        # Make sure there is a value (0 or '' are good defaults) if you cannot trust the source has a value.
        @arg{ 'txt', 'type' } = ( shift, shift );
        if (@_) {
            $arg{repl} = shift;
        }
    }

    # Now that we have the args, clean them up
    $arg{type}                           ||= 'default';
    $arg{'length'}                       ||= -1;
    $arg{allow_non_printable_characters} ||= 0;

    # Don't reverse if we have a pattern (it will set that for us); make sure we use reverse if we're in SQL, HTML, asterisk or filename mode.
    if ( !$arg{pat} && ( $arg{type} eq 'html' || $arg{type} eq 'sql' || $arg{type} eq 'asterisk' || $arg{type} eq 'filename' ) ) {
        $arg{reverse} = 1;
    }

    # Current max length of server ids.
    if ( $arg{type} eq 'server_id' ) {
        $arg{length} = 6;
    }

    # make a variable for the text.
    $txt = $arg{txt};

    # Set up the regex variables.
    my $OK_CHARS = exists( $arg{pat} ) ? $arg{pat} : exists( $types{ $arg{type} } ) ? $types{ $arg{type} } : $types{default};

    #my $REPL     = exists($arg{repl}) && length($arg{repl}) == 1 ? $arg{repl} : '_';

    my $REPL = exists( $arg{repl} ) ? $arg{repl} : '_';

    # This argument option is really long because it generally should not be used.
    if ( $arg{allow_non_printable_characters} == 0 ) {

        # Get rid of anything not printable.
        if ( $arg{collapse} ) {
            $txt =~ s/[[:^print:]]+/$REPL/g;
        } else {
            $txt =~ s/[[:^print:]]/$REPL/g;
        }
    }

    # Do the substitution; if we have a collapse flag, turn multiple entries into a single entry.
    if ( $arg{'reverse'} ) {
        if ( $arg{collapse} ) {
            $txt =~ s/[$OK_CHARS]+/$REPL/g;
        } else {
            $txt =~ s/[$OK_CHARS]/$REPL/g;
        }
    } else {
        if ( $arg{collapse} ) {
            $txt =~ s/[^$OK_CHARS]+/$REPL/g;
        } else {
            $txt =~ s/[^$OK_CHARS]/$REPL/g;
        }
    }

    if ( $arg{'length'} > 0 && length($txt) > $arg{'length'} ) {
        return substr( $txt, 0, $arg{'length'} );
    } else {
        return $txt;
    }
}

# sub path_to: return full path to FCS Root directory

sub path_to {
    my ( $class, @dirs ) = @_;

    if ( !$ENV{FON_DIR} || !-e $ENV{FON_DIR} ) {
        my $dir;
        if ( index( __FILE__, "Fap" ) > 0 ) {
            my @path = split( /\//, substr( __FILE__, 0, index( __FILE__, "Fap" ) - 1 ) );
            pop(@path);
            $dir = "/" . join( "/", @path );
        } else {
            $dir = substr( getcwd, 0, rindex( getcwd(), "/" ) );
        }
        if ( !-e $dir && -e substr( $dir, 1 ) ) { $dir = substr( $dir, 1 ); }
        $dir = substr( $dir, 1 ) if ( $dir =~ /^\/\// );
        $ENV{FON_DIR} = $dir;
    }
    return join( "/", $ENV{FON_DIR}, @dirs );
}

##### msg - error message
##### die?

sub throw_error {
    my ( $class, $msg, $die ) = @_;

    my @details = caller(1);

    my $error_string = sprintf( "%s %s() line %d: %s", $details[1], $details[3], $details[2], $msg );
    if ($die) {
        die $error_string;
    } else {
        warn $error_string;
    }
}

=head2 is_valid_server_id

	Checks if the server_id is syntactically valid and actually exists.
	
	Args: server_id
	Returns: 1 if the server_id is valid, undef if not valid or an error occured

=cut

sub is_valid_server_id {
    my $server_id   = shift;
    my $customer_id = shift;

    if ( !defined($server_id) || $server_id !~ /^\d+$/ ) {
        Fap->trace_error('invalid server_id');
        return undef;
    }

    my $db = Fap::Model::Fcs->new();
    my $rs;
    if ($customer_id) {
        $rs = $db->table('Server')->single( {
                server_id   => $server_id,
                customer_id => $customer_id
            } );
    } else {

        $rs = $db->table('Server')->find( { server_id => $server_id, } );
    }
    if ( !defined($rs) ) {
        Fap->trace_error('server_id doesn\'t exist');
        return undef;
    }

    return 1;
}

=head2 is_valid_extension

	Checks if extension is syntactically valid and actually belongs to a server.
	
	Args: server_id, exten
	Returns: 1 if the extension is valid, undef if not valid or an error occured

=cut

sub is_valid_extension {
    my $server_id = shift;
    my $exten     = shift;

    if ( !is_valid_server_id($server_id) ) {
        Fap->trace_error("$@");
        return undef;
    }

    if ( !defined($exten) || $exten !~ /^\d+$/ ) {
        Fap->trace_error("invalid exten");
        return undef;
    }

    my $db = Fap::Model::Fcs->new();

    my $rs = $db->table('Extension')->single( {
            server_id => $server_id,
            extension => $exten
        } );
    if ( !defined($rs) ) {
        Fap->trace_error('exten doesn\'t exist');
        return undef;
    }

    return 1;
}

=head2 is_valid_device_id

	Checks if device_id is syntactically valid and actually exists.
	
	Args: device_id
	Returns: 1 if the device_id is valid, undef if not valid or an error occured

=cut

sub is_valid_device_id {
    my $device_id = shift;

    if ( !defined($device_id) || $device_id !~ /^\d+$/ ) {
        Fap->trace_error('invalid device_id');
        return undef;
    }

    my $db = Fap::Model::Fcs->new();

    my $rs = $db->table('Device')->single( { device_id => $device_id } );
    if ( !defined($rs) ) {
        Fap->trace_error('device_id doesn\'t exist');
        return undef;
    }

    return 1;
}

=head2 is_valid_qty

	Checks if quantity is syntactically valid. For now just tests if its a sequence of digits.
	
	Args: qty
	Returns: 1 if the qty is valid, undef if not valid or an error occured

=cut

sub is_valid_qty {
    my $qty = shift;

    if ( !defined($qty) || $qty !~ /^\d+$/ ) {
        Fap->trace_error('invalid qty');
        return undef;
    }

    return 1;
}

=head2 version_compare 

=over 4

Numaric compare 2 version numbers

Args:   v1 ['==', '!=', '<=', '>=', '<', '>'] v2
Returns: 
bool 1|0;

=back

=cut
##############################################################################
# version_compare 
##############################################################################
sub version_compare
{
	my ($v1, $op, $v2) = @_;

	# 2010.1.1x is now older than 12.x
	if ($v1 =~ /^2010\./) {
		$v1 = "5.2.$v1";
	}
	if ($v2 =~ /^2010\./) {
		$v2 = "5.2.$v2";
	}
	s/[._]?(\d+)/chr($1 & 0x0FFFF)/eg for($v1,$v2);
	my %cmp = (
		'=='  => sub { shift eq shift  },
		'!='  => sub { shift ne shift  },
		'<='  => sub { shift le shift  },
		'>='  => sub { shift ge shift  },
		'<'   => sub { shift lt shift  },
		'>'   => sub { shift gt shift  },
		'<=>' => sub { shift cmp shift },
	);
	return $cmp{$op}->($v1, $v2);
}


=head2 return_random_string

=over 4

Returns random strings of characters of length specified

Args:    length of string to return (defaults to 10)
Returns: random string of characters

=back

=cut
##############################################################################
# return_random_string: Return a random character string of the specified
#                       length.
#
#    Args: length
# Returns: random_string
##############################################################################
sub return_random_string
{
	my $length = shift(@_) || 10;
	my @chars = qw(
		2 3 4 5 6 7 8 9 A B C D E F G H J K L M N P
		Q R S T U V W X Y Z a b c d e f g h i j k m n o p
		q r s t u v w x y z _
	);

	srand();
	my $rand_string = '';
	# Pick a random character from our array, and append it
	$rand_string .= $chars[int rand @chars] while length($rand_string) < $length;

	return($rand_string);
}

=head2 return_random_password

Like return_random_string, but force returns a strong password.

=cut

sub return_random_password
{
	my $length = shift(@_) || 10;

	# A strong password has at least one of each of...
	my %charsets = (
		nums    => [ qw(0 1 2 3 4 5 6 7 8 9) ],
		upper   => [ qw(A B C D E F G H I J K L M N P Q R S T U V W X Y Z) ],
		lower   => [ qw(a b c d e f g h i j k m n o p q r s t u v w x y z) ],
		chars   => [ qw(_ ! # @ +) ],
	);

	# Shuffle the order of characters pulled from each set; re-shuffle every time
	# we exhaust the shuffled list.
	my @sets = qw(nums upper lower chars);
	my @shuffle = shuffle(@sets);

	my $rand_string = '';
	while (length $rand_string < $length) {
		# Go through the shuffled list and pull a random char from each set.
		foreach my $set (@shuffle) {
			last unless length $rand_string < $length;
			my $char = $charsets{$set}->[ int(rand(scalar(@{$charsets{$set}}))) ];
			$rand_string .= $char;
		}

		# Re-shuffle.
		@shuffle = shuffle(@sets);
	}

	return $rand_string;
}

=head2 return_random_number

=over 4

Returns a random number of specified length

Args:    length of string to return (defaults to 10)
Returns: random string of numbers

=back

=cut
##############################################################################
# return_random_number: Return a random number of the specified length.  
#
#    Args: length
# Returns: random_number
##############################################################################
sub return_random_number
{
	my $length = shift(@_) || 10;
	my @chars = qw(1 2 3 4 5 6 7 8 9 0);

	srand();
	my $rand_number = '';
	# Pick a random character from our array, and append it
	$rand_number .= $chars[int rand @chars] while length($rand_number) < $length;

	return($rand_number);
}

=head2 weak_password

=over 4

Check if a password is weak or not. Returns 1 if the password is weak, 0 otherwise.

   Args: password string
Returns: boolean true or false

=back

=cut

##############################################################################
# weak_password
##############################################################################
sub weak_password
{
	my $pw = shift;
	my $username = shift;

	# 8 chars or longer
	if (length($pw) < 8)
	{
		$@ = "Web Password must be 8 characters or more.";
		return 1;
	}

	# username can't be a component of the password
	if ($username and $pw =~ /\Q$username\E/)
	{
		$@ = "Web Password cannot contain the Web Username.";
		return 1;
	}

	# make sure there is at least 2 digits and 2 letters if there is no punctuation
	# This allows for all numbers or all letters as long as there is a punctuation mark somewhere
	if ($pw !~ /[\!-\/]|[\:-\@]|[\[-\`]|[\{-\~}]/)
	{
		if ($pw !~ /\d.*\d/ or $pw !~ /\p{IsAlpha}.*\p{IsAlpha}/)
		{
			$@ = "Web Password must contain at least 2 numbers and 2 letters.";
			return 1;
		}
	}

	# Check to see if the password is mostly one character
	for (my $i = 0; $i <= length($pw); $i++)
	{
		my $tocheck = substr($pw, $i, 1);

		my $counter = 0;
		for (my $j = 0; $j <= length($pw); $j++)
		{
			$counter++ if ($tocheck eq substr($pw, $j, 1));
		}

		if(($counter / length($pw)) >= 0.5)
		{
			$@ = "Web Password must not contain the same consecutive characters";
			return 1;
		}
	}

	# All checks out
	return 0;
}


=head2 strong_password

=over 4

Check if a password is strong or not. Returns 1 if the password is strong, 0 otherwise.

   Args: password string
Returns: boolean true or false

=back

=cut

##############################################################################
# strong_password
##############################################################################
sub strong_password
{
	return &weak_password ? 0 : 1;
}

=head2 validate_email_address

=over 4

validates an email address to make sure it's (more or less) standards compliant.

Args:    email address
Returns: boolean true (email address) or false (undef)

=back

=cut
#############################################################################
# validate_email_address: this sub takes a passed email address and cleans it
# up and then validates that it "looks good". This means first it removes
# white space, then it looks for things like "@", a hostname, etc. 
#
#    Args: $email_address
# Returns: $email_address (clean) or 0 (if found error); 
#############################################################################
sub validate_email_address {

	if ($_[0] =~ /^[\w\-+.]+\@(?:[a-z0-9-]+\.)+[a-z]+$/i)
	{
		return $_[0];
	}
	else
	{
		return undef; 
	}
}

=head2 utf8ify()

=over 4

Converts a data structure to have strings encoded in UTF-8.  If encode parameter is not set, 
this function will decode the data from UTF-8.

Args: $data, <$encode>
Returns: none.  It updates $data to have encoded (decoded) UTF-8

=back

=cut
sub utf8ify
{
    my ($data, $encode) = @_;

    # check if data is alredy in UTF-8
    my $is_utf8 = Deep::Encode::deep_utf8_check($data);

    if ($encode)
    {
        # only encode if it is not yet already in UTF-8
        if ( !$is_utf8 )
        {
            Deep::Encode::deep_utf8_encode($data);
        }
    }
    else
    {
        # only decode if data is in UTF-8
        if ($is_utf8)
        {
            Deep::Encode::deep_utf8_decode($data);
        }
    }
}

1;

__DATA__
