# resource "aws_iam_openid_connect_provider" "github_actions" {
#   url    = "https://token.actions.githubusercontent.com"
#   client_id_list = ["sts.amazonaws.com"]

#   thumbprint_list = ["1b511abead59c6ce207077c0bf0e0043b1382612"] # Replace with the actual thumbprint after creating the provider manually
# }