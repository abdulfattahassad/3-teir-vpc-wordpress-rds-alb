
data "aws_availability_zones" "available" {
 
}

#### Basic VPC Config#####
resource "aws_vpc" "main" {
  enable_dns_hostnames                 = var.enable_dns_hostnames
  enable_dns_support                   = var.enable_dns_support
  cidr_block       = var.vpc_cidr
  tags = {
    Name = var.vpc_name   
  }
}


##### Create AZ,Public-Subnet, Private-Subnet, DB-Subnet via cirdrsubnet and element functions ####

data "aws_availability_zones" "with" {
}

resource "aws_subnet" "private_subnets" {
count = var.private_subnets_number

vpc_id = aws_vpc.main.id
cidr_block = cidrsubnet(var.vpc_cidr,var.in_subnets_max,count.index)
availability_zone = element(data.aws_availability_zones.with.names,count.index)

tags = {
  Name = "private_subnet  ${format("%02d", count.index + 1)}"
}

 map_public_ip_on_launch = true


}


resource "aws_subnet" "public_subnets" {
count = var.public_subnets_number

vpc_id = aws_vpc.main.id
cidr_block = cidrsubnet(var.vpc_cidr,var.in_subnets_max,var.public_subnets_number+1+ count.index)
availability_zone = element(data.aws_availability_zones.with.names,count.index)

tags = {
  Name = "public_subnet  ${format("%02d", count.index + 1)}"
}

 map_public_ip_on_launch = true

}


resource "aws_subnet" "database_subnets" {
count = var.database_subnets_number

vpc_id = aws_vpc.main.id
cidr_block = cidrsubnet(var.vpc_cidr,var.in_subnets_max,var.database_subnets_number+var.public_subnets_number+2+count.index)
availability_zone = element(data.aws_availability_zones.with.names,count.index)

tags = {
  Name = "database_subnet  ${format("%02d", count.index + 1)}"
}


}




### Create Elastic IP addresses for NAT_Gateways ####
resource "aws_eip" "eip" {

    count = var.private_subnets_number
    domain = "vpc"
  
depends_on = [ aws_internet_gateway.igw ]


}
  

##### Create NAT Gateway#######

resource "aws_nat_gateway" "nat_gateway" {

    count = var.private_subnets_number

    allocation_id = element( aws_eip.eip.*.id, count.index )
    subnet_id     = element( (aws_subnet.public_subnets.*.id), count.index )

tags = {
  Name = "nat_gateway ${format("%02d", count.index + 1)}"
}

depends_on = [ aws_internet_gateway.igw ]
}
  
###### Create IGW #####

resource "aws_internet_gateway" "igw" {

  
    vpc_id = aws_vpc.main.id
tags = {
  Name = "IGW"
}

}


#### create Route Table for Private_subnet ###
  resource "aws_route_table" "rt_private_subnet" {
  vpc_id = aws_vpc.main.id

  count = var.private_subnets_number
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.nat_gateway.*.id,count.index)
  }

  

  tags = {
    Name = "rt-private_subnet"
  }
}


resource "aws_route_table_association" "rt_private_subnet_asso" {
  count=var.private_subnets_number
  
  subnet_id      = element(aws_subnet.private_subnets.*.id,count.index)
  route_table_id = element (aws_route_table.rt_private_subnet.*.id,count.index)
}




#### create Route Table for Public_subnet  ###
  resource "aws_route_table" "rt_public_subnet" {
  vpc_id = aws_vpc.main.id

  count = var.public_subnets_number
  route {
    cidr_block = "0.0.0.0/0"
   gateway_id = aws_internet_gateway.igw.id
  }

  

  tags = {
    Name = "rt-public_subnet ,"
  }
}


resource "aws_route_table_association" "rt_public_subnet_asso" {
  count=var.public_subnets_number
  
  subnet_id      = element(aws_subnet.public_subnets.*.id,count.index)
  route_table_id = element (aws_route_table.rt_public_subnet.*.id,count.index)
}

#### create Route Table for Database_subnet  ###
  resource "aws_route_table" "rt_database_subnet" {
  vpc_id = aws_vpc.main.id

  count = var.database_subnets_number
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.nat_gateway.*.id,count.index)
  }

  

  tags = {
    Name = "rt-database_subnet"
  }
}


resource "aws_route_table_association" "rt_database_subnet_asso" {
  count=var.database_subnets_number
  
  subnet_id      = element(aws_subnet.database_subnets.*.id,count.index)
  route_table_id = element (aws_route_table.rt_database_subnet.*.id,count.index)
}
  
