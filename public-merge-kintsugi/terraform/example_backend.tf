terraform {
  backend "s3" {
    region = "us-east-1"
    bucket = "eth-kintsugi-state"
    #key = "eth-kintsugi-state/{env}/state.tfstate"
    encrypt        = true #AES-256 encryption
    dynamodb_table = "eth-kintsugi-lock"
  }
}