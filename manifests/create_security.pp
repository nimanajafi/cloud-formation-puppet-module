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
# 
#

class cloud_formation::create_security (
  Hash $aws = {},
  String $region = lookup('cloud_formation::region'),
  String $security_group_name = lookup('cloud_formation::security::security_group_name'),
  String $vpc_internet_gateway_name = lookup('cloud_formation::security::vpc_internet_gateway_name'),
  String $vpc_subnet_name = lookup('cloud_formation::security::vpc_subnet_name'),
  String $vpc_routetable_name = lookup('cloud_formation::security::vpc_routetable_name'),
  String $vpc_name = lookup('cloud_formation::security::vpc_name'),
  String $vpc_dhcp_options_name = lookup('cloud_formation::security::vpc_dhcp_options_name'),
) {

  $trust_relationship = file("${module_name}/document.json")

  Ec2_securitygroup {
    region => $region,
  }

  Ec2_instance {
    region            => $region,
    availability_zone => "${region}b",
  }
  
  #Define the vpc group and Classless Inter-domain Routing
  ec2_vpc { $vpc_name:
    ensure       => present,
    region       => $region,
    cidr_block   => '<IP-CIDR>',
  }

  #Below ports 80(http) and 443(https) are being opened to the given ip range
  ec2_securitygroup { $security_group_name:
    ensure      => present,
    region      => $region,
    vpc         => $vpc_name,
    description => 'Security group for VPC',
    ingress     => [{
      security_group => $security_group_name,
    },{
      protocol => 'tcp',
      port     => 80,
      cidr     => '<IP-range-1>'
    },{
      protocol => 'tcp',
      port     => 80,
      cidr     => '<IP-range-2>'
    },{
      protocol => 'tcp',
      port     => 80,
      cidr     => '<IP-range-3>'
    },{
      protocol => 'tcp',
      port     => 80,
      cidr     => '<IP-range-4>'
    },{
      protocol => 'tcp',
      port     => 80,
      cidr     => '<IP-range-5>'
    },{
      protocol => 'tcp',
      port     => 443,
      cidr     => '<IP-range-1>'
    },{
      protocol => 'tcp',
      port     => 443,
      cidr     => '<IP-range-2>'
    },{
      protocol => 'tcp',
      port     => 443,
      cidr     => '<IP-range-3>'
    },{
      protocol => 'tcp',
      port     => 443,
      cidr     => '<IP-range-4>'
    },{
      protocol => 'tcp',
      port     => 443,
      cidr     => '<IP-range-5>'
    }

    ]
  }
  
  #Below defines the public subnet
  ec2_vpc_subnet { $vpc_subnet_name:
    ensure            => present,
    region            => $region,
    vpc               => $vpc_name,
    cidr_block        => '<IP-CIDR>',
    availability_zone => "${region}b",
    route_table       => $vpc_routetable_name,
  }
  
  #Below defines the internet gateway
  ec2_vpc_internet_gateway { $vpc_internet_gateway_name:
    ensure => present,
    region => $region,
    vpc    => $vpc_name,
  }

  #Below defines the routing table
  ec2_vpc_routetable { $vpc_routetable_name:
    ensure => present,
    region => $region,
    vpc    => $vpc_name,
    routes => [
      {
        destination_cidr_block => '<IP-CIDR>',
        gateway                => 'local'
      },{
        destination_cidr_block => '<IP-CIDR>',
        gateway                =>  $vpc_internet_gateway_name
      },
    ],
  }

}
