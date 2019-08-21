# Policyfile.rb - Describe how you want Chef Infra to build your system.
#
# For more information on the Policyfile feature, visit
# https://docs.chef.io/policyfile.html

name "my-datadog"

# Where to find external cookbooks
default_source :supermarket
# default_source :chef_repo, "../"

# # attributes: set attributes from your cookbooks
default['datadog']['api_key'] = "d4d7a8c885c4d0c04bec60dcab8b692c"
# Use an existing application key or create a new one for Chef
default['datadog']['application_key'] = "e6993e99f32852859d1ab041863822df824b4303"

default['datadog']['tomcat']['instances'] = [
    {
      :server => "localhost",
      :port => "9000",
      :name => "national-parks"
    }
  ]

# default['patching'] = {}

# default['applications'] = {
#   'windows' => {}
# }

# # run_list: run these recipes in the order specified.
run_list [
  "datadog::dd-handler",
  "datadog::tomcat"
]
