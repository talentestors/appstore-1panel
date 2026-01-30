#!/bin/bash
# This script copies the version from docker-compose.yml to config.json.

echo "Starting renovate-app-version.sh"
echo "App name: $1"
echo "Old version: $2"

app_name=$1
old_version=$2

# find all docker-compose files under apps/$app_name (there should be only one)
docker_compose_files=$(find apps/$app_name/$old_version -name docker-compose.yml)

echo "Found docker-compose files: $docker_compose_files"

for docker_compose_file in $docker_compose_files
do
    echo "Processing: $docker_compose_file"

	# Assuming that the app version will be from the first docker service
	first_service=$(yq '.services | keys | .[0]' $docker_compose_file)

	image=$(yq .services.$first_service.image $docker_compose_file)

    echo "First service: $first_service"
    echo "Image: $image"

	# Only apply changes if the format is <image>:<version>
	if [[ "$image" == *":"* ]]; then
	  version=$(cut -d ":" -f2- <<< "$image")

	  # Trim the "v" prefix
	  trimmed_version=${version/#"v"}

      echo "Extracted version: $version"
      echo "Trimmed version: $trimmed_version"
      echo "Renaming directory from $old_version to $trimmed_version"

      mv apps/$app_name/$old_version apps/$app_name/$trimmed_version
    else
      echo "Image format not recognized, skipping"
    fi
done

echo "renovate-app-version.sh completed"
