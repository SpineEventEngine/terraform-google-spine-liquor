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

provider "google" {
  project = var.project
}

# Init VPC network for Liquor instances.
module "liquor_network" {
  source = "./modules/network"

  project  = var.project
  regions  = tolist([
    var.region
  ])
  vpc_name = "liquor"
}

module "instance_template" {
  source = "./modules/instance-template"

  project      = var.project
  region       = var.region
  network      = module.liquor_network.network
  subnetwork   = module.liquor_network.subnets[var.region]
  container    = var.container
  machine_type = var.vm_machine_type
  env          = var.env
  additional_metadata = var.metadata
}

resource "google_compute_instance_from_template" "liquor-server" {
  name = "liquor-server"
  zone = var.zone

  source_instance_template = module.instance_template.template.self_link

  network_interface {
    subnetwork = module.liquor_network.subnets[var.region]
    access_config {
      nat_ip = var.vm_address
    }
  }
}
