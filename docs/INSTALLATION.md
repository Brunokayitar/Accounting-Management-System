# Rwanda AMS Installation Guide

This guide provides detailed instructions for installing and configuring the Rwanda Accounting Management System in various environments.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Local Development Setup](#local-development-setup)
3. [Docker Installation](#docker-installation)
4. [Production Installation](#production-installation)
5. [Configuration](#configuration)
6. [Database Setup](#database-setup)
7. [Testing Installation](#testing-installation)
8. [Troubleshooting](#troubleshooting)

## Prerequisites

### System Requirements

#### Minimum Requirements
- **OS**: Ubuntu 20.04 LTS, CentOS 8, macOS 11+, or Windows 10 with WSL2
- **CPU**: 2 cores, 2.4 GHz
- **RAM**: 4 GB
- **Storage**: 20 GB available space
- **Network**: Stable internet connection for RRA API integration

#### Recommended Requirements
- **OS**: Ubuntu 22.04 LTS or Amazon Linux 2
- **CPU**: 4 cores, 3.0 GHz
- **RAM**: 8 GB
- **Storage**: 50 GB SSD storage
- **Network**: High-speed internet with redundancy

### Software Dependencies

#### Required Software
- **Node.js**: Version 18.0 or later
- **npm**: Version 8.0 or later (comes with Node.js)
- **PostgreSQL**: Version 15.0 or later
- **Redis**: Version 7.0 or later

#### Optional Software
- **Docker**: Version 24.0 or later (for containerized deployment)
- **Kubernetes**: Version 1.28 or later (for production clusters)
- **Git**: For version control and deployment

### Network Requirements
- **Inbound**: Port 8080 (application), 5432 (PostgreSQL), 6379 (Redis)
- **Outbound**: HTTPS (443) for RRA API, SMTP (587) for email
- **Internal**: Database and cache connections

## Local Development Setup

### Step 1: Install Node.js

#### Ubuntu/Debian
```bash
# Install Node.js 18 LTS
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Verify installation
node --version
npm --version
```

#### macOS (using Homebrew)
```bash
# Install Homebrew if not already installed
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install Node.js
brew install node@18

# Verify installation
node --version
npm --version
```

#### Windows (using Node.js installer)
1. Download Node.js 18 LTS from [nodejs.org](https://nodejs.org/)
2. Run the installer with default settings
3. Open Command Prompt and verify: `node --version`

### Step 2: Install PostgreSQL

#### Ubuntu/Debian
```bash
# Install PostgreSQL 15
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
sudo apt-get update
sudo apt-get install postgresql-15 postgresql-client-15

# Start PostgreSQL service
sudo systemctl start postgresql
sudo systemctl enable postgresql

# Create database user
sudo -u postgres createuser --superuser rwanda_ams
sudo -u postgres psql -c "ALTER USER rwanda_ams PASSWORD 'secure_password';"
sudo -u postgres createdb rwanda_ams_dev -O rwanda_ams
```

#### macOS (using Homebrew)
```bash
# Install PostgreSQL
brew install postgresql@15

# Start PostgreSQL service
brew services start postgresql@15

# Create database and user
createuser --superuser rwanda_ams
psql -c "ALTER USER rwanda_ams PASSWORD 'secure_password';"
createdb rwanda_ams_dev -O rwanda_ams
```

#### Windows (using PostgreSQL installer)
1. Download PostgreSQL 15 from [postgresql.org](https://www.postgresql.org/download/windows/)
2. Run installer, set password for 'postgres' user
3. Use pgAdmin or psql to create:
   - User: `rwanda_ams` with password `secure_password`
   - Database: `rwanda_ams_dev` owned by `rwanda_ams`

### Step 3: Install Redis

#### Ubuntu/Debian
```bash
# Install Redis
sudo apt update
sudo apt install redis-server

# Configure Redis
sudo systemctl start redis-server
sudo systemctl enable redis-server

# Test Redis
redis-cli ping
```

#### macOS (using Homebrew)
```bash
# Install Redis
brew install redis

# Start Redis service
brew services start redis

# Test Redis
redis-cli ping
```

#### Windows (using WSL2 or Docker)
```bash
# Using WSL2 Ubuntu
sudo apt update
sudo apt install redis-server
sudo service redis-server start

# Or using Docker
docker run -d --name redis -p 6379:6379 redis:7-alpine
```

### Step 4: Clone and Setup Application

```bash
# Clone the repository
git clone https://github.com/rwanda-ams/ams.git
cd ams

# Install dependencies
npm install

# Copy environment configuration
cp .env.example .env

# Edit configuration file
nano .env  # or use your preferred editor
```

### Step 5: Configure Environment Variables

Edit the `.env` file with your settings:

```env
# Database Configuration
DATABASE_URL=postgresql://rwanda_ams:secure_password@localhost:5432/rwanda_ams_dev
DB_HOST=localhost
DB_PORT=5432
DB_NAME=rwanda_ams_dev
DB_USERNAME=rwanda_ams
DB_PASSWORD=secure_password

# Redis Configuration
REDIS_URL=redis://localhost:6379
REDIS_HOST=localhost
REDIS_PORT=6379

# Application Configuration
NODE_ENV=development
PORT=8080
APP_URL=http://localhost:8080
LOG_LEVEL=debug

# Authentication
JWT_SECRET=your_jwt_secret_key_change_this_in_production
SESSION_SECRET=your_session_secret_change_this_in_production

# Rwanda Revenue Authority (RRA) Configuration
RRA_API_URL=https://etax.rra.gov.rw/api
RRA_ENVIRONMENT=sandbox
RRA_API_KEY=your_rra_api_key_here
RRA_CLIENT_ID=your_rra_client_id
RRA_CLIENT_SECRET=your_rra_client_secret

# Email Configuration (for notifications)
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_SECURE=false
SMTP_USER=your-email@gmail.com
SMTP_PASS=your-app-password

# File Storage (local development)
STORAGE_TYPE=local
UPLOAD_PATH=./uploads

# Security
ENCRYPTION_KEY=32_character_encryption_key_here_change_this
BCRYPT_ROUNDS=12

# Feature Flags
ENABLE_AUDIT_LOGGING=true
ENABLE_RRA_INTEGRATION=false  # Set to false for development
ENABLE_EMAIL_NOTIFICATIONS=false  # Set to false for development
```

### Step 6: Initialize Database

```bash
# Run database migrations
npm run db:migrate

# Seed initial data (includes Rwanda tax codes)
npm run db:seed

# Verify database setup
npm run db:verify
```

### Step 7: Start Development Server

```bash
# Start the application
npm run dev

# In separate terminal, verify health
curl http://localhost:8080/api/health
```

The application should now be running at `http://localhost:8080`.

## Docker Installation

### Prerequisites
- Docker 24.0 or later
- Docker Compose 2.0 or later

### Quick Start with Docker

```bash
# Clone repository
git clone https://github.com/rwanda-ams/ams.git
cd ams

# Copy environment file
cp .env.example .env.docker

# Edit Docker environment
nano .env.docker

# Start all services
docker-compose up -d

# View logs
docker-compose logs -f app

# Verify installation
curl http://localhost:8080/api/health
```

### Docker Environment Configuration

Create `.env.docker` file:

```env
# Database (using Docker PostgreSQL)
POSTGRES_DB=rwanda_ams
POSTGRES_USER=rwanda_ams
POSTGRES_PASSWORD=secure_docker_password
DATABASE_URL=postgresql://rwanda_ams:secure_docker_password@postgres:5432/rwanda_ams

# Redis (using Docker Redis)
REDIS_URL=redis://redis:6379

# Application
NODE_ENV=production
APP_PORT=8080
JWT_SECRET=docker_jwt_secret_change_this
SESSION_SECRET=docker_session_secret_change_this

# RRA Configuration
RRA_API_URL=https://etax.rra.gov.rw/api
RRA_ENVIRONMENT=sandbox
```

### Docker Services Management

```bash
# Start services
docker-compose up -d

# Stop services
docker-compose down

# View service status
docker-compose ps

# Restart specific service
docker-compose restart app

# View application logs
docker-compose logs -f app

# Access application container
docker-compose exec app sh

# Backup database
docker-compose exec postgres pg_dump -U rwanda_ams rwanda_ams > backup.sql

# Restore database
docker-compose exec -T postgres psql -U rwanda_ams rwanda_ams < backup.sql
```

## Production Installation

### Prerequisites for Production

#### Server Requirements
- **OS**: Ubuntu 22.04 LTS (recommended)
- **CPU**: 4+ cores, 3.0+ GHz
- **RAM**: 16+ GB
- **Storage**: 100+ GB SSD
- **Network**: High-speed internet with SSL certificate

#### Security Requirements
- Firewall configured (UFW recommended)
- SSL/TLS certificates
- Regular security updates
- Backup strategy in place

### Production Setup Steps

#### Step 1: Prepare Server

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install required packages
sudo apt install -y curl wget gnupg2 software-properties-common

# Install Node.js 18
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs

# Install PostgreSQL 15
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
sudo apt update
sudo apt install -y postgresql-15 postgresql-client-15

# Install Redis
sudo apt install -y redis-server

# Install process manager
sudo npm install -g pm2
```

#### Step 2: Configure Database

```bash
# Configure PostgreSQL
sudo -u postgres psql << EOF
CREATE USER rwanda_ams WITH PASSWORD 'production_secure_password';
CREATE DATABASE rwanda_ams OWNER rwanda_ams;
GRANT ALL PRIVILEGES ON DATABASE rwanda_ams TO rwanda_ams;
\q
EOF

# Configure PostgreSQL settings
sudo nano /etc/postgresql/15/main/postgresql.conf
```

Add/modify these settings in `postgresql.conf`:

```conf
# Performance settings
shared_buffers = 256MB
effective_cache_size = 1GB
work_mem = 4MB
maintenance_work_mem = 64MB
max_connections = 200

# Security settings
ssl = on
ssl_cert_file = '/etc/ssl/certs/ssl-cert-snakeoil.pem'
ssl_key_file = '/etc/ssl/private/ssl-cert-snakeoil.key'

# Logging
log_statement = 'all'
log_min_duration_statement = 100
```

#### Step 3: Configure Redis

```bash
# Edit Redis configuration
sudo nano /etc/redis/redis.conf
```

Key settings for production:

```conf
# Security
bind 127.0.0.1
requirepass production_redis_password

# Memory management
maxmemory 512mb
maxmemory-policy allkeys-lru

# Persistence
save 900 1
save 300 10
save 60 10000
```

#### Step 4: Setup Application

```bash
# Create application user
sudo useradd -m -s /bin/bash rwanda-ams
sudo su - rwanda-ams

# Clone application
git clone https://github.com/rwanda-ams/ams.git
cd ams

# Install dependencies
npm ci --only=production

# Build application
npm run build

# Create production environment file
cp .env.example .env.production
```

#### Step 5: Configure Production Environment

Edit `.env.production`:

```env
# Production Database
DATABASE_URL=postgresql://rwanda_ams:production_secure_password@localhost:5432/rwanda_ams
DB_HOST=localhost
DB_PORT=5432
DB_NAME=rwanda_ams
DB_USERNAME=rwanda_ams
DB_PASSWORD=production_secure_password

# Production Redis
REDIS_URL=redis://:production_redis_password@localhost:6379
REDIS_PASSWORD=production_redis_password

# Application
NODE_ENV=production
PORT=8080
APP_URL=https://ams.yourcompany.rw
LOG_LEVEL=info

# Security - Generate strong secrets
JWT_SECRET=generate_32_character_secret_here
SESSION_SECRET=generate_32_character_session_secret
ENCRYPTION_KEY=generate_32_character_encryption_key

# RRA Production Configuration
RRA_API_URL=https://etax.rra.gov.rw/api
RRA_ENVIRONMENT=production
RRA_API_KEY=your_production_rra_api_key
RRA_CLIENT_ID=your_production_client_id
RRA_CLIENT_SECRET=your_production_client_secret

# Email Configuration
SMTP_HOST=smtp.yourprovider.com
SMTP_PORT=587
SMTP_USER=noreply@yourcompany.rw
SMTP_PASS=your_email_password

# File Storage - AWS S3 recommended for production
STORAGE_TYPE=s3
AWS_REGION=us-east-1
AWS_ACCESS_KEY_ID=your_aws_access_key
AWS_SECRET_ACCESS_KEY=your_aws_secret_key
S3_BUCKET=rwanda-ams-prod-documents

# Feature Flags - Enable for production
ENABLE_AUDIT_LOGGING=true
ENABLE_RRA_INTEGRATION=true
ENABLE_EMAIL_NOTIFICATIONS=true
ENABLE_BACKUP_ENCRYPTION=true
```

#### Step 6: Initialize Production Database

```bash
# Run migrations
npm run db:migrate

# Seed production data
npm run db:seed:production

# Create admin user
npm run create-admin -- --email admin@yourcompany.rw --password AdminPassword123!
```

#### Step 7: Configure Process Manager

```bash
# Create PM2 ecosystem file
cat > ecosystem.config.js << EOF
module.exports = {
  apps: [
    {
      name: 'rwanda-ams',
      script: 'dist/server/node-build.mjs',
      instances: 'max',
      exec_mode: 'cluster',
      env: {
        NODE_ENV: 'production',
        PORT: 8080
      },
      env_file: '.env.production',
      error_file: 'logs/error.log',
      out_file: 'logs/out.log',
      log_file: 'logs/combined.log',
      time: true,
      max_memory_restart: '1G',
      restart_delay: 4000,
      max_restarts: 10,
      min_uptime: '10s'
    }
  ]
};
EOF

# Start application with PM2
pm2 start ecosystem.config.js
pm2 save
pm2 startup

# Setup log rotation
pm2 install pm2-logrotate
pm2 set pm2-logrotate:max_size 10M
pm2 set pm2-logrotate:retain 30
```

#### Step 8: Configure Reverse Proxy (Nginx)

```bash
# Install Nginx
sudo apt install -y nginx

# Create site configuration
sudo nano /etc/nginx/sites-available/rwanda-ams
```

Nginx configuration:

```nginx
server {
    listen 80;
    server_name ams.yourcompany.rw;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name ams.yourcompany.rw;

    ssl_certificate /etc/ssl/certs/ams.yourcompany.rw.pem;
    ssl_certificate_key /etc/ssl/private/ams.yourcompany.rw.key;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers off;

    location / {
        proxy_pass http://127.0.0.1:8080;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
        proxy_read_timeout 86400;
    }

    # Security headers
    add_header X-Frame-Options DENY;
    add_header X-Content-Type-Options nosniff;
    add_header X-XSS-Protection "1; mode=block";
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains";
}
```

Enable site:

```bash
sudo ln -s /etc/nginx/sites-available/rwanda-ams /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

#### Step 9: Configure Firewall

```bash
# Install and configure UFW
sudo ufw enable
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Allow necessary ports
sudo ufw allow 22    # SSH
sudo ufw allow 80    # HTTP
sudo ufw allow 443   # HTTPS

# Deny direct access to application port
sudo ufw deny 8080

# Check status
sudo ufw status verbose
```

## Configuration

### Environment Variables Reference

| Variable | Description | Example | Required |
|----------|-------------|---------|----------|
| `DATABASE_URL` | PostgreSQL connection string | `postgresql://user:pass@host:5432/db` | Yes |
| `REDIS_URL` | Redis connection string | `redis://localhost:6379` | Yes |
| `JWT_SECRET` | JWT signing secret (32+ chars) | `random_32_character_string` | Yes |
| `RRA_API_URL` | RRA eTax API endpoint | `https://etax.rra.gov.rw/api` | Yes |
| `RRA_API_KEY` | RRA API authentication key | `api_key_from_rra` | Yes |
| `SMTP_HOST` | Email server hostname | `smtp.gmail.com` | No |
| `AWS_ACCESS_KEY_ID` | AWS access key for S3 storage | `AKIAIOSFODNN7EXAMPLE` | No |

### Rwanda Tax Configuration

The system includes pre-configured Rwanda tax codes based on current RRA regulations:

```sql
-- VAT Codes
VAT_18: 18% standard rate (most goods/services)
VAT_0: 0% zero-rated (exports, international transport)
VAT_EXEMPT: Exempt (financial services, education, healthcare)

-- Withholding Tax Codes
WHT_15: 15% standard rate (resident payments)
WHT_5: 5% reduced rate (domestic dividends/interest)
WHT_30: 30% non-resident rate (no treaty benefits)

-- PAYE Codes
PAYE_0: 0% band (up to RWF 60,000/month)
PAYE_20: 20% band (RWF 60,001-100,000/month)
PAYE_30: 30% band (above RWF 100,000/month)
CASUAL_15: 15% flat rate (casual labor)
```

## Database Setup

### Manual Database Creation

If automated setup fails, create database manually:

```sql
-- Connect as postgres superuser
sudo -u postgres psql

-- Create user and database
CREATE USER rwanda_ams WITH PASSWORD 'your_password';
CREATE DATABASE rwanda_ams OWNER rwanda_ams;
GRANT ALL PRIVILEGES ON DATABASE rwanda_ams TO rwanda_ams;

-- Connect to new database
\c rwanda_ams

-- Create extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "btree_gist";

-- Exit
\q
```

### Run Migrations Manually

```bash
# Navigate to project directory
cd /path/to/rwanda-ams

# Run schema creation
psql -h localhost -U rwanda_ams -d rwanda_ams -f schema/001_init.sql

# Run seed data
psql -h localhost -U rwanda_ams -d rwanda_ams -f schema/002_seed_data.sql

# Verify installation
psql -h localhost -U rwanda_ams -d rwanda_ams -c "SELECT COUNT(*) FROM tenants;"
```

## Testing Installation

### Health Check

```bash
# Test application health
curl http://localhost:8080/api/health

# Expected response:
{
  "status": "healthy",
  "timestamp": "2024-01-15T10:30:00.000Z",
  "uptime": 1234567,
  "database": "connected",
  "redis": "connected"
}
```

### Database Connectivity

```bash
# Test database connection
npm run db:test

# Test tax calculations
npm run test:tax-engine

# Verify RRA integration (if enabled)
npm run test:rra-integration
```

### API Testing

```bash
# Install API testing tools
npm install -g newman

# Run API tests
newman run tests/api/rwanda-ams.postman_collection.json

# Test VAT calculation
curl -X POST http://localhost:8080/api/v1/entities/test/vat/calculate \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer your_jwt_token" \
  -d '{"amount": 1000000, "taxCode": "VAT_18", "priceInclusive": false}'
```

### Performance Testing

```bash
# Install performance testing tools
npm install -g artillery

# Run performance tests
artillery run tests/performance/load-test.yml

# Monitor system resources
htop  # or top on systems without htop
```

## Troubleshooting

### Common Issues

#### Database Connection Failed

**Symptom**: `ECONNREFUSED` or `authentication failed` errors

**Solution**:
```bash
# Check PostgreSQL status
sudo systemctl status postgresql

# Restart PostgreSQL
sudo systemctl restart postgresql

# Check pg_hba.conf authentication
sudo nano /etc/postgresql/15/main/pg_hba.conf

# Ensure this line exists:
local   all             all                                     md5

# Restart PostgreSQL after changes
sudo systemctl restart postgresql
```

#### Redis Connection Failed

**Symptom**: `ECONNREFUSED` connecting to Redis

**Solution**:
```bash
# Check Redis status
sudo systemctl status redis-server

# Test Redis connection
redis-cli ping

# Check Redis configuration
sudo nano /etc/redis/redis.conf

# Ensure Redis is bound to correct interface
bind 127.0.0.1 ::1

# Restart Redis
sudo systemctl restart redis-server
```

#### Application Won't Start

**Symptom**: Application exits immediately or shows startup errors

**Solution**:
```bash
# Check application logs
npm run logs

# Or with PM2
pm2 logs rwanda-ams

# Check environment variables
env | grep -E "(DATABASE|REDIS|JWT)"

# Verify Node.js version
node --version  # Should be 18+

# Verify dependencies
npm list --depth=0
```

#### Tax Calculations Incorrect

**Symptom**: VAT/WHT calculations don't match expected values

**Solution**:
```bash
# Verify tax codes
npm run db:verify-tax-codes

# Check tax code effective dates
psql -h localhost -U rwanda_ams -d rwanda_ams -c "
  SELECT code, name, rate, effective_from, effective_to 
  FROM tax_codes 
  WHERE is_active = true 
  ORDER BY code;
"

# Run tax engine tests
npm run test:tax-engine

# Check audit logs for calculation details
npm run logs:tax-calculations
```

#### RRA Integration Errors

**Symptom**: RRA API calls fail or return errors

**Solution**:
```bash
# Check RRA API configuration
echo $RRA_API_URL
echo $RRA_ENVIRONMENT

# Test RRA API connectivity
curl -H "Authorization: Bearer $RRA_API_KEY" \
     "$RRA_API_URL/ping"

# Check RRA credentials
npm run test:rra-connection

# Review RRA integration logs
npm run logs:rra-integration
```

### Performance Issues

#### Slow Database Queries

**Solution**:
```bash
# Enable query logging
sudo nano /etc/postgresql/15/main/postgresql.conf

# Add these lines:
log_statement = 'all'
log_min_duration_statement = 100

# Restart PostgreSQL
sudo systemctl restart postgresql

# Check slow queries
sudo tail -f /var/log/postgresql/postgresql-15-main.log

# Analyze query performance
psql -h localhost -U rwanda_ams -d rwanda_ams -c "
  SELECT query, calls, total_time, mean_time 
  FROM pg_stat_statements 
  ORDER BY total_time DESC 
  LIMIT 10;
"
```

#### High Memory Usage

**Solution**:
```bash
# Check process memory usage
ps aux | grep node

# Monitor with PM2
pm2 monit

# Restart application if memory leak suspected
pm2 restart rwanda-ams

# Check for memory leaks in logs
pm2 logs rwanda-ams | grep -i "memory\|heap"
```

### Getting Help

#### Log Collection

Before reporting issues, collect relevant logs:

```bash
# Application logs
pm2 logs rwanda-ams --lines 1000 > app-logs.txt

# System logs
sudo journalctl -u postgresql -n 1000 > postgres-logs.txt
sudo journalctl -u redis-server -n 1000 > redis-logs.txt
sudo journalctl -u nginx -n 1000 > nginx-logs.txt

# System information
uname -a > system-info.txt
free -h >> system-info.txt
df -h >> system-info.txt
```

#### Support Channels

- **GitHub Issues**: [Report bugs or request features](https://github.com/rwanda-ams/ams/issues)
- **Email Support**: support@rwanda-ams.com
- **Documentation**: [Online documentation](https://docs.rwanda-ams.com)
- **Community Forum**: [Developer community](https://community.rwanda-ams.com)

Include the following information when requesting support:
- Operating system and version
- Node.js and npm versions
- Error messages and stack traces
- Steps to reproduce the issue
- Application logs (sanitized)

---

This installation guide covers development, Docker, and production setups. For Kubernetes deployment, see [DEPLOYMENT.md](DEPLOYMENT.md).
