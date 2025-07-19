-- =====================================================
-- PabsApp Database Indexes and Constraints
-- Author: Tamas dari TamsHub
-- Version: 1.0.0
-- Created: 2025-01-19
-- =====================================================

-- =====================================================
-- PERFORMANCE INDEXES
-- =====================================================

-- Users table indexes
CREATE INDEX idx_users_auth_user_id ON public.users(auth_user_id);
CREATE INDEX idx_users_username ON public.users(username);
CREATE INDEX idx_users_email ON public.users(email);
CREATE INDEX idx_users_is_active ON public.users(is_active);
CREATE INDEX idx_users_created_at ON public.users(created_at);

-- User sessions indexes
CREATE INDEX idx_user_sessions_user_id ON public.user_sessions(user_id);
CREATE INDEX idx_user_sessions_token ON public.user_sessions(session_token);
CREATE INDEX idx_user_sessions_active ON public.user_sessions(is_active);
CREATE INDEX idx_user_sessions_expires ON public.user_sessions(expires_at);

-- Todos table indexes
CREATE INDEX idx_todos_user_id ON public.todos(user_id);
CREATE INDEX idx_todos_category_id ON public.todos(category_id);
CREATE INDEX idx_todos_status ON public.todos(status);
CREATE INDEX idx_todos_priority ON public.todos(priority);
CREATE INDEX idx_todos_due_date ON public.todos(due_date);
CREATE INDEX idx_todos_completed_at ON public.todos(completed_at);
CREATE INDEX idx_todos_location_coords ON public.todos USING GIST(location_coordinates);
CREATE INDEX idx_todos_created_at ON public.todos(created_at);

-- Todo categories indexes
CREATE INDEX idx_todo_categories_user_id ON public.todo_categories(user_id);
CREATE INDEX idx_todo_categories_name ON public.todo_categories(user_id, name);

-- Media files indexes
CREATE INDEX idx_media_files_user_id ON public.media_files(user_id);
CREATE INDEX idx_media_files_album_id ON public.media_files(album_id);
CREATE INDEX idx_media_files_media_type ON public.media_files(media_type);
CREATE INDEX idx_media_files_taken_at ON public.media_files(taken_at);
CREATE INDEX idx_media_files_location_coords ON public.media_files USING GIST(location_coordinates);
CREATE INDEX idx_media_files_is_favorite ON public.media_files(is_favorite);
CREATE INDEX idx_media_files_processing_status ON public.media_files(processing_status);
CREATE INDEX idx_media_files_file_hash ON public.media_files(file_hash);

-- Media albums indexes
CREATE INDEX idx_media_albums_user_id ON public.media_albums(user_id);
CREATE INDEX idx_media_albums_name ON public.media_albums(user_id, name);

-- Transactions indexes
CREATE INDEX idx_transactions_user_id ON public.transactions(user_id);
CREATE INDEX idx_transactions_category_id ON public.transactions(category_id);
CREATE INDEX idx_transactions_payment_method_id ON public.transactions(payment_method_id);
CREATE INDEX idx_transactions_type ON public.transactions(transaction_type);
CREATE INDEX idx_transactions_date ON public.transactions(transaction_date);
CREATE INDEX idx_transactions_amount ON public.transactions(amount);
CREATE INDEX idx_transactions_location_coords ON public.transactions USING GIST(location_coordinates);
CREATE INDEX idx_transactions_created_at ON public.transactions(created_at);

-- Transaction categories indexes
CREATE INDEX idx_transaction_categories_user_id ON public.transaction_categories(user_id);
CREATE INDEX idx_transaction_categories_type ON public.transaction_categories(category_type);
CREATE INDEX idx_transaction_categories_name ON public.transaction_categories(user_id, name, category_type);

-- Payment methods indexes
CREATE INDEX idx_payment_methods_user_id ON public.payment_methods(user_id);
CREATE INDEX idx_payment_methods_type ON public.payment_methods(method_type);
CREATE INDEX idx_payment_methods_active ON public.payment_methods(is_active);
CREATE INDEX idx_payment_methods_default ON public.payment_methods(is_default);

-- Budgets indexes
CREATE INDEX idx_budgets_user_id ON public.budgets(user_id);
CREATE INDEX idx_budgets_category_id ON public.budgets(category_id);
CREATE INDEX idx_budgets_period ON public.budgets(start_date, end_date);
CREATE INDEX idx_budgets_active ON public.budgets(is_active);

