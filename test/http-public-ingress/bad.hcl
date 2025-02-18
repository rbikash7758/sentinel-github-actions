mock "tfplan/v2" {
  module {
    source = "mock-bad-tfplan-v2.sentinel"
  }
}

test {
  rules = {
    main = false
  }
}
