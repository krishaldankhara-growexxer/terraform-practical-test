terraform {
  backend "s3" {
    bucket       = "tf-state-krishal-ap-south-1"
    key          = "dev/terraform.tfstate"
    region       = "ap-south-1"
    encrypt      = true
    use_lockfile = true
    assume_role = {
      role_arn = "arn:aws:iam::118402680584:role/TerraformCrossAccountRole-Krishal-AWS"
    }
  }
}
