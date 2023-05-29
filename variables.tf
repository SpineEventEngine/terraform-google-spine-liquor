#
# Copyright 2023, TeamDev. All rights reserved.
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

variable "project" {
  description = "The ID of Google Cloud Project."
  type        = string
}

variable "region" {
  description = "The GCP region of an Liquor instance group zone."
  type        = string
}

variable "zone" {
  description = "The GCP zone where instance group must be placed."
  type        = string
}

variable "container" {
  description = "The GCE container image FQN to be used by the Liquor instances."
  type        = string
}

variable "vm_address" {
  description = "The GCE VM static IP address to be assigned to the VM."
  type        = string
}

variable "vm_machine_type" {
  description = "The GCE VM machine type to be used for the Liquor instances."
  type        = string
  default     = "e2-highcpu-2"
}

variable "env" {
  description = "Environment variables to set for the Liquor server."
  type        = list(object({ name = string, value = string }))
  default     = []
}

variable "metadata" {
  type        = map(any)
  description = "Metadata to attach to the instance."
  default     = {}
}

variable "admin" {
  description = <<EOT
    Configuration for the Admin Server of the Liquor image.
    The guide on how to provide sensitive data to the template and avoid passing it to the VCS:
    https://developer.hashicorp.com/terraform/tutorials/configuration-language/sensitive-variables#set-values-with-a-tfvars-file
  EOT
  sensitive   = true
  type        = object({
    enabled  = bool
    port     = optional(number)
    login    = optional(string)
    password = optional(string)
  })
  validation {
    condition     = (var.admin.login != null && var.admin.password != null) || (var.admin.login == null && var.admin.password == null)
    error_message = "Impossible to set only `login` or `password`, both should be set."
  }
  default = {
    enabled = false
  }
}
