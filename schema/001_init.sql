-- Rwanda Accounting Management System (AMS) Database Schema
-- This schema supports multi-tenant, multi-entity accounting with Rwanda tax compliance
-- Created for PostgreSQL 14+

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "btree_gist";

-- ============================================================================
-- TENANT AND ENTITY MANAGEMENT
-- ============================================================================

-- Tenants (Organizations using the system)
CREATE TABLE tenants (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    subdomain VARCHAR(100) UNIQUE NOT NULL,
    subscription_plan VARCHAR(50) NOT NULL DEFAULT 'basic',
    subscription_status VARCHAR(20) NOT NULL DEFAULT 'active',
    settings JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Business Entities (Companies within a tenant)
CREATE TABLE entities (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    legal_name VARCHAR(255) NOT NULL,
    tin VARCHAR(20) UNIQUE, -- Tax Identification Number
    vat_number VARCHAR(20) UNIQUE,
    entity_type VARCHAR(50) NOT NULL, -- 'company', 'partnership', 'sole_proprietorship'
    incorporation_date DATE,
    address TEXT,
    phone VARCHAR(20),
    email VARCHAR(255),
    website VARCHAR(255),
    functional_currency CHAR(3) DEFAULT 'RWF',
    fiscal_year_end DATE DEFAULT '2023-12-31',
    vat_registration_status VARCHAR(20) DEFAULT 'registered', -- 'registered', 'exempt', 'not_registered'
    vat_filing_frequency VARCHAR(20) DEFAULT 'monthly', -- 'monthly', 'quarterly'
    annual_turnover_threshold DECIMAL(15,2) DEFAULT 200000000, -- RWF threshold for filing frequency
    settings JSONB DEFAULT '{}',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================================================
-- USER MANAGEMENT AND RBAC
-- ============================================================================

-- Users
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255),
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    is_active BOOLEAN DEFAULT TRUE,
    last_login_at TIMESTAMP WITH TIME ZONE,
    email_verified_at TIMESTAMP WITH TIME ZONE,
    two_factor_enabled BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Roles
CREATE TABLE roles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    permissions JSONB DEFAULT '[]', -- Array of permission strings
    is_system_role BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(tenant_id, name)
);

-- User Role Assignments
CREATE TABLE user_roles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role_id UUID NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
    entity_id UUID REFERENCES entities(id) ON DELETE CASCADE, -- Entity-specific access
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, role_id, entity_id)
);

-- ============================================================================
-- CHART OF ACCOUNTS
-- ============================================================================

-- Account Categories
CREATE TABLE account_categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    account_type VARCHAR(20) NOT NULL, -- 'asset', 'liability', 'equity', 'revenue', 'expense'
    is_system_category BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(tenant_id, name)
);

-- Chart of Accounts
CREATE TABLE accounts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    entity_id UUID NOT NULL REFERENCES entities(id) ON DELETE CASCADE,
    account_code VARCHAR(20) NOT NULL,
    name VARCHAR(255) NOT NULL,
    account_type VARCHAR(20) NOT NULL, -- 'asset', 'liability', 'equity', 'revenue', 'expense'
    category_id UUID REFERENCES account_categories(id),
    parent_account_id UUID REFERENCES accounts(id),
    is_system_account BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    normal_balance VARCHAR(10) NOT NULL, -- 'debit', 'credit'
    tax_relevant BOOLEAN DEFAULT FALSE,
    vat_account_type VARCHAR(20), -- 'vat_output', 'vat_input', 'vat_payable', null
    currency CHAR(3) DEFAULT 'RWF',
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(entity_id, account_code)
);

-- ============================================================================
-- TAX CONFIGURATION
-- ============================================================================

-- Tax Code Types
CREATE TABLE tax_code_types (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    calculation_method VARCHAR(50) NOT NULL, -- 'percentage', 'fixed_amount', 'tiered'
    is_system_type BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(tenant_id, name)
);

