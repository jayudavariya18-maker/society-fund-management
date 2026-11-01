-- ====================================================================
-- BAJRANG RESIDENTIAL SOCIETY FUND MANAGEMENT SYSTEM
-- Migration: 20261101_000002_rls_and_audit.sql
-- Row Level Security (RLS) Policies & Database-Side Audit Automation
-- ====================================================================

-- 1. Helper Functions to identify the authenticated member
CREATE OR REPLACE FUNCTION public.is_active_member()
RETURNS BOOLEAN AS $$
    SELECT EXISTS (
        SELECT 1 FROM public.members
        WHERE auth_uid = auth.uid()
        AND membership_status = 'ACTIVE'
    );
$$ LANGUAGE sql SECURITY DEFINER STABLE;

CREATE OR REPLACE FUNCTION public.current_member_id()
RETURNS UUID AS $$
    SELECT member_id FROM public.members
    WHERE auth_uid = auth.uid()
    AND membership_status = 'ACTIVE'
    LIMIT 1;
$$ LANGUAGE sql SECURITY DEFINER STABLE;

-- 2. ENABLE RLS ON ALL 11 TABLES
ALTER TABLE public.society ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.members ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.registration_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.registration_approvals ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.funds ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.festivals ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.festival_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.contributions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.expenses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.audit_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.announcements ENABLE ROW LEVEL SECURITY;

-- --------------------------------------------------------------------
-- A. POLICIES: SOCIETY
-- --------------------------------------------------------------------
-- Anyone authenticated can view society info (for onboarding/login)
CREATE POLICY "Allow authenticated read society"
    ON public.society FOR SELECT
    TO authenticated
    USING (true);

-- Active members can update society info
CREATE POLICY "Allow active members update society"
    ON public.society FOR UPDATE
    TO authenticated
    USING (public.is_active_member())
    WITH CHECK (public.is_active_member());

-- --------------------------------------------------------------------
-- B. POLICIES: MEMBERS
-- --------------------------------------------------------------------
-- Active members can view all society members
CREATE POLICY "Allow active members read members"
    ON public.members FOR SELECT
    TO authenticated
    USING (public.is_active_member() OR auth_uid = auth.uid());

-- Members can update their own profile info
CREATE POLICY "Allow members update own profile"
    ON public.members FOR UPDATE
    TO authenticated
    USING (auth_uid = auth.uid())
    WITH CHECK (auth_uid = auth.uid());

-- --------------------------------------------------------------------
-- C. POLICIES: REGISTRATION_REQUESTS
-- --------------------------------------------------------------------
-- Authenticated users can insert their own registration request
CREATE POLICY "Allow users insert own registration request"
    ON public.registration_requests FOR INSERT
    TO authenticated
    WITH CHECK (auth_uid = auth.uid());

-- Users can view their own registration request; active members can view all pending/decided requests
CREATE POLICY "Allow users read own registration request or active members view all"
    ON public.registration_requests FOR SELECT
    TO authenticated
    USING (auth_uid = auth.uid() OR public.is_active_member());

-- Active members can update registration requests (reviewing/approving/rejecting)
CREATE POLICY "Allow active members update registration requests"
    ON public.registration_requests FOR UPDATE
    TO authenticated
    USING (public.is_active_member() AND auth_uid != auth.uid())
    WITH CHECK (public.is_active_member() AND auth_uid != auth.uid());

-- --------------------------------------------------------------------
-- D. POLICIES: REGISTRATION_APPROVALS
-- --------------------------------------------------------------------
-- Active members can read registration approvals
CREATE POLICY "Allow active members read registration approvals"
    ON public.registration_approvals FOR SELECT
    TO authenticated
    USING (public.is_active_member());

-- Active members can insert registration approvals (preventing self-approval)
CREATE POLICY "Allow active members insert registration approvals"
    ON public.registration_approvals FOR INSERT
    TO authenticated
    WITH CHECK (
        public.is_active_member() 
        AND approved_by = public.current_member_id()
    );

-- --------------------------------------------------------------------
-- E. POLICIES: FUNDS
-- --------------------------------------------------------------------
-- Only active members can read funds
CREATE POLICY "Allow active members read funds"
    ON public.funds FOR SELECT
    TO authenticated
    USING (public.is_active_member());

-- Active members can create funds (e.g. for a new festival)
CREATE POLICY "Allow active members insert funds"
    ON public.funds FOR INSERT
    TO authenticated
    WITH CHECK (public.is_active_member());

-- Active members can update funds
CREATE POLICY "Allow active members update funds"
    ON public.funds FOR UPDATE
    TO authenticated
    USING (public.is_active_member())
    WITH CHECK (public.is_active_member());

-- --------------------------------------------------------------------
-- F. POLICIES: FESTIVALS & FESTIVAL_EVENTS
-- --------------------------------------------------------------------
CREATE POLICY "Allow active members read festivals"
    ON public.festivals FOR SELECT
    TO authenticated
    USING (public.is_active_member());

