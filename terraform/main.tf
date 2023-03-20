provider "aws" {
  region = "eu-central-1"
}

provider "kubernetes" {
  config_context_cluster = "my-cluster-name"
  version = "~> 2.0"
}
