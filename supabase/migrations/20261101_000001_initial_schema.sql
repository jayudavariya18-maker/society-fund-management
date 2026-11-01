-- ====================================================================
-- BAJRANG RESIDENTIAL SOCIETY FUND MANAGEMENT SYSTEM
-- Migration: 20261101_000001_initial_schema.sql
-- Single-Society, No-Roles, Immutable Accounting & Audit Logging Schema
-- ====================================================================

-- 0. Enable UUID Extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. TABLE: SOCIETY (Single Residential Society deployment)
CREATE TABLE IF NOT EXISTS public.society (
    society_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    society_name VARCHAR(150) NOT NULL,
    address TEXT NOT NULL,
    city VARCHAR(100) NOT NULL,
    state VARCHAR(100) NOT NULL,
    pincode VARCHAR(10) NOT NULL,
    contact_number VARCHAR(20) NOT NULL,
    email VARCHAR(120),
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- 2. TABLE: MEMBERS
CREATE TABLE IF NOT EXISTS public.members (
    member_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    society_id UUID NOT NULL REFERENCES public.society(society_id) ON DELETE RESTRICT,
    auth_uid UUID UNIQUE NOT NULL, -- Corresponds to Supabase auth.users(id)
    full_name VARCHAR(120) NOT NULL,
    phone_number VARCHAR(20) NOT NULL UNIQUE,
    flat_number VARCHAR(30) NOT NULL,
    email VARCHAR(120),
    profile_image_url TEXT,
    membership_status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE' 
        CHECK (membership_status IN ('ACTIVE', 'INACTIVE', 'SUSPENDED')),
    joined_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- 3. TABLE: REGISTRATION_REQUESTS
CREATE TABLE IF NOT EXISTS public.registration_requests (
    request_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    society_id UUID NOT NULL REFERENCES public.society(society_id) ON DELETE RESTRICT,
    auth_uid UUID NOT NULL,
    full_name VARCHAR(120) NOT NULL,
    phone_number VARCHAR(20) NOT NULL,
    flat_number VARCHAR(30) NOT NULL,
    additional_information TEXT,
    request_status VARCHAR(20) NOT NULL DEFAULT 'PENDING'
        CHECK (request_status IN ('PENDING', 'APPROVED', 'REJECTED')),
    submitted_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    reviewed_by UUID REFERENCES public.members(member_id),
    reviewed_at TIMESTAMPTZ,
    rejection_reason TEXT,
    CONSTRAINT uq_pending_user UNIQUE (auth_uid, request_status)
);

-- 4. TABLE: FESTIVALS
CREATE TABLE IF NOT EXISTS public.festivals (
    festival_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    society_id UUID NOT NULL REFERENCES public.society(society_id) ON DELETE RESTRICT,
    festival_name VARCHAR(120) NOT NULL,
    description TEXT,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL CHECK (end_date >= start_date),
    status VARCHAR(20) NOT NULL DEFAULT 'UPCOMING'
        CHECK (status IN ('UPCOMING', 'ONGOING', 'COMPLETED', 'CANCELLED')),
    cover_image_url TEXT,
    created_by UUID NOT NULL REFERENCES public.members(member_id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- 5. TABLE: FESTIVAL_EVENTS
CREATE TABLE IF NOT EXISTS public.festival_events (
    event_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    festival_id UUID NOT NULL REFERENCES public.festivals(festival_id) ON DELETE RESTRICT,
    event_name VARCHAR(120) NOT NULL,
    description TEXT,
    event_date DATE NOT NULL,
    event_location VARCHAR(150),
    estimated_budget NUMERIC(12,2) NOT NULL DEFAULT 0.00 CHECK (estimated_budget >= 0),
    created_by UUID NOT NULL REFERENCES public.members(member_id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- 6. TABLE: FUNDS (General vs Dedicated Festival Funds)
CREATE TABLE IF NOT EXISTS public.funds (
    fund_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    society_id UUID NOT NULL REFERENCES public.society(society_id) ON DELETE RESTRICT,
    fund_name VARCHAR(120) NOT NULL,
    fund_type VARCHAR(20) NOT NULL CHECK (fund_type IN ('GENERAL', 'FESTIVAL')),
    festival_id UUID REFERENCES public.festivals(festival_id) ON DELETE RESTRICT,
    description TEXT,
    opening_balance NUMERIC(12,2) NOT NULL DEFAULT 0.00 CHECK (opening_balance >= 0),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    -- Strict Fund Isolation Constraint:
    -- GENERAL funds must have NULL festival_id; FESTIVAL funds must have NOT NULL festival_id.
    CONSTRAINT chk_fund_type_isolation CHECK (
        (fund_type = 'GENERAL' AND festival_id IS NULL) OR
        (fund_type = 'FESTIVAL' AND festival_id IS NOT NULL)
    ),
    -- Each festival has at most one dedicated fund
    CONSTRAINT uq_festival_fund UNIQUE (festival_id)
);

-- 7. TABLE: CONTRIBUTIONS
CREATE TABLE IF NOT EXISTS public.contributions (
    contribution_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    fund_id UUID NOT NULL REFERENCES public.funds(fund_id) ON DELETE RESTRICT,
    member_id UUID REFERENCES public.members(member_id) ON DELETE RESTRICT, -- Nullable for anonymous donations
    amount NUMERIC(12,2) NOT NULL CHECK (amount > 0),
    contribution_type VARCHAR(50) NOT NULL CHECK (
        contribution_type IN ('MONTHLY_MAINTENANCE', 'GENERAL_DONATION', 'FESTIVAL_CONTRIBUTION', 'SPECIAL_CONTRIBUTION', 'OTHER')
    ),
    payment_method VARCHAR(30) NOT NULL CHECK (
        payment_method IN ('CASH', 'UPI', 'BANK_TRANSFER', 'CHEQUE', 'OTHER')
    ),
    transaction_reference VARCHAR(100),
    payment_date DATE NOT NULL DEFAULT CURRENT_DATE,
    notes TEXT,
    receipt_number VARCHAR(50) NOT NULL UNIQUE,
    attachment_url TEXT,
    created_by UUID NOT NULL REFERENCES public.members(member_id) ON DELETE RESTRICT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    status VARCHAR(20) NOT NULL DEFAULT 'POSTED' CHECK (status IN ('POSTED', 'REVERSED', 'ADJUSTED')),
    -- Prevent duplicate submissions with same reference & amount on same date
    CONSTRAINT uq_idempotent_txn UNIQUE (fund_id, transaction_reference, payment_date, amount)
);

-- 8. TABLE: EXPENSES
CREATE TABLE IF NOT EXISTS public.expenses (
    expense_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    fund_id UUID NOT NULL REFERENCES public.funds(fund_id) ON DELETE RESTRICT,
    event_id UUID REFERENCES public.festival_events(event_id) ON DELETE RESTRICT,
    amount NUMERIC(12,2) NOT NULL CHECK (amount > 0),
    expense_category VARCHAR(50) NOT NULL CHECK (
        expense_category IN (
            'ELECTRICITY', 'CLEANING', 'SECURITY', 'REPAIRS', 
            'DECORATION', 'FOOD', 'SOUND_SYSTEM', 'TRANSPORTATION', 
            'EVENT_ARRANGEMENTS', 'MAINTENANCE', 'PRINTING', 'OTHER'
        )
    ),
    description TEXT NOT NULL,
    vendor_name VARCHAR(120),
    payment_method VARCHAR(30) NOT NULL CHECK (
        payment_method IN ('CASH', 'UPI', 'BANK_TRANSFER', 'CHEQUE', 'OTHER')
    ),
    expense_date DATE NOT NULL DEFAULT CURRENT_DATE,
    bill_image_url TEXT,
    receipt_reference VARCHAR(100),
    created_by UUID NOT NULL REFERENCES public.members(member_id) ON DELETE RESTRICT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    status VARCHAR(20) NOT NULL DEFAULT 'POSTED' CHECK (status IN ('POSTED', 'REVERSED', 'ADJUSTED')),
    correction_reference UUID REFERENCES public.expenses(expense_id)
);

-- 9. TABLE: AUDIT_LOGS (Immutable Activity Ledger)
CREATE TABLE IF NOT EXISTS public.audit_logs (
    log_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    society_id UUID NOT NULL REFERENCES public.society(society_id) ON DELETE RESTRICT,
    member_id UUID REFERENCES public.members(member_id) ON DELETE SET NULL,
    action VARCHAR(50) NOT NULL,
    record_type VARCHAR(50) NOT NULL,
    record_id UUID NOT NULL,
    old_values JSONB,
    new_values JSONB,
    timestamp TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    device_information TEXT
);

-- 10. TABLE: ANNOUNCEMENTS
CREATE TABLE IF NOT EXISTS public.announcements (
    announcement_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    society_id UUID NOT NULL REFERENCES public.society(society_id) ON DELETE RESTRICT,
    title VARCHAR(200) NOT NULL,
    message TEXT NOT NULL,
    attachment_url TEXT,
    created_by UUID NOT NULL REFERENCES public.members(member_id) ON DELETE RESTRICT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- 11. TABLE: REGISTRATION_APPROVALS (Traceable decision records)
CREATE TABLE IF NOT EXISTS public.registration_approvals (
    approval_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    request_id UUID NOT NULL UNIQUE REFERENCES public.registration_requests(request_id) ON DELETE RESTRICT,
    approved_by UUID NOT NULL REFERENCES public.members(member_id) ON DELETE RESTRICT,
    decision VARCHAR(20) NOT NULL CHECK (decision IN ('APPROVED', 'REJECTED')),
    comments TEXT,
    decided_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- ====================================================================
-- INDEXES FOR HIGH-PERFORMANCE SEARCH, REPORTING & FILTERING
-- ====================================================================
CREATE INDEX IF NOT EXISTS idx_members_auth_uid ON public.members(auth_uid);
CREATE INDEX IF NOT EXISTS idx_members_society_id ON public.members(society_id);
CREATE INDEX IF NOT EXISTS idx_funds_society_id ON public.funds(society_id);
CREATE INDEX IF NOT EXISTS idx_funds_festival_id ON public.funds(festival_id);
CREATE INDEX IF NOT EXISTS idx_contributions_fund_id ON public.contributions(fund_id);
CREATE INDEX IF NOT EXISTS idx_contributions_member_id ON public.contributions(member_id);
CREATE INDEX IF NOT EXISTS idx_contributions_payment_date ON public.contributions(payment_date);
CREATE INDEX IF NOT EXISTS idx_expenses_fund_id ON public.expenses(fund_id);
CREATE INDEX IF NOT EXISTS idx_expenses_event_id ON public.expenses(event_id);
CREATE INDEX IF NOT EXISTS idx_expenses_expense_date ON public.expenses(expense_date);
CREATE INDEX IF NOT EXISTS idx_audit_logs_timestamp ON public.audit_logs(timestamp DESC);
CREATE INDEX IF NOT EXISTS idx_registration_requests_status ON public.registration_requests(request_status);
CREATE INDEX IF NOT EXISTS idx_announcements_created_at ON public.announcements(created_at DESC);

-- ====================================================================
-- BUSINESS LOGIC CONSTRAINTS & VALIDATION TRIGGERS
-- ====================================================================

-- A. Validate that an expense assigned to an event matches the festival of the fund
CREATE OR REPLACE FUNCTION public.fn_validate_expense_event_fund()
RETURNS TRIGGER AS $$
DECLARE
    v_fund_festival_id UUID;
    v_event_festival_id UUID;
    v_fund_type VARCHAR(20);
BEGIN
    SELECT fund_type, festival_id INTO v_fund_type, v_fund_festival_id
    FROM public.funds WHERE fund_id = NEW.fund_id;

    IF NEW.event_id IS NOT NULL THEN
        IF v_fund_type = 'GENERAL' THEN
            RAISE EXCEPTION 'General Fund expenses cannot be linked directly to a festival event.';
        END IF;

        SELECT festival_id INTO v_event_festival_id
        FROM public.festival_events WHERE event_id = NEW.event_id;

        IF v_fund_festival_id IS DISTINCT FROM v_event_festival_id THEN
            RAISE EXCEPTION 'The selected event does not belong to the festival tied to this fund.';
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_validate_expense_event_fund ON public.expenses;
CREATE TRIGGER trg_validate_expense_event_fund
BEFORE INSERT OR UPDATE ON public.expenses
FOR EACH ROW EXECUTE FUNCTION public.fn_validate_expense_event_fund();

-- B. Prevent Self-Approval on Registration Requests
CREATE OR REPLACE FUNCTION public.fn_validate_registration_approval()
RETURNS TRIGGER AS $$
DECLARE
    v_applicant_auth_uid UUID;
    v_reviewer_auth_uid UUID;
    v_reviewer_status VARCHAR(20);
BEGIN
    -- Get applicant auth_uid
    SELECT auth_uid INTO v_applicant_auth_uid 
    FROM public.registration_requests 
    WHERE request_id = NEW.request_id;

    -- Get reviewer details
    SELECT auth_uid, membership_status INTO v_reviewer_auth_uid, v_reviewer_status
    FROM public.members 
    WHERE member_id = NEW.approved_by;

    IF v_reviewer_status != 'ACTIVE' THEN
        RAISE EXCEPTION 'Only active members can approve or reject registration requests.';
    END IF;

    IF v_applicant_auth_uid = v_reviewer_auth_uid THEN
        RAISE EXCEPTION 'Self-approval is strictly forbidden. Another active member must approve your request.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_validate_registration_approval ON public.registration_approvals;
CREATE TRIGGER trg_validate_registration_approval
BEFORE INSERT ON public.registration_approvals
FOR EACH ROW EXECUTE FUNCTION public.fn_validate_registration_approval();

-- C. Automatically update registration_requests and create member on APPROVED
CREATE OR REPLACE FUNCTION public.fn_process_registration_decision()
RETURNS TRIGGER AS $$
DECLARE
    v_req RECORD;
BEGIN
    SELECT * INTO v_req FROM public.registration_requests WHERE request_id = NEW.request_id;

    -- Update request status
    UPDATE public.registration_requests
    SET request_status = NEW.decision,
        reviewed_by = NEW.approved_by,
        reviewed_at = NEW.decided_at,
        rejection_reason = NEW.comments
    WHERE request_id = NEW.request_id;

    -- If approved, create member record if not existing
    IF NEW.decision = 'APPROVED' THEN
        INSERT INTO public.members (
            society_id,
            auth_uid,
            full_name,
            phone_number,
            flat_number,
            membership_status,
            joined_at
        ) VALUES (
            v_req.society_id,
            v_req.auth_uid,
            v_req.full_name,
            v_req.phone_number,
            v_req.flat_number,
            'ACTIVE',
            NEW.decided_at
        ) ON CONFLICT (phone_number) DO UPDATE
        SET membership_status = 'ACTIVE',
            flat_number = EXCLUDED.flat_number,
            updated_at = timezone('utc'::text, now());
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_process_registration_decision ON public.registration_approvals;
CREATE TRIGGER trg_process_registration_decision
AFTER INSERT ON public.registration_approvals
FOR EACH ROW EXECUTE FUNCTION public.fn_process_registration_decision();

-- ====================================================================
-- FINANCIAL ACCOUNTING VIEWS (Exact Decimal Engine)
-- ====================================================================

-- 1. Fund Summary View (General & Festival Funds)
CREATE OR REPLACE VIEW public.vw_fund_balances AS
SELECT 
    f.fund_id,
    f.society_id,
    f.fund_name,
    f.fund_type,
    f.festival_id,
    fest.festival_name,
    f.opening_balance,
    COALESCE(c.total_contributions, 0.00) AS total_contributions,
    COALESCE(e.total_expenses, 0.00) AS total_expenses,
    (f.opening_balance + COALESCE(c.total_contributions, 0.00) - COALESCE(e.total_expenses, 0.00)) AS current_balance,
    COALESCE(c.contribution_count, 0) AS contribution_count,
    COALESCE(e.expense_count, 0) AS expense_count,
    f.is_active,
    f.created_at,
    f.updated_at
FROM public.funds f
LEFT JOIN public.festivals fest ON f.festival_id = fest.festival_id
LEFT JOIN (
    SELECT 
        fund_id, 
        SUM(amount) AS total_contributions,
        COUNT(contribution_id) AS contribution_count
    FROM public.contributions 
    WHERE status = 'POSTED'
    GROUP BY fund_id
) c ON f.fund_id = c.fund_id
LEFT JOIN (
    SELECT 
        fund_id, 
        SUM(amount) AS total_expenses,
        COUNT(expense_id) AS expense_count
    FROM public.expenses 
    WHERE status = 'POSTED'
    GROUP BY fund_id
) e ON f.fund_id = e.fund_id;

-- 2. Society Overall Financial Summary View
CREATE OR REPLACE VIEW public.vw_society_financial_summary AS
SELECT 
    s.society_id,
    s.society_name,
    SUM(fb.opening_balance) AS total_opening_balance,
    SUM(fb.total_contributions) AS total_contributions,
    SUM(fb.total_expenses) AS total_expenses,
    SUM(fb.current_balance) AS total_society_balance,
    SUM(CASE WHEN fb.fund_type = 'GENERAL' THEN fb.current_balance ELSE 0 END) AS general_fund_balance,
    SUM(CASE WHEN fb.fund_type = 'FESTIVAL' THEN fb.current_balance ELSE 0 END) AS festival_fund_balance,
    COUNT(DISTINCT m.member_id) FILTER (WHERE m.membership_status = 'ACTIVE') AS active_members_count
FROM public.society s
LEFT JOIN public.vw_fund_balances fb ON s.society_id = fb.society_id AND fb.is_active = TRUE
LEFT JOIN public.members m ON s.society_id = m.society_id
GROUP BY s.society_id, s.society_name;
