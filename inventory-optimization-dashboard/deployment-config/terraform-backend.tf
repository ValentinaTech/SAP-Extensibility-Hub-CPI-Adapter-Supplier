# terraform-backend.tf

provider "null" {
  # The null provider is used here purely to demonstrate structure where a real SAP BTP 
  # or AWS/GCP/Azure provider would typically be configured for infrastructure provisioning.
}

resource "null_resource" "btp_project_placeholder" {
  triggers = {
    project_name = var.project_id
  }

  # Connection block removed as it was empty and unnecessary for a null_resource.

  depends_on = [
    module.sap_btp_instance # Assuming a module exists that provisions the BTP instance
  ]
}

variable "project_id" {
  description = "The unique identifier for this project within your organization."
  type        = string
  default     = ""
}
