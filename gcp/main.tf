#Enable the Required GCP Services
resource "google_project_service" "r_services" {
  project            = var.project
  for_each           = var.Resources.GCPServices
  service            = each.value.name
  disable_on_destroy = can(each.value.disable_on_destroy) ? each.value.disable_on_destroy : null
}

#To Create VPC
module "m_vpc" {
  source     = "./module/vpc"
  Resources  = var.Resources
  depends_on = [google_project_service.r_services]
}

#To Create CloudRun
module "m_cloudrun" {
  source     = "./module/cloudrun"
  Resources  = var.Resources
  depends_on = [google_project_service.r_services, module.m_vpc]

}