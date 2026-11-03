-- ====================================================================
-- RAMSEVA — RAMDEVRA RESIDENTIAL SOCIETY
-- Migration: 20261102_000003_ramseva_init_and_bootstrap.sql
-- 1. Rebrand to Ramdevra Society
-- 2. Clean demo seed records & enforce ₹0 opening balance
-- 3. Enable Supabase Realtime publication on all ledger tables
-- 4. Implement secure First-Member Bootstrap stored procedure
-- ====================================================================

-- 1. REBRAND SOCIETY
UPDATE public.society
SET society_name = 'Ramdevra Society',
    email = 'ramdevra.society@gmail.com',
    updated_at = timezone('utc'::text, now())
WHERE society_id = '00000000-0000-0000-0000-000000000001';

-- 2. CLEAN UP ANY HISTORICAL DEMO SEED RECORDS
-- Only remove known hardcoded demo UUIDs to protect genuine user data
DELETE FROM public.registration_approvals WHERE approval_id IN ('99999999-9999-9999-9999-999999999001');
DELETE FROM public.registration_requests WHERE request_id IN ('88888888-8888-8888-8888-888888888000', '88888888-8888-8888-8888-888888888001');
DELETE FROM public.announcements WHERE announcement_id IN ('77777777-7777-7777-7777-777777777001', '77777777-7777-7777-7777-777777777002');
DELETE FROM public.expenses WHERE expense_id IN ('66666666-6666-6666-6666-666666666001', '66666666-6666-6666-6666-666666666002');
DELETE FROM public.contributions WHERE contribution_id IN (
    '55555555-5555-5555-5555-555555555001',
    '55555555-5555-5555-5555-555555555002',
    '55555555-5555-5555-5555-555555555003',
    '55555555-5555-5555-5555-555555555004'
);
DELETE FROM public.festival_events WHERE event_id IN ('44444444-4444-4444-4444-444444444001', '44444444-4444-4444-4444-444444444002');
DELETE FROM public.funds WHERE fund_id IN ('22222222-2222-2222-2222-222222222002', '22222222-2222-2222-2222-222222222003');
DELETE FROM public.festivals WHERE festival_id IN ('33333333-3333-3333-3333-333333333001', '33333333-3333-3333-3333-333333333002');
DELETE FROM public.members WHERE member_id IN (
    '11111111-1111-1111-1111-111111111001',
    '11111111-1111-1111-1111-111111111002',
    '11111111-1111-1111-1111-111111111003'
);
DELETE FROM public.audit_logs WHERE log_id IN (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa1',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa2',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa3',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa4'
);

-- Set General Fund opening balance to strictly ₹0.00
UPDATE public.funds
SET opening_balance = 0.00,
    updated_at = timezone('utc'::text, now())
WHERE fund_id = '22222222-2222-2222-2222-222222222001';

-- 3. ENABLE SUPABASE REALTIME REPLICATION FOR MULTI-DEVICE SYNCHRONISATION
DO $$
BEGIN
    BEGIN
        ALTER PUBLICATION supabase_realtime ADD TABLE public.contributions;
    EXCEPTION WHEN duplicate_object THEN NULL;
    END;
    BEGIN
        ALTER PUBLICATION supabase_realtime ADD TABLE public.expenses;
    EXCEPTION WHEN duplicate_object THEN NULL;
    END;
    BEGIN
        ALTER PUBLICATION supabase_realtime ADD TABLE public.funds;
    EXCEPTION WHEN duplicate_object THEN NULL;
    END;
    BEGIN
        ALTER PUBLICATION supabase_realtime ADD TABLE public.members;
    EXCEPTION WHEN duplicate_object THEN NULL;
    END;
    BEGIN
        ALTER PUBLICATION supabase_realtime ADD TABLE public.festivals;
    EXCEPTION WHEN duplicate_object THEN NULL;
    END;
    BEGIN
        ALTER PUBLICATION supabase_realtime ADD TABLE public.festival_events;
    EXCEPTION WHEN duplicate_object THEN NULL;
    END;
    BEGIN
        ALTER PUBLICATION supabase_realtime ADD TABLE public.announcements;
    EXCEPTION WHEN duplicate_object THEN NULL;
    END;
    BEGIN
        ALTER PUBLICATION supabase_realtime ADD TABLE public.registration_requests;
    EXCEPTION WHEN duplicate_object THEN NULL;
    END;
    BEGIN
        ALTER PUBLICATION supabase_realtime ADD TABLE public.registration_approvals;
    EXCEPTION WHEN duplicate_object THEN NULL;
    END;
