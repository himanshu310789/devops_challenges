#!/bin/bash
# This Code is used to fetch key value pair from nested object.

retrieve_fun() {

  new_key=$(echo $2 | sed -e 's|/|.|g')
  output=$(echo $1 | jq ".${new_key}")
  echo "value = $output"
}

############## Script Start Here ######################

## Nested Object Input
echo
read -p "Please provide the complete nested json object: " object


## Key of Nested Object
echo
read -p "Please provide the appropriate key in format [ a/b/c or x/y/z ]: " key

retrieve_fun $object $key
