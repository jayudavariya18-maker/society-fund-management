-- ====================================================================
-- BAJRANG RESIDENTIAL SOCIETY FUND MANAGEMENT SYSTEM
-- Seed Data: supabase/seed.sql
-- Realistic Initial Society Records, Funds, Festivals & Audit Records
-- ====================================================================

-- 1. Insert Society
INSERT INTO public.society (
    society_id, society_name, address, city, state, pincode, contact_number, email
) VALUES (
    '00000000-0000-0000-0000-000000000001',
    'Bajrang Heights Co-Operative Housing Society',
    'Plot 42-45, Maruti Nandan Marg, Satellite',
    'Ahmedabad',
    'Gujarat',
    '380015',
    '+919876543210',
    'bajrang.heights.society@gmail.com'
) ON CONFLICT (society_id) DO NOTHING;

-- 2. Insert Active Founding Members
INSERT INTO public.members (
    member_id, society_id, auth_uid, full_name, phone_number, flat_number, email, membership_status, joined_at
) VALUES 
(
    '11111111-1111-1111-1111-111111111001',
    '00000000-0000-0000-0000-000000000001',
    'aaaaaaa1-0000-0000-0000-000000000001',
    'Rajeshbhai Patel',
    '+919825000001',
    'A-402',
    'rajesh.patel@gmail.com',
    'ACTIVE',
    '2025-01-01 10:00:00+05:30'
),
(
    '11111111-1111-1111-1111-111111111002',
    '00000000-0000-0000-0000-000000000001',
    'aaaaaaa2-0000-0000-0000-000000000002',
    'Amitkumar Shah',
    '+919825000002',
    'B-201',
    'amit.shah@gmail.com',
    'ACTIVE',
    '2025-01-01 10:00:00+05:30'
),
(
    '11111111-1111-1111-1111-111111111003',
    '00000000-0000-0000-0000-000000000001',
    'aaaaaaa3-0000-0000-0000-000000000003',
    'Meenaben Trivedi',
    '+919825000003',
    'C-104',
    'meena.trivedi@gmail.com',
    'ACTIVE',
    '2025-01-15 11:30:00+05:30'
) ON CONFLICT (phone_number) DO NOTHING;

-- 3. Insert Festivals
INSERT INTO public.festivals (
    festival_id, society_id, festival_name, description, start_date, end_date, status, created_by
) VALUES
(
    '33333333-3333-3333-3333-333333333001',
    '00000000-0000-0000-0000-000000000001',
    'Navratri Mahotsav 2026',
    '9 Days of Dandiya Raas, Garba & Aarti celebration with resident community',
    '2026-10-10',
    '2026-10-19',
    'UPCOMING',
    '11111111-1111-1111-1111-111111111001'
),
(
    '33333333-3333-3333-3333-333333333002',
    '00000000-0000-0000-0000-000000000001',
    'Diwali Snehamilan 2026',
    'New Year Annakut, Deepotsav & Society Annual Community Dinner',
    '2026-11-08',
    '2026-11-10',
    'UPCOMING',
    '11111111-1111-1111-1111-111111111002'
) ON CONFLICT (festival_id) DO NOTHING;

-- 4. Insert Festival Events
INSERT INTO public.festival_events (
    event_id, festival_id, event_name, description, event_date, event_location, estimated_budget, created_by
) VALUES
(
    '44444444-4444-4444-4444-444444444001',
    '33333333-3333-3333-3333-333333333001',
    'Grand Garba Night & Orchestra',
    'Live Gujarati folk band and traditional sound arrangement',
    '2026-10-15',
    'Central Society Lawn',
    35000.00,
    '11111111-1111-1111-1111-111111111001'
),
(
    '44444444-4444-4444-4444-444444444002',
    '33333333-3333-3333-3333-333333333001',
    'Maha Aarti, Hawan & Mahaprasad',
    'Ashtami sacred fire and community feast',
    '2026-10-18',
    'Community Hall',
    25000.00,
    '11111111-1111-1111-1111-111111111003'
) ON CONFLICT (event_id) DO NOTHING;

