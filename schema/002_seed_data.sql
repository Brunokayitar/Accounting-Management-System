-- Rwanda AMS Seed Data
-- Sample data for development and testing including Rwanda-specific tax codes
-- Source: RRA regulations as of 2024

-- ============================================================================
-- SAMPLE TENANT AND ENTITY
-- ============================================================================

-- Insert sample tenant
INSERT INTO tenants (id, name, subdomain, subscription_plan) VALUES 
(
    '00000000-0000-0000-0000-000000000001',
    'Demo Corporation Rwanda',
    'demo',
    'enterprise'
);

-- Insert sample entity
INSERT INTO entities (
    id, 
    tenant_id, 
    name, 
    legal_name, 
    tin, 
    vat_number,
    entity_type,
    incorporation_date,
    address,
    phone,
    email,
    vat_filing_frequency,
    annual_turnover_threshold
) VALUES (
    '00000000-0000-0000-0000-000000000101',
    '00000000-0000-0000-0000-000000000001',
    'Kigali Tech Solutions Ltd',
    'Kigali Technology Solutions Limited',
    'TIN123456789',
    'VAT123456789',
    'company',
    '2020-01-15',
    'KG 123 Street, Kigali, Rwanda',
    '+250788123456',
    'finance@kigalitech.rw',
    'monthly',
    200000000.00
);

-- ============================================================================
-- SYSTEM ROLES (Rwanda-specific accounting roles)
-- ============================================================================

INSERT INTO roles (id, tenant_id, name, description, permissions, is_system_role) VALUES
(
    '00000000-0000-0000-0000-000000001001',
    '00000000-0000-0000-0000-000000000001',
    'System Administrator',
    'Full system access including tenant configuration',
    '["system:*", "entity:*", "accounting:*", "tax:*", "user:*", "audit:*"]',
    true
),
(
    '00000000-0000-0000-0000-000000001002',
    '00000000-0000-0000-0000-000000000001',
    'CFO',
    'Chief Financial Officer with full financial access',
    '["entity:read", "accounting:*", "tax:*", "reports:*", "user:read"]',
    true
),
(
    '00000000-0000-0000-0000-000000001003',
    '00000000-0000-0000-0000-000000000001',
    'Senior Accountant',
    'Full accounting operations and tax compliance',
    '["accounting:*", "tax:*", "reports:read", "invoices:*", "payments:*"]',
    true
),
(
    '00000000-0000-0000-0000-000000001004',
    '00000000-0000-0000-0000-000000000001',
    'Tax Agent',
    'Tax compliance specialist with limited GL access',
    '["tax:*", "reports:read", "vat:*", "wht:*", "paye:*"]',
    true
),
(
    '00000000-0000-0000-0000-000000001005',
    '00000000-0000-0000-0000-000000000001',
    'Auditor',
    'Read-only access for audit purposes',
    '["accounting:read", "tax:read", "reports:read", "audit:read"]',
    true
),
(
    '00000000-0000-0000-0000-000000001006',
    '00000000-0000-0000-0000-000000000001',
    'AP/AR Clerk',
    'Accounts payable and receivable operations',
    '["invoices:*", "payments:*", "customers:*", "vendors:*"]',
    true
);

-- ============================================================================
-- ACCOUNT CATEGORIES (Rwanda Chart of Accounts Structure)
-- ============================================================================

INSERT INTO account_categories (id, tenant_id, name, account_type, is_system_category) VALUES
('00000000-0000-0000-0000-000000002001', '00000000-0000-0000-0000-000000000001', 'Current Assets', 'asset', true),
('00000000-0000-0000-0000-000000002002', '00000000-0000-0000-0000-000000000001', 'Fixed Assets', 'asset', true),
('00000000-0000-0000-0000-000000002003', '00000000-0000-0000-0000-000000000001', 'Current Liabilities', 'liability', true),
('00000000-0000-0000-0000-000000002004', '00000000-0000-0000-0000-000000000001', 'Long-term Liabilities', 'liability', true),
('00000000-0000-0000-0000-000000002005', '00000000-0000-0000-0000-000000000001', 'Equity', 'equity', true),
('00000000-0000-0000-0000-000000002006', '00000000-0000-0000-0000-000000000001', 'Operating Revenue', 'revenue', true),
('00000000-0000-0000-0000-000000002007', '00000000-0000-0000-0000-000000000001', 'Operating Expenses', 'expense', true),
('00000000-0000-0000-0000-000000002008', '00000000-0000-0000-0000-000000000001', 'Tax Accounts', 'liability', true);

