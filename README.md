# lita-cp-deploy

可以透過 lita 執行 opswork or jenkins

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
    "region": "ap-northeast-1", // optional
    "layer_ids": ["xxx"], // optional
    "type": "aws",
    "stack_id": "xxx",
    "app_id": "xxx"
  },
  {
    "name": "China Staging Web",
    "short_name": "c stg web",
    "type": "jenkins",
    "user": "xiii",
    "password": "xxx",
    "TriggerURL": "http://jenkins/job/run_deploy/buildWithParameters?token=xxx&cause=xxx"
  }
}'
```

```
lita deploy <short_name>

or

lita deploy <short_name> revision=develop
```

## chef-client deploy specially revision with jenkins

Enter job configure > This build is parameterized

![jenkins_parameterized](docs/jenkins_parameterized.png?raw=true "Title")

setting shell script

![jenkins_parameterized_2](docs/jenkins_parameterized_2.png?raw=true "Title")
