# Copyright 2012, Fonality Inc. ALL RIGHTS RESERVED
package Fap::Provision::Server;

use Fap;
use Fap::Model::Fcs;
use Fap::Model::Cdr;
use Fap::Net::RPC;
use Fap::Audio;
use Fap::Global;
use Fap::Locale;
use Fap::Provision;
use Fap::Server;
use Socket;
use HTML::Template;
use LWP::UserAgent;
use Net::Ping;
use F::ConfIO;
use F::IAX;
use F::Lock;
use F::Unbound;

sub new {
    my ( $class, %args ) = @_;
    my ($serv, $serv_info);
    
    # check for the required keys
    my(@required_params) = qw(
        cust_id
        product
        dest_add
    );
    foreach my $a (@required_params) 
    {
        unless(defined($args{$a})) 
        {
            Fap->trace_error("Err: required parameter '$a' missing");
            return undef;
        }
    }
    
    # validate the required keys
    if (ref($args{product}) ne 'HASH')
    {
        Fap->trace_error("product value is invalid");
        return undef;
    }
    if (ref($args{dest_add}) ne 'HASH')
    {
        Fap->trace_error("dest_add value is invalid");
        return undef;
    }
    if ($args{cust_id} !~ /^\d\d*$/)
    {
        Fap->trace_error("cust_id value is invalid");
        return undef;
    }
        
    if (!defined($args{fcs_schema}))
    {
        $args{fcs_schema} = Fap::Model::Fcs->new();
    }
    
    if (defined($args{server_id}))
    {
        $serv = Fap::Server->new('server_id' => $args{server_id});
        $serv_info = $serv->{'details'};
        foreach my $key (qw/deployment server_provider customer/)
        {
            delete $serv_info->{$key};
        }
    }

    if ($args{host} !~ /^\d\d*$/)
    {
        $args{host} = undef;
    }
    
    my $self = bless {
        mode       => $args{mode},
        product    => $args{product},
        dest_add   => $args{dest_add},
        cust_id    => $args{cust_id},
        fcs_schema => $args{fcs_schema},
        datacenter => $args{datacenter},
        host       => $args{host},
        serv_obj   => $serv,
        serv_info  => $serv_info
    }, $class;
    
    $self->convert_country();    
    
    return $self;
}

sub insert_basic_details
{
    my $self = shift;
    
    if (defined($self->{'serv_info'}))
    {
        Fap->trace_error("Err: Unable to create new entries while server's profile still present");
        return undef;
    }
    
    my $default = Fap->load_conf("provision");
    $default->{'customer_id'}    = $self->{'cust_id'};
    $default->{'country'}        = $self->{'dest_add'}->{'country'};
    $default->{'ftp_password'}   = Fap::Util::return_random_number(8);
    $default->{'cp_version'}     = Fap::Global::kCP_VERSION();
    $default->{'cp_location'}    = Fap::Provision::cp_location();
    $default->{'deployment_id'}  = $self->{'product'}->{'deployment_id'};
    $default->{'localtime_file'} = Fap::Locale::get_timezone($self->{'dest_add'}->{'country_info'}->{'alpha_code_2'},$self->{'dest_add'}->{'state_prov'});
    
    my $rs = $self->{'fcs_schema'}->table('Server')->create($default);
    $self->{'serv_info'} = ($self->{'fcs_schema'}->strip($rs));
    
    return 1;
}

