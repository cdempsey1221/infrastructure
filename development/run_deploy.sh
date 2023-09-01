#!/bin/bash

# set AWS API env vars
source ../shared/aws_init/initalize_aws_api_vars.sh

init_terraform_if_required() {
    if [ ! -d ".terraform" ] ; then
        echo "Terraform is not initialized.  Running terraform init."
        terraform init --reconfigure
    fi
}

run() {
    # set default to plan
    plan_or_apply=${1:-plan}
    if [ "$plan_or_apply" = "apply" ] ; then
        echo "Terraform is set to `apply`.  Running terraform apply."
        terraform apply -var-file=dev.tfvars --auto-approve
    else
        # just set anything != 'apply' to plan
        echo "Terraform is set to plan.  Running terraform plan."
        terraform plan -var-file=dev.tfvars
    fi
}

init_terraform_if_required
run $1