-- ============================================================================
-- CHART OF ACCOUNTS (Rwanda-compliant structure)
-- ============================================================================

INSERT INTO accounts (id, entity_id, account_code, name, account_type, category_id, normal_balance, tax_relevant, vat_account_type, description) VALUES
-- Assets
('00000000-0000-0000-0000-000000003001', '00000000-0000-0000-0000-000000000101', '1001', 'Cash - Bank of Kigali', 'asset', '00000000-0000-0000-0000-000000002001', 'debit', false, null, 'Primary operating account'),
('00000000-0000-0000-0000-000000003002', '00000000-0000-0000-0000-000000000101', '1002', 'Cash - Equity Bank', 'asset', '00000000-0000-0000-0000-000000002001', 'debit', false, null, 'Secondary operating account'),
('00000000-0000-0000-0000-000000003003', '00000000-0000-0000-0000-000000000101', '1101', 'Accounts Receivable', 'asset', '00000000-0000-0000-0000-000000002001', 'debit', false, null, 'Customer receivables'),
('00000000-0000-0000-0000-000000003004', '00000000-0000-0000-0000-000000000101', '1102', 'VAT Input Credits', 'asset', '00000000-0000-0000-0000-000000002001', 'debit', true, 'vat_input', 'VAT paid on purchases - recoverable'),
('00000000-0000-0000-0000-000000003005', '00000000-0000-0000-0000-000000000101', '1103', 'WHT Credits', 'asset', '00000000-0000-0000-0000-000000002001', 'debit', true, null, 'Withholding tax credits against CIT'),
('00000000-0000-0000-0000-000000003006', '00000000-0000-0000-0000-000000000101', '1201', 'Equipment', 'asset', '00000000-0000-0000-0000-000000002002', 'debit', false, null, 'Computer equipment and furniture'),

-- Liabilities
('00000000-0000-0000-0000-000000003007', '00000000-0000-0000-0000-000000000101', '2001', 'Accounts Payable', 'liability', '00000000-0000-0000-0000-000000002003', 'credit', false, null, 'Vendor payables'),
('00000000-0000-0000-0000-000000003008', '00000000-0000-0000-0000-000000000101', '2101', 'VAT Payable', 'liability', '00000000-0000-0000-0000-000000002008', 'credit', true, 'vat_payable', 'VAT collected on sales - payable to RRA'),
('00000000-0000-0000-0000-000000003009', '00000000-0000-0000-0000-000000000101', '2102', 'WHT Payable', 'liability', '00000000-0000-0000-0000-000000002008', 'credit', true, null, 'Withholding tax collected - payable to RRA'),
('00000000-0000-0000-0000-000000003010', '00000000-0000-0000-0000-000000000101', '2103', 'PAYE Payable', 'liability', '00000000-0000-0000-0000-000000002008', 'credit', true, null, 'Employee PAYE tax - payable to RRA'),
('00000000-0000-0000-0000-000000003011', '00000000-0000-0000-0000-000000000101', '2104', 'CIT Payable', 'liability', '00000000-0000-0000-0000-000000002008', 'credit', true, null, 'Corporate Income Tax payable'),

-- Equity
('00000000-0000-0000-0000-000000003012', '00000000-0000-0000-0000-000000000101', '3001', 'Share Capital', 'equity', '00000000-0000-0000-0000-000000002005', 'credit', false, null, 'Issued share capital'),
('00000000-0000-0000-0000-000000003013', '00000000-0000-0000-0000-000000000101', '3002', 'Retained Earnings', 'equity', '00000000-0000-0000-0000-000000002005', 'credit', false, null, 'Accumulated profits'),

-- Revenue
('00000000-0000-0000-0000-000000003014', '00000000-0000-0000-0000-000000000101', '4001', 'Professional Services Revenue', 'revenue', '00000000-0000-0000-0000-000000002006', 'credit', true, null, 'IT consulting and development services'),
('00000000-0000-0000-0000-000000003015', '00000000-0000-0000-0000-000000000101', '4002', 'Software License Revenue', 'revenue', '00000000-0000-0000-0000-000000002006', 'credit', true, null, 'Software licensing income'),