sub setup_tunnel
{
    my $self = shift;
    
    return undef if not defined $self->{'serv_info'};
    
    $self->{'serv_info'}->{'iax2_username'}  = 's' . $self->{'serv_info'}->{'server_id'};
    $self->{'serv_info'}->{'iax2_password'}  = Fap::Util::return_random_string(8);
    $self->{'serv_info'}->{'local_areacode'} = Fap::Provision::area_code($self->{'serv_info'});
    
    if ($self->{'product'}->{'deployment'}->{'is_hosted'})
    {
        my $host_info = {'mosted_hoster' => 0};
        if ($self->{'host'})
        {
            my $host_rs   = $self->{'fcs_schema'}->table('Server')->find({"server_id" => $self->{'host'}});
            $host_info = ($self->{'fcs_schema'}->strip($host_rs));
        }
        $host_info = $self->get_available_host() if not $host_info->{'mosted_hoster'};
        
        # ok we return immediately if we can't find a host
        return undef if not $host_info;
        
        $self->{'serv_info'}->{'mosted'}                = $host_info->{'server_id'};
        $self->{'serv_info'}->{'tun_address'}           = $host_info->{'tun_address'};
        $self->{'serv_info'}->{'tun_address2'}          = $host_info->{'tun_address2'};
        $self->{'serv_info'}->{'asterisk_version'}      = $host_info->{'asterisk_version'};
        $self->{'serv_info'}->{'remote_auth_username'}  = $host_info->{'remote_auth_username'};
        $self->{'serv_info'}->{'remote_auth_password'}  = $host_info->{'remote_auth_password'};
        $self->{'serv_info'}->{'remote_mgr_password'}   = $host_info->{'remote_mgr_password'};
        $self->{'serv_info'}->{'local_mgr_password'}    = $host_info->{'local_mgr_password'};
        $self->{'serv_info'}->{'tun_credential_access'} = 0;
    }
    else
    {
        if (lc($self->{'product'}->{'deployment'}->{'name'}) eq 'software')
        {
            $self->{'serv_info'}->{'remote_auth_username'} = Fap::Util::return_random_string(12);
            $self->{'serv_info'}->{'remote_auth_password'} = Fap::Util::return_random_string(12);
            $self->{'serv_info'}->{'tun_address'}  = Fap::Provision::generate_tun_ip($self->{'serv_info'}->{'server_id'}, 1);
        }
        else
        {
            $self->{'serv_info'}->{'tun_address'}  = Fap::Provision::generate_tun_ip($self->{'serv_info'}->{'server_id'});
        }
        
        $self->{'serv_info'}->{'tun_address2'} = $self->{'serv_info'}->{'tun_address'};
        $self->{'serv_info'}->{'tun_address2'} =~ s/^(\d+)/$1 + 1/eg;
        $self->{'serv_info'}->{'tun_password'} = Fap::Util::return_random_string(30);
        $self->{'serv_info'}->{'tun_credential_access'} = 1;
        $self->{'serv_info'}->{'remote_mgr_password'}   = Fap::Util::return_random_password(20);
        $self->{'serv_info'}->{'local_mgr_password'}    = Fap::Util::return_random_password(20);

        # chars should be alphanumeric
        $self->{'serv_info'}->{'tun_password'} =~ s/[^\da-zA-Z]//g;
    }
    
    $self->{'fcs_schema'}->table('Server')->search({server_id => $self->{'serv_info'}->{'server_id'}})->update($self->{'serv_info'});
    
    return $self->provision_tunnels();
}

sub provision_tunnels
{
    my $self = shift;
    
    return undef if not defined $self->{'serv_info'};
    
    if ($self->{'product'}->{'deployment'}->{'is_hosted'})
    {
        foreach my $cnt (qw/1 2/)
        {
            my $ip = "tun_address" . ($cnt == 1 ? '' : '2');
            $self->{'fcs_schema'}->table('RrInternal')->create({
                'name' => 'pbxtra' . $self->{'serv_info'}->{'server_id'} . ($cnt == 1 ? '' : '-2'), 
                'data' => $self->{'serv_info'}->{$ip}, 
                'type' => 'A', 
                'zone' => 3
            });
        }    
        
        $self->{'fcs_schema'}->table('Rr')->create({
            'data' => 's' . $self->{'serv_info'}->{'mosted'}, 
            'name' => 's' . $self->{'serv_info'}->{'server_id'}, 
            'type' => 'CNAME', 
            'zone' => 1, 
            'ttl'  => 300
        });
        
        my $host_ip = gethostbyname("s$self->{'serv_info'}->{'mosted'}x.pbxtra.fonality.com");
        $host_ip = inet_ntoa($host_ip);
        
        my $data = [
            {'data' => $host_ip, 'name' => 's' . $self->{'serv_info'}->{'server_id'} . 'x', 'type' => 'A', 'zone' => 1, 'ttl' => 300},
            {'data' => $host_ip, 'name' => 's' . $self->{'serv_info'}->{'server_id'} . 'i', 'type' => 'A', 'zone' => 1, 'ttl' => 300},
            {'data' => "10 5269 connect-hud.fonality.com.", 'name' => "_xmpp-server._tcp.s$self->{'serv_info'}->{'server_id'}", 'type' => 'SRV', 'zone' => 1, 'ttl' => 300},
            {'data' => "10 5222 connect-hud.fonality.com.", 'name' => "_xmpp-client._tcp.s$self->{'serv_info'}->{'server_id'}", 'type' => 'SRV', 'zone' => 1, 'ttl' => 300},
            {'data' => "10 5269 connect-hud.fonality.com.", 'name' => "_jabber._tcp.s$self->{'serv_info'}->{'server_id'}", 'type' => 'SRV', 'zone' => 1, 'ttl' => 300}
        ];
        
        foreach my $rec (@{$data})
        {
            $self->{'fcs_schema'}->table('Rr')->create($rec);
        }    
    }
    else
    {
        my $host = "tbp-vpn";
        my $tun_data = { 
            'stype' => 'trixbox',
            'auth'  => "hsiane6434bGdjs9303ndjjalL",
            'sid'   => $self->{'serv_info'}->{'server_id'},
            'ip1'   => $self->{'serv_info'}->{'tun_address'},
            'ip2'   => $self->{'serv_info'}->{'tun_address2'},
            'base1' => ($self->{'serv_info'}->{'tun_address'} =~ /^(.*)\.\d+$/),
            'base2' => ($self->{'serv_info'}->{'tun_address2'} =~ /^(.*)\.\d+$/),
            'tun_password' => $self->{'serv_info'}->{'tun_password'}
        };

        if ( lc($self->{'product'}->{'deployment'}->{'name'}) ne 'software' )
        {
            $host = "vpn";
            $tun_data->{'stype'} = 'pbxtra';
        }
    
        foreach my $cnt (qw/1 2/)
        {
            my $ip = "ip" . $cnt;
            $self->{'fcs_schema'}->table('RrInternal')->create({
                'name' => $tun_data->{'stype'} . $tun_data->{'sid'} . ($cnt == 1 ? '' : '-2'), 
                'data' => $tun_data->{$ip}, 
                'type' => 'A', 
                'zone' => 3
            });
        }    
    
        my $ua = LWP::UserAgent->new;
        $ua->timeout(60);

        foreach my $cnt (qw/1 2/)
        {
            my $response = $ua->post("http://${host}${cnt}.fonality.com/new",$tun_data);

            if (!$response->is_success) 
            {
                Fap->trace_error("Err: $response->status_line");
                return undef;
            }
        }
    }
    
    return 1;
}

