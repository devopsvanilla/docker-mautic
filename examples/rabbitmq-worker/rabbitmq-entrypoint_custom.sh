#!/bin/bash
set -e

# Install curl if not already installed
if ! command -v curl &> /dev/null; then
  echo "Installing curl..."
  apt-get update && apt-get install -y curl
fi

rabbitmq-server &

# Additional health check using RabbitMQ management API
until curl -s -o /dev/null -w "%{http_code}" http://localhost:15672/api/healthchecks/node | grep -q "200"; do
  sleep 5
done

# Create vhosts
rabbitmqctl add_vhost "${RABBITMQ_MAIL_VHOST}"
rabbitmqctl add_vhost "${RABBITMQ_HIT_VHOST}"
rabbitmqctl add_vhost "${RABBITMQ_FAILED_VHOST}"
rabbitmqctl set_permissions -p "${RABBITMQ_MAIL_VHOST}" "${RABBITMQ_DEFAULT_USER}" ".*" ".*" ".*"
rabbitmqctl set_permissions -p "${RABBITMQ_HIT_VHOST}" "${RABBITMQ_DEFAULT_USER}" ".*" ".*" ".*"
rabbitmqctl set_permissions -p "${RABBITMQ_FAILED_VHOST}" "${RABBITMQ_DEFAULT_USER}" ".*" ".*" ".*"

# Set correct permissions for RabbitMQ directories
chown -R rabbitmq:rabbitmq /var/lib/rabbitmq

