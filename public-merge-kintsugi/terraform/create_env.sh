#!/bin/bash
set -e
# keep track of the last executed command
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
# echo an error message before exiting
#trap 'echo "\"${last_command}\" command filed with exit code $?."' EXIT

if [ $# -ne 1 ]; then
  echo 1>&2 "Usage: $0 env_to_create"
  exit 3
fi

env_name=$1
echo "Creating Env: ${env_name}"
mkdir env/${env_name}
cd env/${env_name}

ln -s ../../main.tf .
ln -s ../../variables.tf .

cp ../../example_backend.tf .
cp ../../example_env.tfvars ./${env_name}.tfvars

echo "Finished creating: ${env_name}"