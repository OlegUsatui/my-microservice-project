variable "repo_name" { type = string }
variable "scan_on_push" { type = bool   default = true }
variable "force_delete" { type = bool   default = false }
variable "image_mutability" { type = string default = "MUTABLE" }
