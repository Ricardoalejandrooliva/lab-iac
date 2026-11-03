variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "state_bucket_name" {
  description = "Bucket S3 para el estado remoto de infra/ (nombre único global)"
  type        = string
}

variable "github_owner" {
  description = "Usuario u organización de GitHub"
  type        = string
}

variable "github_repo" {
  description = "Nombre del repositorio (sin el owner)"
  type        = string
}

variable "github_branch" {
  description = "Única rama autorizada a asumir el rol"
  type        = string
  default     = "develop"
}

variable "role_name" {
  type    = string
  default = "lab-iac-github-actions"
}

variable "create_oidc_provider" {
  description = "false si la cuenta YA tiene el proveedor OIDC de GitHub (solo puede haber uno por cuenta)"
  type        = bool
  default     = true
}
