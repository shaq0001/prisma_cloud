#!/bin/bash
echo "$LINENO: $0" >&2
export PS4='$LINENO: '
#
accNum=$(aws sts get-caller-identity | jq -r '.Account')
if [ -z "$accNum" ]; then
   echo "aws call failed" >&2
   exit 1
fi

case "$1" in
   "--help"|"-help"|"help") 
  cat <<EOF
$0 { [ --apply | --destroy | --plan | --state ], "" }  <other terraform parameters>

where --apply is default action in absence of a 1st parameter having -- 
EOF

exit ;;
   "--destroy"|"--plan"|"--state"|"--replace") which=$(echo $1 | sed -e 's/--//'); shift;;
   *) which="apply";;
esac

# check for the existence of multi envs within accounts

accListCount=$(cd accounts;ls -l | grep ${accNum} | wc -l)

echo $1|grep -q -- -
dash=$?

if [ $dash -eq 0 ] || [ $accListCount -eq 1 ]; then
   myDataDir=accounts/${accNum}
   export TF_VAR_ENV_ABBREV=""
elif [ $accListCount -gt 1 ]; then
   env_abbr=$(echo "$1" | tr '[:lower:]' '[:upper:]')
   export TF_VAR_ENV_ABBREV="-${env_abbr}"
   shift
   if [ -z "$env_abbr" ]; then 
      dir=accounts/$accNum
   else
      dir=accounts/$accNum-$env_abbr
   fi
   if [ -d $dir ]; then
       myDataDir="$dir"
    else
       echo "directory accounts/$accNum-$env_abbr does not exist"
       exit 1
    fi
else    
   echo "This account is not setup!"
   exit 1
fi

#
# put .terraform folder elsewhere
#
echo "export TF_DATA_DIR=${myDataDir}/.terraform"
export TF_DATA_DIR=${myDataDir}/.terraform

if [ -e ${myDataDir}/envScript ]; then
   .  ${myDataDir}/envScript
   [ $? -ne 0 ] && exit 1
else

   case "${accNum}" in
      089902810488) echo "Working in NEW Stage";;
      102553174541) echo "Working in Implementation";;
      438171280653) echo "Working in DEV";;
      452418757197) echo "Working in NEW-DEV";;
      502667418623) echo "Working in PRODUCTION" ;;
      543800268692) echo "Working in LCH PRODUCTION" ;;      
      804656202561) echo "Working in Admin";;
      819417623337) 
               case "$env_abbr" in
                  DEMO) echo "Working in DEMO";;
                  TRN) echo "Working in TRAINING";;
                  LAB) echo "Working in LAB";;
                  *) echo "Working in Account 819417623337";; 
               esac
               ;;
      *) echo "Error $accNum unknown"
         exit 1 ;;
   esac
fi
# apply
case "$which" in
  apply|destroy|plan )
echo "terraform ${which}  ${optTFVars} -var-file=${myDataDir}/variables.tfvars $@"
      terraform ${which}   ${optTFVars} -var-file=${myDataDir}/variables.tfvars $@;;
  *) echo "terraform ${which} $@"
     terraform ${which} $@;;
     
esac
