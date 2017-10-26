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

class cloud_formation::create_stack (
  Hash $aws = {},
  String $region = lookup('cloud_formation::region'),
  String $security_group_name = lookup('cloud_formation::stack::security_group_name'),
  String $vpc_internet_gateway_name = lookup('cloud_formation::stack::vpc_internet_gateway_name'),
  String $vpc_subnet_name = lookup('cloud_formation::stack::vpc_subnet_name'),
  String $vpc_routetable_name = lookup('cloud_formation::stack::vpc_routetable_name'),
  String $vpc_name = lookup('cloud_formation::stack::vpc_name'),
  String $vpc_dhcp_options_name = lookup('cloud_formation::stack::vpc_dhcp_options_name'),
  Array $instance_names = lookup('cloud_formation::stack::instance_names'),
){
  
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
    cidr_block   => '10.0.0.0/16', # 65531 ips are available
  }

  #This part defines the security group and inbound(ingress) rules to the instance
  #Below ip ranges are given by ScotiaBank network team and they are all ScotiaBank's pubilc ips
  #Below ports 80(http) and 443(https) are being opened to the mentioned ip range
  ec2_securitygroup {$security_group_name:
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

  #Below defines the public subnet within scotia-cds-vpc
  ec2_vpc_subnet {$vpc_subnet_name:
    ensure            => present,
    region            => $region,
    vpc               => $vpc_name,
    cidr_block        => '<IP-CIDR>',
    availability_zone => "${region}b",
    route_table       => $vpc_routetable_name,
  }
  
  #Below defines the internet gateway for scotia-cds-vpc
  ec2_vpc_internet_gateway { $vpc_internet_gateway_name:
    ensure => present,
    region => $region,
    vpc    => $vpc_name,
  }
  
  #Below defines the routing table for scotia-cds-igw created above
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
        gateway                => $vpc_internet_gateway_name
      },
    ],
  }
  
  #Important zone: be careful what you define here. It might be costly!!! 
 
  #Below creates the ec2 instance in above subnet and using  the created security group
  #ami image id should be passed to it depending on what OS needs to be installed
  #instance size can be defined too
  #RHEL7.2: ami-2051294ai(EAST),ami-d1315fb1(WEST), Amazon Linux: ami-f5f41398(EAST), Microsoft Windows Server 2012: ami-e0e00f8d9(EAST)
  #instance type is the size of the instance and can be t2.nano , t2.micro , t2.small, t2.medium, t2.large, ....
  
  ec2_instance { $instance_names:
    ensure          => present,
    image_id        => 'ami-d1315fb1',#RHEL7.2
    associate_public_ip_address => true,
    security_groups => [$security_group_name],
    instance_type   => 't2.micro',
    subnet          => $vpc_subnet_name,
    tags            => {
      department => 'engineering',
      project    => 'cloud',
      created_by => $::id,
    }
  }
  
}
