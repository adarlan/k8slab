locals {
  values_file_path = coalesce(
    var.aws_config != null && "values.aws-config.yaml",
    var.kind_config != null && "values.kind-config.yaml",
    "values.yaml"
  )
}
