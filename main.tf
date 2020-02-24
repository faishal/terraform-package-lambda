variable "source_dir" {
  description = "The directory with the lambda function to package"
}

variable "build_dir" {
  description = "Optional; An ephemeral directory to perform the builds in. One will be created with a random name if omitted."
  default     = ""
}

variable "output_path" {
  description = "Where to output the zip package to"
}

resource "random_uuid" "build_dir" {}

locals {
  build_dir = coalesce(var.build_dir, format("/tmp/%s", random_uuid.build_dir.result))
}

data "external" "packaging_script" {
  program = ["bash", "${path.module}/bin/package.sh"]

  query = {
    source_dir = var.source_dir
    build_dir  = local.build_dir
  }
}

data "archive_file" "zip" {
  type        = "zip"
  source_dir  = data.external.packaging_script.result.packaged_dir
  output_path = var.output_path
}

output "zip_file" {
  value = var.output_path
}

output "output_sha" {
  value = data.archive_file.zip.output_sha
}

output "output_base64sha256" {
  value = data.archive_file.zip.output_base64sha256
}

output "output_md5" {
  value = data.archive_file.zip.output_md5
}