-- Financial goals indexes
CREATE INDEX idx_financial_goals_user_id ON public.financial_goals(user_id);
CREATE INDEX idx_financial_goals_status ON public.financial_goals(status);
CREATE INDEX idx_financial_goals_type ON public.financial_goals(goal_type);
CREATE INDEX idx_financial_goals_target_date ON public.financial_goals(target_date);

-- System metrics indexes
CREATE INDEX idx_system_metrics_user_id ON public.system_metrics(user_id);
CREATE INDEX idx_system_metrics_device_id ON public.system_metrics(device_id);
CREATE INDEX idx_system_metrics_recorded_at ON public.system_metrics(recorded_at);

-- API health logs indexes
CREATE INDEX idx_api_health_logs_user_id ON public.api_health_logs(user_id);
CREATE INDEX idx_api_health_logs_api_name ON public.api_health_logs(api_name);
CREATE INDEX idx_api_health_logs_checked_at ON public.api_health_logs(checked_at);
CREATE INDEX idx_api_health_logs_is_healthy ON public.api_health_logs(is_healthy);

-- Performance metrics indexes
CREATE INDEX idx_performance_metrics_user_id ON public.performance_metrics(user_id);
CREATE INDEX idx_performance_metrics_name ON public.performance_metrics(metric_name);
CREATE INDEX idx_performance_metrics_category ON public.performance_metrics(metric_category);
CREATE INDEX idx_performance_metrics_recorded_at ON public.performance_metrics(recorded_at);

-- Weather data indexes
CREATE INDEX idx_weather_data_user_id ON public.weather_data(user_id);
CREATE INDEX idx_weather_data_location_coords ON public.weather_data USING GIST(location_coordinates);
CREATE INDEX idx_weather_data_expires_at ON public.weather_data(expires_at);
CREATE INDEX idx_weather_data_fetched_at ON public.weather_data(fetched_at);

-- Saved locations indexes
CREATE INDEX idx_saved_locations_user_id ON public.saved_locations(user_id);
CREATE INDEX idx_saved_locations_coords ON public.saved_locations USING GIST(coordinates);
CREATE INDEX idx_saved_locations_type ON public.saved_locations(location_type);
CREATE INDEX idx_saved_locations_category ON public.saved_locations(category);
CREATE INDEX idx_saved_locations_favorite ON public.saved_locations(is_favorite);
CREATE INDEX idx_saved_locations_name ON public.saved_locations(user_id, name);

-- Location history indexes
CREATE INDEX idx_location_history_user_id ON public.location_history(user_id);
CREATE INDEX idx_location_history_coords ON public.location_history USING GIST(coordinates);
CREATE INDEX idx_location_history_recorded_at ON public.location_history(recorded_at);
CREATE INDEX idx_location_history_activity_type ON public.location_history(activity_type);

-- Geofences indexes
CREATE INDEX idx_geofences_user_id ON public.geofences(user_id);
CREATE INDEX idx_geofences_location_id ON public.geofences(saved_location_id);
CREATE INDEX idx_geofences_center_coords ON public.geofences USING GIST(center_coordinates);
CREATE INDEX idx_geofences_active ON public.geofences(is_active);

-- Geofence events indexes
CREATE INDEX idx_geofence_events_user_id ON public.geofence_events(user_id);
CREATE INDEX idx_geofence_events_geofence_id ON public.geofence_events(geofence_id);
CREATE INDEX idx_geofence_events_type ON public.geofence_events(event_type);
CREATE INDEX idx_geofence_events_triggered_at ON public.geofence_events(triggered_at);

-- API endpoints indexes
CREATE INDEX idx_api_endpoints_user_id ON public.api_endpoints(user_id);
CREATE INDEX idx_api_endpoints_category ON public.api_endpoints(category);
CREATE INDEX idx_api_endpoints_favorite ON public.api_endpoints(is_favorite);
CREATE INDEX idx_api_endpoints_last_used ON public.api_endpoints(last_used_at);

-- API request history indexes
CREATE INDEX idx_api_request_history_user_id ON public.api_request_history(user_id);
CREATE INDEX idx_api_request_history_endpoint_id ON public.api_request_history(endpoint_id);
CREATE INDEX idx_api_request_history_executed_at ON public.api_request_history(executed_at);
CREATE INDEX idx_api_request_history_status_code ON public.api_request_history(status_code);
CREATE INDEX idx_api_request_history_successful ON public.api_request_history(is_successful);

