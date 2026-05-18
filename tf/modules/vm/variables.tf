variable "name" { type = string }
variable "image" { type = string } # full Artifact Registry image URL
variable "zone" { default = "us-central1-a" }
variable "machine_type" { default = "e2-micro" }
variable "network" { default = "default" }
variable "tags" {
  type    = list(string)
  default = []
}
variable "port" { default = 3000 }
