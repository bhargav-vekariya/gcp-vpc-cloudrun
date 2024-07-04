project = "elevated-honor-428407-s3"
region  = "us-central1"


Resources = {
  GCPServices = {
    cloudrun = {
      name               = "run.googleapis.com"
      disable_on_destroy = false
    }

  }
  VPCResource = {
    vpc1 = {
      name                    = "test1"
      project                 = "elevated-honor-428407-s3"
      auto_create_subnetworks = false
    }
  }
  SubnetResource = {
    subnet1 = {
      name                 = "subnet1"
      ip_cidr_range        = "10.2.0.0/16"
      region               = "us-central1"
      network_resource_key = "vpc1"
      secondary_ip_range = {
        secondary_ip_range_1 = {
          range_name    = "tf-test-secondary-range-update1"
          ip_cidr_range = "192.168.10.0/24"
        }
      }
    }
  }
  CloudRunResource = {
    cloudrun1 = {
      name                  = "cloudrun1"
      location              = "us-central1"
      cloudrun_resource_key = "cloudrun1"
      template = {
        template1 = {
          containers = {
            container1 = {
              image = "us-docker.pkg.dev/cloudrun/container/hello"
              container_port = "80"
            }
          }
        }
      }
    }
  }
  Noauth = {
    cloudrun1 = {
      cloudrun_resource_key = "cloudrun1"
    }
  }
}