-- Debug sessions indexes
CREATE INDEX idx_debug_sessions_user_id ON public.debug_sessions(user_id);
CREATE INDEX idx_debug_sessions_status ON public.debug_sessions(status);
CREATE INDEX idx_debug_sessions_started_at ON public.debug_sessions(started_at);

-- Notifications indexes
CREATE INDEX idx_notifications_user_id ON public.notifications(user_id);
CREATE INDEX idx_notifications_type ON public.notifications(notification_type);
CREATE INDEX idx_notifications_category ON public.notifications(category);
CREATE INDEX idx_notifications_is_read ON public.notifications(is_read);
CREATE INDEX idx_notifications_scheduled_at ON public.notifications(scheduled_at);
CREATE INDEX idx_notifications_created_at ON public.notifications(created_at);

-- App settings indexes
CREATE INDEX idx_app_settings_user_id ON public.app_settings(user_id);
CREATE INDEX idx_app_settings_key ON public.app_settings(setting_key);
CREATE INDEX idx_app_settings_category ON public.app_settings(category);

-- Audit logs indexes
CREATE INDEX idx_audit_logs_user_id ON public.audit_logs(user_id);
CREATE INDEX idx_audit_logs_action ON public.audit_logs(action);
CREATE INDEX idx_audit_logs_resource_type ON public.audit_logs(resource_type);
CREATE INDEX idx_audit_logs_resource_id ON public.audit_logs(resource_id);
CREATE INDEX idx_audit_logs_severity ON public.audit_logs(severity);
CREATE INDEX idx_audit_logs_created_at ON public.audit_logs(created_at);

-- =====================================================
-- COMPOSITE INDEXES FOR COMPLEX QUERIES
-- =====================================================

-- User activity tracking
CREATE INDEX idx_user_activity ON public.audit_logs(user_id, created_at DESC);

-- Todo management
CREATE INDEX idx_todos_user_status_priority ON public.todos(user_id, status, priority);
CREATE INDEX idx_todos_user_due_date ON public.todos(user_id, due_date) WHERE due_date IS NOT NULL;

-- Financial tracking
CREATE INDEX idx_transactions_user_date_type ON public.transactions(user_id, transaction_date DESC, transaction_type);
CREATE INDEX idx_transactions_user_category_date ON public.transactions(user_id, category_id, transaction_date DESC);

-- Location tracking
CREATE INDEX idx_location_history_user_time ON public.location_history(user_id, recorded_at DESC);

-- API monitoring
CREATE INDEX idx_api_health_user_time ON public.api_health_logs(user_id, checked_at DESC);
CREATE INDEX idx_api_requests_user_time ON public.api_request_history(user_id, executed_at DESC);

-- Media management
CREATE INDEX idx_media_user_type_date ON public.media_files(user_id, media_type, taken_at DESC);

-- Performance monitoring
CREATE INDEX idx_performance_user_category_time ON public.performance_metrics(user_id, metric_category, recorded_at DESC);

-- =====================================================
-- PARTIAL INDEXES FOR OPTIMIZATION
-- =====================================================

-- Active sessions only
CREATE INDEX idx_active_sessions ON public.user_sessions(user_id, expires_at) WHERE is_active = true;

-- Pending todos only
CREATE INDEX idx_pending_todos ON public.todos(user_id, due_date) WHERE status = 'pending';

-- Failed API requests only
CREATE INDEX idx_failed_api_requests ON public.api_request_history(user_id, executed_at DESC) WHERE is_successful = false;

-- Unread notifications only
CREATE INDEX idx_unread_notifications ON public.notifications(user_id, created_at DESC) WHERE is_read = false;

-- Active geofences only
CREATE INDEX idx_active_geofences ON public.geofences(user_id) WHERE is_active = true;

-- Recent location history (last 30 days)
CREATE INDEX idx_recent_location_history ON public.location_history(user_id, recorded_at DESC) 
WHERE recorded_at > NOW() - INTERVAL '30 days';

-- =====================================================
-- FULL-TEXT SEARCH INDEXES
-- =====================================================

-- Todo search
CREATE INDEX idx_todos_search ON public.todos USING gin(to_tsvector('indonesian', title || ' ' || COALESCE(description, '')));