sub close_tunnel
{
    my $self = shift;
    
    return undef if not defined $self->{'serv_info'};
    
    # removed the entries from the mydns database
    my $rs = undef;
    if ( $self->{'serv_info'}->{'mosted'} )
    {
        $rs = $self->{'fcs_schema'}->table('Rr')->search( { 'name' => { 'like', "%" . $self->{'serv_info'}->{'server_id'} ."%" } } );
        while( my $row = $rs->next ) 
        {
            $self->{'fcs_schema'}->table('Rr')->search( { 'id' => $self->{'fcs_schema'}->strip($row)->{'id'} } )->delete;
        }
    }
    $rs = $self->{'fcs_schema'}->table('RrInternal')->search( { 'name' => { 'like', "%" . $self->{'serv_info'}->{'server_id'} ."%" } } );
    while( my $row = $rs->next ) 
    {
        $self->{'fcs_schema'}->table('RrInternal')->search( { 'id' => $self->{'fcs_schema'}->strip($row)->{'id'} } )->delete;
    }
    
    return 1;
}

sub install_asterisk
{
    my $self = shift;

    return undef if not defined $self->{'serv_info'};

    my $pbxtra_version = '5.2';
    my $dir = Fap::Global::kNFS_MOUNT();
    my $default_tar = 'default'.$pbxtra_version.'.tar';

    # check if there is unbound specific tar
    if ($self->{'deployment'}->{'is_hosted'})
    {
        if (-f "${dir}/default${pbxtra_version}.unbound.tar")
        {
            $default_tar = "default" . $pbxtra_version . ".unbound.tar";
        }
        elsif (-f "${dir}/default.unbound.tar")
        {
            $default_tar = "default.unbound.tar";
        }
        else
        {
            $default_tar = 'default-1.6.tar';
        }    
    } 
    else
    {
        if (not -f "${dir}/$default_tar")
        {
            if(-f "${dir}/default.tar")
            {
                $default_tar = 'default.tar';
            }
            else
            {
                Fap->trace_error("Err: ${dir}/default.tar missing");
                return undef;
            }
        }

    }
    
    my $rv = chdir($dir);
    unless($rv) 
    {
        Fap->trace_error("Err: Unable to chdir to $dir: $!: $@");
        return undef;
    }
    
    # Unpack, but not over an existing dir
    if(-x 'default') 
    {
        rename('default', "default.$$." . time());
    }

    # Allow multiple instances of this to run
    mkdir("default.$self->{'serv_info'}->{'server_id'}");
    $rv = system("/bin/tar -C ${dir}/default.$self->{'serv_info'}->{'server_id'} -xf ${dir}/${default_tar}");
    
    unless($rv == 0) 
    {
        Fap->trace_error("Err: Unable to unpack $dir/$default_tar: $!");
        return undef;
    }

    # Prevent a directory in the existing correct location from being there -- it's ok if this fails
    if (-e $self->{'serv_info'}->{'server_id'})
    {
        $rv = rename($self->{'serv_info'}->{'server_id'}, "$self->{'serv_info'}->{'server_id'}." . time());
    }

    # Move the directory to the correct location
    $rv = rename("default.$self->{'serv_info'}->{'server_id'}/default", $self->{'serv_info'}->{'server_id'});
    unless($rv) 
    {
        Fap->trace_error("Err: Unable to rename 'default' to $self->{'serv_info'}->{'server_id'} in $dir: $!");
        return undef;
    }

    # Remove our temp directory which allowed multiple instances of us to run
    rmdir("default.$self->{'serv_info'}->{'server_id'}");
    
    # we don't need to install asterisk for hosted systems
    return 1 if $self->{'product'}->{'deployment'}->{'is_hosted'};
    
    if ( lc($self->{'product'}->{'deployment'}->{'name'}) ne 'software' )
    {
        my $dbh = $self->{'fcs_schema'}->dbh('pbxtra');
        my $rpc = Fap::Net::RPC::rpc_connect($self->{'serv_info'}->{'server_id'}, $dbh);
        my $response = Fap::Net::RPC::system_call($rpc, $self->{'serv_info'}->{'server_id'}, "/usr/sbin/asterisk -V");
        $self->{'fcs_schema'}->switch_db('fcs');
        chomp($response);
        my $astv = (split /\s/, $response)[1];
        if (defined($astv) && $astv ne '')
        {
            $self->{'serv_info'}->{'asterisk_version'} = $astv;
            $self->{'fcs_schema'}->table('Server')->search({server_id => $self->{'serv_info'}->{'server_id'}})->update($self->{'serv_info'});
        } 
    }

    return 1;
}

