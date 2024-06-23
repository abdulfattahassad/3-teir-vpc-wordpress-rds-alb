variable "vpc_cidr" {
    default  =  "10.100.0.0/16"
    type = string
  
}

variable "vpc_name" {
    default  =  "main"
  
}

variable "enable_dns_hostnames" {
    type = bool
    default = true
  
}

variable "enable_dns_support" {
    type = bool
    default = true
  
}


#### Configure Variable  for private_subnets_number  should be equal database_subnets_number AND public_subnets_number###


variable private_subnets_number {

    description = "The number of private subnets to create (defaults to 3 if not specified)."
    default     =  2
    type        = number
}



variable public_subnets_number {

    description = "The number of public subnets to create (defaults to 3 if not specified)."
    default     = 2
    type        = number
}

variable "database_subnets_number" {
    default = 2
    type = number
  
}

variable in_subnets_max {

    description = "use with cidersubnet function to make the subnetmask for subnets."
    default     = 8
    type        = number
}


variable "ingress" {

    type = list(number)
  
     default = [ 80,22,443 ]
}

variable "SL-Names" {
    
type = list(number)
default = [ 80, 22 ]

  
          
} 




variable "dbadmin" {
    
type = string
default = "admin"
  
          
} 


variable "dbpassword" {
    
type = string
default = "adminadminadmin"
  
          
} 


  





variable IGW {

    description = "An internet gateway and route is created unless this variable is supplied as false."
    default     = true
    type        = bool
}


variable "userdata_file" {
  type = string
  
  #default = "normal_web_server_script.sh"
  default = "wordpressupdate.sh"
}