-- Expenses
('00000000-0000-0000-0000-000000003016', '00000000-0000-0000-0000-000000000101', '5001', 'Salaries and Wages', 'expense', '00000000-0000-0000-0000-000000002007', 'debit', true, null, 'Employee compensation'),
('00000000-0000-0000-0000-000000003017', '00000000-0000-0000-0000-000000000101', '5002', 'Office Rent', 'expense', '00000000-0000-0000-0000-000000002007', 'debit', true, null, 'Office space rental'),
('00000000-0000-0000-0000-000000003018', '00000000-0000-0000-0000-000000000101', '5003', 'Professional Fees', 'expense', '00000000-0000-0000-0000-000000002007', 'debit', true, null, 'Legal and consulting fees'),
('00000000-0000-0000-0000-000000003019', '00000000-0000-0000-0000-000000000101', '5004', 'Equipment Purchase', 'expense', '00000000-0000-0000-0000-000000002007', 'debit', true, null, 'Computer and office equipment');

-- ============================================================================
-- RWANDA TAX CODES (Current rates as of 2024)
-- Sources: RRA Official Publications, PwC Rwanda Tax Guide, EY Rwanda Tax Guide
-- ============================================================================

INSERT INTO tax_codes (
    id, 
    entity_id, 
    code, 
    name, 
    tax_type, 
    rate, 
    applies_to, 
    gl_account_id, 
    effective_from, 
    description, 
    rra_code
) VALUES
-- VAT CODES (Source: RRA VAT Law, updated rates effective 2024)
(
    '00000000-0000-0000-0000-000000004001',
    '00000000-0000-0000-0000-000000000101',
    'VAT_18',
    'VAT Standard Rate 18%',
    'VAT',
    18.0000,
    'both',
    '00000000-0000-0000-0000-000000003008',
    '2024-01-01',
    'Standard VAT rate for most goods and services in Rwanda',
    'VAT-STD'
),
(
    '00000000-0000-0000-0000-000000004002',
    '00000000-0000-0000-0000-000000000101',
    'VAT_0',
    'VAT Zero Rate 0%',
    'VAT',
    0.0000,
    'sales',
    '00000000-0000-0000-0000-000000003008',
    '2024-01-01',
    'Zero-rated supplies - exports, international transport, approved raw materials',
    'VAT-ZER'
),
(
    '00000000-0000-0000-0000-000000004003',
    '00000000-0000-0000-0000-000000000101',
    'VAT_EXEMPT',
    'VAT Exempt',
    'EXEMPT',
    0.0000,
    'both',
    null,
    '2024-01-01',
    'VAT exempt supplies - financial services, insurance, education, healthcare',
    'VAT-EXE'
),

-- WITHHOLDING TAX CODES (Source: RRA Withholding Tax Guidelines)
(
    '00000000-0000-0000-0000-000000004004',
    '00000000-0000-0000-0000-000000000101',
    'WHT_15',
    'Withholding Tax 15%',
    'WHT',
    15.0000,
    'purchases',
    '00000000-0000-0000-0000-000000003009',
    '2024-01-01',
    'Standard withholding tax rate on most payments to residents',
    'WHT-STD'
),
(
    '00000000-0000-0000-0000-000000004005',
    '00000000-0000-0000-0000-000000000101',
    'WHT_5',
    'Withholding Tax 5%',
    'WHT',
    5.0000,
    'purchases',
    '00000000-0000-0000-0000-000000003009',
    '2024-01-01',
    'Reduced WHT rate on dividends and interest from domestic sources',
    'WHT-RED'
),
(
    '00000000-0000-0000-0000-000000004006',
    '00000000-0000-0000-0000-000000000101',
    'WHT_30',
    'Withholding Tax 30%',
    'WHT',
    30.0000,
    'purchases',
    '00000000-0000-0000-0000-000000003009',
    '2024-01-01',
    'WHT on payments to non-residents without tax treaty benefits',
    'WHT-NR'
),
(
    '00000000-0000-0000-0000-000000004007',
    '00000000-0000-0000-0000-000000000101',
    'WHT_0',
    'Withholding Tax Exempt',
    'EXEMPT',
    0.0000,
    'purchases',
    null,
    '2024-01-01',
    'Payments exempt from withholding tax - government, approved entities',
    'WHT-EXE'
),

