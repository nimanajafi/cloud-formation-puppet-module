# cloud-formation-puppet-module

#### Table of Contents

1. [Description](#description)
2. [Setup - The basics of getting started with cloud_formation](#setup)
    * [Setup requirements](#setup-requirements)
    * [Beginning with cloud_formation](#beginning-with-cloud_formation)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)

## Description

This module creates and destroys the full stack in AWS. It can create VPC, SecurityGroups, Subnets, VPC Gateway,Route table, and at the end EC2 instance.

## Setup
Modify create.pp and destory.pp under cloud-formation-puppet-module/tests/ with the right aws_access_key_id & aws_secret_access_key for the unit testing. If you use puppet master to send the parameters make sure you are sending these two parameters.

### Setup Requirements

This module depends on cloud-setup-puppet-module.

WARNING: In addition, you need to specify the default region with  export `AWS_REGION=us-east-1`  before you start. You can also choose regions other than "us-east" depending on your needs. 

Users need to put their aws_access_key_id & aws_secret_access_key in cloud-formation-puppet-module/tests/*.pp files to be able to create or delete instances.

### Beginning with cloud_formation

It is easy to create any type of EC2 instance using this module. Users who use this module should know the basics about AWS.

User can create any EC2 instance type with any size in any region. Please choose it knowing that there is cost involved. For AWS cost calculation please go to:
https://calculator.s3.amazonaws.com/index.html


## Usage

Using this module is pretty easy. Depending on what is required, user can modify the below files:

cloud-formation-puppet-module/manifests/create_stack.pp

cloud-formation-puppet-module/manifests/destroy_stack.pp

cloud-formation-puppet-module/manifests/create_cluster.pp

cloud-formation-puppet-module/manifests/destroy_cluster.pp

## Reference

cloud-formation-puppet-module/manifests/init.pp

## Limitations

You need permission to access cloud and user creation by security before you start.

