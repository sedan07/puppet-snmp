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
  $max                  = 0, 
  $min                  = 0 
) {

  include snmp

  if !is_numeric($max) { fail ("Invalid value for max, ${max}") }
  if !is_numeric($min) { fail ("Invalid value for min, ${min}") }

  datacat_fragment {"$snmp::snmpd_custom_config-${name}":
    target => "$snmp::snmpd_custom_config",
    data  => {
      "proc_monitor" => {
	"$process" => {
	  max     => $max,
	  min     => $min
	}
      }
    }
  }
}