sub create_conf
{
    my $self = shift;

    return undef if not defined $self->{'serv_info'};

    my $dir = Fap::Global::kNFS_MOUNT() . '/' . $self->{'serv_info'}->{'server_id'};
    my $rv = chdir($dir);

    unless($rv) 
    {
        Fap->trace_error("Err: Unable to chdir to $dir: $!: $@");
        return undef;
    }
    
    F::IAX::add_iax_static($self->{'serv_info'}->{'server_id'});
    
    my $default_conf = {
        'sip.conf' => {
            'IP'            => $self->{'serv_info'}->{'tun_address2'}
        },
        'voicemail.conf' => {
            'SERVER_ID'     => $self->{'serv_info'}->{'server_id'}
        },
        'iax.conf' => {
            'IAX2_USERNAME' => $self->{'serv_info'}->{'iax2_username'},
            'IAX2_PASSWORD' => $self->{'serv_info'}->{'iax2_password'}
        },
        'fonality/globals.conf' => {
            'SERVER_ID'     => $self->{'serv_info'}->{'server_id'},
            'IAX2_USERNAME' => $self->{'serv_info'}->{'iax2_username'},
            'IAX2_PASSWORD' => $self->{'serv_info'}->{'iax2_password'},
            'GATEWAY'       => 'proxy1.pbxtra.fonality.com',
            'AREA_CODE'     => $self->{'serv_info'}->{'local_areacode'}
        },
        'manager.conf' => {
            'LOCAL_PASS'    => $self->{'serv_info'}->{'local_mgr_password'},
            'REMOTE_PASS'   => $self->{'serv_info'}->{'remote_mgr_password'}
        },
    };
    
    foreach my $conf (keys %{$default_conf})
    {
        my($template) = HTML::Template->new(filename => "${dir}/${conf}", die_on_bad_params => 0);
        
        unless($template) {
            Fap->trace_error("Err: unable to set up template: $tmpl_file: $!");
            return undef;
        }
        $template->param($default_conf->{$conf});
        my($output) = $template->output;
        
        my $ioh = F::ConfIO->new({server => $self->{'serv_info'}->{'server_id'}, file => $conf, use_cache => 1, RaiseError => 1});
        $ioh->write;
        $ioh->clear;
        $ioh->append($output);
        $ioh->close;
    }
    
    # Put an entry for this server into /etc/asterisk/iax.conf
    my $lock = F::Lock->new({file => '/etc/asterisk/iax.conf', type => 'write'});
    if (!defined($lock))
    {
        Fap->trace_error("Err: Cannot write lock /etc/asterisk/iax.conf.");
        return undef;
    }
    
    $rv = open(IAX,">>/etc/asterisk/iax.conf");
    unless($rv) 
    {
        $lock->unlock;
        Fap->trace_error("Err: Error opening /etc/asterisk/iax.conf: $!");
        return(undef);
    }

    print IAX "\n[s" . $self->{'serv_info'}->{'server_id'} . "]\n";
    print IAX "type=friend\n";
    print IAX "host=" . $self->{'serv_info'}->{'tun_address'} . "\n";
    print IAX "secret=" . $self->{'serv_info'}->{'iax2_password'} . "\n";
    print IAX "context=pbxtra\n";
    print IAX "accountcode=" . $self->{'serv_info'}->{'server_id'} ."; server_id\n";
    close(IAX);
    $lock->unlock;
    
    if ($self->{'product'}->{'deployment'}->{'is_hosted'})
    {
        my @subdirs = ( 'hud', 'system', 'fonality/fmfm', 'hud3.0', 'tftpd' );
        my $output_path = '/nfs/unbound/servers';
        my $backup_path = Fap::Global::kUNBOUND_BACKUP_PATH();
        
        # trap all STDOUT output from legacy F modules
        my $output = '';
        open TOOUTPUT, '>', \$output;
        select TOOUTPUT;
        
        # Generate the new conf files for this virtual server
        F::Unbound::update_includes ($self->{'serv_info'}->{'mosted'}, $self->{'serv_info'}->{'server_id'});

        # Check that the structure is in place
        foreach my $subdir (@subdirs)
        {
            system("mkdir -p $output_path/$self->{'serv_info'}->{'mosted'}/$self->{'serv_info'}->{'server_id'}/etc/asterisk/$subdir");
        }
        system("mkdir -p $backup_path/$self->{'serv_info'}->{'server_id'}/var/lib/asterisk/sounds/callscreens");
        system("mkdir -p $backup_path/$self->{'serv_info'}->{'server_id'}/var/spool/asterisk/monitor");
        system("mkdir -p $backup_path/$self->{'serv_info'}->{'server_id'}/var/spool/asterisk/voicemail/default-$self->{'serv_info'}->{'server_id'}");

        # These files make sure that necessary directories get created as nobody:nobody, so asterisk can write to it
        system("touch $backup_path/$self->{'serv_info'}->{'server_id'}/var/spool/asterisk/monitor/createme");
        system("touch $backup_path/$self->{'serv_info'}->{'server_id'}/var/lib/asterisk/sounds/callscreens/createme");
        system("touch $backup_path/$self->{'serv_info'}->{'server_id'}/var/spool/asterisk/voicemail/default-$self->{'serv_info'}->{'server_id'}/createme");
        
        # Copy the key file from the host
        F::Unbound::copy_host_key($self->{'serv_info'}->{'mosted'}, $self->{'serv_info'}->{'server_id'} );
        F::Unbound::rewrite_all($self->{'serv_info'}->{'mosted'}, $self->{'serv_info'}->{'server_id'});
        
        # let go of the trap but clean it first
        $output = undef;
        select STDOUT;
        close TOOUTPUT;
    }
    else
    {
        # Generate a unique blowfish key
        if (open(RAND, "</dev/urandom"))
        {
            my $key;
            read(RAND, $key, 39);
            close(RAND);

            # get hex
            $key = uc(unpack("H*", $key));
    
            my $ioh = F::ConfIO->new({server => $self->{'serv_info'}->{'server_id'}, file => "key", use_cache => 1});
            $ioh->write;
            $ioh->clear;
            $ioh->append($key."\n");
            $ioh->close;
        }
    }
    
    $self->{'serv_info'}->{'use_db_conf'} = 1;
    $self->{'fcs_schema'}->table('Server')->search({server_id => $self->{'serv_info'}->{'server_id'}})->update($self->{'serv_info'});
    
    return 1;
}

