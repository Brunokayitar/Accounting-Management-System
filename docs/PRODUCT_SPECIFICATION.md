# Rwanda AMS - Product Specification

## User Personas

### 1. Primary Personas

#### Persona A: Chief Financial Officer (CFO) - Large Enterprise

**Name**: Sarah Uwimana  
**Company**: Kigali Technology Holdings Ltd (Annual Turnover: RWF 5.2B)  
**Background**: CPA with 12 years experience, manages 4 subsidiary companies  
**Pain Points**:

- Manual consolidation of multi-entity financials
- Complex VAT compliance across entities
- Difficulty tracking WHT obligations
- Time-consuming RRA filing preparation

**Goals**:

- Automated consolidated reporting
- Real-time compliance dashboard
- Accurate tax calculations
- Streamlined audit preparation

#### Persona B: Senior Accountant - Mid-size Business

**Name**: Jean Baptiste Nkurunziza  
**Company**: Rwanda Coffee Exports Ltd (Annual Turnover: RWF 800M)  
**Background**: ACCA qualified, 8 years experience, monthly VAT filer  
**Pain Points**:

- Manual VAT return preparation takes 2 days monthly
- WHT certificate generation is error-prone
- Bank reconciliation complexity
- PAYE calculations require external consultant

**Goals**:

- One-click VAT return generation
- Automated WHT processing
- Integrated bank feeds
- Self-service PAYE calculations

#### Persona C: Tax Agent/Consultant

**Name**: Marie Claire Mukamana  
**Company**: Kigali Tax Advisors (Serves 25+ clients)  
**Background**: Tax consultant specializing in RRA compliance  
**Pain Points**:

- Different systems for different clients
- Manual data consolidation
- Tracking regulatory changes across clients
- Time-intensive client onboarding

**Goals**:

- Multi-client dashboard
- Standardized compliance workflows
- Automated regulatory updates
- Efficient client management

### 2. Secondary Personas

#### Persona D: Auditor

**Name**: David Gasana  
**Company**: External Audit Firm  
**Needs**: Complete audit trails, detailed transaction logs, compliance verification

#### Persona E: Business Owner/CEO

**Name**: Grace Mutesi  
**Company**: Growing Manufacturing Business  
**Needs**: High-level financial insights, compliance assurance, cost control

## User Stories

### A. Core Accounting Module

#### A1. General Ledger Management

**As a** Senior Accountant  
**I want to** post journal entries with automatic tax implications  
**So that** I can maintain accurate books while ensuring tax compliance

**Acceptance Criteria**:

- System validates GL account codes
- Automatic VAT posting to appropriate liability accounts
- WHT calculations post to asset accounts as credits
- Audit trail captures user, timestamp, and reason codes
- Multi-currency entries convert to RWF at current rates

#### A2. Multi-Entity Consolidation

**As a** CFO managing multiple entities  
**I want to** view consolidated financial statements  
**So that** I can report to board and comply with group reporting requirements

**Acceptance Criteria**:

- Eliminate inter-company transactions automatically
- Apply consistent accounting policies across entities
- Generate consolidated Balance Sheet and P&L
- Support entity-specific chart of accounts
- Drill-down capability to source transactions

### B. Rwanda VAT Compliance

#### B1. Automated VAT Calculation

**As an** Accountant preparing invoices  
**I want to** automatically calculate correct VAT amounts  
**So that** I ensure compliance with 18% standard rate and exemptions

**Acceptance Criteria**:

- System applies 18% VAT to standard-rated supplies
- Zero-rate supplies show 0% VAT calculation
- Exempt supplies exclude VAT calculation entirely
- Line-level tax code selection available
- VAT-inclusive and VAT-exclusive pricing options

#### B2. VAT Return Generation

**As an** Accountant for a monthly VAT filer  
**I want to** auto-generate completed VAT return forms  
**So that** I can submit to RRA within 15-day deadline

**Acceptance Criteria**:

- System determines filing frequency based on annual turnover
- Pre-populates all VAT return fields from transaction data
- Calculates total VAT collectible and input VAT credits
- Generates CSV format compatible with RRA eTax system
- Validates data completeness before generation
- Creates audit report showing calculation methodology

#### B3. VAT Filing Period Management

**As a** Tax Agent serving various clients  
**I want the** system to automatically determine VAT filing frequency  
**So that** I ensure clients file monthly vs quarterly correctly

**Acceptance Criteria**:

- Tracks annual turnover automatically
- Switches to monthly filing when turnover exceeds RWF 200M
- Provides alerts before filing deadline changes
- Maintains historical filing frequency records
- Supports manual override with approval workflow

### C. Withholding Tax (WHT) Management

#### C1. WHT Matrix Application

**As an** Accounts Payable clerk  
**I want** automatic WHT calculation on vendor payments  
**So that** I comply with 15% standard WHT requirements

**Acceptance Criteria**:

- Applies correct WHT rates based on payment type
- Supports 15% standard rate and 5% reduced rate
- Excludes WHT for payments below minimum thresholds
- Posts WHT to appropriate asset accounts
- Generates WHT vouchers automatically

#### C2. WHT Certificate Generation

**As an** Accountant managing vendor relationships  
**I want to** generate WHT certificates for quarterly submission  
**So that** I provide vendors required documentation for CIT credits

**Acceptance Criteria**:

