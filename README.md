[![Circle CI](https://circleci.com/gh/IntimateMerger/dockerfile-rundeck/tree/master.svg?style=svg)](https://circleci.com/gh/IntimateMerger/dockerfile-rundeck/tree/master)

# Rundeck Dockerfile
Dockerfile for [Rundeck](http://rundeck.org/) on AWS

## How to use this image

### Environment

If you don't set the env, Rundeck use the default env.

| name | default | description |
| --- | --- | --- |
| TZ | Asia/Tokyo | Timezone |
| RUNDECK_PORT | 4440 | Listen Port |
| RUNDECK_URL |  | exp) https://rundeck.example.com |
| RUNDECK_MYSQL_HOST |  | exp) rundeck.xxxxxxxxxxxxx.ap-northeast-1.rds.amazonaws.com |
| RUNDECK_MYSQL_DATABASE | rundeck |  |
| RUNDECK_MYSQL_USERNAME | rundeck |  |
| RUNDECK_MYSQL_PASSWORD | rundeck |  |
| AWS_ACCESS_KEY_ID |  | for rundeck-ec2-nodes-plugin |
| AWS_SECRET_ACCESS_KEY |  | for rundeck-ec2-nodes-plugin |
| AWS_SECRET_KEY |  | for rundeck-s3-log-plugin |
| RUNDECK_S3_BUCKET |  | for rundeck-s3-log-plugin |
| RUNDECK_S3_REGION | ap-northeast-1 | for rundeck-s3-log-plugin |

### Example

```bash
$ docker run -d -p 4440:4440 \
    -e "RUNDECK_URL=https://rundeck.example.com" \
    -e "RUNDECK_S3_BUCKET=rundeck-example" \
    -e "RUNDECK_MYSQL_HOST=example.ap-northeast-1.rds.amazonaws.com" \
    -t intimatemerger/rundeck:latest
```

### with docker-compose

Example docker-compose.yml for rundeck:

```yml
rundeck:
  image: intimatemerger/rundeck
  links:
    - db:db_host
  ports:
    - 4440:4440
  environment:
    RUNDECK_URL: http://localhost:4440
    RUNDECK_MYSQL_HOST: db_host

db:
  image: mariadb
  environment:
    MYSQL_ROOT_PASSWORD: root
    MYSQL_DATABASE: rundeck
    MYSQL_USER: rundeck
    MYSQL_PASSWORD: rundeck
```