sub purge_conf
{
    my $self = shift;
    
    return undef if not defined $self->{'serv_info'};
    
    my @dir_to_purge;
    
    if ( $self->{'serv_info'}->{'mosted'} )
    {
        # rewrite the confs to remove the server, and then sync them down
        F::Unbound::update_includes ( $self->{'serv_info'}->{'mosted'}, $self->{'serv_info'}->{'server_id'}, 1 );
        F::Unbound::sync_host_server( $self->{'serv_info'}->{'mosted'} );
        F::Unbound::reload( $self->{'serv_info'}->{'mosted'} );
        
        # remove conf files from host server
        push @dir_to_purge, "/data/" . $self->{'serv_info'}->{'server_id'};
        push @dir_to_purge, "/var/lib/asterisk/sounds/" . $self->{'serv_info'}->{'server_id'};
        push @dir_to_purge, "/var/lib/asterisk/sounds/custom/" . $self->{'serv_info'}->{'server_id'};
        push @dir_to_purge, "/var/spool/asterisk/voicemail/default-" . $self->{'serv_info'}->{'server_id'};
        my $dbh = $self->{'fcs_schema'}->dbh('pbxtra');
        my $rpc = Fap::Net::RPC::rpc_connect( $self->{'serv_info'}->{'mosted'}, $dbh );
        foreach my $dir (@dir_to_purge)
        {
            Fap::Net::RPC::rsend_request( $rpc, 'rm', $dir );
        }
        $self->{'fcs_schema'}->switch_db('fcs');
        @dir_to_purge = ();
        
        # remove conf files from the nfs
        push @dir_to_purge, "/nfs/unbound/servers/" .  $self->{'serv_info'}->{'mosted'} . "/" . $self->{'serv_info'}->{'server_id'};
        push @dir_to_purge, Fap::Global::kUNBOUND_BACKUP_PATH() . "/" . $self->{'serv_info'}->{'server_id'};
    } 
    
    # remove conf files from local system
    push @dir_to_purge, Fap::Global::kNFS_MOUNT() . '/' . $self->{'serv_info'}->{'server_id'};
    foreach my $dir (@dir_to_purge)
    {
        system("rm -Rf $dir");
    }    
    
    # remove conf files from database
    my $chk = $self->{'fcs_schema'}->table('ConfigConfFile')->search( { 'server_id' => $self->{'serv_info'}->{'server_id'} } );
    if ( my $row = $chk->first )
    {
        $chk->delete;
    }    

    return 1;
}

