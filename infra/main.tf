locals {
  name_prefix = "${var.project}-${var.environment}"
}

# ================= DATA: AMI y red existentes =================
data "aws_ssm_parameter" "al2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

data "aws_vpc" "default" {
  default = true
}

# Zonas donde existe el tipo de instancia (evita us-east-1e, que no tiene t3)
data "aws_ec2_instance_type_offerings" "type" {
  location_type = "availability-zone"
  filter {
    name   = "instance-type"
    values = [var.instance_type]
  }
}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
  filter {
    name   = "default-for-az"
    values = ["true"]
  }
  filter {
    name   = "availability-zone"
    values = data.aws_ec2_instance_type_offerings.type.locations
  }
}

# ================= EC2 + Security Group =================
resource "aws_security_group" "web" {
  name        = "${local.name_prefix}-web-sg"
  description = "HTTP solo desde la IP autorizada; sin SSH"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.http_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Si cambia el nombre (experimento 3) crea el nuevo antes de borrar el viejo
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_instance" "web" {
  ami                         = data.aws_ssm_parameter.al2023.value
  instance_type               = var.instance_type
  subnet_id                   = sort(data.aws_subnets.public.ids)[0]
  vpc_security_group_ids      = [aws_security_group.web.id]
  associate_public_ip_address = true

  metadata_options {
    http_tokens   = "required" # IMDSv2 obligatorio
    http_endpoint = "enabled"
  }

  root_block_device {
    volume_type = "gp3"
    volume_size = 8
    encrypted   = true
  }

  user_data = <<-EOT
    #!/bin/bash
    dnf install -y nginx
    echo "<h1>LAB IaC - ${local.name_prefix}</h1><p>Desplegado con Terraform + GitHub Actions</p>" > /usr/share/nginx/html/index.html
    systemctl enable --now nginx
  EOT
  user_data_replace_on_change = true

  # La AMI "latest" cambia con el tiempo: no reemplazar la instancia por eso
  lifecycle {
    ignore_changes = [ami]
  }

  tags = {
    Name = "${local.name_prefix}-web"
  }
}

# ================= S3 privado =================
resource "aws_s3_bucket" "data" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_public_access_block" "data" {
  bucket                  = aws_s3_bucket.data.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "data" {
  bucket = aws_s3_bucket.data.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "data" {
  bucket = aws_s3_bucket.data.id
  versioning_configuration {
    status = "Enabled"
  }
}

# ================= CloudWatch =================
resource "aws_cloudwatch_log_group" "app" {
  name              = "/lab/${local.name_prefix}/app"
  retention_in_days = var.log_retention_days
}
