variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "project" {
  type    = string
  default = "lab-iac"
}

variable "environment" {
  description = "Experimento 3: dev -> qa"
  type        = string
  default     = "qa"
}

variable "instance_type" {
  description = "Experimento 1: t3.micro -> t3.small"
  type        = string
  default     = "t3.micro"
}

variable "log_retention_days" {
  description = "Experimento 2: 7 -> 14"
  type        = number
  default     = 14
}

variable "bucket_name" {
  description = "Experimento 4. Viene de la variable de GitHub LAB_BUCKET_NAME"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9.-]{1,61}[a-z0-9]$", var.bucket_name))
    error_message = "Nombre de bucket inválido: minúsculas, números, puntos o guiones (3-63 caracteres)."
  }
}

variable "http_cidr" {
  description = "Tu IP pública con /32. Viene de LAB_HTTP_CIDR"
  type        = string

  validation {
    condition     = can(cidrhost(var.http_cidr, 0))
    error_message = "Debe ser un CIDR válido, por ejemplo 181.10.20.30/32."
  }
}
