#
# This is a ci configuration of the scenario 100. This configuration adjust the permission to the service principal calling terraform
#

level = "level0"
scenarios = {
  launchpad = 100
}

# Default region
default_region = "region1"

regions = {
  region1 = "southeastasia"
}

launchpad_key_names = {
  keyvault               = "launchpad"
  azuread_app            = "caf_launchpad_level0"
  keyvault_client_secret = "aadapp-caf-launchpad-level0"
  tfstates = [
    "level0"
  ]
}

resource_groups = {
  tfstate = {
    name       = "launchpad-tfstates"
    region     = "region1"
    useprefix  = true
    max_length = 40
  }
  security = {
    name       = "launchpad-security"
    useprefix  = true
    max_length = 40
  }
}


storage_accounts = {
  level0 = {
    name                     = "level0"
    resource_group_key       = "tfstate"
    account_kind             = "BlobStorage"
    account_tier             = "Standard"
    account_replication_type = "RAGRS"
    tags = {
      # Those tags must never be changed while set as they are used by the rover to locate the launchpad and the tfstates.
      tfstate     = "level0"
      environment = "sandpit"
      launchpad   = "launchpad_light" # Do not change. Required for the rover to work in AIRS, Limited privilege environments for demonstration purpuses
      ##
    }
    containers = {
      tfstate = {
        name = "tfstate"
      }
    }
  }
}

keyvaults = {
  # Do not rename the key "launchpad" to be able to upgrade to the standard launchpad
  launchpad = {
    name                = "launchpad"
    resource_group_key  = "security"
    region              = "region1"
    convention          = "cafrandom"
    sku_name            = "standard"
    soft_delete_enabled = true

    tags = {
      tfstate     = "level0"
      environment = "sandpit"
    }
  }

}


keyvault_access_policies = {
  # A maximum of 16 access policies per keyvault
  launchpad = {
    logged_in_app = {
      # if the key is set to "logged_in_app" add the user running terraform in the keyvault policy
      # More examples in /examples/keyvault
      secret_permissions = ["Set", "Get", "List", "Delete", "Purge"]
    }
  }

}

subscriptions = {
  logged_in_subscription = {
    role_definition_name = "Owner"
    aad_app_key          = "caf_launchpad_level0"

    diagnostic_profiles = {}
  }
}

azuread_apps = {
  # Do not rename the key "launchpad" to be able to upgrade to higher scenario
  caf_launchpad_level0 = {
    convention              = "cafrandom"
    useprefix               = true
    application_name        = "caf_launchpad_level0"
    password_expire_in_days = 180
    keyvaults = {
      launchpad = {
        secret_prefix = "aadapp-caf-launchpad-level0"
        access_policy = {
          secret_permissions = ["Get", "List", "Set", "Delete", "Purge"]
        }
      }
    }
  }
}


role_mapping = {
  custom_role_mapping = {}
  built_in_role_mapping = {
    storage_account_keys = {
      level0 = {
        "Storage Blob Data Contributor" = {
          object_ids = [
            "logged_in_app"
          ]
        }
      }
    }
  }
}