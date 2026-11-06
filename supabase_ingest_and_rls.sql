-- ============================================================================
-- Radar Labour — Supabase Multi-Device Ingest & Row Level Security (RLS)
-- Version: 2.0 (November 2026 Improvements)
-- Status: Prepared for Owner Review ONLY. DO NOT apply to hosted production
--         unless explicitly authorized by the project owner.
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. Sequences & Tables Schema
-- ----------------------------------------------------------------------------

-- Monotonically increasing server sequence for ordered event synchronization across devices
CREATE SEQUENCE IF NOT EXISTS events_server_seq_seq START WITH 1 INCREMENT BY 1;

-- Events Ledger (Append-Only)
CREATE TABLE IF NOT EXISTS public.events (
    event_id TEXT PRIMARY KEY,
    device_id TEXT NOT NULL,
    device_seq BIGINT NOT NULL,
    server_seq BIGINT UNIQUE DEFAULT nextval('events_server_seq_seq'),
    event_type TEXT NOT NULL,
    action TEXT NOT NULL,
    business_date TEXT NOT NULL,
    employee_uid TEXT,
    team_id TEXT,
    housing_id TEXT,
    user_id TEXT,
    payload JSONB DEFAULT '{}'::jsonb,
    device_time_utc TIMESTAMPTZ NOT NULL,
    received_at TIMESTAMPTZ DEFAULT now(),
    late BOOLEAN DEFAULT false,
    sync_status TEXT DEFAULT 'synced',
    reject_reason TEXT,
    CONSTRAINT events_device_sequence_unique UNIQUE (device_id, device_seq)
);

CREATE INDEX IF NOT EXISTS idx_events_server_seq ON public.events (server_seq);
CREATE INDEX IF NOT EXISTS idx_events_business_date ON public.events (business_date);
CREATE INDEX IF NOT EXISTS idx_events_employee ON public.events (employee_uid, business_date);
CREATE INDEX IF NOT EXISTS idx_events_team ON public.events (team_id, business_date);

-- Workforce Employees
CREATE TABLE IF NOT EXISTS public.employees (
    iqama_no TEXT PRIMARY KEY,
    full_name_ar TEXT NOT NULL,
    full_name_en TEXT,
    job_title TEXT,
    job_category TEXT DEFAULT 'direct_labor',
    employment_type TEXT DEFAULT 'company',
    rental_company TEXT,
    iqama_expiry TIMESTAMPTZ,
    current_team_id TEXT,
    is_active BOOLEAN DEFAULT true,
    archived_at TIMESTAMPTZ,
    row_version BIGINT DEFAULT 1
);

-- Teams
CREATE TABLE IF NOT EXISTS public.teams (
    team_id TEXT PRIMARY KEY,
    name_ar TEXT NOT NULL,
    name_en TEXT,
    supervisor_user_id TEXT
);

-- App Users
CREATE TABLE IF NOT EXISTS public.app_users (
    user_id TEXT PRIMARY KEY,
    username TEXT UNIQUE NOT NULL,
    full_name TEXT NOT NULL,
    role TEXT NOT NULL,
    is_active BOOLEAN DEFAULT true,
    password_hash TEXT NOT NULL,
    salt TEXT NOT NULL
);

-- User Scopes (Team / Housing assignments)
CREATE TABLE IF NOT EXISTS public.user_scopes (
    scope_id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL REFERENCES public.app_users(user_id) ON DELETE CASCADE,
    scope_type TEXT NOT NULL, -- 'team' or 'housing'
    scope_value TEXT NOT NULL
);

-- Append-Only Audit Log
CREATE TABLE IF NOT EXISTS public.audit_log (
    audit_id TEXT PRIMARY KEY,
    user_id TEXT,
    action TEXT NOT NULL,
    entity_type TEXT NOT NULL,
    entity_id TEXT NOT NULL,
    device_id TEXT NOT NULL,
    device_time TIMESTAMPTZ NOT NULL,
    received_at TIMESTAMPTZ DEFAULT now(),
    sync_status TEXT DEFAULT 'synced'
);

-- System Settings & Roster Epoch
CREATE TABLE IF NOT EXISTS public.settings (
    key TEXT PRIMARY KEY,
    value TEXT NOT NULL
);

-- Initialize default epoch if missing
INSERT INTO public.settings (key, value)
VALUES ('roster_epoch', '1')
ON CONFLICT (key) DO NOTHING;

-- ----------------------------------------------------------------------------
-- 2. Ingest Events RPC Function
-- ----------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION public.ingest_events(p_events JSONB)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_event JSONB;
    v_event_id TEXT;
    v_device_id TEXT;
    v_device_seq BIGINT;
    v_type TEXT;
    v_action TEXT;
    v_bdate TEXT;
    v_emp_uid TEXT;
    v_team_id TEXT;
    v_housing_id TEXT;
    v_user_id TEXT;
    v_payload JSONB;
    v_dev_time TIMESTAMPTZ;
    v_server_seq BIGINT;
    v_is_late BOOLEAN;
    v_results JSONB := '[]'::jsonb;
    v_existing_seq BIGINT;