-- Tax Codes (VAT, WHT, etc.)
CREATE TABLE tax_codes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    entity_id UUID NOT NULL REFERENCES entities(id) ON DELETE CASCADE,
    code VARCHAR(20) NOT NULL,
    name VARCHAR(100) NOT NULL,
    tax_type VARCHAR(20) NOT NULL, -- 'VAT', 'WHT', 'PAYE', 'CIT', 'EXEMPT'
    rate DECIMAL(5,4) NOT NULL, -- Supports up to 99.9999%
    is_compound BOOLEAN DEFAULT FALSE, -- For compound taxes
    applies_to VARCHAR(20) DEFAULT 'both', -- 'sales', 'purchases', 'both'
    gl_account_id UUID REFERENCES accounts(id), -- GL account for tax posting
    effective_from DATE NOT NULL,
    effective_to DATE,
    description TEXT,
    rra_code VARCHAR(20), -- Official RRA tax code reference
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(entity_id, code, effective_from)
);

-- Tax Rules (Complex tax calculation logic)
CREATE TABLE tax_rules (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    entity_id UUID NOT NULL REFERENCES entities(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    rule_type VARCHAR(50) NOT NULL, -- 'threshold', 'exemption', 'rate_modifier'
    conditions JSONB NOT NULL, -- JSON conditions for rule application
    actions JSONB NOT NULL, -- JSON actions to take when conditions met
    priority INTEGER DEFAULT 0,
    effective_from DATE NOT NULL,
    effective_to DATE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================================================
-- CUSTOMER AND VENDOR MANAGEMENT
-- ============================================================================

-- Customers
CREATE TABLE customers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    entity_id UUID NOT NULL REFERENCES entities(id) ON DELETE CASCADE,
    customer_number VARCHAR(50) NOT NULL,
    name VARCHAR(255) NOT NULL,
    legal_name VARCHAR(255),
    customer_type VARCHAR(20) NOT NULL, -- 'individual', 'company', 'government'
    tin VARCHAR(20),
    vat_number VARCHAR(20),
    email VARCHAR(255),
    phone VARCHAR(20),
    billing_address TEXT,
    shipping_address TEXT,
    credit_limit DECIMAL(15,2) DEFAULT 0,
    payment_terms INTEGER DEFAULT 30, -- Days
    default_tax_code_id UUID REFERENCES tax_codes(id),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(entity_id, customer_number)
);

-- Vendors/Suppliers
CREATE TABLE vendors (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    entity_id UUID NOT NULL REFERENCES entities(id) ON DELETE CASCADE,
    vendor_number VARCHAR(50) NOT NULL,
    name VARCHAR(255) NOT NULL,
    legal_name VARCHAR(255),
    vendor_type VARCHAR(20) NOT NULL, -- 'individual', 'company', 'government'
    tin VARCHAR(20),
    vat_number VARCHAR(20),
    email VARCHAR(255),
    phone VARCHAR(20),
    address TEXT,
    payment_terms INTEGER DEFAULT 30, -- Days
    default_tax_code_id UUID REFERENCES tax_codes(id),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(entity_id, vendor_number)
);

-- ============================================================================
-- GENERAL LEDGER
-- ============================================================================

-- Journal Entry Headers
CREATE TABLE journal_entries (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    entity_id UUID NOT NULL REFERENCES entities(id) ON DELETE CASCADE,
    journal_number VARCHAR(50) NOT NULL,
    entry_type VARCHAR(20) NOT NULL, -- 'manual', 'automatic', 'recurring', 'adjustment'
    reference VARCHAR(100),
    description TEXT,
    entry_date DATE NOT NULL,
    period_year INTEGER NOT NULL,
    period_month INTEGER NOT NULL,
    created_by_user_id UUID NOT NULL REFERENCES users(id),
    approved_by_user_id UUID REFERENCES users(id),
    approval_date TIMESTAMP WITH TIME ZONE,
    status VARCHAR(20) DEFAULT 'draft', -- 'draft', 'posted', 'reversed'
    reversal_entry_id UUID REFERENCES journal_entries(id),
    source_type VARCHAR(50), -- 'invoice', 'payment', 'adjustment', etc.
    source_id UUID, -- ID of source document
    total_debit DECIMAL(15,2) NOT NULL DEFAULT 0,
    total_credit DECIMAL(15,2) NOT NULL DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(entity_id, journal_number)
);

-- Journal Entry Lines
CREATE TABLE journal_entry_lines (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    journal_entry_id UUID NOT NULL REFERENCES journal_entries(id) ON DELETE CASCADE,
    line_number INTEGER NOT NULL,
    account_id UUID NOT NULL REFERENCES accounts(id),
    description TEXT,
    debit_amount DECIMAL(15,2) DEFAULT 0,
    credit_amount DECIMAL(15,2) DEFAULT 0,
    currency CHAR(3) DEFAULT 'RWF',
    exchange_rate DECIMAL(10,6) DEFAULT 1.0,
    debit_amount_base DECIMAL(15,2) DEFAULT 0, -- Amount in functional currency
    credit_amount_base DECIMAL(15,2) DEFAULT 0,
    tax_code_id UUID REFERENCES tax_codes(id),
    tax_amount DECIMAL(15,2) DEFAULT 0,
    customer_id UUID REFERENCES customers(id),
    vendor_id UUID REFERENCES vendors(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(journal_entry_id, line_number)
);

-- ============================================================================
-- INVOICING AND BILLING
-- ============================================================================

-- Invoices (Sales)
CREATE TABLE invoices (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    entity_id UUID NOT NULL REFERENCES entities(id) ON DELETE CASCADE,
    invoice_number VARCHAR(50) NOT NULL,
    customer_id UUID NOT NULL REFERENCES customers(id),
    invoice_date DATE NOT NULL,
    due_date DATE NOT NULL,
    currency CHAR(3) DEFAULT 'RWF',
    exchange_rate DECIMAL(10,6) DEFAULT 1.0,
    subtotal DECIMAL(15,2) NOT NULL DEFAULT 0,
    total_tax DECIMAL(15,2) NOT NULL DEFAULT 0,
    total_amount DECIMAL(15,2) NOT NULL DEFAULT 0,
    total_amount_base DECIMAL(15,2) NOT NULL DEFAULT 0, -- In functional currency
    amount_paid DECIMAL(15,2) NOT NULL DEFAULT 0,
    amount_outstanding DECIMAL(15,2) NOT NULL DEFAULT 0,
    status VARCHAR(20) DEFAULT 'draft', -- 'draft', 'sent', 'paid', 'overdue', 'cancelled'
    notes TEXT,
    terms TEXT,
    journal_entry_id UUID REFERENCES journal_entries(id),
    created_by_user_id UUID NOT NULL REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(entity_id, invoice_number)
);

-- Invoice Line Items
CREATE TABLE invoice_lines (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    invoice_id UUID NOT NULL REFERENCES invoices(id) ON DELETE CASCADE,
    line_number INTEGER NOT NULL,
    description TEXT NOT NULL,
    quantity DECIMAL(10,4) NOT NULL DEFAULT 1,
    unit_price DECIMAL(15,2) NOT NULL,
    line_amount DECIMAL(15,2) NOT NULL,
    tax_code_id UUID NOT NULL REFERENCES tax_codes(id),
    tax_rate DECIMAL(5,4) NOT NULL,
    tax_amount DECIMAL(15,2) NOT NULL DEFAULT 0,
    account_id UUID REFERENCES accounts(id), -- Revenue account
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(invoice_id, line_number)
);

-- Bills (Purchases)
CREATE TABLE bills (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    entity_id UUID NOT NULL REFERENCES entities(id) ON DELETE CASCADE,
    bill_number VARCHAR(50) NOT NULL,
    vendor_id UUID NOT NULL REFERENCES vendors(id),
    vendor_invoice_number VARCHAR(100),
    bill_date DATE NOT NULL,
    due_date DATE NOT NULL,
    currency CHAR(3) DEFAULT 'RWF',
    exchange_rate DECIMAL(10,6) DEFAULT 1.0,
    subtotal DECIMAL(15,2) NOT NULL DEFAULT 0,
    total_tax DECIMAL(15,2) NOT NULL DEFAULT 0,
    total_wht DECIMAL(15,2) NOT NULL DEFAULT 0, -- Withholding tax
    total_amount DECIMAL(15,2) NOT NULL DEFAULT 0,
    total_amount_base DECIMAL(15,2) NOT NULL DEFAULT 0,
    amount_paid DECIMAL(15,2) NOT NULL DEFAULT 0,
    amount_outstanding DECIMAL(15,2) NOT NULL DEFAULT 0,
    status VARCHAR(20) DEFAULT 'draft', -- 'draft', 'approved', 'paid', 'overdue'
    notes TEXT,
    journal_entry_id UUID REFERENCES journal_entries(id),
    created_by_user_id UUID NOT NULL REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(entity_id, bill_number)
);

-- Bill Line Items
CREATE TABLE bill_lines (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    bill_id UUID NOT NULL REFERENCES bills(id) ON DELETE CASCADE,
    line_number INTEGER NOT NULL,
    description TEXT NOT NULL,
    quantity DECIMAL(10,4) NOT NULL DEFAULT 1,
    unit_price DECIMAL(15,2) NOT NULL,
    line_amount DECIMAL(15,2) NOT NULL,
    tax_code_id UUID NOT NULL REFERENCES tax_codes(id),
    tax_rate DECIMAL(5,4) NOT NULL,
    tax_amount DECIMAL(15,2) NOT NULL DEFAULT 0,
    wht_rate DECIMAL(5,4) DEFAULT 0,
    wht_amount DECIMAL(15,2) DEFAULT 0,
    account_id UUID REFERENCES accounts(id), -- Expense account
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(bill_id, line_number)
);

-- ============================================================================
-- PAYMENTS
-- ============================================================================

-- Payments (Both Incoming and Outgoing)
CREATE TABLE payments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    entity_id UUID NOT NULL REFERENCES entities(id) ON DELETE CASCADE,
    payment_number VARCHAR(50) NOT NULL,
    payment_type VARCHAR(20) NOT NULL, -- 'customer_payment', 'vendor_payment'
    payment_method VARCHAR(50) NOT NULL, -- 'bank_transfer', 'cash', 'check', 'mobile_money'
    reference_number VARCHAR(100),
    payment_date DATE NOT NULL,
    amount DECIMAL(15,2) NOT NULL,
    currency CHAR(3) DEFAULT 'RWF',
    exchange_rate DECIMAL(10,6) DEFAULT 1.0,
    amount_base DECIMAL(15,2) NOT NULL, -- In functional currency
    customer_id UUID REFERENCES customers(id),
    vendor_id UUID REFERENCES vendors(id),
    bank_account_id UUID REFERENCES accounts(id),
    status VARCHAR(20) DEFAULT 'pending', -- 'pending', 'cleared', 'bounced'
    notes TEXT,
    journal_entry_id UUID REFERENCES journal_entries(id),
    created_by_user_id UUID NOT NULL REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(entity_id, payment_number)
);

-- Payment Allocations (Linking payments to invoices/bills)
CREATE TABLE payment_allocations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    payment_id UUID NOT NULL REFERENCES payments(id) ON DELETE CASCADE,
    invoice_id UUID REFERENCES invoices(id),
    bill_id UUID REFERENCES bills(id),
    allocation_amount DECIMAL(15,2) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT payment_allocations_document_check 
        CHECK ((invoice_id IS NOT NULL) != (bill_id IS NOT NULL))
);

