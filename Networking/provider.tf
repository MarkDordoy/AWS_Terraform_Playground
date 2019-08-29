provider "aws" {
    version = "=2.25.0"
    region = "eu-west-1"
}

provider "aws" {
    version = "=2.25.0"
    region  = "eu-west-2"
    alias   = "london"
}