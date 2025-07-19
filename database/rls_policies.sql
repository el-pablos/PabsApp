-- =====================================================
-- PabsApp Row Level Security (RLS) Policies
-- Author: Tamas dari TamsHub
-- Version: 1.0.0
-- Created: 2025-01-19
-- =====================================================

-- =====================================================
-- ENABLE RLS ON ALL TABLES
-- =====================================================

-- User management tables
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_preferences ENABLE ROW LEVEL SECURITY;

-- Todo feature tables
ALTER TABLE public.todo_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.todos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.todo_comments ENABLE ROW LEVEL SECURITY;

-- Media feature tables
ALTER TABLE public.media_albums ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.media_files ENABLE ROW LEVEL SECURITY;

-- FinTech feature tables
ALTER TABLE public.transaction_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payment_methods ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.budgets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.financial_goals ENABLE ROW LEVEL SECURITY;

-- Health monitoring tables
ALTER TABLE public.system_metrics ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.api_health_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.performance_metrics ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.weather_data ENABLE ROW LEVEL SECURITY;

-- Location services tables
ALTER TABLE public.saved_locations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.location_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.geofences ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.geofence_events ENABLE ROW LEVEL SECURITY;

-- API debug tools tables
ALTER TABLE public.api_endpoints ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.api_request_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.debug_sessions ENABLE ROW LEVEL SECURITY;

-- System tables
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.app_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.audit_logs ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- HELPER FUNCTIONS
-- =====================================================

-- Function to get current user ID from JWT
CREATE OR REPLACE FUNCTION get_current_user_id()
RETURNS UUID AS $$
BEGIN
    RETURN (auth.jwt() ->> 'sub')::UUID;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to check if user is admin
CREATE OR REPLACE FUNCTION is_admin()
RETURNS BOOLEAN AS $$
BEGIN
    RETURN COALESCE((auth.jwt() ->> 'is_admin')::BOOLEAN, false);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to get user's UUID from auth.users