END $$;

-- 4. SECURE FIRST-MEMBER BOOTSTRAP FUNCTION
-- This procedure safely bootstraps the first resident when active_members_count is 0.
-- Once 1 active member exists, this function immediately locks out and rejects any call.
CREATE OR REPLACE FUNCTION public.bootstrap_first_society_member(
    p_full_name TEXT,
    p_flat_number TEXT,
    p_email TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_active_count INT;
    v_auth_uid UUID;
    v_phone TEXT;
    v_society_id UUID;
    v_new_member public.members%ROWTYPE;
BEGIN
    -- 1. Ensure user is authenticated via Supabase Auth
    v_auth_uid := auth.uid();
    IF v_auth_uid IS NULL THEN
        RAISE EXCEPTION 'Authentication required. Complete phone OTP verification first.';
    END IF;

    -- 2. Verify no active members exist yet (Strict Zero-Member Gate)
    SELECT COUNT(*) INTO v_active_count FROM public.members WHERE membership_status = 'ACTIVE';
    IF v_active_count > 0 THEN
        RAISE EXCEPTION 'Bootstrap is disabled: The society already has active members. Subsequent residents must be approved by an existing active resident.';
    END IF;

    -- 3. Validate inputs
    IF trim(p_full_name) = '' THEN
        RAISE EXCEPTION 'Full name is required.';
    END IF;
    IF trim(p_flat_number) = '' THEN
        RAISE EXCEPTION 'Flat number is required.';
    END IF;

    -- 4. Resolve society ID
    SELECT society_id INTO v_society_id FROM public.society LIMIT 1;
    IF v_society_id IS NULL THEN
        RAISE EXCEPTION 'Society record not initialized.';
    END IF;

    -- 5. Extract authenticated phone
    v_phone := (auth.jwt() ->> 'phone');
    IF v_phone IS NULL OR trim(v_phone) = '' THEN
        SELECT phone INTO v_phone FROM auth.users WHERE id = v_auth_uid;
    END IF;
    IF v_phone IS NULL OR trim(v_phone) = '' THEN
        v_phone := 'PHONE_VERIFIED';
    END IF;

    -- 6. Insert founding active member
    INSERT INTO public.members (
        society_id,
        auth_uid,
        full_name,
        phone_number,
        flat_number,
        email,
        membership_status,
        joined_at
    ) VALUES (
        v_society_id,
        v_auth_uid,
        trim(p_full_name),
        v_phone,
        trim(p_flat_number),
        trim(p_email),
        'ACTIVE',
        timezone('utc'::text, now())
    ) RETURNING * INTO v_new_member;

    -- 7. Audit log
    INSERT INTO public.audit_logs (
        society_id,
        member_id,
        action,
        record_type,
        record_id,
        new_values,
        timestamp
    ) VALUES (
        v_society_id,
        v_new_member.member_id,
        'FOUNDING_MEMBER_BOOTSTRAPPED',
        'members',
        v_new_member.member_id,
        jsonb_build_object(
            'full_name', v_new_member.full_name,
            'flat_number', v_new_member.flat_number,
            'phone', v_new_member.phone_number,
            'notice', 'First resident bootstrap completed. One-time bootstrap mechanism is now locked.'
        ),
        timezone('utc'::text, now())
    );

    RETURN to_jsonb(v_new_member);
END;
$$;
