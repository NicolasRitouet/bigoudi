# Cloudformation stack to setup a SPA on s3, Cloudfront and AWS Certificate manager

[![MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

> This stack builds a setup to deploy a client side app on s3 with Cloudfront as a CDN and HTTPS using AWS Certificate Manager


## Getting started

:unlock: Before using the makefile, you need `aws CLI` installed and configured (`aws configure --profile bigoudi`) and an user-account on the AWS account of Bigoudi with enough permissions to run the update.

1 .`git clone git@github.com:NicolasRitouet/bigoudi.git`
2. change bigoudi with your own project name
3. change bigou.di with your own domain name
4. if you don't have one, create a new AWS account
5. create a new profile for the `AWS cli` with your AWS account
6. modify params.json with your domain name and ARN certificate
6. `make create-stack`

## Cost

The main goal of this stack is to be cost-efficient and easily scalable.

- s3 costs a few cents per month for less than 1Gb
- Cloudfront will be almost free with a limited traffic (if the traffic increases, you'll be hopefully glad to pay a few $ more)
- Route53 Hosted Zone (0.50$ per month)
- AWS Certificate manager creates SSL certificates for free and automatically renewd by AWS

## Resources

### Main stack

This template will create a stack containing the following AWS resources:

- an S3 bucket for the logs
- an S3 bucket for the website
- a Cloudfront Distribution
- an hosted Zone for bigou.di
- a DNS record set for bigou.di
- a DNS record set for www.bigou.di

### SSL Certificate stack

A second cloudformation stack `ssl.yml` is available to create the SSL certificate.

It will create a wildcard certificate for bigou.di and bigoudi.com

This can be done manually or using this command:
`AWS_REGION=us-east-1 STACK_NAME=ssl-bigoudi STACK_FILE_NAME=ssl make create`

:warning: The SSL certificate needs to be deployed in the `us-east-1` region to be associated with Cloudfront.

Once the SSL certificate has been created, copy paste the ARN in the `params.json` file.

Use the following command to find the ARN:  
`AWS_REGION=us-east-1 STACK_NAME=ssl-bigoudi STACK_FILE_NAME=ssl make output`

## Commands

### Push a new stack

```bash
make create
```

### Update an existing stack

```bash
make update
```

### Display stack's output

```bash
make output
```

### Display stack's events

```bash
make watch
```

### Create a new change-set

```bash
make create-hangeset
```

### Describe a change-set

```bash
make describe-changeset CHANGESET-NAME=name-of-changeset
```


### Test syntax of makefile

```bash
make test
```
