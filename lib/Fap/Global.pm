package Fap::Global;

use Sys::Hostname;
use strict;

use constant kNFS_MOUNT  => '/etc/fonality';
use constant kCP_VERSION => '12.6';

# cp_location file maps the version number and the cp location
use constant kCP_LOCATION_FILE => '/etc/fonality/cp_location';

# prov vab directory
use constant kPROV_DIRECTORY => $ENV{'PROV_DIRECTORY'}
  ? $ENV{'PROV_DIRECTORY'}
  : '/var/adm/bin/';
use constant kPROV_F_DIRECTORY => $ENV{'PROV_F_DIRECTORY'}
  ? $ENV{'PROV_F_DIRECTORY'}
  : '/code';

# prov phone conf directory
use constant kPHONE_CONFIG_DIRECTORY => '/tftpd';

# hud_version file maps the hud type and current policy released
use constant kHUD_POLICY_FILE            => '/etc/fonality/hud_policy';
use constant kDEFAULT_HUD_PREMISE_POLICY  => '3.5_5237';
use constant kDEFAULT_HUD_HOSTED_POLICY => '3.6_5003';

# email constants
use constant kSYSTEAMS_EMAIL     => 'fnilam@fonality.com';
use constant kSYSTEAMS_EMAIL_TEST     => 'fnilam@fonality.com';
use constant kPROVISIONING_EMAIL => 'fnilam@fonality.com';
use constant kPROVISIONING_EMAIL_TEST => 'fnilam@fonality.com';

# devs who should receive email when an upgrade fails
# Potentially make a ticket automatically? ( support@fonality.com )
use constant kFAILED_UPGRADE_EMAIL_TO => 'failed_upgrades@fonality.com';

# Send emails from; this doesn't matter as all emails should only be sent internally?
use constant kFAILED_EMAIL_FROM => 'donotreply@fonality.com';

# HUD3 path for conf files
my $hud3_conf_path = "hud3.0";

use constant kMINIMUM_VERSION      => '5.2';
use constant kLOG_LOCATION         => "/tmp/upgrade_installer.log";
use constant kSYSTEM_LOG_LOCATION  => '/tmp/system_upgrade_installer.log';
use constant kUPGRADE_ERR_STR      => '[FONALITY_FAIL]';
use constant kUPGRADE_WIN_STR      => '[FONALITY_COMPLETE]';
use constant kYUM_DIR              => '/etc/yum.repos.d/';
use constant kDEFAULT_HOST_VERSION => '2010.1.2';                            #2010.1.2 is default since this is the first 2010.1.x

# For updates, we need to pull the update via http.
use constant kPBXTRA_RPM_SERVER => 'http://yum.fonality.com/';
use constant kTBPRO_RPM_SERVER  => 'http://yum.trixbox.com/';

# Slow: 30 minutes; Medium: 5 minutes; Fast: 30 seconds
use constant kUPGRADE_SLOW_TIMER => 1800;
use constant kUPGRADE_MEDM_TIMER => 300;
use constant kUPGRADE_FAST_TIMER => 30;

# Special timer for asterisk. 240 seconds.
use constant kUPGRADE_ASTK_TIMER => 240;

# Special timer for file expire age
use constant kFILE_EXPIRE_AGE => 86400;

# Default banner to use when we can't find one.
use constant kDEFAULT_BANNER =>
  "An upgrade is available for your BRANDING_SOFTWARE_NAME! Please <a class=text href='./cpa.cgi?do=opt&update_installer=1'>click here</a> to learn more.";
use constant kLBS_BANNER => 3;

use constant kHAS_BACKUP_FILE  => '/etc/asterisk/standby';
use constant kIS_BACKUP_FILE   => '/etc/asterisk/primary';
use constant kOLD_BACKUP_FILE  => '/etc/standby';
use constant kCOUNTRY_LANGUAGE => { 'default' => 'en', 'jp' => 'jp', 'au' => 'au' };
use constant kDEFAULT_TIMEZONE => '/usr/share/zoneinfo/America/Los_Angeles';

# Collector API
use constant kCOLLECTOR_API_BASE => 'http://cp.test21.fonality.com/collector';
use constant kCOLLECTOR_API_USER => 'dev';
use constant kCOLLECTOR_API_KEY  => '0bce4abc80a807e1ef63ac2c05b04af1';

use constant kUNBOUND_BACKUP_PATH => '/nfs/unbound/backups';

use constant kDID_TYPE => { 'local' => 'did_local', 'international' => 'did_international', 'tollfree' => 'did_tollfree'};

1;
