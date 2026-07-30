# TP2 - Déploiement multi-cloud sécurisé

**Auteur : Rémi Thuillier**

---

# Objectif

L'objectif de ce TP est de déployer une infrastructure cloud avec Terraform en appliquant les bonnes pratiques de sécurité.

---

# Partie A - Initialisation Terraform

## Initialisation

Commande exécutée :

\`\`\`bash
terraform init
\`\`\`

Résultat :

\`\`\`
Terraform has been successfully initialized!
\`\`\`

<img width="896" height="282" alt="image" src="https://github.com/user-attachments/assets/6675a99c-ecdd-4505-a9d1-5c8ef5a9449a" />


---

## Validation

Commande :

\`\`\`bash
terraform validate
\`\`\`

Résultat :

\`\`\`
Success! The configuration is valid.
\`\`\`

<img width="921" height="160" alt="image" src="https://github.com/user-attachments/assets/734ef703-c6b1-403b-8d7c-c8d904b9ae78" />


---

# Partie B - Déploiement AWS

## Configuration

Infrastructure déployée :

- Instance EC2 Ubuntu 24.04
- Volume GP3 chiffré
- IMDSv2 activé
- Installation automatique de Nginx
- Déploiement Terraform

---

## Mesures de sécurité

### IMDSv2

\`\`\`hcl
metadata_options {
  http_endpoint = "enabled"
  http_tokens   = "required"
}
\`\`\`

### Chiffrement du disque

\`\`\`hcl
root_block_device {
  encrypted   = true
  volume_size = 10
  volume_type = "gp3"
}
\`\`\`

---

# Terraform Plan

Commande :

\`\`\`bash
terraform plan -out=dev.tfplan
\`\`\`

Résultat :

\`\`\`
Plan: 1 to add, 0 to change, 0 to destroy.
\`\`\`

<img width="1259" height="203" alt="image" src="https://github.com/user-attachments/assets/fbe22611-1c9f-4bb0-856a-db7bfd4e2a2e" />


---

# Terraform Apply

Commande :

\`\`\`bash
terraform apply dev.tfplan
\`\`\`

Résultat :

\`\`\`
Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
\`\`\`

<img width="1277" height="233" alt="image" src="https://github.com/user-attachments/assets/dc48b28b-97ab-4999-81f2-c60d6439e74c" />


---

# Instance EC2

Terraform a créé avec succès une instance EC2.

Commande :

\`\`\`bash
terraform output instance_ip
\`\`\`

IP publique obtenue :

\`\`\`
34.229.147.88
\`\`\`

<img width="943" height="135" alt="image" src="https://github.com/user-attachments/assets/487f92e6-339c-4a8e-b578-439b60002ec5" />


---

# Vérification Nginx

Commande :

\`\`\`bash
sudo systemctl status nginx
\`\`\`

Résultat :

\`\`\`
active (running)
\`\`\`

<img width="1536" height="370" alt="image" src="https://github.com/user-attachments/assets/829ab4d0-041e-4cb2-a065-c50864c00f2a" />

---

# Vérification locale

Commande :

\`\`\`bash
curl localhost
\`\`\`

Résultat :

\`\`\`html
<h1>TP2 Rémi Thuillier</h1>
<p>Terraform fonctionne !</p>
\`\`\`

<img width="498" height="98" alt="image" src="https://github.com/user-attachments/assets/b3538e38-7f3f-4d57-8c90-fa7ce9a7a888" />


---

# Vérification du site Web

Accès à l'adresse publique :

\`\`\`
http://34.229.147.88
\`\`\`

Le site est accessible depuis Internet.

<img width="568" height="273" alt="image" src="https://github.com/user-attachments/assets/460c6e34-3704-4a05-a7c0-033be1d5ddac" />


---

# Destruction du Terraform 
<img width="840" height="692" alt="image" src="https://github.com/user-attachments/assets/6b76163b-ead2-4a28-be6f-9abbc57587db" />

# Gestion du Terraform State

Le fichier Terraform State contient plusieurs informations sensibles :

1. Adresse IP publique
2. Adresse IP privée
3. Configuration complète de l'infrastructure

Le state Terraform ne doit jamais être exposé publiquement.

Les bonnes pratiques sont :

- chiffrement
- contrôle d'accès
- versioning
- verrouillage du state

---

# Réponse à la question Capital One

IMDSv2 impose l'utilisation d'un jeton pour accéder au service de métadonnées AWS. Une attaque SSRF classique ne peut généralement pas récupérer ce jeton. Cette protection aurait réduit le risque d'exploitation du service de métadonnées. Cependant, le principe du moindre privilège IAM reste la mesure de sécurité principale.

---



Détection et remédiation de la dérive (Drift)
 
Suite à la modification manuelle de la règle SSH (ouverture à `0.0.0.0/0`) directement sur la console AWS, Terraform a détecté la dérive lors de l'exécution de la commande `terraform plan`.
 
**Sortie du plan de détection :**
```hcl
terraform plan
data.aws_ami.ubuntu: Reading...
aws_vpc.principal: Refreshing state... [id=vpc-0f276d01180dc43b1]
data.aws_ami.ubuntu: Read complete after 1s [id=ami-052355af2a014bd2c]
aws_internet_gateway.igw: Refreshing state... [id=igw-0ab9c0a7513aebedc]
aws_subnet.public: Refreshing state... [id=subnet-0867acb9aa89b42b7]
aws_security_group.web: Refreshing state... [id=sg-04746f1cdfa640f2b]
aws_route_table.public: Refreshing state... [id=rtb-03147a2327259b580]
aws_route_table_association.public: Refreshing state... [id=rtbassoc-07eef36a1a137cc41]
aws_instance.web: Refreshing state... [id=i-0108d288875ab946e]
 
 
 
 
Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  ~ update in-place
 
