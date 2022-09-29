#
# Copyright 2021, TeamDev. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Redistribution and use in source and/or binary forms, with or without
# modification, must retain the above copyright notice and the following
# disclaimer.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#

locals {
  container_image_project = var.image_project != "" ? var.image_project : var.project
}

# Prepares a GCE container image.
#
# See https://github.com/terraform-google-modules/terraform-google-container-vm for additional info.
module "gce-container" {
  source  = "terraform-google-modules/container-vm/google"
  version = "~> 2.0"

  cos_image_family = var.image_family
  cos_image_name = var.image_name
  cos_project = local.container_image_project

  container      = {
    env   = var.env
    image = var.container
  }
  restart_policy = "Always"
}

data "google_compute_default_service_account" "default" {
  # The default service account of GCE instances
}

# Generates Instance Template for Liquor Server VMs.
#
# For details about all inputs, see the module docs:
# https://registry.terraform.io/modules/terraform-google-modules/vm/google/latest/submodules/instance_template
module "vm_instance_template" {
  source  = "terraform-google-modules/vm/google//modules/instance_template"
  version = "~> 7.1"

  project_id          = var.project
  region              = var.region
  name_prefix         = "liquor-${var.region}"
  preemptible         = false
  on_host_maintenance = "MIGRATE"
  service_account     = {
    email  = data.google_compute_default_service_account.default.email
    scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }

  # Hardware config
  machine_type = var.machine_type

  # Boot disk config
  disk_size_gb         = 20
  source_image_project = local.container_image_project
  source_image_family  = var.image_family
  source_image         = reverse(split("/", module.gce-container.source_image))[0]
  metadata             = merge(var.additional_metadata, tomap({
    "gce-container-declaration" = module.gce-container.metadata_value,
    "google-logging-enabled"    = "true"
  }))

  # See https://cloud.google.com/security/shielded-cloud/shielded-vm for details.
  enable_shielded_vm       = true
  shielded_instance_config = {
    "enable_integrity_monitoring" : true,
    # Enabling this option causes failures during the application start.
    "enable_secure_boot" : false,
    "enable_vtpm" : true
  }

  # Network interface.
  network    = var.network
  subnetwork = var.subnetwork
  tags       = ["grpc"]
}