- Consolidates WHT by vendor for quarter/year
- Generates RRA-compliant certificate format
- Includes all required fields (TIN, amounts, periods)
- Supports batch generation for multiple vendors
- Maintains certificate register for audit

#### C3. WHT Register Maintenance

**As a** Tax Agent preparing client WHT returns  
**I want** comprehensive WHT register reporting  
**So that** I can submit accurate quarterly WHT returns to RRA

**Acceptance Criteria**:

- Lists all WHT transactions by type and rate
- Summarizes by vendor and time period
- Calculates total WHT collected for period
- Generates CSV export for RRA submission
- Supports filtering by entity and date ranges

### D. PAYE Payroll Integration

#### D1. PAYE Calculation Engine

**As a** Payroll Administrator  
**I want** automated PAYE calculations using current RRA bands  
**So that** I ensure accurate employee tax withholding

**Acceptance Criteria**:

- Applies current PAYE rate bands (0% up to RWF 60,000, progressive rates)
- Handles casual labor 15% flat rate option
- Calculates employer contributions (NSSF, medical insurance)
- Supports monthly and occasional payment frequencies
- Maintains employee tax history

#### D2. PAYE Monthly Returns

**As an** HR Manager  
**I want to** generate monthly PAYE returns  
**So that** I can submit employee tax information to RRA by deadline

**Acceptance Criteria**:

- Summarizes all employee PAYE for month
- Generates RRA-compliant return format
- Includes employee count and total tax withheld
- Calculates penalty interest for late payments
- Exports CSV format for eTax submission

### E. Corporate Income Tax (CIT) Support

#### E1. CIT Regime Selection

**As a** CFO planning tax strategy  
**I want to** configure appropriate CIT regime per entity  
**So that** I optimize tax efficiency while maintaining compliance

**Acceptance Criteria**:

- Supports 28% standard rate configuration
- Enables SME flat/presumptive rate options
- Configures 0%/15% rates for eligible exporters
- Tracks regime qualification criteria
- Alerts when regime changes may be beneficial

#### E2. CIT Annual Filing Pack

**As a** Tax Agent preparing annual CIT returns  
**I want** comprehensive CIT filing pack generation  
**So that** I can submit complete annual returns by March 31 deadline

**Acceptance Criteria**:

- Generates annual income statement for tax purposes
- Calculates taxable income with book-tax differences
- Applies carried-forward losses and WHT credits
- Produces supporting schedules and reconciliations
- Creates audit file for RRA examination

### F. Reporting and Analytics

#### F1. Rwanda Tax Dashboard

**As a** CFO monitoring compliance  
**I want** real-time tax obligation dashboard  
**So that** I can ensure all Rwanda tax requirements are met

**Acceptance Criteria**:

- Shows upcoming filing deadlines (VAT, PAYE, WHT, CIT)
- Displays current tax liability balances
- Tracks payment status for all tax types
- Alerts for approaching deadlines or overdue items
- Provides drill-down to supporting details

#### F2. Financial Statement Generation

**As an** Accountant preparing monthly closes  
**I want** automated financial statement generation  
**So that** I can provide timely management reporting

**Acceptance Criteria**:

- Generates Balance Sheet with proper Rwanda GAAP formatting
- Produces P&L with tax expense properly classified
- Includes cash flow statement with tax payment details
- Supports comparative periods (month, quarter, year)
- Exports to Excel/PDF formats

### G. System Administration

#### G1. Tax Rule Configuration

**As a** System Administrator  
**I want to** configure tax rates and rules  
**So that** I can adapt to RRA regulatory changes

**Acceptance Criteria**:

- Maintains version-controlled tax rate tables
- Supports effective date management for rate changes
- Enables bulk updates across multiple entities
- Provides migration tools for historical data
- Requires approval workflow for rate changes

#### G2. User Access Control

**As an** IT Administrator  
**I want** granular user permission management  
**So that** I can ensure proper segregation of duties

**Acceptance Criteria**:

- Supports role-based access (Admin, Accountant, TaxAgent, Auditor)
- Enables entity-specific access restrictions
- Provides function-level permissions (view, create, edit, approve)
- Maintains user action audit logs
- Supports SSO integration with corporate directories

#### G3. Data Export and Integration

**As a** Business Analyst  
**I want** comprehensive data export capabilities  
**So that** I can integrate with external reporting tools

**Acceptance Criteria**:

- Exports trial balance in standard formats
- Provides transaction-level data extracts
- Supports automated bank feed integration
- Enables API access for third-party applications
- Maintains data export audit trail

### H. Advanced Features

#### H1. Regulatory Change Management

**As a** Tax Agent serving multiple clients  
**I want** automated updates for Rwanda tax regulation changes  
**So that** I can ensure all clients remain compliant

**Acceptance Criteria**:

- Receives RRA regulatory updates via API integration
- Provides impact analysis for tax rule changes
- Implements versioned tax calculation engine
- Supports rollback capabilities for incorrect updates
- Notifies users of required actions for compliance

#### H2. Multi-Currency Operations

**As a** CFO of export-focused business  
**I want** comprehensive multi-currency support  
**So that** I can manage foreign exchange exposure and RWF reporting

**Acceptance Criteria**:

- Maintains real-time FX rates with historical tracking
- Supports transaction-level currency recording
- Calculates FX gains/losses for reporting
- Converts all amounts to RWF for tax purposes
- Provides currency exposure analytics

This specification ensures the Rwanda AMS addresses real-world business needs while maintaining strict compliance with RRA requirements.
