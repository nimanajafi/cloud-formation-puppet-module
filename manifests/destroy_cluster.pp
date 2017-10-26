# Destroy the cluster

class cloud_formation::destroy_cluster(
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


  Ec2_securitygroup {
    region => $region,
  }

  Ec2_instance {
    region => $region,
  }
  
  ecs_run_task { $task_definition_name:
    ensure       => 'absent',
    cluster_name => $cluster_name,
    region       => $region,
  } ~>

  ecs_task_definition { $task_definition_name:
    ensure     => 'absent',
    region     => $region,
  } ~>

  ec2_instance { $instance_names:
    ensure => absent,
  } ~>

  iam_role { $iam_role_name:
    ensure => 'absent',
    path   => '/',
    policy => 'AmazonEC2ContainerServiceforEC2Role',
  } ~>
  
  ecs_cluster { $cluster_name:
    ensure => 'absent',
    region => $region,
  }  

  ec2_securitygroup { $security_group_name:
    ensure   => absent,
    region => $region,
  } ~>

  ec2_vpc_internet_gateway { $vpc_internet_gateway_name:
    ensure => absent,
    region => $region,
  } ~>

  ec2_vpc_subnet { $vpc_subnet_name:
    ensure => absent,
    region => $region,
  } ~>

  ec2_vpc_routetable { $vpc_routetable_name:
    ensure => absent,
    region => $region,
  } ~>

  ec2_vpc { $vpc_name:
    ensure => absent,
    region => $region,
  } ~>

  ec2_vpc_dhcp_options { $vpc_dhcp_options_name:
    ensure => absent,
    region => $region,
  }

}
