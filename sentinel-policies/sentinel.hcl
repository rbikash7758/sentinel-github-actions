sentinel {
  features = {
    terraform = true
  }
}

import "plugin" "tfplan/v2" {
  config = {
    plan_path = "./tfplan.json"
  }
}

policy "enforce-policy-consolidated" {
    source            = "./enforce-policy-consolidated.sentinel"
    enforcement_level = "hard-mandatory"
}