CREATE OR REPLACE FUNCTION get_user_uuid()
RETURNS UUID AS $$
BEGIN
    RETURN (
        SELECT id 
        FROM public.users 
        WHERE auth_user_id = auth.uid()
        LIMIT 1
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- USER MANAGEMENT POLICIES
-- =====================================================

-- Users table policies
CREATE POLICY "Users can view their own profile" ON public.users
    FOR SELECT USING (auth_user_id = auth.uid());

CREATE POLICY "Users can update their own profile" ON public.users
    FOR UPDATE USING (auth_user_id = auth.uid());

CREATE POLICY "Users can insert their own profile" ON public.users
    FOR INSERT WITH CHECK (auth_user_id = auth.uid());

-- User sessions policies
CREATE POLICY "Users can view their own sessions" ON public.user_sessions
    FOR SELECT USING (user_id = get_user_uuid());

CREATE POLICY "Users can manage their own sessions" ON public.user_sessions
    FOR ALL USING (user_id = get_user_uuid());

-- User preferences policies
CREATE POLICY "Users can manage their own preferences" ON public.user_preferences
    FOR ALL USING (user_id = get_user_uuid());

-- =====================================================
-- TODO FEATURE POLICIES
-- =====================================================

-- Todo categories policies
CREATE POLICY "Users can manage their own todo categories" ON public.todo_categories
    FOR ALL USING (user_id = get_user_uuid());

-- Todos policies
CREATE POLICY "Users can manage their own todos" ON public.todos
    FOR ALL USING (user_id = get_user_uuid());

-- Todo comments policies
CREATE POLICY "Users can manage their own todo comments" ON public.todo_comments
    FOR ALL USING (user_id = get_user_uuid());

-- =====================================================
-- MEDIA FEATURE POLICIES
-- =====================================================

-- Media albums policies
CREATE POLICY "Users can manage their own media albums" ON public.media_albums
    FOR ALL USING (user_id = get_user_uuid());

-- Media files policies
CREATE POLICY "Users can manage their own media files" ON public.media_files
    FOR ALL USING (user_id = get_user_uuid());

CREATE POLICY "Users can view public media files" ON public.media_files
    FOR SELECT USING (is_private = false OR user_id = get_user_uuid());

-- =====================================================
-- FINTECH FEATURE POLICIES
-- =====================================================

-- Transaction categories policies
CREATE POLICY "Users can manage their own transaction categories" ON public.transaction_categories
    FOR ALL USING (user_id = get_user_uuid());

-- Payment methods policies
CREATE POLICY "Users can manage their own payment methods" ON public.payment_methods
    FOR ALL USING (user_id = get_user_uuid());

-- Transactions policies
CREATE POLICY "Users can manage their own transactions" ON public.transactions
    FOR ALL USING (user_id = get_user_uuid());

-- Budgets policies
CREATE POLICY "Users can manage their own budgets" ON public.budgets
    FOR ALL USING (user_id = get_user_uuid());

-- Financial goals policies
CREATE POLICY "Users can manage their own financial goals" ON public.financial_goals
    FOR ALL USING (user_id = get_user_uuid());

-- =====================================================
-- HEALTH MONITORING POLICIES
-- =====================================================

-- System metrics policies
CREATE POLICY "Users can manage their own system metrics" ON public.system_metrics
    FOR ALL USING (user_id = get_user_uuid());

-- API health logs policies
CREATE POLICY "Users can manage their own API health logs" ON public.api_health_logs
    FOR ALL USING (user_id = get_user_uuid());

-- Performance metrics policies
CREATE POLICY "Users can manage their own performance metrics" ON public.performance_metrics
    FOR ALL USING (user_id = get_user_uuid());

-- Weather data policies
CREATE POLICY "Users can manage their own weather data" ON public.weather_data
    FOR ALL USING (user_id = get_user_uuid());

-- =====================================================
-- LOCATION SERVICES POLICIES
-- =====================================================

-- Saved locations policies
CREATE POLICY "Users can manage their own saved locations" ON public.saved_locations
    FOR ALL USING (user_id = get_user_uuid());

CREATE POLICY "Users can view public saved locations" ON public.saved_locations
    FOR SELECT USING (is_private = false OR user_id = get_user_uuid());

-- Location history policies
CREATE POLICY "Users can manage their own location history" ON public.location_history
    FOR ALL USING (user_id = get_user_uuid());

-- Geofences policies
CREATE POLICY "Users can manage their own geofences" ON public.geofences
    FOR ALL USING (user_id = get_user_uuid());

-- Geofence events policies
CREATE POLICY "Users can manage their own geofence events" ON public.geofence_events
    FOR ALL USING (user_id = get_user_uuid());

-- =====================================================
-- API DEBUG TOOLS POLICIES
-- =====================================================

-- API endpoints policies
CREATE POLICY "Users can manage their own API endpoints" ON public.api_endpoints
    FOR ALL USING (user_id = get_user_uuid());

-- API request history policies
CREATE POLICY "Users can manage their own API request history" ON public.api_request_history
    FOR ALL USING (user_id = get_user_uuid());

-- Debug sessions policies
CREATE POLICY "Users can manage their own debug sessions" ON public.debug_sessions
    FOR ALL USING (user_id = get_user_uuid());

-- =====================================================
-- SYSTEM POLICIES
-- =====================================================

-- Notifications policies
CREATE POLICY "Users can manage their own notifications" ON public.notifications
    FOR ALL USING (user_id = get_user_uuid());

-- App settings policies
CREATE POLICY "Users can manage their own app settings" ON public.app_settings
    FOR ALL USING (user_id = get_user_uuid());

-- Audit logs policies (read-only for users, admins can see all)
CREATE POLICY "Users can view their own audit logs" ON public.audit_logs
    FOR SELECT USING (user_id = get_user_uuid() OR is_admin());

CREATE POLICY "System can insert audit logs" ON public.audit_logs
    FOR INSERT WITH CHECK (true);

-- =====================================================
-- ADMIN POLICIES
-- =====================================================

-- Admin can view all data (bypass RLS for admin operations)
CREATE POLICY "Admins can view all users" ON public.users
    FOR SELECT USING (is_admin());

CREATE POLICY "Admins can view all audit logs" ON public.audit_logs
    FOR SELECT USING (is_admin());

-- =====================================================
-- SERVICE ROLE POLICIES
-- =====================================================

-- Allow service role to bypass RLS for system operations
CREATE POLICY "Service role can manage all data" ON public.users
    FOR ALL USING (auth.role() = 'service_role');

CREATE POLICY "Service role can manage all sessions" ON public.user_sessions
    FOR ALL USING (auth.role() = 'service_role');

CREATE POLICY "Service role can manage all audit logs" ON public.audit_logs
    FOR ALL USING (auth.role() = 'service_role');

-- =====================================================
-- ANONYMOUS ACCESS POLICIES
-- =====================================================

-- Allow anonymous users to create accounts
CREATE POLICY "Anonymous users can create accounts" ON public.users
    FOR INSERT WITH CHECK (auth.role() = 'anon');

-- =====================================================
-- SECURITY FUNCTIONS
-- =====================================================

-- Function to log security events
CREATE OR REPLACE FUNCTION log_security_event(
    p_action TEXT,
    p_resource_type TEXT,
    p_resource_id UUID DEFAULT NULL,
    p_description TEXT DEFAULT NULL
)
RETURNS VOID AS $$
BEGIN
    INSERT INTO public.audit_logs (
        user_id,
        action,
        resource_type,
        resource_id,
        description,
        severity,
        ip_address,
        user_agent
    ) VALUES (
        get_user_uuid(),
        p_action,
        p_resource_type,
        p_resource_id,
        p_description,
        'info',
        inet_client_addr(),
        current_setting('request.headers', true)::json->>'user-agent'
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to check rate limiting
CREATE OR REPLACE FUNCTION check_rate_limit(
    p_action TEXT,
    p_limit INTEGER DEFAULT 100,
    p_window_minutes INTEGER DEFAULT 60
)
RETURNS BOOLEAN AS $$
DECLARE
    v_count INTEGER;
BEGIN
    SELECT COUNT(*)
    INTO v_count
    FROM public.audit_logs
    WHERE user_id = get_user_uuid()
        AND action = p_action
        AND created_at > NOW() - (p_window_minutes || ' minutes')::INTERVAL;
    
    RETURN v_count < p_limit;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- TRIGGER FUNCTIONS FOR AUDIT LOGGING
-- =====================================================

-- Function to automatically log data changes
CREATE OR REPLACE FUNCTION audit_trigger_function()
RETURNS TRIGGER AS $$
BEGIN
    -- Log the change
    INSERT INTO public.audit_logs (
        user_id,
        action,
        resource_type,
        resource_id,
        old_values,
        new_values,
        ip_address
    ) VALUES (
        get_user_uuid(),
        TG_OP,
        TG_TABLE_NAME,
        COALESCE(NEW.id, OLD.id),
        CASE WHEN TG_OP = 'DELETE' THEN row_to_json(OLD) ELSE NULL END,
        CASE WHEN TG_OP IN ('INSERT', 'UPDATE') THEN row_to_json(NEW) ELSE NULL END,
        inet_client_addr()
    );
    
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Apply audit triggers to sensitive tables
CREATE TRIGGER audit_users_trigger
    AFTER INSERT OR UPDATE OR DELETE ON public.users
    FOR EACH ROW EXECUTE FUNCTION audit_trigger_function();

CREATE TRIGGER audit_transactions_trigger
    AFTER INSERT OR UPDATE OR DELETE ON public.transactions
    FOR EACH ROW EXECUTE FUNCTION audit_trigger_function();

CREATE TRIGGER audit_saved_locations_trigger
    AFTER INSERT OR UPDATE OR DELETE ON public.saved_locations
    FOR EACH ROW EXECUTE FUNCTION audit_trigger_function();
