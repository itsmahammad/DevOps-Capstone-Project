terraform {
  backend "azurerm" {
    # REPLACE these with the outputs from infra/terraform/bootstrap after it is applied.
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "tfstatekb5ggp"
    container_name       = "tfstate"
    key                  = "production/terraform.tfstate"
  }
}