-- ============================================================================
-- RWANDA TAX SPECIFIC TABLES
-- ============================================================================

-- VAT Returns
CREATE TABLE vat_returns (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    entity_id UUID NOT NULL REFERENCES entities(id) ON DELETE CASCADE,
    return_period_start DATE NOT NULL,
    return_period_end DATE NOT NULL,
    filing_frequency VARCHAR(20) NOT NULL, -- 'monthly', 'quarterly'
    total_sales DECIMAL(15,2) NOT NULL DEFAULT 0,
    vat_on_sales DECIMAL(15,2) NOT NULL DEFAULT 0,
    total_purchases DECIMAL(15,2) NOT NULL DEFAULT 0,
    vat_on_purchases DECIMAL(15,2) NOT NULL DEFAULT 0,
    net_vat_payable DECIMAL(15,2) NOT NULL DEFAULT 0,
    status VARCHAR(20) DEFAULT 'draft', -- 'draft', 'submitted', 'accepted'
    submitted_date TIMESTAMP WITH TIME ZONE,
    rra_reference VARCHAR(100),
    export_data JSONB, -- CSV data for RRA submission
    created_by_user_id UUID NOT NULL REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(entity_id, return_period_start, return_period_end)
);

-- WHT Certificates
CREATE TABLE wht_certificates (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    entity_id UUID NOT NULL REFERENCES entities(id) ON DELETE CASCADE,
    certificate_number VARCHAR(50) NOT NULL,
    vendor_id UUID NOT NULL REFERENCES vendors(id),
    period_start DATE NOT NULL,
    period_end DATE NOT NULL,
    total_payment_amount DECIMAL(15,2) NOT NULL,
    wht_rate DECIMAL(5,4) NOT NULL,
    wht_amount DECIMAL(15,2) NOT NULL,
    status VARCHAR(20) DEFAULT 'draft', -- 'draft', 'issued', 'submitted'
    issued_date DATE,
    rra_reference VARCHAR(100),
    created_by_user_id UUID NOT NULL REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(entity_id, certificate_number)
);