-- 5. Insert Funds (Strict Isolation between GENERAL and FESTIVAL)
INSERT INTO public.funds (
    fund_id, society_id, fund_name, fund_type, festival_id, description, opening_balance, is_active
) VALUES
(
    '22222222-2222-2222-2222-222222222001',
    '00000000-0000-0000-0000-000000000001',
    'General Society Maintenance Fund',
    'GENERAL',
    NULL,
    'Primary operational fund for society security, lift maintenance, common electricity, and cleanliness.',
    150000.00,
    TRUE
),
(
    '22222222-2222-2222-2222-222222222002',
    '00000000-0000-0000-0000-000000000001',
    'Navratri Mahotsav 2026 Fund',
    'FESTIVAL',
    '33333333-3333-3333-3333-333333333001',
    'Dedicated fund for Navratri 2026 orchestra, sound, lights, prasad and prizes.',
    0.00,
    TRUE
),
(
    '22222222-2222-2222-2222-222222222003',
    '00000000-0000-0000-0000-000000000001',
    'Diwali Snehamilan 2026 Fund',
    'FESTIVAL',
    '33333333-3333-3333-3333-333333333002',
    'Dedicated fund for Diwali community lights and dinner.',
    0.00,
    TRUE
) ON CONFLICT (fund_id) DO NOTHING;

-- 6. Insert Posted Contributions (Receipts)
INSERT INTO public.contributions (
    contribution_id, fund_id, member_id, amount, contribution_type, payment_method,
    transaction_reference, payment_date, notes, receipt_number, created_by, status
) VALUES
(
    '55555555-5555-5555-5555-555555555001',
    '22222222-2222-2222-2222-222222222001',
    '11111111-1111-1111-1111-111111111001',
    3000.00,
    'MONTHLY_MAINTENANCE',
    'UPI',
    'UPI/261001/498213',
    '2026-10-01',
    'October 2026 monthly maintenance for Flat A-402',
    'REC-202610-0001',
    '11111111-1111-1111-1111-111111111001',
    'POSTED'
),
(
    '55555555-5555-5555-5555-555555555002',
    '22222222-2222-2222-2222-222222222001',
    '11111111-1111-1111-1111-111111111002',
    3000.00,
    'MONTHLY_MAINTENANCE',
    'BANK_TRANSFER',
    'NEFT/AXIS/998124',
    '2026-10-02',
    'October 2026 monthly maintenance for Flat B-201',
    'REC-202610-0002',
    '11111111-1111-1111-1111-111111111002',
    'POSTED'
),
(
    '55555555-5555-5555-5555-555555555003',
    '22222222-2222-2222-2222-222222222002',
    '11111111-1111-1111-1111-111111111001',
    5000.00,
    'FESTIVAL_CONTRIBUTION',
    'UPI',
    'UPI/261005/778120',
    '2026-10-05',
    'Navratri voluntary contribution from Flat A-402',
    'REC-202610-0003',
    '11111111-1111-1111-1111-111111111001',
    'POSTED'
),
(
    '55555555-5555-5555-5555-555555555004',
    '22222222-2222-2222-2222-222222222002',
    '11111111-1111-1111-1111-111111111003',
    5000.00,
    'FESTIVAL_CONTRIBUTION',
    'CASH',
    'CASH-REC-01',
    '2026-10-06',
    'Navratri voluntary contribution from Flat C-104',
    'REC-202610-0004',
    '11111111-1111-1111-1111-111111111003',
    'POSTED'
) ON CONFLICT (receipt_number) DO NOTHING;

-- 7. Insert Posted Expenses
INSERT INTO public.expenses (
    expense_id, fund_id, event_id, amount, expense_category, description,
    vendor_name, payment_method, expense_date, created_by, status
) VALUES
(
    '66666666-6666-6666-6666-666666666001',
    '22222222-2222-2222-2222-222222222001',
    NULL,
    8500.00,
    'ELECTRICITY',
    'Torrent Power Common meter billing for September 2026',
    'Torrent Power Ltd',
    'UPI',
    '2026-10-04',
    '11111111-1111-1111-1111-111111111001',
    'POSTED'
),
(
    '66666666-6666-6666-6666-666666666002',
    '22222222-2222-2222-2222-222222222002',
    '44444444-4444-4444-4444-444444444001',
    4000.00,
    'SOUND_SYSTEM',
    'Advance payment for 9-channel sound mixer & speakers for Garba night',
    'Shiv Sound Services',
    'UPI',
    '2026-10-08',
    '11111111-1111-1111-1111-111111111002',
    'POSTED'
) ON CONFLICT (expense_id) DO NOTHING;

