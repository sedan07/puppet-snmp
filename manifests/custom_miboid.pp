# == Definition: snmp::snmpv3_user
#
# This definition creates a SNMPv3 user.
#
# === Parameters:
#
# [*title*]
#   Effectively this is the name of the index (since we will be using the EXTEND function)
#   that will reference the script that snmp will run 
#   Required
#
# [*script*]
#   This name of the script. Do not include the scripts path name as this is hardcoded
#   This value overrides whatever value is given to *prog*
#
# [*index_name*]
#   This is the name of the index i.e NET-SNMP-EXTEND-MIB::nsExtendResult."googleping"' 
#   Default: $title
#
# [*prog*]
#   If *script* parameter is not specified then the fully qualified path a command i.e "/bin/ping" 
#   must be used here
#   Default: $title 
#
# [*args*]
#   An array of arguments supported by the script 
#   Default: []
#
# === Actions:
#
# Create a custom snmp configuration file thats used to extend snmp 
#
# === Requires:
#
# Class['snmp']
#
# === Sample Usage:
#
#   snmp::custom_miboid { 'googleping':
#     script     => 'googlepingdom.sh',
#     index_name => 'google',
#     prog       => '/bin/ping',
#     args       => '-c1 www.google.com'
#   }
#
# === Authors:
#
# Chinedu Uzoka <acuzoka@gmail.com>
#
#
define snmp::custom_miboid (
  $ensure     = 'present',
  $script     = undef, 
  $index_name = $name,
  $prog       = undef, 
  $args       = "" 
) {

  # Validate our regular expressions

  include snmp

  if $script != undef {

    $manage_prog = "/usr/local/sbin/${script}"

    file { "${script}-snmp-script":
      ensure => $ensure,
      source => template("snmp/${script}"),
      target => "/usr/local/sbin/${script}",
      mode   => '0755',
      owner  => 'root',
      group  => 'root',
    }

  } elsif $prog != undef {
    $manage_prog = $prog
  } else {
    fail ("You must specify either a script or a pre-installed command to use")
  }

  datacat_fragment {"$snmp::snmpd_custom_config-${name}":
    target => "$snmp::snmpd_custom_config",
    data  => {
      "$title" => {
        index_name => $index_name,
        prog       => $manage_prog,
        args       => $args
      }
    }
  }
}
