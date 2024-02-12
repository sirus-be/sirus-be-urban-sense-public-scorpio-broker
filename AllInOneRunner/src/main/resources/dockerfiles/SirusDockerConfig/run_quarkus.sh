#!/bin/bash
cd $scrdir

# Get DSH certificates for Kafka connection
export PKI_CONFIG_DIR=/usr/src/scorpio/certs/dsh
source "/usr/src/scorpio/get_signed_certificate.sh"

# Set the consumer groups for the scorpi broker using the environment variables.
export SCORPIO_CONSUMERGROUP_CSOURCE=$(cat ${PKI_CONFIG_DIR}/datastreams.json | jq -r '.shared_consumer_groups' | jq -r '.[0]')
export SCORPIO_CONSUMERGROUP_HISTORY=$(cat ${PKI_CONFIG_DIR}/datastreams.json | jq -r '.shared_consumer_groups' | jq -r '.[1]')
export SCORPIO_CONSUMERGROUP_CSOURCESUBSCRIPTION=$(cat ${PKI_CONFIG_DIR}/datastreams.json | jq '.shared_consumer_groups' | jq -r '.[2]')
export SCORPIO_CONSUMERGROUP_PRIVATE=$(cat ${PKI_CONFIG_DIR}/datastreams.json | jq -r '.private_consumer_groups' | jq -r '.[0]')

echo "DEBUG: Check content of variables"
echo "SCORPIO_CONSUMERGROUP_CSOURCE: ${SCORPIO_CONSUMERGROUP_CSOURCE}"
echo "SCORPIO_CONSUMERGROUP_HISTORY: ${SCORPIO_CONSUMERGROUP_HISTORY}"
echo "SCORPIO_CONSUMERGROUP_CSOURCESUBSCRIPTION: ${SCORPIO_CONSUMERGROUP_CSOURCESUBSCRIPTION}"
echo "SCORPIO_CONSUMERGROUP_PRIVATE: ${SCORPIO_CONSUMERGROUP_PRIVATE}"

# Add a trap to catch the sigterm before we start the final java process.
trap 'echo Received trapped signal, beginning shutdown...;exit 0;' TERM HUP INT;
trap ":" EXIT

# Startup the final java service. This will be PID1.
exec java -jar $scrjar $*