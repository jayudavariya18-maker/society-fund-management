# Security, Row Level Security (RLS) & Access Model
## Bajrang Residential Society Fund Management System

### 1. Philosophy: "NO ROLES" Equal-Member Transparency
Traditional housing society software concentrates power in high-privilege roles (`Admin`, `Chairman`, `Treasurer`, `Secretary`), creating bottlenecks, opacity, and opportunities for unilateral financial manipulation.

The **Bajrang Society Fund Management System** implements an equal-permission, high-transparency paradigm:
1. **Zero Hierarchical Roles**: All approved resident members have identical read, write, audit, and review permissions.
2. **Every Rupee Has an Identity**: Financial operations require the active resident's authenticated `member_id`.
3. **No Hidden Ledgers**: All active members view identical screens, reports, balance sheets, and audit entries.
4. **Peer Approval for Onboarding**: Any existing active member can approve a new flat resident's registration request, with strict prevention of self-approval.

---

### 2. Row Level Security (RLS) Policy Matrix

| Table | SELECT | INSERT | UPDATE | DELETE |
| :--- | :--- | :--- | :--- | :--- |
| `society` | Authenticated users | System/Migration | Active members | **FORBIDDEN** |
| `members` | Active members OR Own profile | Trigger on Approval | Own profile (`auth_uid`) | **FORBIDDEN** |
| `registration_requests` | Own request OR Active members | Authenticated user (`auth_uid`) | Active members (`auth_uid != reviewer`) | **FORBIDDEN** |
| `registration_approvals` | Active members | Active members (No self-approval) | **FORBIDDEN** | **FORBIDDEN** |
| `funds` | Active members | Active members | Active members | **FORBIDDEN** |
| `festivals` | Active members | Active members | Active members | **FORBIDDEN** |
| `festival_events` | Active members | Active members | Active members | **FORBIDDEN** |
| `contributions` | Active members | Active members (`created_by`) | Status adjustments only | **FORBIDDEN** |
| `expenses` | Active members | Active members (`created_by`) | Status adjustments only | **FORBIDDEN** |
| `audit_logs` | Active members | Trusted Triggers | **FORBIDDEN** | **FORBIDDEN** |
| `announcements` | Active members | Active members (`created_by`) | Active members | **FORBIDDEN** |

---

### 3. Core Security Rules & Invariants

#### 3.1 Self-Approval Prevention
In `fn_validate_registration_approval`:
```sql
IF v_applicant_auth_uid = v_reviewer_auth_uid THEN
    RAISE EXCEPTION 'Self-approval is strictly forbidden. Another active member must approve your request.';
END IF;
```
A user can never activate their own membership.

#### 3.2 Pending Users Denied Financial Access
Unapproved or pending applicants are strictly restricted to reading and submitting their own `registration_requests` row. All financial views (`vw_fund_balances`, `vw_society_financial_summary`), funds, contributions, expenses, and member directories require `public.is_active_member() == true`.

#### 3.3 Immutability of Posted Financial Ledgers
- No `DELETE` policies exist on `contributions` or `expenses`.
- Any accounting error correction requires an auditable adjustment record linked via `correction_reference`.
- The audit trail retains both `old_values` and `new_values` in `JSONB`.

#### 3.4 Idempotency & Duplicate Transaction Protection
Constraint `uq_idempotent_txn` on `public.contributions`:
```sql
UNIQUE (fund_id, transaction_reference, payment_date, amount)
```
Prevents accidental double-tapping or duplicate entries of the same transaction on the same date.

#### 3.5 Fund Isolation
Constraint `chk_fund_type_isolation` on `public.funds`:
```sql
CHECK (
    (fund_type = 'GENERAL' AND festival_id IS NULL) OR
    (fund_type = 'FESTIVAL' AND festival_id IS NOT NULL)
)
```
General Society funds and festival collections cannot be co-mingled or confused.

#### 3.6 Storage Security
Supabase Storage buckets (`expense-bills`, `contribution-receipts`, `festival-media`):
- Restrict write operations to authenticated members.
- Public read access for society transparency.
- 5MB maximum file size limit; supported MIME types: `image/jpeg`, `image/png`, `image/webp`, `application/pdf`.

#### 3.7 Secret Protection
- Never expose the Supabase `service_role` key in Flutter or client code.
- Client applications only hold `SUPABASE_ANON_KEY`.
- All environment keys are loaded through compile-time environment flags (`--dart-define`) or `.env`.