-- PAYE Returns
CREATE TABLE paye_returns (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    entity_id UUID NOT NULL REFERENCES entities(id) ON DELETE CASCADE,
    return_period_start DATE NOT NULL,
    return_period_end DATE NOT NULL,
    total_employees INTEGER NOT NULL DEFAULT 0,
    total_gross_pay DECIMAL(15,2) NOT NULL DEFAULT 0,
    total_paye_withheld DECIMAL(15,2) NOT NULL DEFAULT 0,
    employer_contributions DECIMAL(15,2) NOT NULL DEFAULT 0,
    status VARCHAR(20) DEFAULT 'draft', -- 'draft', 'submitted', 'accepted'
    submitted_date TIMESTAMP WITH TIME ZONE,
    rra_reference VARCHAR(100),
    export_data JSONB, -- CSV data for RRA submission
    created_by_user_id UUID NOT NULL REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(entity_id, return_period_start, return_period_end)
);

-- ============================================================================
-- AUDIT AND COMPLIANCE
-- ============================================================================

-- Audit Log (Immutable history of all changes)
CREATE TABLE audit_log (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    entity_id UUID REFERENCES entities(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    table_name VARCHAR(100) NOT NULL,
    record_id UUID NOT NULL,
    action VARCHAR(20) NOT NULL, -- 'INSERT', 'UPDATE', 'DELETE'
    old_values JSONB,
    new_values JSONB,
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Document Attachments
CREATE TABLE attachments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    entity_id UUID NOT NULL REFERENCES entities(id) ON DELETE CASCADE,
    table_name VARCHAR(100) NOT NULL,
    record_id UUID NOT NULL,
    file_name VARCHAR(255) NOT NULL,
    file_type VARCHAR(100),
    file_size BIGINT,
    file_path TEXT NOT NULL,
    description TEXT,
    uploaded_by_user_id UUID NOT NULL REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================================================
-- INDEXES FOR PERFORMANCE
-- ============================================================================

-- Primary business indexes
CREATE INDEX idx_entities_tenant_id ON entities(tenant_id);
CREATE INDEX idx_users_tenant_id ON users(tenant_id);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_accounts_entity_id ON accounts(entity_id);
CREATE INDEX idx_accounts_code ON accounts(entity_id, account_code);
CREATE INDEX idx_tax_codes_entity_id ON tax_codes(entity_id);
CREATE INDEX idx_customers_entity_id ON customers(entity_id);
CREATE INDEX idx_vendors_entity_id ON vendors(entity_id);

-- Journal entry indexes
CREATE INDEX idx_journal_entries_entity_id ON journal_entries(entity_id);
CREATE INDEX idx_journal_entries_date ON journal_entries(entry_date);
CREATE INDEX idx_journal_entries_period ON journal_entries(period_year, period_month);
CREATE INDEX idx_journal_entry_lines_journal_id ON journal_entry_lines(journal_entry_id);
CREATE INDEX idx_journal_entry_lines_account ON journal_entry_lines(account_id);

-- Invoice and payment indexes
CREATE INDEX idx_invoices_entity_id ON invoices(entity_id);
CREATE INDEX idx_invoices_customer_id ON invoices(customer_id);
CREATE INDEX idx_invoices_date ON invoices(invoice_date);
CREATE INDEX idx_invoices_status ON invoices(status);
CREATE INDEX idx_bills_entity_id ON bills(entity_id);
CREATE INDEX idx_bills_vendor_id ON bills(vendor_id);
CREATE INDEX idx_payments_entity_id ON payments(entity_id);
CREATE INDEX idx_payments_date ON payments(payment_date);

-- Tax compliance indexes
CREATE INDEX idx_vat_returns_entity_id ON vat_returns(entity_id);
CREATE INDEX idx_vat_returns_period ON vat_returns(return_period_start, return_period_end);
CREATE INDEX idx_wht_certificates_entity_id ON wht_certificates(entity_id);
CREATE INDEX idx_wht_certificates_vendor ON wht_certificates(vendor_id);
CREATE INDEX idx_paye_returns_entity_id ON paye_returns(entity_id);

-- Audit indexes
CREATE INDEX idx_audit_log_tenant_id ON audit_log(tenant_id);
CREATE INDEX idx_audit_log_table_record ON audit_log(table_name, record_id);
CREATE INDEX idx_audit_log_created_at ON audit_log(created_at);

-- ============================================================================
-- CONSTRAINTS AND TRIGGERS
-- ============================================================================

-- Ensure journal entries balance
ALTER TABLE journal_entries ADD CONSTRAINT chk_journal_entries_balanced 
    CHECK (total_debit = total_credit);

-- Ensure payment allocations don't exceed payment amount
-- (This would be enforced by application logic and database functions)

-- Function to automatically update updated_at timestamps
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply updated_at triggers to all tables with updated_at columns
CREATE TRIGGER update_tenants_updated_at BEFORE UPDATE ON tenants 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_entities_updated_at BEFORE UPDATE ON entities 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_accounts_updated_at BEFORE UPDATE ON accounts 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_tax_codes_updated_at BEFORE UPDATE ON tax_codes 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_customers_updated_at BEFORE UPDATE ON customers 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_vendors_updated_at BEFORE UPDATE ON vendors 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_invoices_updated_at BEFORE UPDATE ON invoices 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_bills_updated_at BEFORE UPDATE ON bills 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_payments_updated_at BEFORE UPDATE ON payments 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_vat_returns_updated_at BEFORE UPDATE ON vat_returns 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_wht_certificates_updated_at BEFORE UPDATE ON wht_certificates 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_paye_returns_updated_at BEFORE UPDATE ON paye_returns 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Audit trigger function
CREATE OR REPLACE FUNCTION audit_trigger_function()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'DELETE' THEN
        INSERT INTO audit_log (tenant_id, entity_id, table_name, record_id, action, old_values)
        VALUES (
            COALESCE(OLD.tenant_id, (SELECT tenant_id FROM entities WHERE id = OLD.entity_id)),
            OLD.entity_id,
            TG_TABLE_NAME,
            OLD.id,
            TG_OP,
            row_to_json(OLD)
        );
        RETURN OLD;
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO audit_log (tenant_id, entity_id, table_name, record_id, action, old_values, new_values)
        VALUES (
            COALESCE(NEW.tenant_id, (SELECT tenant_id FROM entities WHERE id = NEW.entity_id)),
            NEW.entity_id,
            TG_TABLE_NAME,
            NEW.id,
            TG_OP,
            row_to_json(OLD),
            row_to_json(NEW)
        );
        RETURN NEW;
    ELSIF TG_OP = 'INSERT' THEN
        INSERT INTO audit_log (tenant_id, entity_id, table_name, record_id, action, new_values)
        VALUES (
            COALESCE(NEW.tenant_id, (SELECT tenant_id FROM entities WHERE id = NEW.entity_id)),
            NEW.entity_id,
            TG_TABLE_NAME,
            NEW.id,
            TG_OP,
            row_to_json(NEW)
        );
        RETURN NEW;
    END IF;
    RETURN NULL;
END;
$$ language 'plpgsql';

-- Apply audit triggers to key tables
CREATE TRIGGER audit_trigger_journal_entries 
    AFTER INSERT OR UPDATE OR DELETE ON journal_entries 
    FOR EACH ROW EXECUTE FUNCTION audit_trigger_function();
CREATE TRIGGER audit_trigger_invoices 
    AFTER INSERT OR UPDATE OR DELETE ON invoices 
    FOR EACH ROW EXECUTE FUNCTION audit_trigger_function();
CREATE TRIGGER audit_trigger_payments 
    AFTER INSERT OR UPDATE OR DELETE ON payments 
    FOR EACH ROW EXECUTE FUNCTION audit_trigger_function();
CREATE TRIGGER audit_trigger_vat_returns 
    AFTER INSERT OR UPDATE OR DELETE ON vat_returns 
    FOR EACH ROW EXECUTE FUNCTION audit_trigger_function();
