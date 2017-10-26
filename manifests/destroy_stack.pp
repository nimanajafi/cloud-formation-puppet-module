#Destroy the stack

class cloud_formation::destroy_stack(
  String $region = lookup('cloud_formation::region'),
  String $security_group_name = lookup('cloud_formation::stack::security_group_name'),
  String $vpc_internet_gateway_name = lookup('cloud_formation::stack::vpc_internet_gateway_name'),
  String $vpc_subnet_name = lookup('cloud_formation::stack::vpc_subnet_name'),
  String $vpc_routetable_name = lookup('cloud_formation::stack::vpc_routetable_name'),
  String $vpc_name = lookup('cloud_formation::stack::vpc_name'),
  String $vpc_dhcp_options_name = lookup('cloud_formation::stack::vpc_dhcp_options_name'),
  Array  $instance_names = lookup('cloud_formation::stack::instance_names'),
){


  Ec2_securitygroup {
    region => $region,
  }

  Ec2_instance {
    region => $region,
  }

  ec2_instance { $instance_names:
    ensure => absent,
  } ~>

  ec2_securitygroup { $security_group_name:
    ensure => absent,
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