-- PAYE CODES (Source: RRA PAYE Guidelines - progressive bands)
-- Note: PAYE uses tiered calculation, these represent the bands
(
    '00000000-0000-0000-0000-000000004008',
    '00000000-0000-0000-0000-000000000101',
    'PAYE_0',
    'PAYE Band 1 - 0%',
    'PAYE',
    0.0000,
    'both',
    '00000000-0000-0000-0000-000000003010',
    '2024-01-01',
    'PAYE rate for monthly income up to RWF 60,000',
    'PAYE-B1'
),
(
    '00000000-0000-0000-0000-000000004009',
    '00000000-0000-0000-0000-000000000101',
    'PAYE_20',
    'PAYE Band 2 - 20%',
    'PAYE',
    20.0000,
    'both',
    '00000000-0000-0000-0000-000000003010',
    '2024-01-01',
    'PAYE rate for monthly income RWF 60,001 - 100,000',
    'PAYE-B2'
),
(
    '00000000-0000-0000-0000-000000004010',
    '00000000-0000-0000-0000-000000000101',
    'PAYE_30',
    'PAYE Band 3 - 30%',
    'PAYE',
    30.0000,
    'both',
    '00000000-0000-0000-0000-000000003010',
    '2024-01-01',
    'PAYE rate for monthly income above RWF 100,000',
    'PAYE-B3'
),
(
    '00000000-0000-0000-0000-000000004011',
    '00000000-0000-0000-0000-000000000101',
    'CASUAL_15',
    'Casual Labor Tax 15%',
    'PAYE',
    15.0000,
    'both',
    '00000000-0000-0000-0000-000000003010',
    '2024-01-01',
    'Flat rate tax on casual labor payments',
    'CASUAL'
);

-- ============================================================================
-- TAX RULES (Rwanda-specific tax calculation rules)
-- ============================================================================

INSERT INTO tax_rules (
    id,
    entity_id,
    name,
    rule_type,
    conditions,
    actions,
    priority,
    effective_from,
    description
) VALUES
-- VAT filing frequency rule based on annual turnover
(
    '00000000-0000-0000-0000-000000005001',
    '00000000-0000-0000-0000-000000000101',
    'VAT Filing Frequency - Monthly',
    'threshold',
    '{"annual_turnover": {"operator": ">", "value": 200000000, "currency": "RWF"}}',
    '{"set_filing_frequency": "monthly", "alert_threshold_exceeded": true}',
    100,
    '2024-01-01',
    'Businesses with annual turnover > RWF 200M must file VAT monthly (Source: RRA VAT Law Article 15)'
),
(
    '00000000-0000-0000-0000-000000005002',
    '00000000-0000-0000-0000-000000000101',
    'VAT Filing Frequency - Quarterly',
    'threshold',
    '{"annual_turnover": {"operator": "<=", "value": 200000000, "currency": "RWF"}}',
    '{"set_filing_frequency": "quarterly"}',
    90,
    '2024-01-01',
    'Businesses with annual turnover ≤ RWF 200M may file VAT quarterly (Source: RRA VAT Law Article 15)'
),

-- WHT exemption for government payments
(
    '00000000-0000-0000-0000-000000005003',
    '00000000-0000-0000-0000-000000000101',
    'WHT Exemption - Government Entity',
    'exemption',
    '{"customer_type": {"operator": "=", "value": "government"}}',
    '{"apply_wht": false, "use_tax_code": "WHT_0"}',
    100,
    '2024-01-01',
    'Payments to government entities are typically exempt from WHT (Source: RRA WHT Guidelines)'
),

-- VAT exemption for exports
(
    '00000000-0000-0000-0000-000000005004',
    '00000000-0000-0000-0000-000000000101',
    'VAT Zero Rating - Exports',
    'exemption',
    '{"invoice_type": {"operator": "=", "value": "export"}}',
    '{"use_tax_code": "VAT_0", "require_export_documentation": true}',
    100,
    '2024-01-01',
    'Export sales are zero-rated for VAT (Source: RRA VAT Law Schedule 2)'
);

