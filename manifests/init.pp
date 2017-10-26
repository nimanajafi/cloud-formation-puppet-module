# Class: cloud_formation
# ===========================
#
# Full description of class cloud_formation here.
#
# Parameters
# ----------
#
# Document parameters here.
#
# * `sample parameter`
# Explanation of what this parameter affects and what it defaults to.
# e.g. "Specify one or more upstream ntp servers as an array."
#
# Variables
# ----------
#
# Here you should define a list of variables that this module would require.
#
# * `sample variable`
#  Explanation of how this variable affects the function of this class and if
#  it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#  External Node Classifier as a comma separated list of hostnames." (Note,
#  global variables should be avoided in favor of class parameters as
#  of Puppet 2.6.)
#
# Examples
# --------
#
# @example
#    class { 'cloud_formation':
#      servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#    }
#
# Authors
# -------
#
# Author Name <author@domain.com>
#
# Copyright
# ---------
#
# Copyright 2016 Your name here, unless otherwise noted.
#
#  aws => { aws_access_key_id => 'test12', 
#          aws_secret_access_key => 'test123',
#  }


class cloud_formation (
  String $type ,
  Hash $aws = {},
  String $status = 'present',
){

  class{'cloud_setup':
    option => 'aws',
    aws => $aws
  }

  case $status {
    'present' : {
      class{"cloud_formation::create_${type}": require => Class['cloud_setup']}
    }
    'absent' : {
      class{"cloud_formation::destroy_${type}": require => Class['cloud_setup']}
    }
    default : {
      fail('Please provide an option [present or absent]')
    }

  }
}
