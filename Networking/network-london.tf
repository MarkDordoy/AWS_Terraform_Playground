resource "aws_vpc" "eu_west2_vpc" {
    provider             = aws.london
    cidr_block           = "10.1.0.0/16"
    enable_dns_support   = true
    enable_dns_hostnames = true

    tags = {
        Name = "eu-west2-vpc"
    }
}

resource "aws_subnet" "subnet_public_eu_west2_az_a" {
    provider            = aws.london
    vpc_id              = aws_vpc.eu_west2_vpc.id
    cidr_block          = "10.1.1.0/24"
    availability_zone   = "eu-west-2a"

    tags = {
        PublicSubnet = "true"
        Name         = "eu-west-2a-public"
    }
}

resource "aws_subnet" "subnet_public_eu_west2_az_b" {
    provider            = aws.london
    vpc_id              = aws_vpc.eu_west2_vpc.id
    cidr_block          = "10.1.2.0/24"
    availability_zone   = "eu-west-2b"

    tags = {
        PublicSubnet = "true"
        Name         = "eu-west-2b-public"
    }
}

resource "aws_subnet" "subnet_private_eu_west2_az_a" {
    provider            = aws.london
    vpc_id              = aws_vpc.eu_west2_vpc.id
    cidr_block          = "10.1.3.0/24"
    availability_zone   = "eu-west-2a"

    tags = {
        PublicSubnet = "false"
        Name         = "eu-west-2a-private"
    }
}

resource "aws_subnet" "subnet_private_eu_west2_az_b" {
    provider            = aws.london
    vpc_id              = aws_vpc.eu_west2_vpc.id
    cidr_block          = "10.1.4.0/24"
    availability_zone   = "eu-west-2b"

    tags = {
        PublicSubnet = "false"
        Name         = "eu-west-2b-private"
    }
}

resource "aws_internet_gateway" "eu_west2_igw" {
    provider    = aws.london
    vpc_id      = aws_vpc.eu_west2_vpc.id

    tags = {
        Name = "eu-west2-gateway"
    }
}

resource "aws_eip" "nat_gateway_eu-west2_eip" {
    provider    = aws.london
    vpc         = true

    depends_on  = [aws_internet_gateway.eu_west2_igw]
}

resource "aws_nat_gateway" "nat_gateway_eu_west2" {
    provider        = aws.london
    subnet_id       = aws_subnet.subnet_public_eu_west2_az_a.id
    allocation_id   = aws_eip.nat_gateway_eu-west2_eip.id
    
    tags = {
        Name = "NATGateway_eu-west2a"
    }
    
    depends_on      = [aws_internet_gateway.eu_west2_igw]
}

resource "aws_route" "internet_access_eu_west2" { 
    provider                = aws.london
    route_table_id          = aws_vpc.eu_west2_vpc.main_route_table_id
    destination_cidr_block  = "0.0.0.0/0"
    gateway_id              = aws_internet_gateway.eu_west2_igw.id
}

resource "aws_route_table" "private_route_table_eu_west2" { 
    provider    = aws.london
    vpc_id      = aws_vpc.eu_west2_vpc.id

    tags = {
        Name = "Private route table"
    }
}

resource "aws_route" "private_route_eu_west2" {
    provider                = aws.london
    route_table_id          = aws_route_table.private_route_table_eu_west2.id
    destination_cidr_block  = "0.0.0.0/0"
    nat_gateway_id          = aws_nat_gateway.nat_gateway_eu_west2.id
}

resource "aws_route_table_association" "public_subnet_euw2_aza_association" {
    provider        = aws.london
    subnet_id       = aws_subnet.subnet_public_eu_west2_az_a.id
    route_table_id  = aws_vpc.eu_west2_vpc.main_route_table_id
}

resource "aws_route_table_association" "public_subnet_euw2_azb_association" {
    provider        = aws.london
    subnet_id       = aws_subnet.subnet_public_eu_west2_az_b.id
    route_table_id  = aws_vpc.eu_west2_vpc.main_route_table_id
}

resource "aws_route_table_association" "private_subnet_euw2_aza_association" {
    provider        = aws.london
    subnet_id       = aws_subnet.subnet_private_eu_west2_az_a.id
    route_table_id  = aws_route_table.private_route_table_eu_west2.id
}

resource "aws_route_table_association" "private_subnet_euw2_azb_association" {
    provider        = aws.london
    subnet_id       = aws_subnet.subnet_private_eu_west2_az_b.id
    route_table_id  = aws_route_table.private_route_table_eu_west2.id
}