terraform {
  required_version = ">= 1.10"

  backend "s3" {
    bucket       = "remi-tfstate-test-1785488912"
    key          = "terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }

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

  key_name = "vockey"

  subnet_id = "subnet-0f7d1efe7c6e13939"

  vpc_security_group_ids = [
    "sg-05c13324a42ac9156"
  ]

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
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

cat > /var/www/html/index.html <<'HTML'
<!DOCTYPE html>
<html lang="fr">

<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<title>Subito Pizza</title>

<style>

body{
    margin:0;
    font-family:Arial,sans-serif;
    background:#fff5ec;
}

header{
    background:#d62828;
    color:white;
    text-align:center;
    padding:60px;
}

h1{
    font-size:4rem;
    margin:0;
}

.subtitle{
    font-size:1.4rem;
    margin-top:10px;
}

.menu{
    display:grid;
    grid-template-columns:repeat(auto-fit,minmax(250px,1fr));
    gap:20px;
    padding:40px;
}

.pizza{
    background:white;
    padding:20px;
    border-radius:15px;
    box-shadow:0 0 10px rgba(0,0,0,.15);
    text-align:center;
}

.price{
    color:#d62828;
    font-size:1.5rem;
    font-weight:bold;
}

footer{
    background:#222;
    color:white;
    text-align:center;
    padding:20px;
}

</style>

</head>

<body>

<header>
<h1>🍕 SUBITO PIZZA 🍕</h1>
<p class="subtitle">La pizza qui arrive subito !</p>
</header>

<section class="menu">

<div class="pizza">
<h2>Margherita</h2>
<p>Tomate, mozzarella, basilic</p>
<p class="price">9 €</p>
</div>

<div class="pizza">
<h2>Reine</h2>
<p>Jambon, champignons</p>
<p class="price">11 €</p>
</div>

<div class="pizza">
<h2>4 Fromages</h2>
<p>Mozzarella, chèvre, bleu, emmental</p>
<p class="price">12 €</p>
</div>

<div class="pizza">
<h2>Pepperoni</h2>
<p>Pepperoni, mozzarella</p>
<p class="price">13 €</p>
</div>

</section>

<footer>
Déployé automatiquement avec Terraform • Rémi Thuillier
</footer>

</body>
</html>
HTML

systemctl enable nginx
systemctl restart nginx
EOF

  tags = {
    Name        = "tp2-remi"
    ManagedBy   = "terraform"
    Owner       = "remi"
    Environment = "dev"
  }
}
