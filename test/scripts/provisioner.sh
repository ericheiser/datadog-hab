#!/bin/bash

if ! [ -f /tmp/results/hab_artifact.tar.gz ]; then
  echo "ERROR: No hab_artifact.tar.gz found, did you run 'hab pkg build .'?"
  exit 1
fi

export HAB_LICENSE="accept-no-persist"

# Load variables for use in this script
source /tmp/results/last_build.env

# Extract Habitat artifact (contains `hab` binary and all keys/packages)
sudo tar xf /tmp/results/hab_artifact.tar.gz -C /

# Create `hab` user and group if they do not exist
if grep "^hab:" /etc/passwd > /dev/null; then
  echo "Hab user exists, skipping user creation"
else
  # NOTE: `useradd` also creates a group by default
  sudo useradd hab && true
fi

echo "Determine pkg_prefix for $pkg_artifact"
pkg_prefix=$(find "/hab/pkgs/$pkg_origin/$pkg_name" -maxdepth 2 -mindepth 2 | sort | tail -n 1)
echo "Found: $pkg_prefix"

cd ~
echo "Starting Hab Sup in `pwd`"
nohup sudo -E /hab/bin/hab sup run &
sleep 10

echo "Adding mongo conf"
echo '[mongod]

[mongod.net]
bind_ip = "0.0.0.0"

[mongod.security]
cluster_auth_mode = ""' > /tmp/mongo.toml
/hab/bin/hab config apply mongodb.default $(date +%s) /tmp/mongo.toml

# Execute Chef Infra client inside the package
echo "Running chef-client in $pkg_origin/$pkg_name"
cd "$pkg_prefix" || exit 1
sudo -E /hab/bin/hab svc load "core/mongodb/3.2.9/20170515233318"
sudo -E /hab/bin/hab svc load "ericheiser/national-parks-datadog" --bind database:mongodb.default
sudo -E /hab/bin/hab pkg exec "$pkg_origin/$pkg_name" chef-client -z -c "$pkg_prefix/config/bootstrap-config.rb"
