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

class cloud_formation::create_cluster (
  Hash $aws = {},
  String $region = lookup('cloud_formation::region'),
  String $cluster_name = lookup('cloud_formation::cluster::cluster_name'),
  String $iam_role_name = lookup('cloud_formation::cluster::iam_role_name'),
  String $security_group_name = lookup('cloud_formation::cluster::security_group_name'),
  String $vpc_internet_gateway_name = lookup('cloud_formation::cluster::vpc_internet_gateway_name'),
  String $vpc_subnet_name = lookup('cloud_formation::cluster::vpc_subnet_name'),
  String $vpc_routetable_name = lookup('cloud_formation::cluster::vpc_routetable_name'),
  String $vpc_name = lookup('cloud_formation::cluster::vpc_name'),
  String $vpc_dhcp_options_name = lookup('cloud_formation::cluster::vpc_dhcp_options_name'),
  String $task_definition_name = lookup('cloud_formation::cluster::task_definition_name'),
  Array $instance_names = lookup('cloud_formation::cluster::instance_names'),
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
    cidr_block   => '10.0.0.0/16',
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
  
  #Important zone: be careful what you define here. It might be costly!!! 
 
  #Below is where cluster is being created in couple of sequential steps
  #Step1:Creates the ECS cluster by calling ecs_cluster resource (custom type and provider written in ruby) 
  #Step2:Creates the IAM roles by calling iam_role resource (custom type and provider written in ruby)
  #Step3:Create amazon-ecs-optimized ec2 instance
  #Step4:Create task definition (A task definition is required to run Docker containers in Amazon ECS)(custom type and provider written in ruby)
  #Step5:Create run resource to run the task definition
  
  ecs_cluster { $cluster_name:
    ensure => 'present',
    region => $region,
  }->  
  iam_role{ $iam_role_name:
    ensure             => 'present',
    path               => '/',
    policy             => 'AmazonEC2ContainerServiceforEC2Role',
    trust_relationship => $trust_relationship 
  }->    
  ec2_instance { $instance_names:
    ensure                      => present,
    image_id                    => 'ami-xxxxxxxxx',
    associate_public_ip_address => true,
    user_data                   => template("${module_name}/userdata.erb"),
    iam_instance_profile_name   => $iam_role_name,
    security_groups             => [$security_group_name],
    instance_type               => 'G2/P/....',
    subnet                      => $vpc_subnet_name,
    tags                        => {
      department => 'engineering',
      project    => 'cloud',
      created_by => $::id,
    }
  }->
  ecs_task_definition { $task_definition_name:
    ensure     => 'present',
    containers => [{
       command                 => [''], 
       cpu                     => '1', 
       disable_networking      => '', 
       dns_search_domains      => [], 
       dns_servers             => [], 
       docker_labels           => {}, 
       docker_security_options => [], 
       entry_point             => [], 
       environment             => [], 
       essential               => 'true', 
       extra_hosts             => [], 
       hostname                => 'apache-server', 
       image                   => '73125xyzttta.dkr.ecr.us-east-1.amazonaws.com/test:22.0', 
       links                   => [], 
       memory                  => '100', 
       mount_points            => [], 
       name                    => 'cds_cont', 
       port_mappings           => [{
         container_port => 80, 
         host_port      => 80, 
         protocol       => "tcp"
       }], 
       privileged               => '', 
       readonly_root_filesystem => '', 
       ulimits                  => [], 
       volumes_from             => [], 
       },
    ],
    region     => $region,
  }->
  ecs_run_task { $task_definition_name:
    ensure       => 'present',
    cluster_name => $cluster_name,
    command      => 'httpd-foreground',
    region       => $region,
    count        => '1'
  }

}
