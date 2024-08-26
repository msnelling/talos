provider "vault" {
}

data "vault_generic_secret" "tfe" {
  path = "secret/hashicorp/tfe"
}

locals {
  tfe_token = data.vault_generic_secret.tfe.data["token"]
}