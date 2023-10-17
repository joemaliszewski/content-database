variable "account_id" {
  description = "The AWS account ID."
  type        = string
}

variable "deployment_type" {
  description = "The deployment type (e.g., dev, prod)."
  type        = string
}

variable "region" {
  description = "The AWS region."
  type        = string
}

variable "team" {
  description = "The team name."
  type        = string
}

variable "environment" {
  description = "dev or prod"
  type        = string
}

variable "application" {
  description = "Application name. E.g. dashboard"
  type        = string
}

variable "trusted_ips" {
  description = "List of IP addresses that are allowed access"
  type        = list(string)
}

variable "subnet_ids" {
  description = "List of subnet IDs for the RDS instance."
  type        = list(string)
}

