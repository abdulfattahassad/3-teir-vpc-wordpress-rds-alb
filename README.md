﻿# 3-tier-vpc-wordpress-rds-alb
VPC has three catagories  of subnets distributed in avaiability zones .
Public Subnets which use to reside Application load Balancer
Private Subnets : wordpress application OR normal HTML File
Database Subnets : RDS with Mysql to save information from wordpress.

## This Terraform use functions :
- cidrsubnet : just change VPC varible such as 10.00.0.0/16  - via using this function , automatically 
subnets will be created
- element to distribute subnets with avaiabilty zones.

# Bastion Host
used to access EC2 instances / RDS via Bastian host 


