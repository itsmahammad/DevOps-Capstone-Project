terraform {
  backend "azurerm" {
    # REPLACE these with the outputs from infra/terraform/bootstrap after it is applied.
    resource_group_name  = "REPLACE_WITH_BOOTSTRAP_OUTPUT"
    storage_account_name = "REPLACE_WITH_BOOTSTRAP_OUTPUT"
    container_name       = "tfstate"
    key                  = "production/terraform.tfstate"
  }
}
