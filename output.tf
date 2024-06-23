output "Websitelink"{
value = aws_lb.external_ALB.dns_name
description = "Web Server IP Address"
}


output "DatabaseName" {
    value = aws_db_instance.default.*.db_name
    description = "DB IP Address"
}


output "DatabaseUsername" {
    value = aws_db_instance.default.*.username
    description = "DB IP Address"
}


output "Databasestring" {
    value = aws_db_instance.default.*.endpoint
    description = "DB IP Address"
}



