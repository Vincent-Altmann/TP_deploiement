output "vm_public_ip" {
  value = azurerm_public_ip.test.ip_address
}

output "ssh_private_key" {
  value     = tls_private_key.test.private_key_pem
  sensitive = true
}
