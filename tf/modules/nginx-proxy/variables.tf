variable "name" { type = string }
variable "upstream" { type = string } # host:port of the upstream service
variable "zone" { default = "us-central1-a" }
variable "machine_type" { default = "e2-micro" }
variable "network" { default = "default" }
variable "tags" {
  type    = list(string)
  default = []
}
