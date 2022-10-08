locals {
  product_information = {
    context : {
      project    = "average"
      layer      = "infrastructure"
      service    = "network"
      start_date = "2022-04-01"
      end_date   = "unknown"
    }
    purpose : {
      disaster_recovery = "medium"
      service_class     = "bronze"
    }
    organization : {
      client = "anct"
    }
    stakeholders : {
      business_owner  = "xavier.norris"
      technical_owner = "romain.cambonie@gmail.com"
      approver        = "romain.cambonie@gmail.com"
      creator         = "terraform"
      team            = "average"
    }
  }
}

locals {
  projectTitle = title(replace(local.product_information.context.project, "_", " "))
  layerTitle   = title(replace(local.product_information.context.layer, "_", " "))
  serviceTitle = title(replace(local.product_information.context.service, "_", " "))
  domainNames  = ["average.thunder-arrow.cloud"]
}

locals {
  service = {
    average = {
      name = "average"
      api = {
        name  = "api"
        title = "api"
      }
      client = {
        name  = "client"
        title = "client"
      }
    }
  }
}