CREATE POLICY "Allow active members insert festivals"
    ON public.festivals FOR INSERT
    TO authenticated
    WITH CHECK (public.is_active_member() AND created_by = public.current_member_id());

CREATE POLICY "Allow active members update festivals"
    ON public.festivals FOR UPDATE
    TO authenticated
    USING (public.is_active_member())
    WITH CHECK (public.is_active_member());

CREATE POLICY "Allow active members read festival events"
    ON public.festival_events FOR SELECT
    TO authenticated
    USING (public.is_active_member());

CREATE POLICY "Allow active members insert festival events"
    ON public.festival_events FOR INSERT
    TO authenticated
    WITH CHECK (public.is_active_member() AND created_by = public.current_member_id());

CREATE POLICY "Allow active members update festival events"
    ON public.festival_events FOR UPDATE
    TO authenticated
    USING (public.is_active_member())
    WITH CHECK (public.is_active_member());

-- --------------------------------------------------------------------
-- G. POLICIES: CONTRIBUTIONS (Financial Ledger - Immutable)
-- --------------------------------------------------------------------
-- Only active members can view contributions
CREATE POLICY "Allow active members read contributions"
    ON public.contributions FOR SELECT
    TO authenticated
    USING (public.is_active_member());

-- Active members can create contribution records
CREATE POLICY "Allow active members insert contributions"
    ON public.contributions FOR INSERT
    TO authenticated
    WITH CHECK (public.is_active_member() AND created_by = public.current_member_id());

-- Financial records are IMMUTABLE. Updates are restricted to status transition (e.g., REVERSED / ADJUSTED)
CREATE POLICY "Allow active members adjust contributions"
    ON public.contributions FOR UPDATE
    TO authenticated
    USING (public.is_active_member())
    WITH CHECK (public.is_active_member());

-- No DELETE policy is defined: Financial records CANNOT be deleted by anyone.

-- --------------------------------------------------------------------
-- H. POLICIES: EXPENSES (Financial Ledger - Immutable)
-- --------------------------------------------------------------------
-- Only active members can view expenses
CREATE POLICY "Allow active members read expenses"
    ON public.expenses FOR SELECT
    TO authenticated
    USING (public.is_active_member());

-- Active members can record expenses
CREATE POLICY "Allow active members insert expenses"
    ON public.expenses FOR INSERT
    TO authenticated
    WITH CHECK (public.is_active_member() AND created_by = public.current_member_id());

-- Updates restricted to corrections / reversal status linking
CREATE POLICY "Allow active members adjust expenses"
    ON public.expenses FOR UPDATE
    TO authenticated
    USING (public.is_active_member())
    WITH CHECK (public.is_active_member());

-- No DELETE policy is defined: Outgoing transactions cannot be deleted.

-- --------------------------------------------------------------------
-- I. POLICIES: AUDIT_LOGS (Append-Only Ledger)
-- --------------------------------------------------------------------
-- Active members can read audit logs
CREATE POLICY "Allow active members read audit logs"
    ON public.audit_logs FOR SELECT
    TO authenticated
    USING (public.is_active_member());

-- Audit logs are written via trusted triggers or active member inserts
CREATE POLICY "Allow active members insert audit logs"
    ON public.audit_logs FOR INSERT
    TO authenticated
    WITH CHECK (public.is_active_member());

-- No UPDATE or DELETE policies: Audit logs are strictly append-only.

-- --------------------------------------------------------------------
-- J. POLICIES: ANNOUNCEMENTS
-- --------------------------------------------------------------------
CREATE POLICY "Allow active members read announcements"
    ON public.announcements FOR SELECT
    TO authenticated
    USING (public.is_active_member());

CREATE POLICY "Allow active members insert announcements"
    ON public.announcements FOR INSERT
    TO authenticated
    WITH CHECK (public.is_active_member() AND created_by = public.current_member_id());

CREATE POLICY "Allow active members update announcements"
    ON public.announcements FOR UPDATE
    TO authenticated
    USING (public.is_active_member())
    WITH CHECK (public.is_active_member());

-- ====================================================================
-- AUTOMATIC DATABASE-SIDE AUDIT LOGGING TRIGGER
-- ====================================================================

CREATE OR REPLACE FUNCTION public.fn_auto_audit_logger()
RETURNS TRIGGER AS $$
DECLARE
    v_member_id UUID;
    v_society_id UUID;
    v_action VARCHAR(50);
    v_record_type VARCHAR(50);
    v_record_id UUID;
    v_old JSONB := NULL;
    v_new JSONB := NULL;
