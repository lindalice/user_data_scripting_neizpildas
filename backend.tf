resource "aws_dynamodb_table" "statelock" {
  name         = "ll-scripting-table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}