-- ============================================================================
-- SAMPLE CUSTOMERS AND VENDORS
-- ============================================================================

INSERT INTO customers (
    id, 
    entity_id, 
    customer_number, 
    name, 
    legal_name, 
    customer_type, 
    tin, 
    vat_number,
    email,
    phone,
    billing_address,
    credit_limit,
    payment_terms,
    default_tax_code_id
) VALUES
(
    '00000000-0000-0000-0000-000000006001',
    '00000000-0000-0000-0000-000000000101',
    'CUST001',
    'Rwanda Bank Ltd',
    'Rwanda Development Bank Limited',
    'company',
    'TIN987654321',
    'VAT987654321',
    'procurement@rwandabank.rw',
    '+250788987654',
    'KN 2 Ave, Kigali, Rwanda',
    50000000.00,
    30,
    '00000000-0000-0000-0000-000000004001' -- VAT 18%
),
(
    '00000000-0000-0000-0000-000000006002',
    '00000000-0000-0000-0000-000000000101',
    'CUST002',
    'Ministry of ICT',
    'Ministry of Information and Communication Technology',
    'government',
    null,
    null,
    'ict@gov.rw',
    '+250788555666',
    'Government Ave, Kigali, Rwanda',
    100000000.00,
    60,
    '00000000-0000-0000-0000-000000004003' -- VAT Exempt
),
(
    '00000000-0000-0000-0000-000000006003',
    '00000000-0000-0000-0000-000000000101',
    'CUST003',
    'Andela Rwanda',
    'Andela Rwanda Limited',
    'company',
    'TIN456789123',
    'VAT456789123',
    'finance@andela.com',
    '+250788444555',
    'Kacyiru, Kigali, Rwanda',
    25000000.00,
    15,
    '00000000-0000-0000-0000-000000004001' -- VAT 18%
);

INSERT INTO vendors (
    id,
    entity_id,
    vendor_number,
    name,
    legal_name,
    vendor_type,
    tin,
    vat_number,
    email,
    phone,
    address,
    payment_terms,
    default_tax_code_id
) VALUES
(
    '00000000-0000-0000-0000-000000007001',
    '00000000-0000-0000-0000-000000000101',
    'VEND001',
    'Microsoft East Africa',
    'Microsoft East Africa Limited',
    'company',
    'TIN111222333',
    'VAT111222333',
    'billing@microsoft.com',
    '+254700123456',
    'Nairobi, Kenya',
    30,
    '00000000-0000-0000-0000-000000004004' -- WHT 15%
),
(
    '00000000-0000-0000-0000-000000007002',
    '00000000-0000-0000-0000-000000000101',
    'VEND002',
    'Simba Supermarket',
    'Simba Supermarket Limited',
    'company',
    'TIN444555666',
    'VAT444555666',
    'accounts@simba.rw',
    '+250788123789',
    'KN 82 St, Kigali, Rwanda',
    15,
    '00000000-0000-0000-0000-000000004007' -- WHT Exempt (local supplies)
),
(
    '00000000-0000-0000-0000-000000007003',
    '00000000-0000-0000-0000-000000000101',
    'VEND003',
    'Rwandatel',
    'Rwanda Telecommunications Agency',
    'government',
    null,
    null,
    'billing@rwandatel.rw',
    '+250788999888',
    'Telecom House, Kigali, Rwanda',
    30,
    '00000000-0000-0000-0000-000000004007' -- WHT Exempt (government)
);

-- ============================================================================
-- SAMPLE USERS
-- ============================================================================

INSERT INTO users (
    id,
    tenant_id,
    email,
    first_name,
    last_name,
    phone,
    is_active,
    email_verified_at
) VALUES
(
    '00000000-0000-0000-0000-000000008001',
    '00000000-0000-0000-0000-000000000001',
    'admin@kigalitech.rw',
    'System',
    'Administrator',
    '+250788000001',
    true,
    NOW()
),
(
    '00000000-0000-0000-0000-000000008002',
    '00000000-0000-0000-0000-000000000001',
    'cfo@kigalitech.rw',
    'Sarah',
    'Uwimana',
    '+250788000002',
    true,
    NOW()
),
(
    '00000000-0000-0000-0000-000000008003',
    '00000000-0000-0000-0000-000000000001',
    'accountant@kigalitech.rw',
    'Jean Baptiste',
    'Nkurunziza',
    '+250788000003',
    true,
    NOW()
),
(
    '00000000-0000-0000-0000-000000008004',
    '00000000-0000-0000-0000-000000000001',
    'tax@kigalitech.rw',
    'Marie Claire',
    'Mukamana',
    '+250788000004',
    true,
    NOW()
);

