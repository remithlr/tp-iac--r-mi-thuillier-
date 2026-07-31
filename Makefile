SHELL := /bin/bash

TF_DIR=envs/dev-aws

.PHONY: fmt tflint trivy apply inventory ansible

fmt:
	cd $(TF_DIR) && terraform fmt -check

tflint:
	cd $(TF_DIR) && tflint

trivy:
	trivy config .

apply:
	cd $(TF_DIR) && terraform init
	cd $(TF_DIR) && terraform apply -auto-approve

inventory:
	cd $(TF_DIR) && terraform output -raw instance_ip > ../../ip.txt
	echo "[web]" > inventory.ini
	cat ip.txt >> inventory.ini
	rm ip.txt

ansible:
	ansible-playbook -i inventory.ini playbook.yml
