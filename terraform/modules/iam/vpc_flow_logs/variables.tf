variable "project_resource_name_prefix" {
    description = "Project prefix to apply to resources"
    type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type = map(string)
  default = {}
}