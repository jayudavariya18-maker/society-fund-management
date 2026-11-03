-- ====================================================================
-- RAMSEVA — RAMDEVRA RESIDENTIAL SOCIETY
-- Production Clean Seed: supabase/seed.sql
-- Exact Zero-Balance Opening State, Zero Demo Members, Zero Dummy Records
-- ====================================================================

-- 1. Insert Society: Ramdevra Society
INSERT INTO public.society (
    society_id, society_name, address, city, state, pincode, contact_number, email
) VALUES (
    '00000000-0000-0000-0000-000000000001',
    'Ramdevra Society',
    'Ramdevra Society, Near Temple, Main Road',
    'Ahmedabad',
    'Gujarat',
    '380015',
    '+919876543210',
    'ramdevra.society@gmail.com'
) ON CONFLICT (society_id) DO UPDATE SET
    society_name = EXCLUDED.society_name,
    email = EXCLUDED.email;

-- 2. Insert General Society Fund (Opening Balance: ₹0.00)
INSERT INTO public.funds (
    fund_id, society_id, fund_name, fund_type, festival_id, description, opening_balance, is_active
) VALUES (
    '22222222-2222-2222-2222-222222222001',
    '00000000-0000-0000-0000-000000000001',
    'General Society Maintenance Fund',
    'GENERAL',
    NULL,
    'Primary operational fund for society security, cleanliness, lighting and common maintenance.',
    0.00,
    TRUE
) ON CONFLICT (fund_id) DO UPDATE SET
    opening_balance = 0.00;

-- Clean initial state:
-- Demo members: 0
-- Demo festivals: 0
-- Demo festival events: 0
-- Demo contributions: 0
-- Demo expenses: 0
-- Total starting balance: ₹0.00
