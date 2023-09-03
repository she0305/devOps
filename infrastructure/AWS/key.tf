# Create a private key for the SSH connection
resource "tls_private_key" "k8s_ssh" {
  algorithm = "RSA"
  rsa_bits = 4096
}

# Generates a local file with the private key
resource "local_file" "keyfile" {
  content         = tls_private_key.k8s_ssh.private_key_pem
  filename        = "terraform_key.pem"
  file_permission = "0400" # Only the owner can read the file
}