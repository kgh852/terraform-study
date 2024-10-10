resource "aws_vpc" "wsi-vpc" {
    cidr_block = "10.1.0.0/16"

    tags = {
        Name = "wsi-vpc"
    }
}

resource "aws_subnet" "wsi-public-a" {
    vpc_id = aws_vpc.wsi-vpc.id
    cidr_block = "10.1.2.0/24"
    availability_zone = "ap-northeast-2a"
    map_public_ip_on_launch = true

    tags = {
        Name = "wsi-public-a"
    }
}

resource "aws_subnet" "wsi-public-b" {
    vpc_id = aws_vpc.wsi-vpc.id
    cidr_block = "10.1.3.0/24"
    availability_zone = "ap-northeast-2b"
    map_public_ip_on_launch = true

    tags = {
        Name = "wsi-public-b"
    }
}

resource "aws_subnet" "wsi-private-a" {
    vpc_id = aws_vpc.wsi-vpc.id
    cidr_block = "10.1.0.0/24"
    availability_zone = "ap-northeast-2a"
    map_public_ip_on_launch = true

    tags = {
        Name = "wsi-private-a"
    }
}

resource "aws_subnet" "wsi-private-b" {
    vpc_id = aws_vpc.wsi-vpc.id
    cidr_block = "10.1.1.0/24"
    availability_zone = "ap-northeast-2b"
    map_public_ip_on_launch = true

    tags = {
        Name = "wsi-private-b"
    }
}

resource "aws_internet_gateway" "wsi-igw" {
    vpc_id = aws_vpc.wsi-vpc.id

    tags = {
        Name = "wsi-igw"
    }
}

resource "aws_eip" "wsi-eip-a" {
    vpc = true
}

resource "aws_eip" "wsi-eip-b" {
    vpc = true
}

resource "aws_nat_gateway" "wsi-private-ngw-a" {
    allocation_id = aws_eip.wsi-eip-a.id
    subnet_id = aws_subnet.wsi-public-a.id

    tags = {
        Name = "wsi-ngw-a"
    }
}

resource "aws_nat_gateway" "wsi-private-ngw-b" {
    allocation_id = aws_eip.wsi-eip-b.id
    subnet_id = aws_subnet.wsi-public-b.id

    tags = {
        Name = "wsi-ngw-b"
    }
}

resource "aws_route_table" "wsi-public-rt" {
    vpc_id = aws_vpc.wsi-vpc.id

    tags = {
        Name = "wsi-public-rt"
    }
}

resource "aws_route" "wsi-public-rt" {
    route_table_id = aws_route_table.wsi-public-rt.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.wsi-igw.id
}

resource "aws_route_table" "wsi-private-a-rt" {
    vpc_id = aws_vpc.wsi-vpc.id

    tags = {
        Name = "wsi-private-a-rt"
    }
}

resource "aws_route" "wsi-private-a-rt" {
    route_table_id = aws_route_table.wsi-private-a-rt.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.wsi-private-ngw-a.id
}

resource "aws_route_table" "wsi-private-b-rt" {
    vpc_id = aws_vpc.wsi-vpc.id

    tags = {
        Name = "wsi-private-b-rt"
    }
}

resource "aws_route" "wsi-private-b-rt" {
    route_table_id = aws_route_table.wsi-private-b-rt.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.wsi-private-ngw-b.id
}

resource "aws_route_table_association" "private-a" {
  subnet_id = aws_subnet.wsi-private-a.id
  route_table_id = aws_route_table.wsi-private-a-rt.id
}

resource "aws_route_table_association" "private-b" {
  subnet_id = aws_subnet.wsi-private-b.id
  route_table_id = aws_route_table.wsi-private-b-rt.id
}

resource "aws_route_table_association" "public-a" {
  subnet_id = aws_subnet.wsi-public-a.id
  route_table_id = aws_route_table.wsi-public-rt.id
}

resource "aws_route_table_association" "public-b" {
  subnet_id = aws_subnet.wsi-public-b.id
  route_table_id = aws_route_table.wsi-public-rt.id
}