-- Assign roles to users
INSERT INTO user_roles (user_id, role_id, entity_id) VALUES
('00000000-0000-0000-0000-000000008001', '00000000-0000-0000-0000-000000001001', '00000000-0000-0000-0000-000000000101'), -- Admin
('00000000-0000-0000-0000-000000008002', '00000000-0000-0000-0000-000000001002', '00000000-0000-0000-0000-000000000101'), -- CFO  
('00000000-0000-0000-0000-000000008003', '00000000-0000-0000-0000-000000001003', '00000000-0000-0000-0000-000000000101'), -- Senior Accountant
('00000000-0000-0000-0000-000000008004', '00000000-0000-0000-0000-000000001004', '00000000-0000-0000-0000-000000000101'); -- Tax Agent

-- ============================================================================
-- SAMPLE TRANSACTIONS (for demonstration)
-- ============================================================================

-- Sample invoice to Rwanda Bank Ltd
INSERT INTO invoices (
    id,
    entity_id,
    invoice_number,
    customer_id,
    invoice_date,
    due_date,
    subtotal,
    total_tax,
    total_amount,
    total_amount_base,
    amount_outstanding,
    status,
    notes,
    created_by_user_id
) VALUES (
    '00000000-0000-0000-0000-000000009001',
    '00000000-0000-0000-0000-000000000101',
    'INV-2024-001',
    '00000000-0000-0000-0000-000000006001',
    '2024-01-15',
    '2024-02-14',
    15000000.00,
    2700000.00,
    17700000.00,
    17700000.00,
    17700000.00,
    'sent',
    'Professional IT consulting services for Q4 2023',
    '00000000-0000-0000-0000-000000008003'
);

-- Invoice line items
INSERT INTO invoice_lines (
    id,
    invoice_id,
    line_number,
    description,
    quantity,
    unit_price,
    line_amount,
    tax_code_id,
    tax_rate,
    tax_amount,
    account_id
) VALUES (
    '00000000-0000-0000-0000-000000009101',
    '00000000-0000-0000-0000-000000009001',
    1,
    'Software Development Services - Database Architecture',
    80.0000,
    125000.00,
    10000000.00,
    '00000000-0000-0000-0000-000000004001',
    18.0000,
    1800000.00,
    '00000000-0000-0000-0000-000000003014'
),
(
    '00000000-0000-0000-0000-000000009102',
    '00000000-0000-0000-0000-000000009001',
    2,
    'System Integration and Testing',
    40.0000,
    125000.00,
    5000000.00,
    '00000000-0000-0000-0000-000000004001',
    18.0000,
    900000.00,
    '00000000-0000-0000-0000-000000003014'
);

-- Sample bill from Microsoft (with WHT)
INSERT INTO bills (
    id,
    entity_id,
    bill_number,
    vendor_id,
    vendor_invoice_number,
    bill_date,
    due_date,
    subtotal,
    total_tax,
    total_wht,
    total_amount,
    total_amount_base,
    amount_outstanding,
    status,
    notes,
    created_by_user_id
) VALUES (
    '00000000-0000-0000-0000-000000009201',
    '00000000-0000-0000-0000-000000000101',
    'BILL-2024-001',
    '00000000-0000-0000-0000-000000007001',
    'MS-INV-2024-12345',
    '2024-01-10',
    '2024-02-09',
    8500000.00,
    1530000.00,
    1275000.00,
    8755000.00,
    8755000.00,
    8755000.00,
    'approved',
    'Microsoft Office 365 Enterprise licenses for 100 users',
    '00000000-0000-0000-0000-000000008003'
);

