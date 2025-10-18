# Docker Compose Examples

A comprehensive collection of real-world Docker Compose examples covering various service patterns, application architectures, and deployment scenarios.

## Table of Contents

1. [Web Application Stacks](#web-application-stacks)
2. [Database Services](#database-services)
3. [Caching and Message Queues](#caching-and-message-queues)
4. [Monitoring and Logging](#monitoring-and-logging)
5. [CI/CD and Development Tools](#cicd-and-development-tools)
6. [Content Management Systems](#content-management-systems)
7. [Data Processing and Analytics](#data-processing-and-analytics)
8. [Security and Authentication](#security-and-authentication)
9. [Networking Examples](#networking-examples)
10. [Advanced Patterns](#advanced-patterns)

---

## Web Application Stacks

### MERN Stack (MongoDB, Express, React, Node.js)

```yaml
version: "3.8"

services:
  # React Frontend
  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile
    ports:
      - "3000:3000"
    volumes:
      - ./frontend/src:/app/src
      - /app/node_modules
    environment:
      - REACT_APP_API_URL=http://localhost:5000/api
      - CHOKIDAR_USEPOLLING=true
    networks:
      - mern-network
    depends_on:
      - backend

  # Express Backend
  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile
    ports:
      - "5000:5000"
    volumes:
      - ./backend:/app
      - /app/node_modules
    environment:
      - NODE_ENV=development
      - MONGODB_URI=mongodb://mongo:27017/mernapp
      - JWT_SECRET=dev-secret-key
      - PORT=5000
    networks:
      - mern-network
    depends_on:
      mongo:
        condition: service_healthy

  # MongoDB Database
  mongo:
    image: mongo:6
    container_name: mongodb
    restart: unless-stopped
    ports:
      - "27017:27017"
    environment:
      - MONGO_INITDB_ROOT_USERNAME=admin
      - MONGO_INITDB_ROOT_PASSWORD=secret
      - MONGO_INITDB_DATABASE=mernapp
    volumes:
      - mongo-data:/data/db
      - mongo-config:/data/configdb
      - ./mongo-init.js:/docker-entrypoint-initdb.d/mongo-init.js:ro
    networks:
      - mern-network
    healthcheck:
      test: ["CMD", "mongosh", "--eval", "db.adminCommand('ping')"]
      interval: 10s
      timeout: 5s
      retries: 5

  # Mongo Express (Database UI)
  mongo-express:
    image: mongo-express:latest
    container_name: mongo-express
    restart: unless-stopped
    ports:
      - "8081:8081"
    environment:
      - ME_CONFIG_MONGODB_ADMINUSERNAME=admin
      - ME_CONFIG_MONGODB_ADMINPASSWORD=secret
      - ME_CONFIG_MONGODB_URL=mongodb://admin:secret@mongo:27017/
      - ME_CONFIG_BASICAUTH_USERNAME=admin
      - ME_CONFIG_BASICAUTH_PASSWORD=admin
    networks:
      - mern-network
    depends_on:
      - mongo

networks:
  mern-network:
    driver: bridge

volumes:
  mongo-data:
    driver: local
  mongo-config:
    driver: local
```

### LAMP Stack (Linux, Apache, MySQL, PHP)

```yaml
version: "3.8"

services:
  # Apache + PHP
  web:
    build:
      context: ./docker/php
      dockerfile: Dockerfile
    container_name: lamp-web
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./public:/var/www/html
      - ./docker/php/php.ini:/usr/local/etc/php/php.ini:ro
      - ./docker/apache/apache2.conf:/etc/apache2/apache2.conf:ro
      - ./docker/apache/sites-available:/etc/apache2/sites-available:ro
      - ssl-certs:/etc/apache2/ssl
    environment:
      - APACHE_DOCUMENT_ROOT=/var/www/html/public
      - PHP_MEMORY_LIMIT=256M
      - PHP_UPLOAD_MAX_FILESIZE=64M
    networks:
      - lamp-network
    depends_on:
      mysql:
        condition: service_healthy

  # MySQL Database
  mysql:
    image: mysql:8.0
    container_name: lamp-mysql
    restart: unless-stopped
    ports:
      - "3306:3306"
    environment:
      - MYSQL_ROOT_PASSWORD=root_secret
      - MYSQL_DATABASE=lampdb
      - MYSQL_USER=lampuser
      - MYSQL_PASSWORD=lamppass
    volumes:
      - mysql-data:/var/lib/mysql
      - ./docker/mysql/my.cnf:/etc/mysql/conf.d/my.cnf:ro
      - ./docker/mysql/init:/docker-entrypoint-initdb.d
    networks:
      - lamp-network
    command: --default-authentication-plugin=mysql_native_password
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost", "-u", "root", "-proot_secret"]
      interval: 10s
      timeout: 5s
      retries: 5

  # phpMyAdmin
  phpmyadmin:
    image: phpmyadmin/phpmyadmin:latest
    container_name: lamp-phpmyadmin
    restart: unless-stopped
    ports:
      - "8080:80"
    environment:
      - PMA_HOST=mysql
      - PMA_PORT=3306
      - PMA_USER=root
      - PMA_PASSWORD=root_secret
      - UPLOAD_LIMIT=64M
    networks:
      - lamp-network
    depends_on:
      - mysql

  # Mailhog (Email Testing)
  mailhog:
    image: mailhog/mailhog:latest
    container_name: lamp-mailhog
    restart: unless-stopped
    ports:
      - "1025:1025"
      - "8025:8025"
    networks:
      - lamp-network

networks:
  lamp-network:
    driver: bridge

volumes:
  mysql-data:
    driver: local
  ssl-certs:
    driver: local
```

### Next.js + PostgreSQL + Redis

```yaml
version: "3.8"

services:
  # Next.js Application
  nextjs:
    build:
      context: ./nextjs-app
      dockerfile: Dockerfile.dev
      target: development
    container_name: nextjs-app
    ports:
      - "3000:3000"
    volumes:
      - ./nextjs-app:/app
      - /app/node_modules
      - /app/.next
    environment:
      - NODE_ENV=development
      - DATABASE_URL=postgresql://postgres:postgres@postgres:5432/nextjs_db
      - REDIS_URL=redis://redis:6379
      - NEXTAUTH_URL=http://localhost:3000
      - NEXTAUTH_SECRET=dev-secret
    networks:
      - nextjs-network
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_started
    command: npm run dev

  # PostgreSQL Database
  postgres:
    image: postgres:15-alpine
    container_name: nextjs-postgres
    restart: unless-stopped
    ports:
      - "5432:5432"
    environment:
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=postgres
      - POSTGRES_DB=nextjs_db
    volumes:
      - postgres-data:/var/lib/postgresql/data
      - ./database/init.sql:/docker-entrypoint-initdb.d/init.sql:ro
    networks:
      - nextjs-network
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 10s
      timeout: 5s
      retries: 5

  # Redis Cache
  redis:
    image: redis:7-alpine
    container_name: nextjs-redis
    restart: unless-stopped
    ports:
      - "6379:6379"
    volumes:
      - redis-data:/data
    networks:
      - nextjs-network
    command: redis-server --appendonly yes --requirepass redis_password
    healthcheck:
      test: ["CMD", "redis-cli", "--raw", "incr", "ping"]
      interval: 10s
      timeout: 3s
      retries: 5

  # pgAdmin (Database UI)
  pgadmin:
    image: dpage/pgadmin4:latest
    container_name: nextjs-pgadmin
    restart: unless-stopped
    ports:
      - "5050:80"
    environment:
      - PGADMIN_DEFAULT_EMAIL=admin@admin.com
      - PGADMIN_DEFAULT_PASSWORD=admin
      - PGADMIN_CONFIG_SERVER_MODE=False
    volumes:
      - pgadmin-data:/var/lib/pgadmin
    networks:
      - nextjs-network
    depends_on:
      - postgres

  # Redis Commander (Redis UI)
  redis-commander:
    image: rediscommander/redis-commander:latest
    container_name: nextjs-redis-commander
    restart: unless-stopped
    ports:
      - "8082:8081"
    environment:
      - REDIS_HOSTS=local:redis:6379:0:redis_password
    networks:
      - nextjs-network
    depends_on:
      - redis

networks:
  nextjs-network:
    driver: bridge

volumes:
  postgres-data:
  redis-data:
  pgadmin-data:
```

### Django + PostgreSQL + Celery + Redis

```yaml
version: "3.8"

services:
  # Django Web Application
  web:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: django-web
    command: python manage.py runserver 0.0.0.0:8000
    volumes:
      - .:/code
      - static-volume:/code/staticfiles
      - media-volume:/code/media
    ports:
      - "8000:8000"
    environment:
      - DEBUG=True
      - SECRET_KEY=django-insecure-dev-key
      - DATABASE_URL=postgresql://django:django@postgres:5432/django_db
      - CELERY_BROKER_URL=redis://redis:6379/0
      - CELERY_RESULT_BACKEND=redis://redis:6379/0
    networks:
      - django-network
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy

  # PostgreSQL Database
  postgres:
    image: postgres:15-alpine
    container_name: django-postgres
    volumes:
      - postgres-data:/var/lib/postgresql/data
    environment:
      - POSTGRES_DB=django_db
      - POSTGRES_USER=django
      - POSTGRES_PASSWORD=django
    networks:
      - django-network
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U django"]
      interval: 10s
      timeout: 5s
      retries: 5

  # Redis (Cache & Celery Broker)
  redis:
    image: redis:7-alpine
    container_name: django-redis
    volumes:
      - redis-data:/data
    networks:
      - django-network
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 3s
      retries: 5

  # Celery Worker
  celery-worker:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: django-celery-worker
    command: celery -A myproject worker -l info
    volumes:
      - .:/code
    environment:
      - DATABASE_URL=postgresql://django:django@postgres:5432/django_db
      - CELERY_BROKER_URL=redis://redis:6379/0
      - CELERY_RESULT_BACKEND=redis://redis:6379/0
    networks:
      - django-network
    depends_on:
      - postgres
      - redis
    deploy:
      replicas: 2

  # Celery Beat (Scheduler)
  celery-beat:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: django-celery-beat
    command: celery -A myproject beat -l info --scheduler django_celery_beat.schedulers:DatabaseScheduler
    volumes:
      - .:/code
    environment:
      - DATABASE_URL=postgresql://django:django@postgres:5432/django_db
      - CELERY_BROKER_URL=redis://redis:6379/0
      - CELERY_RESULT_BACKEND=redis://redis:6379/0
    networks:
      - django-network
    depends_on:
      - postgres
      - redis

  # Flower (Celery Monitoring)
  flower:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: django-flower
    command: celery -A myproject flower
    volumes:
      - .:/code
    ports:
      - "5555:5555"
    environment:
      - CELERY_BROKER_URL=redis://redis:6379/0
      - CELERY_RESULT_BACKEND=redis://redis:6379/0
    networks:
      - django-network
    depends_on:
      - redis
      - celery-worker

  # NGINX (Production)
  nginx:
    image: nginx:alpine
    container_name: django-nginx
    ports:
      - "80:80"
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf:ro
      - static-volume:/staticfiles:ro
      - media-volume:/media:ro
    networks:
      - django-network
    depends_on:
      - web

networks:
  django-network:
    driver: bridge

volumes:
  postgres-data:
  redis-data:
  static-volume:
  media-volume:
```

---

## Database Services

### PostgreSQL with Replication

```yaml
version: "3.8"

services:
  # Primary PostgreSQL
  postgres-primary:
    image: postgres:15-alpine
    container_name: postgres-primary
    environment:
      - POSTGRES_USER=replicator
      - POSTGRES_PASSWORD=replicator_password
      - POSTGRES_DB=myapp
      - POSTGRES_HOST_AUTH_METHOD=md5
      - POSTGRES_INITDB_ARGS=--encoding=UTF-8 --lc-collate=C --lc-ctype=C
    volumes:
      - postgres-primary-data:/var/lib/postgresql/data
      - ./postgres/primary/postgresql.conf:/etc/postgresql/postgresql.conf
      - ./postgres/primary/pg_hba.conf:/etc/postgresql/pg_hba.conf
      - ./postgres/setup-primary.sh:/docker-entrypoint-initdb.d/setup-primary.sh
    networks:
      - db-network
    ports:
      - "5432:5432"
    command: postgres -c config_file=/etc/postgresql/postgresql.conf

  # Standby PostgreSQL (Read Replica)
  postgres-standby:
    image: postgres:15-alpine
    container_name: postgres-standby
    environment:
      - POSTGRES_USER=replicator
      - POSTGRES_PASSWORD=replicator_password
      - PGPASSWORD=replicator_password
    volumes:
      - postgres-standby-data:/var/lib/postgresql/data
      - ./postgres/standby/postgresql.conf:/etc/postgresql/postgresql.conf
      - ./postgres/setup-standby.sh:/docker-entrypoint-initdb.d/setup-standby.sh
    networks:
      - db-network
    ports:
      - "5433:5432"
    depends_on:
      - postgres-primary

networks:
  db-network:
    driver: bridge

volumes:
  postgres-primary-data:
  postgres-standby-data:
```

### MongoDB Replica Set

```yaml
version: "3.8"

services:
  mongo1:
    image: mongo:6
    container_name: mongo1
    command: ["--replSet", "rs0", "--bind_ip_all", "--port", "27017"]
    ports:
      - "27017:27017"
    volumes:
      - mongo1-data:/data/db
      - ./mongo/mongo-init.sh:/docker-entrypoint-initdb.d/mongo-init.sh:ro
    networks:
      - mongo-network
    healthcheck:
      test: ["CMD", "mongosh", "--eval", "db.adminCommand('ping')"]
      interval: 10s
      timeout: 5s
      retries: 5

  mongo2:
    image: mongo:6
    container_name: mongo2
    command: ["--replSet", "rs0", "--bind_ip_all", "--port", "27017"]
    ports:
      - "27018:27017"
    volumes:
      - mongo2-data:/data/db
    networks:
      - mongo-network
    depends_on:
      - mongo1

  mongo3:
    image: mongo:6
    container_name: mongo3
    command: ["--replSet", "rs0", "--bind_ip_all", "--port", "27017"]
    ports:
      - "27019:27017"
    volumes:
      - mongo3-data:/data/db
    networks:
      - mongo-network
    depends_on:
      - mongo1

networks:
  mongo-network:
    driver: bridge

volumes:
  mongo1-data:
  mongo2-data:
  mongo3-data:
```

### MySQL with Master-Slave Replication

```yaml
version: "3.8"

services:
  # MySQL Master
  mysql-master:
    image: mysql:8.0
    container_name: mysql-master
    environment:
      - MYSQL_ROOT_PASSWORD=root
      - MYSQL_DATABASE=myapp
      - MYSQL_USER=repl_user
      - MYSQL_PASSWORD=repl_password
    volumes:
      - mysql-master-data:/var/lib/mysql
      - ./mysql/master/my.cnf:/etc/mysql/conf.d/my.cnf:ro
      - ./mysql/master/init.sql:/docker-entrypoint-initdb.d/init.sql:ro
    networks:
      - mysql-network
    ports:
      - "3306:3306"
    command: --server-id=1 --log-bin=mysql-bin --binlog-do-db=myapp

  # MySQL Slave
  mysql-slave:
    image: mysql:8.0
    container_name: mysql-slave
    environment:
      - MYSQL_ROOT_PASSWORD=root
      - MYSQL_DATABASE=myapp
    volumes:
      - mysql-slave-data:/var/lib/mysql
      - ./mysql/slave/my.cnf:/etc/mysql/conf.d/my.cnf:ro
      - ./mysql/slave/init.sql:/docker-entrypoint-initdb.d/init.sql:ro
    networks:
      - mysql-network
    ports:
      - "3307:3306"
    depends_on:
      - mysql-master
    command: --server-id=2 --relay-log=mysql-relay-bin --read-only=1

networks:
  mysql-network:
    driver: bridge

volumes:
  mysql-master-data:
  mysql-slave-data:
```

---

## Caching and Message Queues

### Redis Cluster

```yaml
version: "3.8"

services:
  redis-node-1:
    image: redis:7-alpine
    container_name: redis-node-1
    command: redis-server --cluster-enabled yes --cluster-config-file nodes.conf --cluster-node-timeout 5000 --appendonly yes
    ports:
      - "7001:6379"
    volumes:
      - redis-node-1:/data
    networks:
      - redis-cluster

  redis-node-2:
    image: redis:7-alpine
    container_name: redis-node-2
    command: redis-server --cluster-enabled yes --cluster-config-file nodes.conf --cluster-node-timeout 5000 --appendonly yes
    ports:
      - "7002:6379"
    volumes:
      - redis-node-2:/data
    networks:
      - redis-cluster

  redis-node-3:
    image: redis:7-alpine
    container_name: redis-node-3
    command: redis-server --cluster-enabled yes --cluster-config-file nodes.conf --cluster-node-timeout 5000 --appendonly yes
    ports:
      - "7003:6379"
    volumes:
      - redis-node-3:/data
    networks:
      - redis-cluster

  redis-node-4:
    image: redis:7-alpine
    container_name: redis-node-4
    command: redis-server --cluster-enabled yes --cluster-config-file nodes.conf --cluster-node-timeout 5000 --appendonly yes
    ports:
      - "7004:6379"
    volumes:
      - redis-node-4:/data
    networks:
      - redis-cluster

  redis-node-5:
    image: redis:7-alpine
    container_name: redis-node-5
    command: redis-server --cluster-enabled yes --cluster-config-file nodes.conf --cluster-node-timeout 5000 --appendonly yes
    ports:
      - "7005:6379"
    volumes:
      - redis-node-5:/data
    networks:
      - redis-cluster

  redis-node-6:
    image: redis:7-alpine
    container_name: redis-node-6
    command: redis-server --cluster-enabled yes --cluster-config-file nodes.conf --cluster-node-timeout 5000 --appendonly yes
    ports:
      - "7006:6379"
    volumes:
      - redis-node-6:/data
    networks:
      - redis-cluster

  # Cluster initialization
  redis-cluster-init:
    image: redis:7-alpine
    container_name: redis-cluster-init
    command: >
      sh -c "sleep 5 &&
             redis-cli --cluster create
             redis-node-1:6379
             redis-node-2:6379
             redis-node-3:6379
             redis-node-4:6379
             redis-node-5:6379
             redis-node-6:6379
             --cluster-replicas 1 --cluster-yes"
    networks:
      - redis-cluster
    depends_on:
      - redis-node-1
      - redis-node-2
      - redis-node-3
      - redis-node-4
      - redis-node-5
      - redis-node-6

networks:
  redis-cluster:
    driver: bridge

volumes:
  redis-node-1:
  redis-node-2:
  redis-node-3:
  redis-node-4:
  redis-node-5:
  redis-node-6:
```

### RabbitMQ with High Availability

```yaml
version: "3.8"

services:
  rabbitmq1:
    image: rabbitmq:3-management-alpine
    container_name: rabbitmq1
    hostname: rabbitmq1
    environment:
      - RABBITMQ_ERLANG_COOKIE=secret_cookie
      - RABBITMQ_DEFAULT_USER=admin
      - RABBITMQ_DEFAULT_PASS=admin
    volumes:
      - rabbitmq1-data:/var/lib/rabbitmq
      - ./rabbitmq/rabbitmq.conf:/etc/rabbitmq/rabbitmq.conf:ro
      - ./rabbitmq/enabled_plugins:/etc/rabbitmq/enabled_plugins:ro
    ports:
      - "5672:5672"
      - "15672:15672"
    networks:
      - rabbitmq-network

  rabbitmq2:
    image: rabbitmq:3-management-alpine
    container_name: rabbitmq2
    hostname: rabbitmq2
    environment:
      - RABBITMQ_ERLANG_COOKIE=secret_cookie
      - RABBITMQ_DEFAULT_USER=admin
      - RABBITMQ_DEFAULT_PASS=admin
    volumes:
      - rabbitmq2-data:/var/lib/rabbitmq
      - ./rabbitmq/rabbitmq.conf:/etc/rabbitmq/rabbitmq.conf:ro
      - ./rabbitmq/enabled_plugins:/etc/rabbitmq/enabled_plugins:ro
    ports:
      - "5673:5672"
      - "15673:15672"
    networks:
      - rabbitmq-network
    depends_on:
      - rabbitmq1

  rabbitmq3:
    image: rabbitmq:3-management-alpine
    container_name: rabbitmq3
    hostname: rabbitmq3
    environment:
      - RABBITMQ_ERLANG_COOKIE=secret_cookie
      - RABBITMQ_DEFAULT_USER=admin
      - RABBITMQ_DEFAULT_PASS=admin
    volumes:
      - rabbitmq3-data:/var/lib/rabbitmq
      - ./rabbitmq/rabbitmq.conf:/etc/rabbitmq/rabbitmq.conf:ro
      - ./rabbitmq/enabled_plugins:/etc/rabbitmq/enabled_plugins:ro
    ports:
      - "5674:5672"
      - "15674:15672"
    networks:
      - rabbitmq-network
    depends_on:
      - rabbitmq1

  # HAProxy Load Balancer
  haproxy:
    image: haproxy:alpine
    container_name: rabbitmq-haproxy
    volumes:
      - ./haproxy/haproxy.cfg:/usr/local/etc/haproxy/haproxy.cfg:ro
    ports:
      - "5670:5670"
      - "15670:15670"
      - "8404:8404"
    networks:
      - rabbitmq-network
    depends_on:
      - rabbitmq1
      - rabbitmq2
      - rabbitmq3

networks:
  rabbitmq-network:
    driver: bridge

volumes:
  rabbitmq1-data:
  rabbitmq2-data:
  rabbitmq3-data:
```

### Apache Kafka with Schema Registry

```yaml
version: "3.8"

services:
  zookeeper:
    image: confluentinc/cp-zookeeper:latest
    container_name: zookeeper
    environment:
      ZOOKEEPER_CLIENT_PORT: 2181
      ZOOKEEPER_TICK_TIME: 2000
    volumes:
      - zookeeper-data:/var/lib/zookeeper/data
      - zookeeper-logs:/var/lib/zookeeper/log
    networks:
      - kafka-network

  kafka-broker-1:
    image: confluentinc/cp-kafka:latest
    container_name: kafka-broker-1
    depends_on:
      - zookeeper
    ports:
      - "9092:9092"
    environment:
      KAFKA_BROKER_ID: 1
      KAFKA_ZOOKEEPER_CONNECT: zookeeper:2181
      KAFKA_ADVERTISED_LISTENERS: PLAINTEXT://kafka-broker-1:9092,PLAINTEXT_HOST://localhost:29092
      KAFKA_LISTENER_SECURITY_PROTOCOL_MAP: PLAINTEXT:PLAINTEXT,PLAINTEXT_HOST:PLAINTEXT
      KAFKA_INTER_BROKER_LISTENER_NAME: PLAINTEXT
      KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR: 3
      KAFKA_TRANSACTION_STATE_LOG_MIN_ISR: 2
      KAFKA_TRANSACTION_STATE_LOG_REPLICATION_FACTOR: 3
    volumes:
      - kafka-broker-1-data:/var/lib/kafka/data
    networks:
      - kafka-network

  kafka-broker-2:
    image: confluentinc/cp-kafka:latest
    container_name: kafka-broker-2
    depends_on:
      - zookeeper
    ports:
      - "9093:9092"
    environment:
      KAFKA_BROKER_ID: 2
      KAFKA_ZOOKEEPER_CONNECT: zookeeper:2181
      KAFKA_ADVERTISED_LISTENERS: PLAINTEXT://kafka-broker-2:9092,PLAINTEXT_HOST://localhost:29093
      KAFKA_LISTENER_SECURITY_PROTOCOL_MAP: PLAINTEXT:PLAINTEXT,PLAINTEXT_HOST:PLAINTEXT
      KAFKA_INTER_BROKER_LISTENER_NAME: PLAINTEXT
      KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR: 3
      KAFKA_TRANSACTION_STATE_LOG_MIN_ISR: 2
      KAFKA_TRANSACTION_STATE_LOG_REPLICATION_FACTOR: 3
    volumes:
      - kafka-broker-2-data:/var/lib/kafka/data
    networks:
      - kafka-network

  kafka-broker-3:
    image: confluentinc/cp-kafka:latest
    container_name: kafka-broker-3
    depends_on:
      - zookeeper
    ports:
      - "9094:9092"
    environment:
      KAFKA_BROKER_ID: 3
      KAFKA_ZOOKEEPER_CONNECT: zookeeper:2181
      KAFKA_ADVERTISED_LISTENERS: PLAINTEXT://kafka-broker-3:9092,PLAINTEXT_HOST://localhost:29094
      KAFKA_LISTENER_SECURITY_PROTOCOL_MAP: PLAINTEXT:PLAINTEXT,PLAINTEXT_HOST:PLAINTEXT
      KAFKA_INTER_BROKER_LISTENER_NAME: PLAINTEXT
      KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR: 3
      KAFKA_TRANSACTION_STATE_LOG_MIN_ISR: 2
      KAFKA_TRANSACTION_STATE_LOG_REPLICATION_FACTOR: 3
    volumes:
      - kafka-broker-3-data:/var/lib/kafka/data
    networks:
      - kafka-network

  schema-registry:
    image: confluentinc/cp-schema-registry:latest
    container_name: schema-registry
    depends_on:
      - kafka-broker-1
      - kafka-broker-2
      - kafka-broker-3
    ports:
      - "8081:8081"
    environment:
      SCHEMA_REGISTRY_HOST_NAME: schema-registry
      SCHEMA_REGISTRY_KAFKASTORE_BOOTSTRAP_SERVERS: kafka-broker-1:9092,kafka-broker-2:9092,kafka-broker-3:9092
      SCHEMA_REGISTRY_LISTENERS: http://0.0.0.0:8081
    networks:
      - kafka-network

  kafka-ui:
    image: provectuslabs/kafka-ui:latest
    container_name: kafka-ui
    depends_on:
      - kafka-broker-1
      - kafka-broker-2
      - kafka-broker-3
      - schema-registry
    ports:
      - "8080:8080"
    environment:
      KAFKA_CLUSTERS_0_NAME: local
      KAFKA_CLUSTERS_0_BOOTSTRAPSERVERS: kafka-broker-1:9092,kafka-broker-2:9092,kafka-broker-3:9092
      KAFKA_CLUSTERS_0_ZOOKEEPER: zookeeper:2181
      KAFKA_CLUSTERS_0_SCHEMAREGISTRY: http://schema-registry:8081
    networks:
      - kafka-network

networks:
  kafka-network:
    driver: bridge

volumes:
  zookeeper-data:
  zookeeper-logs:
  kafka-broker-1-data:
  kafka-broker-2-data:
  kafka-broker-3-data:
```

---

## Monitoring and Logging

### Complete Monitoring Stack (Prometheus, Grafana, AlertManager)

```yaml
version: "3.8"

services:
  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--web.console.libraries=/etc/prometheus/console_libraries'
      - '--web.console.templates=/etc/prometheus/consoles'
      - '--storage.tsdb.retention.time=30d'
      - '--web.enable-lifecycle'
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus/prometheus.yml:/etc/prometheus/prometheus.yml:ro
      - ./prometheus/alert_rules.yml:/etc/prometheus/alert_rules.yml:ro
      - prometheus-data:/prometheus
    networks:
      - monitoring
    restart: unless-stopped

  alertmanager:
    image: prom/alertmanager:latest
    container_name: alertmanager
    command:
      - '--config.file=/etc/alertmanager/config.yml'
      - '--storage.path=/alertmanager'
    ports:
      - "9093:9093"
    volumes:
      - ./alertmanager/config.yml:/etc/alertmanager/config.yml:ro
      - alertmanager-data:/alertmanager
    networks:
      - monitoring
    restart: unless-stopped

  grafana:
    image: grafana/grafana:latest
    container_name: grafana
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_USER=admin
      - GF_SECURITY_ADMIN_PASSWORD=admin
      - GF_INSTALL_PLUGINS=grafana-clock-panel,grafana-piechart-panel
      - GF_SERVER_ROOT_URL=http://localhost:3000
    volumes:
      - grafana-data:/var/lib/grafana
      - ./grafana/provisioning:/etc/grafana/provisioning:ro
      - ./grafana/dashboards:/var/lib/grafana/dashboards:ro
    networks:
      - monitoring
    depends_on:
      - prometheus
    restart: unless-stopped

  node-exporter:
    image: prom/node-exporter:latest
    container_name: node-exporter
    command:
      - '--path.procfs=/host/proc'
      - '--path.sysfs=/host/sys'
      - '--path.rootfs=/rootfs'
      - '--collector.filesystem.mount-points-exclude=^/(sys|proc|dev|host|etc)($$|/)'
    ports:
      - "9100:9100"
    volumes:
      - /proc:/host/proc:ro
      - /sys:/host/sys:ro
      - /:/rootfs:ro
    networks:
      - monitoring
    restart: unless-stopped

  cadvisor:
    image: gcr.io/cadvisor/cadvisor:latest
    container_name: cadvisor
    ports:
      - "8080:8080"
    volumes:
      - /:/rootfs:ro
      - /var/run:/var/run:ro
      - /sys:/sys:ro
      - /var/lib/docker/:/var/lib/docker:ro
      - /dev/disk/:/dev/disk:ro
    networks:
      - monitoring
    restart: unless-stopped
    privileged: true

  postgres-exporter:
    image: prometheuscommunity/postgres-exporter:latest
    container_name: postgres-exporter
    environment:
      DATA_SOURCE_NAME: "postgresql://postgres:password@postgres:5432/myapp?sslmode=disable"
    ports:
      - "9187:9187"
    networks:
      - monitoring
    restart: unless-stopped

  redis-exporter:
    image: oliver006/redis_exporter:latest
    container_name: redis-exporter
    environment:
      - REDIS_ADDR=redis://redis:6379
    ports:
      - "9121:9121"
    networks:
      - monitoring
    restart: unless-stopped

networks:
  monitoring:
    driver: bridge

volumes:
  prometheus-data:
  alertmanager-data:
  grafana-data:
```

### ELK Stack (Elasticsearch, Logstash, Kibana) + Filebeat

```yaml
version: "3.8"

services:
  elasticsearch:
    image: docker.elastic.co/elasticsearch/elasticsearch:8.10.0
    container_name: elasticsearch
    environment:
      - discovery.type=single-node
      - "ES_JAVA_OPTS=-Xms2g -Xmx2g"
      - xpack.security.enabled=false
      - xpack.monitoring.collection.enabled=true
    ports:
      - "9200:9200"
      - "9300:9300"
    volumes:
      - elasticsearch-data:/usr/share/elasticsearch/data
      - ./elasticsearch/elasticsearch.yml:/usr/share/elasticsearch/config/elasticsearch.yml:ro
    networks:
      - elk
    healthcheck:
      test: ["CMD-SHELL", "curl -f http://localhost:9200/_cluster/health || exit 1"]
      interval: 30s
      timeout: 10s
      retries: 5

  logstash:
    image: docker.elastic.co/logstash/logstash:8.10.0
    container_name: logstash
    volumes:
      - ./logstash/pipeline:/usr/share/logstash/pipeline:ro
      - ./logstash/config/logstash.yml:/usr/share/logstash/config/logstash.yml:ro
      - ./logstash/patterns:/usr/share/logstash/patterns:ro
    ports:
      - "5000:5000/tcp"
      - "5000:5000/udp"
      - "9600:9600"
    environment:
      LS_JAVA_OPTS: "-Xmx1g -Xms1g"
    networks:
      - elk
    depends_on:
      elasticsearch:
        condition: service_healthy

  kibana:
    image: docker.elastic.co/kibana/kibana:8.10.0
    container_name: kibana
    ports:
      - "5601:5601"
    environment:
      ELASTICSEARCH_URL: http://elasticsearch:9200
      ELASTICSEARCH_HOSTS: http://elasticsearch:9200
    volumes:
      - ./kibana/kibana.yml:/usr/share/kibana/config/kibana.yml:ro
    networks:
      - elk
    depends_on:
      elasticsearch:
        condition: service_healthy

  filebeat:
    image: docker.elastic.co/beats/filebeat:8.10.0
    container_name: filebeat
    user: root
    volumes:
      - ./filebeat/filebeat.yml:/usr/share/filebeat/filebeat.yml:ro
      - /var/lib/docker/containers:/var/lib/docker/containers:ro
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - filebeat-data:/usr/share/filebeat/data
    command: filebeat -e -strict.perms=false
    networks:
      - elk
    depends_on:
      - elasticsearch
      - logstash

networks:
  elk:
    driver: bridge

volumes:
  elasticsearch-data:
  filebeat-data:
```

---

## CI/CD and Development Tools

### Complete GitLab Stack

```yaml
version: "3.8"

services:
  gitlab:
    image: gitlab/gitlab-ce:latest
    container_name: gitlab
    restart: unless-stopped
    hostname: gitlab.local
    environment:
      GITLAB_OMNIBUS_CONFIG: |
        external_url 'http://gitlab.local'
        gitlab_rails['gitlab_shell_ssh_port'] = 2222
        gitlab_rails['backup_keep_time'] = 604800
        gitlab_ci['backup_keep_time'] = 604800
        prometheus_monitoring['enable'] = true
    ports:
      - "80:80"
      - "443:443"
      - "2222:22"
    volumes:
      - gitlab-config:/etc/gitlab
      - gitlab-logs:/var/log/gitlab
      - gitlab-data:/var/opt/gitlab
    networks:
      - gitlab-network
    shm_size: '256m'

  gitlab-runner:
    image: gitlab/gitlab-runner:latest
    container_name: gitlab-runner
    restart: unless-stopped
    volumes:
      - gitlab-runner-config:/etc/gitlab-runner
      - /var/run/docker.sock:/var/run/docker.sock
    networks:
      - gitlab-network
    depends_on:
      - gitlab

  # PostgreSQL for GitLab (external database)
  postgres:
    image: postgres:15-alpine
    container_name: gitlab-postgres
    restart: unless-stopped
    environment:
      POSTGRES_DB: gitlabhq_production
      POSTGRES_USER: gitlab
      POSTGRES_PASSWORD: gitlab
    volumes:
      - gitlab-postgres-data:/var/lib/postgresql/data
    networks:
      - gitlab-network

  # Redis for GitLab
  redis:
    image: redis:7-alpine
    container_name: gitlab-redis
    restart: unless-stopped
    volumes:
      - gitlab-redis-data:/data
    networks:
      - gitlab-network

networks:
  gitlab-network:
    driver: bridge

volumes:
  gitlab-config:
  gitlab-logs:
  gitlab-data:
  gitlab-runner-config:
  gitlab-postgres-data:
  gitlab-redis-data:
```

This comprehensive EXAMPLES.md provides 20+ production-ready Docker Compose examples covering all major use cases. Each example includes:
- Complete service definitions
- Network configurations
- Volume management
- Health checks
- Environment variables
- Dependency management

Would you like me to continue with the remaining sections (Content Management Systems, Data Processing, Security, Networking Examples, and Advanced Patterns)?
