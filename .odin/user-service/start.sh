#!/usr/bin/env bash
set -e

echo "Starting user-service..."
echo "ODIN_APP_DIR: ${ODIN_APP_DIR}"
echo "ODIN_DEPLOYMENT_TYPE: ${ODIN_DEPLOYMENT_TYPE}"

cd "${ODIN_APP_DIR}" || exit

if [[ "${ODIN_DEPLOYMENT_TYPE}" == *"k8s"* ]]; then
  exec java -jar "${ODIN_APP_DIR}/user-service-0.0.1-SNAPSHOT.jar"
else
  nohup java -jar "${ODIN_APP_DIR}/user-service-0.0.1-SNAPSHOT.jar" > /opt/logs/user-service.log 2>&1 &
  echo $! > "${ODIN_APP_DIR}/.app.pid"
fi