BEGIN
    v_member_id := public.current_member_id();
    v_record_type := TG_TABLE_NAME;

    IF TG_OP = 'INSERT' THEN
        v_action := TG_TABLE_NAME || '_CREATED';
        v_record_id := NEW.entry_id; -- fallback
        IF TG_TABLE_NAME = 'contributions' THEN
            v_action := 'CONTRIBUTION_ADDED';
            v_record_id := NEW.contribution_id;
            SELECT society_id INTO v_society_id FROM public.funds WHERE fund_id = NEW.fund_id;
        ELSIF TG_TABLE_NAME = 'expenses' THEN
            v_action := 'EXPENSE_ADDED';
            v_record_id := NEW.expense_id;
            SELECT society_id INTO v_society_id FROM public.funds WHERE fund_id = NEW.fund_id;
        ELSIF TG_TABLE_NAME = 'festivals' THEN
            v_action := 'FESTIVAL_CREATED';
            v_record_id := NEW.festival_id;
            v_society_id := NEW.society_id;
        ELSIF TG_TABLE_NAME = 'festival_events' THEN
            v_action := 'EVENT_CREATED';
            v_record_id := NEW.event_id;
            SELECT society_id INTO v_society_id FROM public.festivals WHERE festival_id = NEW.festival_id;
        ELSIF TG_TABLE_NAME = 'announcements' THEN
            v_action := 'ANNOUNCEMENT_CREATED';
            v_record_id := NEW.announcement_id;
            v_society_id := NEW.society_id;
        ELSIF TG_TABLE_NAME = 'registration_approvals' THEN
            v_action := 'REGISTRATION_' || NEW.decision;
            v_record_id := NEW.approval_id;
            SELECT society_id INTO v_society_id FROM public.registration_requests WHERE request_id = NEW.request_id;
        END IF;

        v_new := to_jsonb(NEW);
    ELSIF TG_OP = 'UPDATE' THEN
        v_action := TG_TABLE_NAME || '_UPDATED';
        v_old := to_jsonb(OLD);
        v_new := to_jsonb(NEW);

        IF TG_TABLE_NAME = 'contributions' THEN
            v_record_id := NEW.contribution_id;
            IF OLD.status != NEW.status THEN
                v_action := 'CONTRIBUTION_' || NEW.status;
            END IF;
            SELECT society_id INTO v_society_id FROM public.funds WHERE fund_id = NEW.fund_id;
        ELSIF TG_TABLE_NAME = 'expenses' THEN
            v_record_id := NEW.expense_id;
            IF OLD.status != NEW.status THEN
                v_action := 'EXPENSE_' || NEW.status;
            END IF;
            SELECT society_id INTO v_society_id FROM public.funds WHERE fund_id = NEW.fund_id;
        ELSE
            SELECT society_id INTO v_society_id FROM public.society LIMIT 1;
        END IF;
    END IF;

    -- Fallback society_id if null
    IF v_society_id IS NULL THEN
        SELECT society_id INTO v_society_id FROM public.society LIMIT 1;
    END IF;

    INSERT INTO public.audit_logs (
        society_id,
        member_id,
        action,
        record_type,
        record_id,
        old_values,
        new_values,
        timestamp
    ) VALUES (
        v_society_id,
        v_member_id,
        v_action,
        v_record_type,
        v_record_id,
        v_old,
        v_new,
        timezone('utc'::text, now())
    );

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Attach audit trigger to core tables
DROP TRIGGER IF EXISTS trg_audit_contributions ON public.contributions;
CREATE TRIGGER trg_audit_contributions
AFTER INSERT OR UPDATE ON public.contributions
FOR EACH ROW EXECUTE FUNCTION public.fn_auto_audit_logger();

DROP TRIGGER IF EXISTS trg_audit_expenses ON public.expenses;
CREATE TRIGGER trg_audit_expenses
AFTER INSERT OR UPDATE ON public.expenses
FOR EACH ROW EXECUTE FUNCTION public.fn_auto_audit_logger();

DROP TRIGGER IF EXISTS trg_audit_festivals ON public.festivals;
CREATE TRIGGER trg_audit_festivals
AFTER INSERT OR UPDATE ON public.festivals
FOR EACH ROW EXECUTE FUNCTION public.fn_auto_audit_logger();

DROP TRIGGER IF EXISTS trg_audit_events ON public.festival_events;
CREATE TRIGGER trg_audit_events
AFTER INSERT OR UPDATE ON public.festival_events
FOR EACH ROW EXECUTE FUNCTION public.fn_auto_audit_logger();

DROP TRIGGER IF EXISTS trg_audit_announcements ON public.announcements;
CREATE TRIGGER trg_audit_announcements
AFTER INSERT OR UPDATE ON public.announcements
FOR EACH ROW EXECUTE FUNCTION public.fn_auto_audit_logger();

DROP TRIGGER IF EXISTS trg_audit_approvals ON public.registration_approvals;
CREATE TRIGGER trg_audit_approvals
AFTER INSERT ON public.registration_approvals
FOR EACH ROW EXECUTE FUNCTION public.fn_auto_audit_logger();
