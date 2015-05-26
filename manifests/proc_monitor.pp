# == Definition: snmp::proc_monitor
#
# This definition creates a SNMPv3 user.
#
# === Parameters:
#
# [*title*]
#   This is the name of the process that you want monitored.  The name of the process will be 
#   found running 'ps -e'
#   Required
#
# [*max*]
#
# [*min*]
#
# === Actions:
#
# ALl snmp to monitor processes 
#
# === Requires:
#
# Class['snmp']
#
# === Sample Usage:
#
#   snmp::proc_monitor { 'apache2':
#     max => 2,
#     min => 1 
#   }
#
# === Authors:
#
# Chinedu Uzoka <acuzoka@gmail.com>
#
#
define snmp::proc_monitor (
  $ensure               = 'present',
  $process              = $name,
  $max                  = undef,
  $min                  = undef,
) {

  # Validate our regular expressions
  validate_re($min, '^[0-9]+$|undef', "This type is an integer")
  validate_re($max, '^[0-9]+$|undef', "This type is an integer")

  include snmp
 
  if $max != undef and $min == undef {
    $manage_max = $max
    $manage_min = 0
  } elsif $max =~ /^0$|^undef$/ and $min =~ /^0$|^undef$/ {
    $manage_max = 0
    $manage_min = 0
  } else {
    $manage_max = $max
    $manage_min = $min
  }

  datacat_fragment {"$snmp::snmpd_custom_config-${name}":
    target => "$snmp::snmpd_custom_config",
    data  => {
      "proc_monitor" => {
	"$process" => {
	  max     => $manage_max,
	  min     => $manage_min
	}
      }
    }
  }
}
