#!/usr/bin/env bash
set -euo pipefail

#Configuration Variables
LOCATION="centralus"
RESOURCE_GROUP_NAME="rg-terraform-state-mgmt"
STORAGE_ACCOUNT_NAME="sttfstatehybrid$(openssl rand -hex 3)"
CONTAINER_NAME="tfstate-hybrid-enterprise"

echo " Creating Resource Group: ${RESOURCE_GROUP_NAME}..."
az group create \
    --name "${RESOURCE_GROUP_NAME}" \
    --location "${LOCATION}" \
    --tags Environment=Management Purpose=TerraformState Project=Hybrid-Proxmox-Azure

echo " Creating Storage Account: ${STORAGE_ACCOUNT_NAME}..."
az storage account create \
    --name "${STORAGE_ACCOUNT_NAME}" \
    --resource-group "${RESOURCE_GROUP_NAME}" \
    --location "${LOCATION}" \
    --sku STANDARD_LRS \
    --kind STORAGEV2 \
    --allow-blob-public-access false \
    --min-tls-version TLS1_2 \
    --https-only true \
    --tags Environment=Management ManagedBy=Terraform

echo " Enabling Blob Versioning for State Recovery..."
az storage account blob-service-properties update \
    --name "${STORAGE_ACCOUNT_NAME}" \
    --resource-group "${RESOURCE_GROUP_NAME}" \
    --enable-versioning true

echo " Creating Blob Container: ${CONTAINER_NAME}..."
az storage container create \
    --name "${CONTAINER_NAME}" \
    --account-name "${STORAGE_ACCOUNT_NAME}" \
    --auth-mode login

echo "=========================================================="
echo "Backend Provisioning Complete!"
echo "Resource Group:  ${RESOURCE_GROUP_NAME}"
echo "Storage Account: ${STORAGE_ACCOUNT_NAME}"
echo "Container Name:  ${CONTAINER_NAME}"
echo "=========================================================="