sub add_basic_roles
{
    my $self = shift;

    return undef if not defined $self->{'serv_info'};
    
    if (not defined $self->{'serv_obj'})
    {
        $self->{'serv_obj'} = Fap::Server->new('server_id' => $self->{'serv_info'}->{'server_id'});
    }
     
    return $self->{'serv_obj'}->add_basic_roles();
}

sub delete_roles
{
    my $self = shift;
    
    return undef if not defined $self->{'serv_info'};
    
    # the ff tables are ON DELETE CASCADE ON UPDATE CASCADE with this table
    # - group_user
    my $rs = $self->{'fcs_schema'}->table('Group')->search( { 'server_id' => $self->{'serv_info'}->{'server_id'} } );
    $rs->delete;
    
    # the ff tables are ON DELETE CASCADE ON UPDATE CASCADE with this table
    # - role_perm
    # - user_role
    # - role_tollrestriction
    $rs = $self->{'fcs_schema'}->table('Role')->search( { 'server_id' => $self->{'serv_info'}->{'server_id'} } );
    while(my $row = $rs->next) 
    {
        $self->{'fcs_schema'}->table('Role')->search( { 'role_id' => $self->{'fcs_schema'}->strip($row)->{'role_id'} } )->delete;
    }
    
    return 1;
}

sub create_cdr
{
    my $self = shift;
    
    return undef if not defined $self->{'serv_info'};

    my $cdrdb = Fap::Model::Cdr->new();
    my $ret = $cdrdb->clone_table('cdr',suffix=>$self->{'serv_info'}->{'server_id'});
    
    if (!defined($ret)) 
    {
        Fap->trace_error("Err: Could not create CDR table.");
        return undef;
    }
    
    $self->{'serv_info'}->{'get_cdrs'} = 1;
    $self->{'fcs_schema'}->table('Server')->search({server_id => $self->{'serv_info'}->{'server_id'}})->update($self->{'serv_info'});
    
    return 1;
}

sub add_audio_group
{
    my $self  = shift;
    my $group = shift;

    my $audio = Fap::Audio->new();

    if (!$audio->add_audio_group($self->{'serv_info'}->{'server_id'}, $group)) {
	Fap->trace_error('Cannot add audio group to ' . $self->{'serv_info'}->{'server_id'});
        return undef;
    }

    return 1;
}

sub remove_audio
{
    my $self = shift;
    
    return undef if not defined $self->{'serv_info'};
    
    my $audio = Fap::Audio->new();
    $audio->purge_all_audio_in_server( $self->{'serv_info'}->{'server_id'} );

    return 1;
}

sub create_virt_device
{
    my $self = shift;

    return undef if not defined $self->{'serv_info'};

    # create the /dev/null device
    my $rs = $self->{'fcs_schema'}->table('Device')->find_or_create({server_id => $self->{'serv_info'}->{'server_id'}, name => '/dev/null', description => 'No Phone', type => 'none'});
    if (!$rs) 
    {
        Fap->trace_error('Cannot create virtual device');
        return undef;
    }

    return 1;
}

sub remove_virt_device
{
    my $self = shift;

    return undef if not defined $self->{'serv_info'};

    # remove all devices for this server
    my $rs = $self->{'fcs_schema'}->table('Device')->find({server_id => $self->{'serv_info'}->{'server_id'}, name => '/dev/null'})->delete();
    if (!$rs) 
    {
        Fap->trace_error('Cannot remove virtual device');
        return undef;
    }

    return 1;
}

sub convert_country
{
    my $self = shift;
    
    my $cnt = length($self->{'dest_add'}->{'country'}) == 2 ? 2 : 3;
    
    my $rs = $self->{'fcs_schema'}->table('Country')->find({"alpha_code_${cnt}" => $self->{'dest_add'}->{'country'}});
    if ($self->{'dest_add'}->{'country_info'} = ($self->{'fcs_schema'}->strip($rs)))
    {
        $self->{'dest_add'}->{'country'} = $self->{'dest_add'}->{'country_info'}->{'alpha_code_3'};
    }    
}