Terraform will perform the following actions:
 
  # aws_security_group.web will be updated in-place
  ~ resource "aws_security_group" "web" {
        id                     = "sg-04746f1cdfa640f2b"
      ~ ingress                = [
          - {
              - cidr_blocks      = [
                  - "0.0.0.0/0",
                ]
              - from_port        = 22
              - ipv6_cidr_blocks = []
              - prefix_list_ids  = []
              - protocol         = "tcp"
              - security_groups  = []
              - self             = false
              - to_port          = 22
                # (1 unchanged attribute hidden)
            },
          + {
              + cidr_blocks      = [
                  + "37.70.218.118/32",
                ]
              + description      = "SSH depuis IP administration UNIQUEMENT"
              + from_port        = 22
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "tcp"
              + security_groups  = []
              + self             = false
              + to_port          = 22
            },
            # (1 unchanged element hidden)
        ]
        name                   = "tp2-aws-sg-web"
        tags                   = {
            "Environment" = "dev"
            "ManagedBy"   = "terraform"
            "Name"        = "tp2-aws-sg-web"
            "Owner"       = "rémi"
            "Projet"      = "tp2"
        }
        # (9 unchanged attributes hidden)
    }
 
Plan: 0 to add, 1 to change, 0 to destroy.
 
─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
 
Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take exactly these actions if you run "terraform apply" now.
Releasing state lock. This may take a few moments...
 
Sensibilité du fichier d'état (State)
 
L'inspection du fichier d'état démontre qu'il contient la topologie complète et des données sensibles en clair.
 
**Trois informations sensibles trouvées dans l'état :**
1. L'adresse IP publique de l'instance EC2 : `35.175.225.176`
2. L'identifiant unique du VPC (réseau privé) : `vpc-0f276d01180dc43b1`
3. L'identifiant du sous-réseau public : `subnet-0867acb9aa89b42b7`
 
**Contrôle de sécurité mis en place :**
Pour protéger ce fichier critique, la configuration a été externalisée sur un backend distant S3. Les contrôles appliqués sont :
*   **Chiffrement au repos obligatoire** (`encrypt = true`) via KMS.
*   **Verrouillage d'état** natif (`use_lockfile = true`) pour prévenir la corruption.
*   **Blocage des accès publics** et **versioning** activés sur le bucket S3 pour garantir la résilience.
 
 
Équivalence des ressources Terraform (AWS vs Azure)
 
| Concept Cloud | Ressource Terraform AWS | Ressource Terraform Azure |
| :--- | :--- | :--- |
| **Réseau virtuel** | `aws_vpc` | `azurerm_virtual_network` |
| **Sous-réseau** | `aws_subnet` | `azurerm_subnet` |
| **Pare-feu d'instance** | `aws_security_group` | `azurerm_network_security_group` |
| **IP Publique** | *Attribut* (`map_public_ip_on_launch`) | `azurerm_public_ip` |
| **Serveur Linux** | `aws_instance` | `azurerm_linux_virtual_machine` |
 
---
 
Analyse de l'incident Capital One (2019) vs IMDSv2
 
L'imposition de la version 2 du service de métadonnées (`http_tokens = "required"`) exige l'émission d'une requête HTTP PUT avec un en-tête personnalisé pour obtenir un jeton, et limite le saut réseau (hop limit) à 1. Dans l'affaire Capital One, cela **aurait bloqué l'attaque**, car la faille SSRF du WAF ne permettait que de forger des requêtes GET simples sans en-tête spécifique. En revanche, cela **n'aurait pas changé** le défaut de conception fondamental : le rôle IAM attaché à l'instance possédait des privilèges de lecture excessifs (violation du principe de moindre privilège).
 
 