BEGIN
    IF p_events IS NULL OR jsonb_typeof(p_events) <> 'array' THEN
        RETURN jsonb_build_object('error', 'Invalid payload format: expected JSON array of events');
    END IF;

    FOR v_event IN SELECT * FROM jsonb_array_elements(p_events)
    LOOP
        v_event_id   := v_event->>'event_id';
        v_device_id  := v_event->>'device_id';
        v_device_seq := (v_event->>'device_seq')::BIGINT;
        v_type       := v_event->>'event_type';
        v_action     := v_event->>'action';
        v_bdate      := v_event->>'business_date';
        v_emp_uid    := v_event->>'employee_uid';
        v_team_id    := v_event->>'team_id';
        v_housing_id := v_event->>'housing_id';
        v_user_id    := v_event->>'user_id';
        v_payload    := COALESCE(v_event->'payload', '{}'::jsonb);
        v_dev_time   := COALESCE((v_event->>'device_time_utc')::TIMESTAMPTZ, now());
        v_is_late    := COALESCE((v_event->>'late')::BOOLEAN, false);

        -- Check idempotency: already ingested event
        SELECT server_seq INTO v_existing_seq FROM public.events WHERE event_id = v_event_id;
        IF FOUND THEN
            v_results := v_results || jsonb_build_object(
                'event_id', v_event_id,
                'status', 'acked',
                'duplicate', true,
                'server_seq', v_existing_seq
            );
            CONTINUE;
        END IF;

        -- Strict Business Validation: Business Date pattern YYYY-MM-DD
        IF v_bdate IS NULL OR v_bdate !~ '^\d{4}-\d{2}-\d{2}$' THEN
            v_results := v_results || jsonb_build_object(
                'event_id', v_event_id,
                'status', 'rejected',
                'reject_reason', 'invalid_business_date_format'
            );
            CONTINUE;
        END IF;

        -- Assign next server sequence and insert
        v_server_seq := nextval('events_server_seq_seq');

        INSERT INTO public.events (
            event_id, device_id, device_seq, server_seq,
            event_type, action, business_date,
            employee_uid, team_id, housing_id, user_id,
            payload, device_time_utc, received_at,
            late, sync_status
        ) VALUES (
            v_event_id, v_device_id, v_device_seq, v_server_seq,
            v_type, v_action, v_bdate,
            v_emp_uid, v_team_id, v_housing_id, v_user_id,
            v_payload, v_dev_time, now(),
            v_is_late, 'synced'
        );

        v_results := v_results || jsonb_build_object(
            'event_id', v_event_id,
            'status', 'acked',
            'server_seq', v_server_seq
        );
    END LOOP;

    RETURN v_results;
END;
$$;

-- ----------------------------------------------------------------------------
-- 3. Row Level Security (RLS) Policies
-- ----------------------------------------------------------------------------

ALTER TABLE public.events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.employees ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.teams ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.app_users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_scopes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.audit_log ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.settings ENABLE ROW LEVEL SECURITY;

-- Helper to inspect active user role
CREATE OR REPLACE FUNCTION public.current_app_user_role()
RETURNS TEXT
LANGUAGE sql STABLE
AS $$
    SELECT role FROM public.app_users WHERE user_id = auth.uid()::text AND is_active = true;
$$;

-- Policy: Admin / ProjectManager / HR have complete read & write access
CREATE POLICY admin_full_events ON public.events
    FOR ALL
    USING (public.current_app_user_role() IN ('projectManager', 'hr'))
    WITH CHECK (public.current_app_user_role() IN ('projectManager', 'hr'));

CREATE POLICY admin_full_employees ON public.employees
    FOR ALL
    USING (public.current_app_user_role() IN ('projectManager', 'hr'))
    WITH CHECK (public.current_app_user_role() IN ('projectManager', 'hr'));

CREATE POLICY admin_full_teams ON public.teams
    FOR ALL
    USING (public.current_app_user_role() IN ('projectManager', 'hr'))
    WITH CHECK (public.current_app_user_role() IN ('projectManager', 'hr'));

CREATE POLICY admin_full_audit ON public.audit_log
    FOR ALL
    USING (public.current_app_user_role() IN ('projectManager', 'hr'))
    WITH CHECK (public.current_app_user_role() IN ('projectManager', 'hr'));

-- Policy: Field Supervisors (Site)
CREATE POLICY site_supervisor_read_events ON public.events
    FOR SELECT
    USING (
        public.current_app_user_role() = 'siteSupervisor'
        AND (
            team_id IN (SELECT scope_value FROM public.user_scopes WHERE user_id = auth.uid()::text AND scope_type = 'team')
            OR team_id IS NULL
        )
    );

CREATE POLICY site_supervisor_insert_events ON public.events
    FOR INSERT
    WITH CHECK (
        public.current_app_user_role() = 'siteSupervisor'
        AND (
            team_id IN (SELECT scope_value FROM public.user_scopes WHERE user_id = auth.uid()::text AND scope_type = 'team')
            OR team_id IS NULL
        )
    );

-- Policy: Field Supervisors (Housing)
CREATE POLICY housing_supervisor_read_events ON public.events
    FOR SELECT
    USING (
        public.current_app_user_role() = 'housingSupervisor'
        AND (
            housing_id IN (SELECT scope_value FROM public.user_scopes WHERE user_id = auth.uid()::text AND scope_type = 'housing')
            OR housing_id IS NULL
        )
    );

CREATE POLICY housing_supervisor_insert_events ON public.events
    FOR INSERT
    WITH CHECK (
        public.current_app_user_role() = 'housingSupervisor'
        AND (
            housing_id IN (SELECT scope_value FROM public.user_scopes WHERE user_id = auth.uid()::text AND scope_type = 'housing')
            OR housing_id IS NULL
        )
    );

-- Policy: Viewers (Read-only on events, workers, teams)
CREATE POLICY viewer_select_events ON public.events
    FOR SELECT
    USING (public.current_app_user_role() = 'viewer');

CREATE POLICY viewer_select_employees ON public.employees
    FOR SELECT
    USING (public.current_app_user_role() = 'viewer');

CREATE POLICY viewer_select_teams ON public.teams
    FOR SELECT
    USING (public.current_app_user_role() = 'viewer');
