#!/bin/sh

CONTAINER_NAME=$( cat /opt/piraeus/client/.satellite_container_name )
docker exec -it ${CONTAINER_NAME} linstor $@
EXIT_CODE=$?

# EXIT_CODE > 1 means "docker exec succeeds but the command it runs failed;
# EXIT_CODE == 1 means "docker exec" itself fails. 
# For efficency, only when "docker exec fails", try find the correct running container

if [ ${EXIT_CODE} = '1' ]; then
   echo "* Trying to find the running container:"
   NEW_CONTAINER_NAME=$( docker inspect --format='{{.Name}}' $( docker ps -q ) \
        | grep "$( echo ${CONTAINER_NAME} | sed -E 's/_[1-9]+$//' )" \
        | head -1 \
        | sed 's#^/##' )
   if [ -z ${NEW_CONTAINER_NAME} ]; then
      exit ${EXIT_CODE}
   else
        echo "* Found running container:"
        echo ${NEW_CONTAINER_NAME} | tee /opt/piraeus/client/.satellite_container_name
        echo "* Re-running: \"linstor $@\""
        docker exec -it ${NEW_CONTAINER_NAME} linstor $@
   fi
else
   exit ${EXIT_CODE}