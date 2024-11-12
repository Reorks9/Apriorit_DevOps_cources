# Output the Public IP of the Load Balancer
output "load_balancer_public_ip" {
  description = "The Public IP address of the Load Balancer"
  value       = azurerm_public_ip.lb_public_ip.ip_address
}