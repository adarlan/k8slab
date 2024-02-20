provider "aws" {

  # DOC https://registry.terraform.io/providers/hashicorp/aws/latest/docs

  default_tags {
    tags = {
      Environment = "Playground"
      Owner       = "YourName"
      Project     = "YourProject"
      Billing     = "CostCenter123"
    }
  }
}
