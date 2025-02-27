#!/bin/bash
set -e

# Install curl if not already installed
if ! command -v curl &> /dev/null; then
  echo "Installing curl..."
  apt-get update && apt-get install -y curl
fi

# Start RabbitMQ server in the background
echo "Starting RabbitMQ server..."
rabbitmq-server > /var/log/rabbitmq/rabbitmq.log 2>&1 &
RABBITMQ_PID=$!

# Function to check if RabbitMQ is fully operational
check_rabbitmq() {
    rabbitmqctl status >/dev/null 2>&1 && \
    curl -s -u "${RABBITMQ_DEFAULT_USER}":"${RABBITMQ_DEFAULT_PASS}" http://localhost:15672/api/overview >/dev/null 2>&1
}

# Wait for RabbitMQ to be fully operational
echo "Waiting for RabbitMQ to be fully operational..."
TIMEOUT=180
START_TIME=$(date +%s)

until check_rabbitmq || [ $(($(date +%s) - $START_TIME)) -gt $TIMEOUT ]; do
    echo "Waiting for RabbitMQ..."
    sleep 5
done

if ! check_rabbitmq; then
    echo "Error: RabbitMQ failed to start within ${TIMEOUT} seconds"
    exit 1
fi

echo "RabbitMQ is up and running!"

# Function to check if a vhost exists
vhost_exists() {
  vhost="$1"
  rabbitmqctl list_vhosts | grep -q "^$vhost$"
}

# Create vhosts and set permissions
echo "Creating RabbitMQ vhosts..."

if ! vhost_exists "${RABBITMQ_MAIL_VHOST}"; then
  rabbitmqctl add_vhost "${RABBITMQ_MAIL_VHOST}"
  rabbitmqctl set_permissions -p "${RABBITMQ_MAIL_VHOST}" "${RABBITMQ_DEFAULT_USER}" ".*" ".*" ".*"
  echo "Created vhost ${RABBITMQ_MAIL_VHOST} and set permissions."
else
  echo "Vhost ${RABBITMQ_MAIL_VHOST} already exists."
fi

if ! vhost_exists "${RABBITMQ_HIT_VHOST}"; then
  rabbitmqctl add_vhost "${RABBITMQ_HIT_VHOST}"
  rabbitmqctl set_permissions -p "${RABBITMQ_HIT_VHOST}" "${RABBITMQ_DEFAULT_USER}" ".*" ".*" ".*"
    echo "Created vhost ${RABBITMQ_HIT_VHOST} and set permissions."
else
  echo "Vhost ${RABBITMQ_HIT_VHOST} already exists."
fi

if ! vhost_exists "${RABBITMQ_FAILED_VHOST}"; then
  rabbitmqctl add_vhost "${RABBITMQ_FAILED_VHOST}"
  rabbitmqctl set_permissions -p "${RABBITMQ_FAILED_VHOST}" "${RABBITMQ_DEFAULT_USER}" ".*" ".*" ".*"
  echo "Created vhost ${RABBITMQ_FAILED_VHOST} and set permissions."
else
  echo "Vhost ${RABBITMQ_FAILED_VHOST} already exists."
fi

echo "RabbitMQ vhosts created/verified!"

# Set correct permissions for RabbitMQ directories
chown -R rabbitmq:rabbitmq /var/lib/rabbitmq
echo "RabbitMQ directories permissions set!"

echo "==============RabbitMQ setup complete!=============="

tail -f /var/log/rabbitmq/rabbitmq.log &

wait $RABBITMQ_PID