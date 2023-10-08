provider "aws" {
    region = "us-east-1"
}

resource "aws_instance" "demo-server" { 
    //ami = "ami-067d1e60475437da2"
    #using ubuntu as ami image
    ami = "ami-053b0d53c279acc90"
    instance_type = "t2.micro"
    key_name = "tw"
    //security_groups = [ "devops-project1-sg" ]
    vpc_security_group_ids = [aws_security_group.devops-project1-sg.id]
    subnet_id = aws_subnet.dp1-public-subnet-01.id
    for_each = toset(["Jenkins-master", "jenkins-build-slave", "ansible"])
   tags = {
     Name = "${each.key}"
   }

}

resource "aws_security_group" "devops-project1-sg" {
  name        = "devops-project1-sg"
  description = "SSH Access"
  vpc_id = aws_vpc.devops-project1-vpc.id
  ingress {
    description      = "For SSH access"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "SSH-PORT ACCESS"

  }
}

resource "aws_vpc" "devops-project1-vpc" {
  cidr_block = "10.1.0.0/16"
  tags = {
    Name = "devops-project1-vpc"
  }
  
}

resource "aws_subnet" "dp1-public-subnet-01" {
  vpc_id = aws_vpc.devops-project1-vpc.id 
  cidr_block = "10.1.1.0/24"
  map_public_ip_on_launch = "true"
  availability_zone = "us-east-1a"
  tags = {
    Name = "dp1-public-subent-01"
  }
}

resource "aws_subnet" "dp1-public-subnet-02" {
  vpc_id = aws_vpc.devops-project1-vpc.id 
  cidr_block = "10.1.2.0/24"
  map_public_ip_on_launch = "true"
  availability_zone = "us-east-1b"
  tags = {
    Name = "dp1-public-subent-02"
  }
}

resource "aws_internet_gateway" "devops-project1-igw" {
  vpc_id = aws_vpc.devops-project1-vpc.id 
  tags = {
    Name = "devops-project1-igw"
  } 
}

resource "aws_route_table" "dp1-public-rt" {
  vpc_id = aws_vpc.devops-project1-vpc.id 
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.devops-project1-igw.id 
  }
}

resource "aws_route_table_association" "dp1-rta-public-subnet-01" {
  subnet_id = aws_subnet.dp1-public-subnet-01.id
  route_table_id = aws_route_table.dp1-public-rt.id   
}

resource "aws_route_table_association" "dp1-rta-public-subnet-02" {
  subnet_id = aws_subnet.dp1-public-subnet-02.id 
  route_table_id = aws_route_table.dp1-public-rt.id   
}