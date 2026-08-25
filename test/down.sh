#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

require_env MU_NAMESPACE
require_dir "$ENVIRONMENT_DIR"

for app in crystal nodejs frontend; do
  banner "Beginning ${app} pipeline term"
  cd "${ENVIRONMENT_DIR}/ecsdemo-${app}"
  mu pipeline term
done

banner "Beginning acceptance platform term"
cd "${ENVIRONMENT_DIR}/ecsdemo-platform"
mu env term acceptance

banner "Beginning production platform term"
mu env term production

banner "Beginning ecr repo delete"
for app in frontend nodejs crystal; do
  ignore_missing aws ecr delete-repository --repository-name "${MU_NAMESPACE}-ecsdemo-${app}" --force
done

banner "Beginning s3 bucket delete"
REGION=$(current_region)
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

for bucket in codedeploy codepipeline; do
  ignore_missing aws s3 rm --recursive "s3://${MU_NAMESPACE}-${bucket}-${REGION}-${ACCOUNT_ID}"
done

banner "Beginning cf stack delete"
for app in frontend nodejs crystal; do
  for env in acceptance production; do
    ignore_missing aws cloudformation delete-stack \
      --stack-name "${MU_NAMESPACE}-iam-service-ecsdemo-${app}-${env}"
  done
  ignore_missing aws cloudformation delete-stack --stack-name "${MU_NAMESPACE}-repo-ecsdemo-${app}"
done

for bucket in codedeploy codepipeline; do
  ignore_missing aws cloudformation delete-stack --stack-name "${MU_NAMESPACE}-bucket-${bucket}"
done

banner "Beginning sleep 300"
sleep 300 # delay waiting for all the other CF stacks to be deleted -- replace with a count of stacks or something

banner "Beginning iam-common stack delete"
ignore_missing aws cloudformation delete-stack --stack-name "${MU_NAMESPACE}-iam-common"

banner "Teardown complete"