-- Transaction search
CREATE INDEX idx_transactions_search ON public.transactions USING gin(to_tsvector('indonesian', title || ' ' || COALESCE(description, '')));

-- Location search
CREATE INDEX idx_saved_locations_search ON public.saved_locations USING gin(to_tsvector('indonesian', name || ' ' || COALESCE(description, '') || ' ' || COALESCE(address, '')));

-- Media search
CREATE INDEX idx_media_files_search ON public.media_files USING gin(to_tsvector('indonesian', filename || ' ' || COALESCE(location_name, '')));

-- =====================================================
-- CONSTRAINTS AND CHECKS
-- =====================================================

-- Ensure valid coordinates (latitude: -90 to 90, longitude: -180 to 180)
ALTER TABLE public.todos ADD CONSTRAINT check_todos_valid_coordinates 
CHECK (location_coordinates IS NULL OR (
    ST_X(location_coordinates) BETWEEN -180 AND 180 AND 
    ST_Y(location_coordinates) BETWEEN -90 AND 90
));

ALTER TABLE public.saved_locations ADD CONSTRAINT check_saved_locations_valid_coordinates 
CHECK (ST_X(coordinates) BETWEEN -180 AND 180 AND ST_Y(coordinates) BETWEEN -90 AND 90);

ALTER TABLE public.location_history ADD CONSTRAINT check_location_history_valid_coordinates 
CHECK (ST_X(coordinates) BETWEEN -180 AND 180 AND ST_Y(coordinates) BETWEEN -90 AND 90);

-- Ensure positive amounts for transactions
ALTER TABLE public.transactions ADD CONSTRAINT check_transactions_positive_amount 
CHECK (amount > 0);

-- Ensure valid percentages
ALTER TABLE public.system_metrics ADD CONSTRAINT check_system_metrics_valid_percentages 
CHECK (
    (cpu_usage IS NULL OR cpu_usage BETWEEN 0 AND 100) AND
    (battery_level IS NULL OR battery_level BETWEEN 0 AND 100)
);

-- Ensure valid HTTP status codes
ALTER TABLE public.api_health_logs ADD CONSTRAINT check_api_health_valid_status_code 
CHECK (status_code IS NULL OR status_code BETWEEN 100 AND 599);

-- Ensure valid geofence radius
ALTER TABLE public.geofences ADD CONSTRAINT check_geofences_valid_radius 
CHECK (radius > 0 AND radius <= 10000); -- Max 10km radius

-- Ensure valid file sizes
ALTER TABLE public.media_files ADD CONSTRAINT check_media_files_valid_size 
CHECK (file_size IS NULL OR file_size > 0);

-- Ensure valid ratings
ALTER TABLE public.saved_locations ADD CONSTRAINT check_saved_locations_valid_rating 
CHECK (rating IS NULL OR (rating >= 0 AND rating <= 5));

-- =====================================================
-- TRIGGERS FOR UPDATED_AT TIMESTAMPS
-- =====================================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply trigger to all tables with updated_at column
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON public.users FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_user_sessions_updated_at BEFORE UPDATE ON public.user_sessions FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_user_preferences_updated_at BEFORE UPDATE ON public.user_preferences FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_todo_categories_updated_at BEFORE UPDATE ON public.todo_categories FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_todos_updated_at BEFORE UPDATE ON public.todos FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_todo_comments_updated_at BEFORE UPDATE ON public.todo_comments FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_media_albums_updated_at BEFORE UPDATE ON public.media_albums FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_media_files_updated_at BEFORE UPDATE ON public.media_files FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_transaction_categories_updated_at BEFORE UPDATE ON public.transaction_categories FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_payment_methods_updated_at BEFORE UPDATE ON public.payment_methods FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_transactions_updated_at BEFORE UPDATE ON public.transactions FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_budgets_updated_at BEFORE UPDATE ON public.budgets FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_financial_goals_updated_at BEFORE UPDATE ON public.financial_goals FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_saved_locations_updated_at BEFORE UPDATE ON public.saved_locations FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_geofences_updated_at BEFORE UPDATE ON public.geofences FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_api_endpoints_updated_at BEFORE UPDATE ON public.api_endpoints FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_debug_sessions_updated_at BEFORE UPDATE ON public.debug_sessions FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_notifications_updated_at BEFORE UPDATE ON public.notifications FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_app_settings_updated_at BEFORE UPDATE ON public.app_settings FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
