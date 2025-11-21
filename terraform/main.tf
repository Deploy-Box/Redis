terraform {
  required_providers {
    azurerm = {
      source  = "azurerm"
      version = "4.40.0"
    }
  }
}
provider "azurerm" {
  features {}
}

resource "azurerm_network_interface" "res-0" {
  accelerated_networking_enabled = false
  dns_servers                    = []
  ip_forwarding_enabled          = false
  location                       = "eastus"
  name                           = "myvm3_nic"
  resource_group_name            = "testing_rg"
  tags                           = {}
  ip_configuration {
    name                                               = "ipconfig1"
    primary                                            = true
    private_ip_address_allocation                      = "Dynamic"
    private_ip_address_version                         = "IPv4"
    subnet_id                                          = "/subscriptions/3106bb2d-2f28-445e-ab1e-79d93bd15979/resourceGroups/testing_rg/providers/Microsoft.Network/virtualNetworks/vnet-eastus/subnets/snet-eastus-2"
  }
}


resource "azurerm_linux_virtual_machine" "res-1" {
  admin_password                                         = "password123!"
  admin_username                                         = "kalebwbishop"
  user_data = base64encode(<<-EOF
    #!/bin/bash

    # Update package manager
    sudo dnf update -y

    # Install Docker/Moby
    sudo dnf install -y moby-engine moby-cli
    sudo systemctl start docker
    sudo systemctl enable docker

    # Create application directory
    sudo mkdir -p /opt/app

    sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose

    # Download application files
    curl -L -o /opt/app/main.zip https://github.com/Deploy-Box/Redis/archive/refs/heads/main.zip

    # Unzip application files
    sudo dnf install -y unzip
    sudo unzip /opt/app/main.zip -d /opt/app

    # Create systemd service file for docker-compose
    cat <<'SERVICE' | sudo tee /etc/systemd/system/docker-compose.service
    [Unit]
    Description=Docker Compose Application Service
    Requires=docker.service
    After=docker.service network-online.target
    Wants=network-online.target

    [Service]
    Type=oneshot
    RemainAfterExit=yes
    WorkingDirectory=/opt/app/Redis-main

    # Pull images and start the stack
    ExecStart=/usr/local/bin/docker-compose up -d

    # Stop the stack
    ExecStop=/usr/local/bin/docker-compose down

    # Restart containers if they exit
    ExecReload=/usr/local/bin/docker-compose restart

    TimeoutStartSec=0

    [Install]
    WantedBy=multi-user.target
    SERVICE

    # Enable and start the service
    sudo systemctl daemon-reload
    sudo systemctl enable docker-compose.service
    sudo systemctl start docker-compose.service

  EOF
  )
  allow_extension_operations                             = true
  availability_set_id                                    = "/subscriptions/3106bb2d-2f28-445e-ab1e-79d93bd15979/resourceGroups/testing_rg/providers/Microsoft.Compute/availabilitySets/TESTING"
  bypass_platform_safety_checks_on_user_schedule_enabled = false
  computer_name                                          = "myvm3"
  disable_password_authentication                        = false
  disk_controller_type                                   = "SCSI"
  encryption_at_host_enabled                             = false
  extensions_time_budget                                 = "PT1H30M"
  location                                               = "eastus"
  max_bid_price                                          = -1
  name                                                   = "myvm3"
  network_interface_ids                                  = [azurerm_network_interface.res-0.id]
  patch_assessment_mode                                  = "ImageDefault"
  patch_mode                                             = "ImageDefault"
  priority                                               = "Regular"
  provision_vm_agent                                     = true
  resource_group_name                                    = "testing_rg"
  secure_boot_enabled                                    = true
  size                                                   = "Standard_B1s"
  tags                                                   = {}
  vtpm_enabled                                           = true
  additional_capabilities {
    hibernation_enabled = false
    ultra_ssd_enabled   = false
  }
  os_disk {
    caching                          = "ReadWrite"
    disk_size_gb                     = 8
    name                             = "myvm3_OsDisk_1_25de8926e92e44c6908885a8744c1dee"
    storage_account_type             = "StandardSSD_LRS"
    write_accelerator_enabled        = false
  }
  source_image_reference {
    offer     = "azure-linux-3"
    publisher = "microsoftcblmariner"
    sku       = "azure-linux-3-kernel-hwe"
    version   = "latest"
  }
}
