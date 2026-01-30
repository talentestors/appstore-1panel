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

	image=$(yq -r .services.$first_service.image $docker_compose_file)

    echo "First service: $first_service"
    echo "Image: $image"

	# Only apply changes if the format is <image>:<version>
	if [[ "$image" == *":"* ]]; then
	  # Extract version from the last colon (handles registries with ports)
	  version=$(echo "$image" | rev | cut -d ":" -f1 | rev)

	  # Remove quotes, "v" prefix, and any trailing characters
	  trimmed_version=${version/#"v"}
	  trimmed_version=${trimmed_version//\"/}
	  trimmed_version=$(echo "$trimmed_version" | tr -d '"')

      echo "Extracted version: $version"
      echo "Trimmed version: $trimmed_version"
      echo "Renaming directory from $old_version to $trimmed_version"

      # Only rename if the trimmed version is different from the old version
      if [ "$old_version" != "$trimmed_version" ] && [ ! -d "apps/$app_name/$trimmed_version" ]; then
        mv apps/$app_name/$old_version apps/$app_name/$trimmed_version
        echo "Directory renamed successfully"
      else
        echo "Directory rename skipped (version unchanged or already exists)"
      fi
    else
      echo "Image format not recognized, skipping"
    fi
done

echo "renovate-app-version.sh completed"