sub server_location_from_customer_location
{
    my $self = shift;
    
    return 'DEV' if lc($self->{'mode'}) eq 'test';

    my $rs = $self->{'fcs_schema'}->table('Datacenter')->search({
        'state_prov' => $self->{'dest_add'}->{'state_prov'},
        'country_id' => $self->{'dest_add'}->{'country_info'}->{'country_id'}
    })->first;

    # Return the appropriate datacenter.  If something goes wrong, default to LA.
    $self->{'datacenter'} = $rs ? $self->{'fcs_schema'}->strip($rs)->{'location'} : "LA";

    return $self->{'datacenter'};
}

sub get_available_host
{
    my $self = shift;
    my $row = undef;
    
    # we select which datacenter will our guest go
    if (lc($self->{'mode'}) ne 'test')
    {
        # was there a pre-select datacenter, then we validate it
        if ($self->{'datacenter'} && lc($self->{'datacenter'}) ne 'dev')
        {
            my $rs = $self->{'fcs_schema'}->table('Datacenter')->search({'location' => $self->{'datacenter'}})->first;
            $self->{'datacenter'} = $self->{'fcs_schema'}->strip($rs)->{'location'};
        }
        
        # lets get the nearest datacenter base from where the orders shipping address since no datacenter was pre-selected
        $self->{'datacenter'} = $self->server_location_from_customer_location() if not $self->{'datacenter'};
    }
    
    # now lets get the host available in this datacenter
    my $rs = $self->{'fcs_schema'}->table('Server')->search(
        {
            "unbound_hosts.server_type" => 'cce',
            "unbound_hosts.location" => $self->{'datacenter'}
        },
        {
            'join'     => [ 'unbound_hosts', 'extensions' ],
            '+select'  => [ { count => 'extensions.extension', -as => 'count' } ],
            'columns'  => [ 'unbound_hosts.server_id' ],
            'select'   => [ 'unbound_hosts.server_id' ],
            'as'       => [ 'server_id' ],
            'group_by' => [ 'server_id' ],
            'order_by' => 'count'
        }
    );
    
    unless ($row = $rs->next)
    {
        # ok we can't relay for the host with the least traffic volume
        # try to get a server that was designated to host our type
        $rs = $self->{'fcs_schema'}->table('UnboundHost')->search(
            {
                "server_type" => 'cce',
                "location" => $self->{'datacenter'}
            }
        );
        $row = $rs->next;
    }

    if ($row)
    {
        my $p = Net::Ping->new("tcp", $timeout);
        $p->{port_num} = 443;
    
        do
        {
            # get the host info
            my $host_rs   = $self->{'fcs_schema'}->table('Server')->find({"server_id" => $self->{'fcs_schema'}->strip($row)->{'server_id'}});
            my $host_info = ($self->{'fcs_schema'}->strip($host_rs));
        
            if ($host_info)
            {
                # lets see if this host is up and running
                ($status) = $p->ping($host_info->{'tun_address'});
                if ($status)
                {
                    return $host_info;
                }
                else
                {
                    ($status) = $p->ping($host_info->{'tun_address2'});
                    if ($status)
                    {
                        return $host_info;
                    }
                }
            }
        } while ($row = $rs->next);
    }
    
    # this is bad, we couldn't get a host for our guest
    Fap->trace_error("Err: Unable to get a host for the system");
    return undef;
}

