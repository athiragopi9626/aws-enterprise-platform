
variable "repository_name" {
  description = "Name of the private ECR repository."
  type        = string
}

variable "tags" {
  description = "Common AWS resource tags."
  type        = map(string)
  default     = {}
}
