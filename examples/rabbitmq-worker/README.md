# Mautic Docker deployment with RabbitMQ Worker

This example demonstrates how to run Mautic with RabbitMQ as the message queue system for handling asynchronous tasks and assume the use of Docker Compose v2 including best practices for running Mautic with RabbitMQ in a containerized environment.

Also adds the possibility of importing files in background (See mautic_web-entrypoint_custom.sh)

## Prerequisites

- [Docker Engine 20.10.0 or newer](https://docs.docker.com/get-started/get-docker/)
- [Docker Compose v2.0.0 or newer](https://docs.docker.com/compose/install/)
- [Git (for cloning the repository)](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)

## Directory Structure
```
rabbitmq-worker/                     # Root project directory
├── .env                             # Docker Compose Global environment variables
├── .mautic_env                      # Docker Compose Mautic specific environment variables
├── docker-compose.yml               # Docker Compose configuration file
├── mautic_web-entrypoint_custom.sh  # Custom Docker Image Entrypoint for Docker Mautic Image used in Web container
├── rabbitmq-entrypoint_custom.sh    # Custom entrypoint container script to create vhosts used in Mautic
├── supervisord.conf                 # Custom configuration with best practices do Mautic Workers
├── undeploy.sh                      # Undeploy application from you Docker Host
├── volumes/                         # Created at execution for container storage
│   ├── mautic/                      # Mautic specific shared directories
│   │   ├── config/                  # Configuration files
│   │   ├── cron/                    # Cron files
│   │   ├── logs/                    # Application logs
│   │   └── media/                   # Media storage
│   │       ├── files/               # Uploaded files
│   │       └── images/              # Uploaded images
│   ├── mysql/                       # MySQL data storage
│   ├── rabbitmq/                    # RabbitMQ data storage
└── README.md                        # This file instructions
```

## Configuration

1. Optional: Create the directories specified by the volumes in docker-compose.yml for custom settings. Refer to the [README.md](../../README.md) file in the root of this repository for detailed instructions:

```bash
mkdir -p volumes/mautic/{config,cron,media/{files,images}}
```

2. Copy the example environment files:

```bash
cp .env.example .env
cp .mautic_env.example .mautic_env
```
3. Configure the  ```.env``` file with your database settings.

4. Configure the ```.mautic_env``` file with RabbitMQ settings.

5. Change sections variables in <b><i>enviroment</i></b> of  ```docker-compose.yml``` file for specific settings of each container and also the resources limits of each service as CPU and RAM.

6. Ajustes os valores do arquivo ```supervisord.conf```

## Deployment

1. Start the services:
```bash
docker compose up -d
```
2. Monitor the startup process:
```bash
docker compose up -d
````
3. Access Mautic:

- Web Interface: http://localhost:8003

- RabbitMQ Management Interface: http://localhost:15672 (default credentials: guest/guest)

## Logs
#### View Mautic logs:
```bash
cd ./volumes/mautic/logs
ls -la
```
#### View RabbitMQ logs:
```bash
docker compose logs rabbitmq
````

## Backup

Backup for all services can be done from the directory [./volumes](./volumes) created at the Docker Engine host.


## Scaling Workers

#### To scale the number of worker containers:
```bash
docker compose up -d --scale mautic_worker=3
```

## Undeploy containers

Undeplay Containers and delete all associated resources:
```bash
bash undeploy.sh
```

## Troubleshooting

#### Check service health:
```bash
docker compose ps
```

## Security Considerations
- Change default RabbitMQ credentials in production
- Enable SSL/TLS for RabbitMQ connections
- Regularly update all containers to their latest versions
- Monitor queue sizes and consumer health
- Implement proper backup strategies

## Additional Official Resources
- [Mautic Website](https://github.com/mautic)
- [Mautic Documentation](https://docs.mautic.org/en/5.x/)
- [Mautic Forum](https://forum.mautic.org/)
- [Mautic at Docker Hub](https://hub.docker.com/r/mautic/mautic)
- [Mautic at GitHub](https://github.com/mautic)
- [RabbitMQ Documentation](https://www.rabbitmq.com/docs)
- [Docker Documentation](https://docs.docker.com/compose/)
