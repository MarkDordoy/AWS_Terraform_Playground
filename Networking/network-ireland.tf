resource "aws_vpc" "eu_west1_vpc" {
    cidr_block           = "10.0.0.0/16"
    enable_dns_support   = true
    enable_dns_hostnames = true

    tags = {
        Name = "eu-west1-vpc"
    }
}

resource "aws_subnet" "subnet_public_eu_west1_az_a" {
    vpc_id              = aws_vpc.eu_west1_vpc.id
    cidr_block          = "10.0.1.0/24"
    availability_zone   = "eu-west-1a"

    tags = {
        PublicSubnet = "true"
        Name         = "eu-west-1a-public"
    }
}

resource "aws_subnet" "subnet_public_eu_west1_az_b" {
    vpc_id              = aws_vpc.eu_west1_vpc.id
    cidr_block          = "10.0.2.0/24"
    availability_zone   = "eu-west-1b"

    tags = {
        PublicSubnet = "true"
        Name         = "eu-west-1b-public"
    }
}

resource "aws_subnet" "subnet_private_eu_west1_az_a" {
    vpc_id              = aws_vpc.eu_west1_vpc.id
    cidr_block          = "10.0.3.0/24"
    availability_zone   = "eu-west-1a"

    tags = {
        PublicSubnet = "false"
        Name         = "eu-west-1a-private"
    }
}

resource "aws_subnet" "subnet_private_eu_west1_az_b" {
    vpc_id              = aws_vpc.eu_west1_vpc.id
    cidr_block          = "10.0.4.0/24"
    availability_zone   = "eu-west-1b"

    tags = {
        PublicSubnet = "false"
        Name         = "eu-west-1b-private"
    }
}

resource "aws_internet_gateway" "eu_west1_igw" {
    vpc_id  = aws_vpc.eu_west1_vpc.id

    tags    = {
        Name = "eu-west1-gateway"
    }
}

resource "aws_eip" "nat_gateway_eu-west1_eip" {
    vpc         = true
    depends_on  = [aws_internet_gateway.eu_west1_igw]
}

resource "aws_nat_gateway" "nat_gateway_eu-west1" {
    subnet_id       = aws_subnet.subnet_public_eu_west1_az_a.id
    allocation_id   = aws_eip.nat_gateway_eu-west1_eip.id

    tags = {
        Name = "NATGateway_eu-west1a"
    }

    depends_on      = [aws_internet_gateway.eu_west1_igw]
}

resource "aws_route" "internet_access" { 
    route_table_id          = aws_vpc.eu_west1_vpc.main_route_table_id
    destination_cidr_block  = "0.0.0.0/0"
    gateway_id              = aws_internet_gateway.eu_west1_igw.id
}

resource "aws_route_table" "private_route_table" { 
    vpc_id              = aws_vpc.eu_west1_vpc.id
    tags = {
        Name = "Private route table"
    }
}

resource "aws_route" "private_route" {
    route_table_id          = aws_route_table.private_route_table.id
    destination_cidr_block  = "0.0.0.0/0"
    nat_gateway_id          = aws_nat_gateway.nat_gateway_eu-west1.id
}

resource "aws_route_table_association" "public_subnet_euw1_aza_association" {
    subnet_id       = aws_subnet.subnet_public_eu_west1_az_a.id
    route_table_id  = aws_vpc.eu_west1_vpc.main_route_table_id
}

resource "aws_route_table_association" "public_subnet_euw1_azb_association" {
    subnet_id       = aws_subnet.subnet_public_eu_west1_az_b.id
    route_table_id  = aws_vpc.eu_west1_vpc.main_route_table_id
}

resource "aws_route_table_association" "private_subnet_euw1_aza_association" {
    subnet_id       = aws_subnet.subnet_private_eu_west1_az_a.id
    route_table_id  = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "private_subnet_euw1_azb_association" {
    subnet_id       = aws_subnet.subnet_private_eu_west1_az_b.id
    route_table_id  = aws_route_table.private_route_table.id
}