-- ====================================================================
-- RAMSEVA — RAMDEVRA RESIDENTIAL SOCIETY
-- Migration: 20261126_000004_society_common_password.sql
-- 1. Add common society password hash to society configuration
-- 2. Stored procedure for verifying common society password
-- 3. Stored procedure for direct resident registration with society password
-- 4. Stored procedure for resident login with mobile and society password
-- ====================================================================

CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- 1. ADD SOCIETY COMMON PASSWORD HASH COLUMN
ALTER TABLE public.society
ADD COLUMN IF NOT EXISTS society_password_hash TEXT DEFAULT '89377b5825c22ad3f3e720211e35cccd7970904f60267f1708c3bd2eb8b770fb';

UPDATE public.society
SET society_password_hash = '89377b5825c22ad3f3e720211e35cccd7970904f60267f1708c3bd2eb8b770fb'
WHERE society_password_hash IS NULL;

-- 2. VERIFY SOCIETY PASSWORD FUNCTION
CREATE OR REPLACE FUNCTION public.verify_society_password(p_password TEXT)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_stored_hash TEXT;
    v_computed_hash TEXT;
    v_salt CONSTANT TEXT := 'ramseva_salt_ramdevra_2026';
BEGIN
    SELECT society_password_hash INTO v_stored_hash FROM public.society LIMIT 1;
    IF v_stored_hash IS NULL THEN
        v_stored_hash := '89377b5825c22ad3f3e720211e35cccd7970904f60267f1708c3bd2eb8b770fb';
    END IF;

    v_computed_hash := encode(digest(v_salt || trim(p_password), 'sha256'), 'hex');
    RETURN (v_computed_hash = v_stored_hash);
END;
$$;

-- 3. REGISTER MEMBER WITH SOCIETY PASSWORD
CREATE OR REPLACE FUNCTION public.register_member_with_society_password(
    p_full_name TEXT,
    p_flat_number TEXT,
    p_phone TEXT,
    p_email TEXT DEFAULT NULL,
    p_password TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_society_id UUID;
    v_existing_member public.members%ROWTYPE;
    v_new_member public.members%ROWTYPE;
    v_clean_phone TEXT;
BEGIN
    -- 1. Validate inputs
    IF trim(p_full_name) = '' THEN
        RAISE EXCEPTION 'Full name is required.';
    END IF;
    IF trim(p_flat_number) = '' THEN
        RAISE EXCEPTION 'Flat number is required.';
    END IF;
    IF trim(p_phone) = '' THEN
        RAISE EXCEPTION 'Mobile phone number is required.';
    END IF;

    -- 2. Verify society common password
    IF p_password IS NULL OR NOT public.verify_society_password(p_password) THEN
        RAISE EXCEPTION 'Incorrect society password. Please contact the society committee.';
    END IF;

    -- 3. Clean and normalize phone number
    v_clean_phone := regexp_replace(trim(p_phone), '[^0-9+]', '', 'g');
    IF NOT (v_clean_phone ~ '^\+?[0-9]{10,13}$') THEN
        RAISE EXCEPTION 'Invalid phone number format. Enter a valid 10-digit mobile number.';
    END IF;

    -- 4. Get society id
    SELECT society_id INTO v_society_id FROM public.society LIMIT 1;
    IF v_society_id IS NULL THEN
        RAISE EXCEPTION 'Society configuration not initialized.';
    END IF;

    -- 5. Check if member already registered with this phone
    SELECT * INTO v_existing_member FROM public.members WHERE phone_number = v_clean_phone LIMIT 1;
    IF v_existing_member.member_id IS NOT NULL THEN
        IF v_existing_member.membership_status = 'ACTIVE' THEN
            -- Update details if flat or name provided
            UPDATE public.members
            SET full_name = trim(p_full_name),
                flat_number = trim(p_flat_number),
                email = CASE WHEN trim(COALESCE(p_email, '')) <> '' THEN trim(p_email) ELSE email END,
                updated_at = timezone('utc'::text, now())
            WHERE member_id = v_existing_member.member_id
            RETURNING * INTO v_new_member;

            RETURN to_jsonb(v_new_member);
        ELSE
            RAISE EXCEPTION 'Membership for this mobile number is not active (Status: %).', v_existing_member.membership_status;
        END IF;
    END IF;

    -- 6. Insert new active member
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
        gen_random_uuid(),
        trim(p_full_name),
        v_clean_phone,
        trim(p_flat_number),
        trim(p_email),
        'ACTIVE',
        timezone('utc'::text, now())
    ) RETURNING * INTO v_new_member;

    -- 7. Audit log entry
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
        'MEMBER_REGISTERED_WITH_PASSWORD',
        'members',
        v_new_member.member_id,
        jsonb_build_object(
            'full_name', v_new_member.full_name,
            'flat_number', v_new_member.flat_number,
            'phone', v_new_member.phone_number,
            'method', 'SOCIETY_COMMON_PASSWORD'
        ),
        timezone('utc'::text, now())
    );

    RETURN to_jsonb(v_new_member);
END;
$$;

-- 4. LOGIN MEMBER WITH MOBILE AND SOCIETY PASSWORD
CREATE OR REPLACE FUNCTION public.login_member_with_society_password(
    p_phone TEXT,
    p_password TEXT
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_clean_phone TEXT;
    v_member public.members%ROWTYPE;
BEGIN
    -- 1. Verify society password
    IF p_password IS NULL OR NOT public.verify_society_password(p_password) THEN
        RAISE EXCEPTION 'Incorrect society password. Please contact the society committee.';
    END IF;

    -- 2. Clean phone number
    v_clean_phone := regexp_replace(trim(p_phone), '[^0-9+]', '', 'g');

    -- 3. Look up member (match exact or without leading country code)
    SELECT * INTO v_member
    FROM public.members
    WHERE phone_number = v_clean_phone
       OR phone_number = '+91' || v_clean_phone
       OR ('+91' || regexp_replace(phone_number, '^\+91', '')) = ('+91' || regexp_replace(v_clean_phone, '^\+91', ''))
    LIMIT 1;

    IF v_member.member_id IS NULL THEN
        RAISE EXCEPTION 'Mobile number not registered in society records. Please register as a new resident.';
    END IF;

    IF v_member.membership_status <> 'ACTIVE' THEN
        RAISE EXCEPTION 'Membership status is %. Please contact society committee.', v_member.membership_status;
    END IF;

    RETURN to_jsonb(v_member);
END;
$$;

-- 5. GRANT PERMISSIONS TO ANON AND AUTHENTICATED
GRANT EXECUTE ON FUNCTION public.verify_society_password(TEXT) TO anon, authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.register_member_with_society_password(TEXT, TEXT, TEXT, TEXT, TEXT) TO anon, authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.login_member_with_society_password(TEXT, TEXT) TO anon, authenticated, service_role;
