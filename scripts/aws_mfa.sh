#!/bin/zsh
# this _should_ also be /bin/bash compat

# ENSURE YOU HAVE `brew install jq` (it's tiny)

# Setting profile to default so we don't risk using the MFA user to try refreshing itself
# ... that doesn't work btw
function aws_mfa {
    export AWS_DEFAULT_PROFILE=default

    echo "MFA Code:"
    USER=grantg
    CODE=$(read -e)
    ARN=$(aws iam list-mfa-devices --user-name $USER --output text --query "MFADevices[0].SerialNumber")
    JSON=$(aws sts get-session-token --duration-seconds 129600 --serial-number $ARN --token-code $CODE --output json --query 'Credentials')
    aws configure set aws_access_key_id $(echo $JSON | jq --raw-output '.AccessKeyId') --profile mfa
    aws configure set aws_secret_access_key $(echo $JSON | jq --raw-output '.SecretAccessKey') --profile mfa
    aws configure set aws_session_token $(echo $JSON | jq --raw-output '.SessionToken') --profile mfa
}
