#!/bin/zsh
# this _should_ also be /bin/bash compat

# ENSURE YOU HAVE `brew install jq` (it's tiny)

# Setting profile to default so we don't risk using the MFA user to try refreshing itself
# ... that doesn't work btw
# Running this inside a sub-shell to ensure weird variables are not set
function aws_mfa() (
    echo "MFA Code:"
    local user=grantg
    local code=$(read -e)
    local arn=$(aws iam list-mfa-devices --user-name $user --output text --query "MFADevices[0].SerialNumber" --profile prog)
    local json=$(aws sts get-session-token --duration-seconds 129600 --serial-number $arn --token-code $code --output json --query 'Credentials' --profile prog)
    aws configure set aws_access_key_id $(echo $json | jq --raw-output '.AccessKeyId') --profile default
    aws configure set aws_secret_access_key $(echo $json | jq --raw-output '.SecretAccessKey') --profile default
    aws configure set aws_session_token $(echo $json | jq --raw-output '.SessionToken') --profile default
)
