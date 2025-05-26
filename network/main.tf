#  __   _____  ___ 
#  \ \ / / _ \/ __|
#   \ V /|  _/ (__ 
#    \_/ |_|  \___|
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

resource "aws_vpc_ipv4_cidr_block_association" "main" {
  count = length(var.vpc_additional_cidrs)

  vpc_id     = aws_vpc.main.id
  cidr_block = var.vpc_additional_cidrs[count.index]
}

#   ___ _   _ ___ _  _ ___ _____   ___ _   _ ___ _    ___ ___ 
#  / __| | | | _ ) \| | __|_   _| | _ \ | | | _ ) |  |_ _/ __|
#  \__ \ |_| | _ \ .` | _|  | |   |  _/ |_| | _ \ |__ | | (__ 
#  |___/\___/|___/_|\_|___| |_|   |_|  \___/|___/____|___\___|                                                      
resource "aws_subnet" "public" {
  for_each = var.public_subnets

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.cidr
  availability_zone = "${var.region}${each.value.az}"

  tags = {
    Name = "${var.project_name}-public-subnet-${each.key}"
  }
}

resource "aws_route_table" "public_internet_access" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-public"
  }

  depends_on = [
    aws_vpc_ipv4_cidr_block_association.main
  ]
}

resource "aws_route" "public_access" {
  route_table_id         = aws_route_table.public_internet_access.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id
}

resource "aws_route_table_association" "public" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public_internet_access.id
}

#   ___ _   _ ___ _  _ ___ _____   ___ ___ _____   ___ _____ ___ 
#  / __| | | | _ ) \| | __|_   _| | _ \ _ \_ _\ \ / /_\_   _| __|
#  \__ \ |_| | _ \ .` | _|  | |   |  _/   /| | \ V / _ \| | | _| 
#  |___/\___/|___/_|\_|___| |_|   |_| |_|_\___| \_/_/ \_\_| |___|                                                             #  
resource "aws_subnet" "private" {
  for_each = var.private_subnets

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.cidr
  availability_zone = "${var.region}${each.value.az}"

  tags = {
    Name = "${var.project_name}-private-subnet-${each.key}"
  }
}

resource "aws_route_table" "private" {
  for_each = var.private_subnets

  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-private-${each.key}"
  }
}

resource "aws_route" "private" {
  for_each = var.private_subnets

  route_table_id         = aws_route_table.private[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = each.value.nat_gateway_id
}

resource "aws_route_table_association" "private" {
  for_each = var.private_subnets

  subnet_id      = aws_subnet.private[each.key].id
  route_table_id = aws_route_table.private[each.key].id
}

#   ___ _   _ ___ _  _ ___ _____   ___  ___ 
#  / __| | | | _ ) \| | __|_   _| |   \| _ )
#  \__ \ |_| | _ \ .` | _|  | |   | |) | _ \
#  |___/\___/|___/_|\_|___| |_|   |___/|___/
resource "aws_subnet" "databases" {
  for_each = var.database_subnets

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.cidr
  availability_zone = "${var.region}${each.value.az}"

  tags = {
    Name = "${var.project_name}-database-subnet-${each.key}"
  }
}

#   _  _   _ _____    ___   _ _____ _____      _____   __
#  | \| | /_\_   _|  / __| /_\_   _| __\ \    / /_\ \ / /
#  | .` |/ _ \| |   | (_ |/ _ \| | | _| \ \/\/ / _ \ V / 
#  |_|\_/_/ \_\_|    \___/_/ \_\_| |___| \_/\_/_/ \_|_|  
resource "aws_eip" "this" {
  for_each = var.azs
  vpc      = true
  tags = {
    Name = "${var.project_name}-eip-${each.key}"
  }
}

resource "aws_nat_gateway" "this" {
  for_each      = var.azs
  subnet_id     = aws_subnet.public[each.key].id
  allocation_id = aws_eip.this[each.key].id
}


#   ___ _  _ _____ ___ ___ _  _ ___ _____    ___   _ _____ _____      ___   
#  |_ _| \| |_   _| __| _ \ \| | __|_   _|  / __| /_\_   _| __\ \    / /_\  
#   | || .` | | | | _||   / .` | _|  | |   | (_ |/ _ \| | | _| \ \/\/ / _ \ 
#  |___|_|\_| |_| |___|_|_\_|\_|___| |_|    \___/_/ \_\_| |___| \_/\_/_/ \_\                                                                
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}
