.PHONY : create update events watch output delete validate validate-all

##############################################################################
#
#  Makefile to manage a cloudformation stack
#
#         v.1.0.0
#
#    written by Nicolas Ritouet
# 
##############################################################################

# Default variables
AWS_REGION ?= eu-west-1
AWS_PROFILE ?= bigoudi
PARAMS = params.json
STACK_NAME = bigoudi
STACK_FILE_NAME ?= stack


##############################################################################
#
# Functions
#
##############################################################################

#
# Create a new Cloudformation stack
#
create: validate
	aws cloudformation create-stack --stack-name $(STACK_NAME) --template-body file://`pwd`/$(STACK_FILE_NAME).yml \
    --parameters file://`pwd`/$(PARAMS) --profile $(AWS_PROFILE) --region $(AWS_REGION)

#
# Validate template syntax and update an existing stack (without validation)
#
update: validate .confirm
	aws cloudformation update-stack --stack-name $(STACK_NAME) --template-body file://`pwd`/stack.yml \
		--parameters file://`pwd`/$(PARAMS) --capabilities CAPABILITY_IAM --profile $(AWS_PROFILE) --region $(AWS_REGION)

#
# Validate template syntax and create a change-set for the specified stack (Dry-run)
#
create-changeset: validate
	aws cloudformation create-change-set --change-set-name $(CHANGESET_NAME) --stack-name $(STACK_NAME) --template-body file://`pwd`/$(STACK_FOLDER)/$(STACK)/stack.yml \
    --parameters file://`pwd`/$(PARAMS) --capabilities CAPABILITY_IAM --profile $(AWS_PROFILE) --region $(AWS_REGION)

#
# Describe an existing change-set for the specified stack
#
describe-changeset:
	aws cloudformation describe-change-set --change-set-name $(CHANGESET_NAME) --stack-name $(STACK_NAME) --profile $(AWS_PROFILE) --region $(AWS_REGION)

#
# Execute an existing change-set for the specified stack (verify that all changes are expected)
#
execute-changeset: .confirm
	aws cloudformation execute-change-set --change-set-name $(CHANGESET_NAME) --stack-name $(STACK_NAME) --profile $(AWS_PROFILE) --region $(AWS_REGION)

#
# Remove an existing change-set for the specified stack
#
delete-changeset:
	aws cloudformation delete-change-set --change-set-name $(CHANGESET_NAME) --stack-name $(STACK_NAME) --profile $(AWS_PROFILE) --region $(AWS_REGION)

#
# Display all events for the specified stack
#
events:
	aws cloudformation describe-stack-events --stack-name $(STACK_NAME) --profile $(AWS_PROFILE) --region $(AWS_REGION)

#
# Watch all events for the specified stack
#
watch:
	while :; do clear; make events | head -25; sleep 5; done

#
# Display outputs of the specified stack
#
output:
	@which jq || ( which brew && brew install jq || which apt-get && apt-get install jq || which yum && yum install jq || which choco && choco install jq)
	aws cloudformation describe-stacks --stack-name $(STACK_NAME) --profile $(AWS_PROFILE) --region $(AWS_REGION) | jq -r '.Stacks[].Outputs'

#
# Delete the specified stack
#
delete: .confirm
	aws cloudformation delete-stack --stack-name $(STACK_NAME) --profile $(AWS_PROFILE) --region $(AWS_REGION)


#
# Validate syntax of the specified template
#
validate:
	@which aws || pip install awscli
	aws cloudformation validate-template --template-body file://`pwd`/stack.yml

#
# Run the tests (validate all template syntaxes and print makefile)
#
test: validate
	make --just-print


##############################################################################
#
# Utilities
#
##############################################################################
#
# Ask user confirmation before continuing
#
.confirm:
	@while [ -z "$$CONTINUE" ]; do \
		read -r -p "You are about to push changes directly on the stack, are you sure? [y/N] " CONTINUE; \
	done ; \
	if [ ! $$CONTINUE == "y" ]; then \
	if [ ! $$CONTINUE == "Y" ]; then \
		echo "Exiting." ; exit 1 ; \
	fi \
	fi