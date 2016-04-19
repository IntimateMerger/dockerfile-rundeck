RDECK_BASE=/var/lib/rundeck
export RDECK_BASE

JAVA_CMD=java
RUNDECK_TEMPDIR=/tmp/rundeck

#RDECK_HTTP_PORT=4440
#RDECK_HTTPS_PORT=4443

# Change hostname & URL
sed -i -e "/^framework.server.name/c\framework.server.name = ${HOSTNAME}" /etc/rundeck/framework.properties
sed -i -e "/^framework.server.hostname/c\framework.server.hostname = ${HOSTNAME}" /etc/rundeck/framework.properties
sed -i -e "/^framework.server.port/c\framework.server.port = ${RUNDECK_PORT}" /etc/rundeck/framework.properties
sed -i -e "/^framework.server.url/c\framework.server.url = ${RUNDECK_URL}" /etc/rundeck/framework.properties
sed -i -e "/^grails.serverURL/c\grails.serverURL=${RUNDECK_URL}" /etc/rundeck/rundeck-config.properties

# Enable Cluster Mode
echo "rundeck.server.uuid = $(uuidgen)" >> /etc/rundeck/framework.properties
echo "rundeck.clusterMode.enabled = ${RUNDECK_CLUSTER_MODE}" >> /etc/rundeck/rundeck-config.properties

# Use MySQL
sed -i -e "/^dataSource.url/c\dataSource.url = jdbc:mysql://${RUNDECK_MYSQL_HOST}/${RUNDECK_MYSQL_DATABASE}?autoReconnect=true" /etc/rundeck/rundeck-config.properties
echo "dataSource.username = ${RUNDECK_MYSQL_USERNAME}" >> /etc/rundeck/rundeck-config.properties
echo "dataSource.password = ${RUNDECK_MYSQL_PASSWORD}" >> /etc/rundeck/rundeck-config.properties

# Enables DB for Project configuration storage
echo "rundeck.projectsStorageType = db" >> /etc/rundeck/rundeck-config.properties

# Enable DB for Key Storage
echo "rundeck.storage.provider.1.type = db" >> /etc/rundeck/rundeck-config.properties
echo "rundeck.storage.provider.1.path = keys" >> /etc/rundeck/rundeck-config.properties

# Rundeck S3 Log Storage Plugin
echo "framework.plugin.ExecutionFileStorage.org.rundeck.amazon-s3.bucket = ${RUNDECK_S3_BUCKET}" >> /etc/rundeck/framework.properties
echo 'framework.plugin.ExecutionFileStorage.org.rundeck.amazon-s3.path = logs/${job.project}/${job.id}/${job.execid}.log' >> /etc/rundeck/framework.properties
echo "framework.plugin.ExecutionFileStorage.org.rundeck.amazon-s3.region = ${RUNDECK_S3_REGION}" >> /etc/rundeck/framework.properties
echo "rundeck.execution.logs.fileStoragePlugin = org.rundeck.amazon-s3" >> /etc/rundeck/rundeck-config.properties

#
# If JAVA_HOME is set, then add it to home and set JAVA_CMD to use the version specified in that
# path.  JAVA_HOME can be set in the rundeck profile.  Or set in this file.
#JAVA_HOME=<path/to/JDK or JRE/install>

if [ ! -z $JAVA_HOME ]; then
	PATH=$PATH:$JAVA_HOME/bin
	export PATH
	JAVA_CMD=$JAVA_HOME/bin/java
fi



export CLI_CP=$(find /var/lib/rundeck/cli -name \*.jar -printf %p:)
export BOOTSTRAP_CP=$(find /var/lib/rundeck/bootstrap -name \*.jar -printf %p:)
export RDECK_JVM="-Djava.security.auth.login.config=/etc/rundeck/jaas-loginmodule.conf \
	-Dloginmodule.name=RDpropertyfilelogin \
	-Drdeck.config=/etc/rundeck \
	-Drdeck.base=/var/lib/rundeck \
	-Drundeck.server.configDir=/etc/rundeck \
	-Dserver.datastore.path=/var/lib/rundeck/data \
	-Drundeck.server.serverDir=/var/lib/rundeck \
	-Drdeck.projects=/var/rundeck/projects \
	-Drdeck.runlogs=/var/lib/rundeck/logs \
	-Drundeck.config.location=/etc/rundeck/rundeck-config.properties \
	-Djava.io.tmpdir=$RUNDECK_TEMPDIR \
	-Drundeck.jetty.connector.forwarded=true"
#
# Set min/max heap size
#
RDECK_JVM="$RDECK_JVM -Xmx1024m -Xms256m -XX:MaxPermSize=256m -server"
#
# SSL Configuration - Uncomment the following to enable.  Check SSL.properties for details.
#
#export RDECK_JVM="$RDECK_JVM -Drundeck.ssl.config=/etc/rundeck/ssl/ssl.properties -Dserver.https.port=${RDECK_HTTPS_PORT}"

export RDECK_SSL_OPTS="-Djavax.net.ssl.trustStore=/etc/rundeck/ssl/truststore -Djavax.net.ssl.trustStoreType=jks -Djava.protocol.handler.pkgs=com.sun.net.ssl.internal.www.protocol"

if test -t 0 -a -z "$RUNDECK_CLI_TERSE"
then
  RUNDECK_CLI_TERSE=true
  export RUNDECK_CLI_TERSE
fi

if test -n "$JRE_HOME"
then
   unset JRE_HOME
fi

umask 002
