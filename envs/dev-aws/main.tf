terraform {
  required_version = ">= 1.10"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.region
}

resource "aws_instance" "web" {
  ami           = "ami-0f8a61b66d1accaee"
  instance_type = "t3.micro"

  subnet_id = "subnet-0f7d1efe7c6e13939"

  vpc_security_group_ids = [
    "sg-05c13324a42ac9156"
  ]

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    encrypted   = true
    volume_size = 10
    volume_type = "gp3"
  }

  user_data = <<-EOF
#!/bin/bash
apt-get update
apt-get install -y nginx
systemctl enable nginx
systemctl start nginx

cat > /var/www/html/index.html <<HTML
<h1>TP2 Rémi Thuillier</h1>
<p>Terraform fonctionne !</p>
HTML
EOF

  tags = {
    Name = "tp2-remi"
  }
}
