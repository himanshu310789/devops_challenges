#!/bin/bash
# Bash Script to retrieve AWS Instance metadata

CURL="$(which curl)"

## XML to JSON Conversion
fun2() {
  ## Output of the Code
  echo
  echo -e "Output of $ARG : "
  echo -e $VALUE | xq .
}

## JSON Conversion
fun3() {
  ## Output of the Code
  echo
  echo -e "Output of $ARG : "
  echo -e "$ARG\n$VALUE" | tr -s ' ' ',' | jq -nR '[ ( input | split(",") ) as $keys | ( inputs | split(",") ) as $vals | [ [$keys, $vals] | transpose[] | {key:.[0],value:.[1]} ] | from_entries ]'
}

## Fetch Instance Metadata
main_fun () {
  VALUE=`${CURL} -sL http://169.254.169.254/latest/meta-data/${ARG}`

  echo $VALUE | grep -i xml &> /dev/null
  if [ "$?" == "0" ] ; then
    fun2
  else
    fun3
  fi
}


############### Script Start ###############
if [ "$#" -eq 1 ] &> /dev/null
  then
    ARG="$1"

    # Call main function
    main_fun

else
    echo "Usage: /bin/bash ec2_metadata.sh [COMPLETE METADATA NAME AS ARGUMENT]"
fi