-- 8. Insert Announcements
INSERT INTO public.announcements (
    announcement_id, society_id, title, message, created_by
) VALUES
(
    '77777777-7777-7777-7777-777777777001',
    '00000000-0000-0000-0000-000000000001',
    'General Body Meeting on Sunday 10:00 AM',
    'Dear Residents, Please gather at the Club House to discuss water storage cleaning and festival schedules.',
    '11111111-1111-1111-1111-111111111001'
),
(
    '77777777-7777-7777-7777-777777777002',
    '00000000-0000-0000-0000-000000000001',
    'Navratri Garba Passes Distribution',
    'Resident ID badges and visitor parking coupons can be collected this evening from the society office.',
    '11111111-1111-1111-1111-111111111002'
) ON CONFLICT (announcement_id) DO NOTHING;

-- 9. Insert Sample Registration Requests & Historical Approval
INSERT INTO public.registration_requests (
    request_id, society_id, auth_uid, full_name, phone_number, flat_number,
    additional_information, request_status, submitted_at, reviewed_by, reviewed_at
) VALUES
(
    '88888888-8888-8888-8888-888888888000',
    '00000000-0000-0000-0000-000000000001',
    'aaaaaaa3-0000-0000-0000-000000000003',
    'Meenaben Trivedi',
    '+919825000003',
    'C-104',
    'Purchased flat C-104 in January 2025',
    'APPROVED',
    '2025-01-14 09:00:00+05:30',
    '11111111-1111-1111-1111-111111111001',
    '2025-01-15 11:30:00+05:30'
),
(
    '88888888-8888-8888-8888-888888888001',
    '00000000-0000-0000-0000-000000000001',
    'aaaaaaa4-0000-0000-0000-000000000004',
    'Bhavikbhai Joshi',
    '+919825000004',
    'B-503',
    'Moved in on October 1st as new flat owner.',
    'PENDING',
    '2026-10-12 14:00:00+05:30',
    NULL,
    NULL
) ON CONFLICT (request_id) DO NOTHING;

INSERT INTO public.registration_approvals (
    approval_id, request_id, approved_by, decision, comments, decided_at
) VALUES
(
    '99999999-9999-9999-9999-999999999001',
    '88888888-8888-8888-8888-888888888000',
    '11111111-1111-1111-1111-111111111001',
    'APPROVED',
    'Welcome to Bajrang Heights! Flat documents verified.',
    '2025-01-15 11:30:00+05:30'
) ON CONFLICT (approval_id) DO NOTHING;

-- 10. Insert Historical Audit Log Records
INSERT INTO public.audit_logs (
    log_id, society_id, member_id, action, record_type, record_id, old_values, new_values, timestamp
) VALUES
(
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa1',
    '00000000-0000-0000-0000-000000000001',
    '11111111-1111-1111-1111-111111111001',
    'SOCIETY_CREATED',
    'society',
    '00000000-0000-0000-0000-000000000001',
    NULL,
    '{"society_name": "Bajrang Heights Co-Operative Housing Society"}'::jsonb,
    '2025-01-01 09:00:00+05:30'
),
(
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa2',
    '00000000-0000-0000-0000-000000000001',
    '11111111-1111-1111-1111-111111111001',
    'FESTIVAL_CREATED',
    'festivals',
    '33333333-3333-3333-3333-333333333001',
    NULL,
    '{"festival_name": "Navratri Mahotsav 2026"}'::jsonb,
    '2026-09-01 10:00:00+05:30'
),
(
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa3',
    '00000000-0000-0000-0000-000000000001',
    '11111111-1111-1111-1111-111111111001',
    'CONTRIBUTION_ADDED',
    'contributions',
    '55555555-5555-5555-5555-555555555001',
    NULL,
    '{"amount": 3000.00, "receipt_number": "REC-202610-0001", "member": "Rajeshbhai Patel"}'::jsonb,
    '2026-10-01 11:15:00+05:30'
),
(
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa4',
    '00000000-0000-0000-0000-000000000001',
    '11111111-1111-1111-1111-111111111001',
    'EXPENSE_ADDED',
    'expenses',
    '66666666-6666-6666-6666-666666666001',
    NULL,
    '{"amount": 8500.00, "category": "ELECTRICITY", "vendor": "Torrent Power Ltd"}'::jsonb,
    '2026-10-04 15:30:00+05:30'
) ON CONFLICT (log_id) DO NOTHING;