sub sync_files_to_server
{
    my $self = shift;

    return undef if not defined $self->{'serv_info'};
    
    # trap all STDOUT output from legacy F modules
    my $output = '';
    open TOOUTPUT, '>', \$output;
    select TOOUTPUT;
        
    if ($self->{'product'}->{'deployment'}->{'is_hosted'})
    {
        my $host_server_id = $self->{'serv_info'}->{'mosted'};
        my $sid = $self->{'serv_info'}->{'server_id'};
        my $dbh = $self->{'fcs_schema'}->dbh('pbxtra');
        my $rpc = Fap::Net::RPC::rpc_connect($host_server_id, $dbh);
        if (!$rpc) 
        {
            Fap->trace_error("Cannot connect to $host_server_id");
            $self->{'fcs_schema'}->switch_db('fcs');
            return undef;
        }
        eval 
        {
            # create the /data/$sid/var
            Fap::Net::RPC::mkdir($rpc,$host_server_id, "/data/$sid");
            Fap::Net::RPC::mkdir($rpc,$host_server_id, "/data/$sid/var");
            Fap::Net::RPC::mkdir($rpc,$host_server_id, "/data/$sid/var/lib");
            Fap::Net::RPC::mkdir($rpc,$host_server_id, "/data/$sid/var/lib/asterisk");
            Fap::Net::RPC::mkdir($rpc,$host_server_id, "/data/$sid/var/lib/asterisk/sounds");
            Fap::Net::RPC::mkdir($rpc,$host_server_id, "/data/$sid/var/lib/asterisk/sounds/custom");
            Fap::Net::RPC::mkdir($rpc,$host_server_id, "/data/$sid/var/lib/asterisk/sounds/callscreens");
            Fap::Net::RPC::mkdir($rpc,$host_server_id, "/data/$sid/var/spool");
            Fap::Net::RPC::mkdir($rpc,$host_server_id, "/data/$sid/var/spool/asterisk");
            Fap::Net::RPC::mkdir($rpc,$host_server_id, "/data/$sid/var/spool/asterisk/monitor");
            Fap::Net::RPC::mkdir($rpc,$host_server_id, "/data/$sid/var/spool/asterisk/voicemail");
            Fap::Net::RPC::mkdir($rpc,$host_server_id, "/data/$sid/var/spool/asterisk/voicemail/default-$sid");
            Fap::Net::RPC::system_call($rpc,$host_server_id, "ln -s /data/$sid/var/lib/asterisk/sounds /var/lib/asterisk/sounds/$sid", 1 );
            Fap::Net::RPC::system_call($rpc,$host_server_id, "ln -s /data/$sid/var/lib/asterisk/sounds/custom /var/lib/asterisk/sounds/custom/$sid", 1 );
            Fap::Net::RPC::system_call($rpc,$host_server_id, "ln -s /data/$sid/var/spool/asterisk/voicemail/default-$sid /var/spool/asterisk/voicemail/default-$sid", 1 );
        };
        if ($@) {
            Fap->trace_error("Cannot create /data/$sid in $host_server_id");
            $self->{'fcs_schema'}->switch_db('fcs');
            return undef;
        }

        # copy the default var tar and extract it on the host side
        my $var_filename = "unbound-var.tar";
        my $local_size = (stat("/nfs/mosted/template/$var_filename"))[7];

        # check if file is already on the host
        my $result = Fap::Net::RPC::ls_stat($rpc, $host_server_id, "/etc/asterisk");
        my $remote_size;
        if ($result) {
            $remote_size = $result->{'unbound-var.tar'}->[7];
        } else {
            Fap->trace_error("Cannot run ls_stat on $host_server_id:/etc/asterisk/$var_filename");
            $self->{'fcs_schema'}->switch_db('fcs');
            return undef;
        }

        if ($remote_size != $local_size) 
        {
            # copy the file
            Fap::Net::RPC::copy_file($rpc, $host_server_id, "/nfs/mosted/template/$var_filename", "/etc/asterisk/$var_filename.new", undef, 0);
            if ($@) 
            {
                Fap->trace_error("Cannot copy $filname to $host_server_id: $@");
                $self->{'fcs_schema'}->switch_db('fcs');
                return undef;
            }
            Fap::Net::RPC::mv($rpc, $host_server_id, "/etc/asterisk/$var_filename.new", "/etc/asterisk/$var_filename");
        }

        # extract the tar
        Fap::Net::RPC::system_call($rpc, $host_server_id, "/bin/tar -xpf /etc/asterisk/$var_filename -C /data/$sid/", 1);
    }
    
    my @failed = Fap::Net::RPC::sync_server($self->{'serv_info'}->{'server_id'});
    
    if (scalar @failed)
    {
        Fap->trace_error("Err: ".  (scalar @failed) . " failed to sync server");
        $self->{'fcs_schema'}->switch_db('fcs');
        return undef;
    }
    
    if ($self->{'product'}->{'deployment'}->{'is_hosted'})
    {
        if (not F::Unbound::sync_host_server($self->{'serv_info'}->{'mosted'}))
        {
            Fap->trace_error("Err: Unable to sync host");
            $self->{'fcs_schema'}->switch_db('fcs');
            return undef;
        }
        F::Unbound::reload($self->{'serv_info'}->{'mosted'});
    }
    $self->{'fcs_schema'}->switch_db('fcs');

    # let go of the trap but clean it first
    $output = undef;
    select STDOUT;
    close TOOUTPUT;
    
    return 1;
}

sub drop_server
{
    my $self = shift;
    
    return undef if not defined $self->{'serv_info'};
    
    # removed the entry from our database
    $self->{'fcs_schema'}->table('Server')->search( { 'server_id' => $self->{'serv_info'}->{'server_id'} } )->delete;
    $self->{'serv_info'} = undef;
    
    return 1;
}
1;
