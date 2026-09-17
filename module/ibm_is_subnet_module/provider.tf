terraform {
  required_version = ">= 0.14.11, < 2.0.0"
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = "~> 1.60.0"
    }
  }
}
