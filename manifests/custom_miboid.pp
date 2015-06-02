# == Definition: snmp::custom_miboid
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
# [*miboid*]
#   If MIBOID is specified, then the configuration and result tables will be rooted at this 
#   point in the OID tree, but are otherwise structured in exactly the same way. This means 
#   that several separate extend directives can specify the same MIBOID root, without conflicting.
#   Optional:
#
# [*file_script*]
#   This is name of the script. This value must be unique.  Do not include the scripts path 
#   name as the path name is hardcoded to "/usr/local/sbin".  This is used whether or not 
#   the *prog* parameter is used or not
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
# === Examples
#
# If the variable $snmp::snmpd_include_template_dir is set then the scripts file will be taken from 
# this templates location - if this variable is not set then it will be taken from this modules template
# location
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
#     file_script => 'googlepingdom.sh',
#     index_name  => 'google',
#     prog        => '/bin/ping',
#     args        => '-c1 www.google.com'
#   }
#
# === Authors:
#
# Chinedu Uzoka <acuzoka@gmail.com>
#
#
define snmp::custom_miboid (
  $ensure               = 'present',
  $index_name           = $name,
  $miboid               = '',
  $file_script          = undef, 
  $script_template_dir  = undef,
  $prog                 = undef, 
  $args                 = "" 
) {

  # Validate our regular expressions

  include snmp

  if $file_script != undef {

    if $script_template_dir == undef {
      $manage_template = "$module_name/${file_script}"
    } else {
      $manage_template = "${script_template_dir}/${file_script}"
    }

    $manage_prog = "/usr/local/sbin/${file_script}"

    if defined(File["$manage_prog"]) != false  {
      file { "${title}-snmp-script":
	ensure  => $ensure,
	path    => $manage_prog, 
	content => template("$manage_template"),
	mode    => '0755',
	owner   => 'root',
	group   => 'root',
      }
    } 
   
  } elsif $prog != undef {
    $manage_prog = $prog
  } else {
    fail ("You must specify the full path of a script or pre-installed command to use")
  }

  datacat_fragment {"$snmp::snmpd_custom_config-${name}":
    target => "$snmp::snmpd_custom_config",
    data  => {
      "custom_miboid" => {
	"$title" => {
	  index_name => $index_name,
          miboid     => $miboid,
	  prog       => $manage_prog,
	  args       => $args
	}
      }
    }
  }
}
