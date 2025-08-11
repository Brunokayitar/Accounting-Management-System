# Rwanda Accounting Management System (AMS)

[![CI/CD Pipeline](https://github.com/rwanda-ams/ams/actions/workflows/ci-cd.yml/badge.svg)](https://github.com/rwanda-ams/ams/actions/workflows/ci-cd.yml)
[![codecov](https://codecov.io/gh/rwanda-ams/ams/branch/main/graph/badge.svg)](https://codecov.io/gh/rwanda-ams/ams)
[![License](https://img.shields.io/badge/license-Proprietary-red.svg)](LICENSE)

A comprehensive, production-ready Accounting Management System specifically designed for multi-entity businesses operating in Rwanda. Built with Rwanda Revenue Authority (RRA) compliance at its core.

## 🇷🇼 Rwanda Tax Compliance Features

- **VAT Management**: 18% standard rate, 0% zero-rated, and exempt categories
- **Automatic Filing Frequency**: Monthly vs quarterly based on RWF 200M turnover threshold
- **Withholding Tax (WHT)**: 15% standard, 5% reduced, 30% non-resident rates
- **PAYE Calculations**: Progressive bands (0%/20%/30%) and 15% casual labor
- **Corporate Income Tax**: 28% standard rate with SME and export exceptions
- **RRA Integration**: Direct eTax export compatibility

## 🏗️ Architecture

### Technology Stack

- **Frontend**: React 18 + TypeScript + Tailwind CSS + Vite
- **Backend**: Node.js + Express + TypeScript
- **Database**: PostgreSQL 15 with audit trails
- **Cache**: Redis for session management
- **Infrastructure**: Docker + Kubernetes + AWS/Azure
- **Monitoring**: Prometheus + Grafana + ELK Stack

### Key Components

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   React SPA     │    │  Express API    │    │  PostgreSQL     │
│                 │    │                 │    │                 │
│ • Dashboard     │◄──►│ • Tax Engine    │◄──►│ • Multi-tenant  │
│ • Invoice Mgmt  │    │ • GL/AP/AR      │    │ • Audit Trail   │
│ • Tax Reports   │    │ • RRA Export    │    │ • Tax History   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 🚀 Quick Start

### Prerequisites

- Node.js 18+
- PostgreSQL 15+
- Redis 7+
- Docker & Docker Compose (optional)

### Local Development

1. **Clone the repository**

```bash
git clone https://github.com/rwanda-ams/ams.git
cd ams
```

2. **Install dependencies**

```bash
npm install
```

3. **Setup environment variables**

```bash
cp .env.example .env
# Edit .env with your database and API keys
```

4. **Initialize database**

```bash
# Start PostgreSQL and Redis
docker-compose up -d postgres redis

# Run migrations and seed data
npm run db:migrate
npm run db:seed
```

5. **Start development server**

```bash
npm run dev
```

Visit http://localhost:8080 to access the application.

### Docker Development

```bash
# Start all services
docker-compose up -d

# View logs
docker-compose logs -f app

# Access the app
open http://localhost:8080
```

## 📊 Key Features

### Multi-Entity Accounting

- Consolidated financial reporting across subsidiaries
- Entity-specific chart of accounts
- Inter-company transaction elimination
- Multi-currency support with RWF base

### Rwanda Tax Engine

- **VAT Calculations**: Automatic rate application based on product/service codes
- **Filing Frequency**: Auto-switch between monthly/quarterly based on turnover
- **WHT Matrix**: Comprehensive payment type and recipient classification
- **PAYE Bands**: Current RRA progressive tax tables (configurable)
- **Tax Rules**: Version-controlled rules engine for regulatory changes

### Compliance & Reporting

- Pre-filled VAT returns (monthly/quarterly)
- WHT certificates and registers
- PAYE monthly summaries
- Balance Sheet and P&L with tax details
- Audit trails for all transactions
- RRA eTax CSV/Excel export formats

### Security & Access Control

- Role-based access control (Admin, CFO, Accountant, TaxAgent, Auditor)
- Multi-factor authentication (2FA)
- API rate limiting and monitoring
- Encryption at rest and in transit
- GDPR-compliant data handling

## 🏛️ Rwanda Tax Regulations (Sources & Implementation)

### VAT Implementation

**Source**: RRA VAT Law, Article 15

- **Standard Rate**: 18% on most goods and services
- **Zero Rate**: 0% on exports, international transport, approved raw materials
- **Exempt**: Financial services, insurance, education, healthcare
- **Filing**: Monthly (turnover > RWF 200M), Quarterly (≤ RWF 200M)

### Withholding Tax Matrix

**Source**: RRA Withholding Tax Guidelines

- **15% Standard**: Most payments to residents
- **5% Reduced**: Domestic dividends and interest
- **30% Non-Resident**: Payments without tax treaty benefits
- **Exempt**: Government entities, approved organizations

### PAYE Tax Bands (2024)

**Source**: RRA PAYE Guidelines

- **0%**: Monthly income up to RWF 60,000
- **20%**: RWF 60,001 to RWF 100,000
- **30%**: Above RWF 100,000
- **15% Flat**: Casual labor payments

### Corporate Income Tax

**Source**: RRA CIT Law, PwC Rwanda Tax Guide

- **28% Standard**: Effective from 2024
- **Alternative Regimes**: SME flat rates, presumptive taxation
- **Incentives**: 0%/15% for qualifying exporters and international services

## 🔧 Configuration

### Environment Variables

```bash
# Database
DATABASE_URL=postgresql://user:pass@localhost:5432/rwanda_ams
REDIS_URL=redis://localhost:6379

# Authentication
JWT_SECRET=your_jwt_secret_here
SESSION_SECRET=your_session_secret_here

# RRA Integration
RRA_API_URL=https://etax.rra.gov.rw/api
RRA_API_KEY=your_rra_api_key
RRA_ENVIRONMENT=production

# Email
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=noreply@yourcompany.rw
SMTP_PASS=your_email_password

# Storage
AWS_REGION=us-east-1
S3_BUCKET=rwanda-ams-documents
AWS_ACCESS_KEY_ID=your_aws_key
AWS_SECRET_ACCESS_KEY=your_aws_secret

# Monitoring
LOG_LEVEL=info
METRICS_ENABLED=true
```

### Tax Configuration

The system includes configurable tax codes and rules:

```sql
-- Update VAT rate (requires admin approval)
UPDATE tax_codes
SET rate = 18.0, effective_from = '2024-01-01'
WHERE code = 'VAT_18';

-- Add new tax code for Digital Services Tax
INSERT INTO tax_codes (code, name, tax_type, rate, effective_from)
VALUES ('DST_1_5', 'Digital Services Tax 1.5%', 'DST', 1.5, '2024-07-01');
```

## 📚 API Documentation

### Authentication

All API endpoints require Bearer token authentication:

```bash
curl -H "Authorization: Bearer YOUR_JWT_TOKEN" \
     https://api.rwanda-ams.com/v1/entities/123/vat/calculate
```

### Key Endpoints

#### VAT Calculation

```bash
POST /api/v1/entities/{entityId}/vat/calculate
{
  "amount": 1000000,
  "taxCode": "VAT_18",
  "priceInclusive": false
}
```

#### Generate VAT Return

```bash
POST /api/v1/entities/{entityId}/vat/returns
{
  "periodStart": "2024-01-01",
  "periodEnd": "2024-01-31"
}
```

#### WHT Calculation

```bash
POST /api/v1/entities/{entityId}/wht/calculate
{
  "grossAmount": 10000000,
  "paymentType": "professional_services",
  "recipientType": "resident_company"
}
```

**Complete API documentation**: See [api/openapi.yaml](api/openapi.yaml)

## 🚀 Deployment

### Production Deployment on Kubernetes

1. **Configure secrets**

```bash
kubectl create secret generic rwanda-ams-secrets \
  --from-literal=DATABASE_URL="postgresql://..." \
  --from-literal=JWT_SECRET="..." \
  --namespace=rwanda-ams
```

2. **Deploy application**

```bash
kubectl apply -f k8s/
```

3. **Verify deployment**

```bash
kubectl get pods -n rwanda-ams
kubectl logs deployment/rwanda-ams-app -n rwanda-ams
```

### AWS EKS Deployment

```bash
# Create EKS cluster
eksctl create cluster --name rwanda-ams-prod --region us-east-1

# Configure kubectl
aws eks update-kubeconfig --region us-east-1 --name rwanda-ams-prod

# Deploy
kubectl apply -f k8s/
```

### Docker Compose (Development)

```bash
# Production-like environment
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d
```

## 🧪 Testing

### Run Test Suite

```bash
# Unit tests
npm test

# Integration tests
npm run test:integration

# End-to-end tests
npm run test:e2e

# Tax calculation tests
npm run test:tax-engine

# RRA compliance tests
npm run test:compliance
```

### Test Coverage

```bash
npm run test:coverage
open coverage/lcov-report/index.html
```

## 📊 Monitoring & Observability

### Application Metrics

- Request/response times
- Database query performance
- Tax calculation accuracy
- User activity patterns
- Error rates and types

### Business Metrics

- Invoice processing volume
- VAT filing compliance rates
- Payment processing success
- User adoption by entity
- System uptime and reliability

### Grafana Dashboards

- **Financial Overview**: Revenue, expenses, tax obligations
- **Compliance Dashboard**: Filing deadlines, submission status
- **Performance Metrics**: API response times, database performance
- **User Activity**: Login patterns, feature usage

## 🛡️ Security

### Data Protection

- AES-256 encryption for sensitive data
- TLS 1.3 for data in transit
- Regular security audits and penetration testing
- GDPR/privacy compliance measures

### Access Controls

- JWT-based authentication with refresh tokens
- Role-based permissions (RBAC)
- Multi-factor authentication (2FA)
- IP whitelisting for admin functions
- API rate limiting and DDoS protection

### Audit & Compliance

- Immutable audit trail for all transactions
- User action logging with timestamps
- Regular automated backups
- Disaster recovery procedures
- SOC 2 Type II compliance framework

## 🔄 Migration & Upgrades

### Database Migrations

```bash
# Run pending migrations
npm run db:migrate

# Rollback last migration
npm run db:rollback

# Reset database (development only)
npm run db:reset
```

### Tax Rule Updates

When Rwanda tax regulations change:

1. **Update tax codes**: Modify rates and effective dates
2. **Run migration**: Apply changes with historical preservation
3. **Validate calculations**: Test against known scenarios
4. **Deploy**: Use blue-green deployment for zero downtime

```bash
npm run tax:migrate --version=2024.2 --effective-date=2024-07-01
```

## 📞 Support & Maintenance

### Support Channels

- **Technical Issues**: [GitHub Issues](https://github.com/rwanda-ams/ams/issues)
- **Business Queries**: support@rwanda-ams.com
- **Emergency Hotline**: +250-788-SUPPORT (24/7)

### Maintenance Schedule

- **Security Updates**: Applied immediately
- **Feature Updates**: Monthly release cycle
- **Tax Regulation Updates**: As needed (typically quarterly)
- **Database Maintenance**: Weekly during low-usage periods

### Backup & Recovery

- **Automated Backups**: Daily full backup, hourly incremental
- **Retention**: 90 days rolling retention, yearly archives
- **Recovery Time**: < 30 minutes for system restore
- **Recovery Point**: < 5 minutes data loss maximum

## 🤝 Contributing

### Development Process

1. Fork the repository
2. Create feature branch: `git checkout -b feature/vat-improvements`
3. Commit changes: `git commit -m 'Add enhanced VAT calculations'`
4. Push to branch: `git push origin feature/vat-improvements`
5. Submit pull request

### Code Standards

- TypeScript strict mode
- ESLint + Prettier configuration
- 90%+ test coverage requirement
- Security-first coding practices
- Documentation for all public APIs

### Tax Compliance Contributions

When contributing tax-related features:

- Cite official RRA sources
- Include test cases with expected outcomes
- Document any assumptions or interpretations
- Provide migration scripts for existing data

## 📄 License

This project is proprietary software. See [LICENSE](LICENSE) for details.

## 🙏 Acknowledgments

- **Rwanda Revenue Authority (RRA)** for tax regulation guidance
- **PwC Rwanda** for tax interpretation support
- **EY Rwanda** for compliance framework consultation
- **Ministry of ICT** for digital transformation support

---

**Built with ❤️ for Rwanda's digital economy transformation**

For detailed setup instructions, see [docs/INSTALLATION.md](docs/INSTALLATION.md)  
For API reference, see [api/openapi.yaml](api/openapi.yaml)  
For deployment guide, see [docs/DEPLOYMENT.md](docs/DEPLOYMENT.md)
