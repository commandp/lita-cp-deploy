# lita-cp-deploy

可以透過 lita 執行 opswork or http get

## Installation

Add lita-cp-deploy to your Lita instance's Gemfile:

``` ruby
gem "lita-cp-deploy", git: 'https://github.com/commandp/lita-cp-deploy.git'
```

## Usage

```
AWS_REGION=us-east-1
AWS_ACCESS_KEY=xxxxx
AWS_SECRET_ACCESS_KEY=xxxxx
DEPLOY_CONFIG= '{
  "deploy_itams": [{
    "name": "AWS OpsWorks Staging API",
    "short_name": "g stg api", 
    "type": "aws", 
    "stack_id": "xxx",
    "app_id": "xxx"
   }, 
   {
    "name": "Jenkins Staging API",
    "short_name": "c stg api", 
    "type": "http_get", 
    "TriggerURL": "http://jenkins.dev/job/run_deploy/buildWithParameters?token=xxx"
   }]
}'
```
