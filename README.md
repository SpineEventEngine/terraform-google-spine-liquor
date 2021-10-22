Spine Liquor Terraform configuration
----------

This module holds a reusable terraform module which creates the Liquor Server infrastructure.

The module is configured with the GCE environment details alongside the Liquor Server container image 
and the VM IP address.

Following the best practices, the Liquor server will reside in its own VPC and region.

When working with App Engine applications, consider picking up a region closed to the App Engine
apps location.
