FROM java:8

RUN apt-get update \
    && apt-get install -y uuid-runtime mysql-client

# install rundeck
ENV RUNDECK_VERSION=2.6.7-1-GA
RUN wget "http://dl.bintray.com/rundeck/rundeck-deb/rundeck-${RUNDECK_VERSION}.deb" &&\
    dpkg -i rundeck-${RUNDECK_VERSION}.deb &&\
    rm -f rundeck-${RUNDECK_VERSION}.deb &&\
    ln -sf /dev/null /var/log/rundeck/rundeck.access.log &&\
    ln -sf /dev/null /var/log/rundeck/rundeck.api.log &&\
    ln -sf /dev/null /var/log/rundeck/rundeck.audit.log &&\
    ln -sf /dev/null /var/log/rundeck/rundeck.executions.log &&\
    ln -sf /dev/null /var/log/rundeck/rundeck.jobs.log &&\
    ln -sf /dev/null /var/log/rundeck/rundeck.log &&\
    ln -sf /dev/null /var/log/rundeck/rundeck.options.log &&\
    ln -sf /dev/null /var/log/rundeck/rundeck.storage.log

# install rundeck plugins
WORKDIR /var/lib/rundeck/libext
RUN wget "https://github.com/rundeck-plugins/rundeck-ec2-nodes-plugin/releases/download/v1.5.2/rundeck-ec2-nodes-plugin-1.5.2.jar" &&\
    wget "https://github.com/rundeck-plugins/rundeck-s3-log-plugin/releases/download/v1.0.1/rundeck-s3-log-plugin-1.0.1.jar" &&\
    wget "https://github.com/higanworks/rundeck-slack-incoming-webhook-plugin/releases/download/v0.5.dev/rundeck-slack-incoming-webhook-plugin-0.5.jar"

# install vagrant
ENV VAGRANT_VERSION=1.8.1
RUN wget "https://releases.hashicorp.com/vagrant/${VAGRANT_VERSION}/vagrant_${VAGRANT_VERSION}_x86_64.deb" &&\
    dpkg -i vagrant_${VAGRANT_VERSION}_x86_64.deb &&\
    rm -f vagrant_${VAGRANT_VERSION}_x86_64.deb &&\
    vagrant plugin install vagrant-aws &&\
    vagrant box add dummy "https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box"

WORKDIR /var/lib/rundeck

COPY profile.sh /etc/rundeck/profile

ENV TZ=Asia/Tokyo \
    RUNDECK_PORT=4440 \
    RUNDECK_MYSQL_DATABASE=rundeck \
    RUNDECK_MYSQL_USERNAME=rundeck \
    RUNDECK_MYSQL_PASSWORD=rundeck \
    RUNDECK_S3_REGION=ap-northeast-1 \
    RUNDECK_CLUSTER_MODE=false

CMD . /etc/rundeck/profile &&\
    java ${RDECK_JVM} -cp ${BOOTSTRAP_CP} com.dtolabs.rundeck.RunServer /var/lib/rundeck ${RUNDECK_PORT}