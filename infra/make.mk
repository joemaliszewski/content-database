export ENVIRONMENT	?= dev
export PROJECT_NAME = content-database

export RUN_TERRAFORM 	= @docker-compose run --rm infra-utils terraform
export RUN_IO			= @docker-compose run --rm infra-io

export TF_PLAN_NAME	= ${PROJECT_NAME}-${ENVIRONMENT}.plan

export BACKEND_BUCKET	= tfstate.${ENVIRONMENT}.${PROJECT_NAME}.bucket

export BACKEND_KEY		= ${PROJECT_NAME}-${ENVIRONMENT}.tfstate

export IMAGE_TAG = ${GLOBAL_VERSION}

export DOCKER_REPO ?= ${AWS_ACCOUNT_NUMBER}.dkr.ecr.eu-west-1.amazonaws.com

init:
	${RUN_TERRAFORM} init -input=false -backend=false
	${RUN_TERRAFORM} validate

build: _init
	echo "You are deploying to ${ENVIRONMENT}"
	${RUN_TERRAFORM} plan \
		-var environment=${ENVIRONMENT} \
		-var-file=config/${ENVIRONMENT}.tfvars \
		-out ${TF_PLAN_NAME}

deploy:
	${RUN_TERRAFORM} apply ${TF_PLAN_NAME} 

destroy:
	${RUN_TERRAFORM} destroy -input=false -auto-approve \
		-var environment=${ENVIRONMENT} \
		-var image_tag=${IMAGE_TAG} \
		-var-file=config/${ENVIRONMENT}.tfvars

clean:
	$(RUN_IO) -c "rm -rfd .terraform"
	$(RUN_IO) -c "rm -rfd .terraform.d"
	$(RUN_IO) -c "rm -f terraform.tfstate"
	$(RUN_IO) -c "rm -f errored.tfstate"
	$(RUN_IO) -c "rm -f terraform.tfstate.backup"
	$(RUN_IO) -c "rm -f $(TF_PLAN_NAME)"
	$(RUN_IO) -c "rm -f .terraform.lock.hcl"
	$(RUN_IO) -c "rm -rf *.plan"
	$(RUN_IO) -c "rm -rfd .aws"
	$(RUN_IO) -c "rm -rf .ash_history"
	$(RUN_IO) -c "rm -rf .bash_history"

_init:
	${RUN_TERRAFORM} init \
	-backend-config="bucket=${BACKEND_BUCKET}" \
	-backend-config="key=${BACKEND_KEY}" \
	-backend-config="region=${REGION}" \
	-reconfigure

build_deploy: build deploy