-- Bill line items
INSERT INTO bill_lines (
    id,
    bill_id,
    line_number,
    description,
    quantity,
    unit_price,
    line_amount,
    tax_code_id,
    tax_rate,
    tax_amount,
    wht_rate,
    wht_amount,
    account_id
) VALUES (
    '00000000-0000-0000-0000-000000009301',
    '00000000-0000-0000-0000-000000009201',
    1,
    'Microsoft Office 365 E3 License - Annual Subscription',
    100.0000,
    85000.00,
    8500000.00,
    '00000000-0000-0000-0000-000000004001',
    18.0000,
    1530000.00,
    15.0000,
    1275000.00,
    '00000000-0000-0000-0000-000000003018'
);

-- ============================================================================
-- UPDATE SEQUENCES AND CONSTRAINTS
-- ============================================================================

-- Ensure all foreign key constraints are valid
SELECT pg_catalog.setval('public.journal_entries_id_seq', 1, false);
SELECT pg_catalog.setval('public.invoice_lines_id_seq', 2, true);
SELECT pg_catalog.setval('public.bill_lines_id_seq', 1, true);

-- Add comments for documentation
COMMENT ON TABLE tax_codes IS 'Rwanda-specific tax codes with rates sourced from RRA regulations as of 2024';
COMMENT ON TABLE tax_rules IS 'Business rules for automatic tax calculations and compliance checks';
COMMENT ON TABLE vat_returns IS 'VAT return forms for submission to RRA - supports both monthly and quarterly filing';
COMMENT ON TABLE wht_certificates IS 'Withholding tax certificates issued to vendors for CIT credit purposes';
COMMENT ON TABLE paye_returns IS 'PAYE monthly returns for employee tax submissions to RRA';

-- Create helpful views for common queries
CREATE VIEW v_current_tax_codes AS
SELECT tc.*, a.name as gl_account_name 
FROM tax_codes tc
LEFT JOIN accounts a ON tc.gl_account_id = a.id
WHERE tc.is_active = true 
AND (tc.effective_to IS NULL OR tc.effective_to >= CURRENT_DATE);

CREATE VIEW v_outstanding_receivables AS
SELECT 
    i.id,
    i.invoice_number,
    c.name as customer_name,
    i.invoice_date,
    i.due_date,
    i.total_amount,
    i.amount_outstanding,
    CASE 
        WHEN i.due_date < CURRENT_DATE THEN 'overdue'
        WHEN i.due_date <= CURRENT_DATE + INTERVAL '7 days' THEN 'due_soon'
        ELSE 'current'
    END as aging_status
FROM invoices i
JOIN customers c ON i.customer_id = c.id
WHERE i.amount_outstanding > 0
AND i.status != 'cancelled';

CREATE VIEW v_vat_summary_current_month AS
SELECT 
    e.name as entity_name,
    SUM(CASE WHEN jel.credit_amount > 0 AND tc.tax_type = 'VAT' THEN jel.credit_amount ELSE 0 END) as vat_collected,
    SUM(CASE WHEN jel.debit_amount > 0 AND tc.tax_type = 'VAT' THEN jel.debit_amount ELSE 0 END) as vat_paid,
    SUM(CASE WHEN jel.credit_amount > 0 AND tc.tax_type = 'VAT' THEN jel.credit_amount ELSE 0 END) - 
    SUM(CASE WHEN jel.debit_amount > 0 AND tc.tax_type = 'VAT' THEN jel.debit_amount ELSE 0 END) as net_vat_payable
FROM journal_entry_lines jel
JOIN journal_entries je ON jel.journal_entry_id = je.id
JOIN entities e ON je.entity_id = e.id
JOIN tax_codes tc ON jel.tax_code_id = tc.id
WHERE je.period_year = EXTRACT(YEAR FROM CURRENT_DATE)
AND je.period_month = EXTRACT(MONTH FROM CURRENT_DATE)
AND je.status = 'posted'
AND tc.tax_type = 'VAT'
GROUP BY e.id, e.name;

-- Add indexes for the views
CREATE INDEX idx_tax_codes_active_effective ON tax_codes(is_active, effective_from, effective_to);
CREATE INDEX idx_invoices_outstanding ON invoices(amount_outstanding) WHERE amount_outstanding > 0;
CREATE INDEX idx_journal_entries_period_status ON journal_entries(period_year, period_month, status);
