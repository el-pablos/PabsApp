-- =====================================================
-- PabsApp Comprehensive Supabase Database Schema
-- Author: Tamas dari TamsHub
-- Version: 1.0.0
-- Created: 2025-01-19
-- =====================================================

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "postgis";

-- =====================================================
-- 1. AUTHENTICATION & USER MANAGEMENT
-- =====================================================

-- Users table (extends Supabase auth.users)
CREATE TABLE public.users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    auth_user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    full_name VARCHAR(255),
    avatar_url TEXT,
    phone VARCHAR(20),
    date_of_birth DATE,
    gender VARCHAR(10) CHECK (gender IN ('male', 'female', 'other')),
    bio TEXT,
    location VARCHAR(255),
    timezone VARCHAR(50) DEFAULT 'Asia/Jakarta',
    language VARCHAR(10) DEFAULT 'id',
    theme_preference VARCHAR(20) DEFAULT 'system' CHECK (theme_preference IN ('light', 'dark', 'system')),
    notification_settings JSONB DEFAULT '{"email": true, "push": true, "sms": false}',
    privacy_settings JSONB DEFAULT '{"profile_public": true, "location_sharing": false}',
    is_active BOOLEAN DEFAULT true,
    is_verified BOOLEAN DEFAULT false,
    last_login_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- User sessions table
CREATE TABLE public.user_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    session_token VARCHAR(255) UNIQUE NOT NULL,
    device_info JSONB,
    ip_address INET,
    user_agent TEXT,
    is_active BOOLEAN DEFAULT true,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- User preferences table
CREATE TABLE public.user_preferences (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    preference_key VARCHAR(100) NOT NULL,
    preference_value JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, preference_key)
);

-- =====================================================
-- 2. TODOLIST FEATURE
-- =====================================================

-- Todo categories table
CREATE TABLE public.todo_categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    color VARCHAR(7) DEFAULT '#2196F3', -- Hex color code
    icon VARCHAR(50) DEFAULT 'task_alt',
    is_default BOOLEAN DEFAULT false,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, name)
);

-- Todos table
CREATE TABLE public.todos (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    category_id UUID REFERENCES public.todo_categories(id) ON DELETE SET NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    priority VARCHAR(20) DEFAULT 'medium' CHECK (priority IN ('low', 'medium', 'high', 'urgent')),
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'in_progress', 'completed', 'cancelled')),
    due_date TIMESTAMP WITH TIME ZONE,
    reminder_at TIMESTAMP WITH TIME ZONE,
    completed_at TIMESTAMP WITH TIME ZONE,
    
    -- Location data
    location_name VARCHAR(255),
    location_address TEXT,
    location_coordinates POINT, -- PostGIS point type
    location_radius INTEGER DEFAULT 100, -- meters for geofencing
    
    -- Metadata
    tags TEXT[], -- Array of tags
    attachments JSONB DEFAULT '[]', -- Array of attachment objects
    subtasks JSONB DEFAULT '[]', -- Array of subtask objects
    time_estimate INTEGER, -- minutes
    time_spent INTEGER DEFAULT 0, -- minutes
    
    -- System fields
    is_recurring BOOLEAN DEFAULT false,
    recurrence_pattern JSONB, -- Recurrence configuration
    parent_todo_id UUID REFERENCES public.todos(id) ON DELETE CASCADE,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Todo comments/notes table
CREATE TABLE public.todo_comments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    todo_id UUID REFERENCES public.todos(id) ON DELETE CASCADE,
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    comment TEXT NOT NULL,
    attachments JSONB DEFAULT '[]',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- 3. CAMERA & MEDIA STORAGE
-- =====================================================

-- Media albums table
CREATE TABLE public.media_albums (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    cover_media_id UUID, -- Self-reference to media table
    is_private BOOLEAN DEFAULT false,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, name)
);

-- Media files table
CREATE TABLE public.media_files (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    album_id UUID REFERENCES public.media_albums(id) ON DELETE SET NULL,
    
    -- File information
    filename VARCHAR(255) NOT NULL,
    original_filename VARCHAR(255),
    file_path TEXT NOT NULL,
    file_url TEXT,
    file_size BIGINT, -- bytes
    mime_type VARCHAR(100),
    file_hash VARCHAR(64), -- SHA-256 hash for deduplication
    
    -- Media metadata
    media_type VARCHAR(20) CHECK (media_type IN ('photo', 'video', 'audio')),
    duration INTEGER, -- seconds for video/audio
    dimensions JSONB, -- {width: int, height: int}
    orientation INTEGER DEFAULT 1, -- EXIF orientation
    
    -- Location data
    location_name VARCHAR(255),
    location_coordinates POINT,
    location_address TEXT,
    
    -- EXIF/metadata
    camera_make VARCHAR(100),
    camera_model VARCHAR(100),
    camera_settings JSONB, -- ISO, aperture, shutter speed, etc.
    taken_at TIMESTAMP WITH TIME ZONE,
    
    -- Processing status
    processing_status VARCHAR(20) DEFAULT 'pending' CHECK (processing_status IN ('pending', 'processing', 'completed', 'failed')),
    thumbnail_url TEXT,
    compressed_url TEXT,
    
    -- System fields
    tags TEXT[],
    is_favorite BOOLEAN DEFAULT false,
    is_private BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add foreign key constraint for album cover
ALTER TABLE public.media_albums 
ADD CONSTRAINT fk_media_albums_cover 
FOREIGN KEY (cover_media_id) REFERENCES public.media_files(id) ON DELETE SET NULL;

-- =====================================================
-- 4. FINTECH FEATURE
-- =====================================================

-- Transaction categories table
CREATE TABLE public.transaction_categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    category_type VARCHAR(20) CHECK (category_type IN ('income', 'expense', 'transfer')),
    color VARCHAR(7) DEFAULT '#4CAF50',
    icon VARCHAR(50) DEFAULT 'payments',
    parent_category_id UUID REFERENCES public.transaction_categories(id) ON DELETE CASCADE,
    is_default BOOLEAN DEFAULT false,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, name, category_type)
);

-- Payment methods table
CREATE TABLE public.payment_methods (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    method_type VARCHAR(20) CHECK (method_type IN ('cash', 'bank_account', 'credit_card', 'debit_card', 'e_wallet', 'crypto')),
    account_number VARCHAR(100),
    bank_name VARCHAR(100),
    card_last_four VARCHAR(4),
    provider VARCHAR(50), -- e.g., 'gopay', 'ovo', 'dana'
    currency VARCHAR(3) DEFAULT 'IDR',
    balance DECIMAL(15,2) DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    is_default BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, name)
);

-- Transactions table
CREATE TABLE public.transactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    category_id UUID REFERENCES public.transaction_categories(id) ON DELETE SET NULL,
    payment_method_id UUID REFERENCES public.payment_methods(id) ON DELETE SET NULL,
    
    -- Transaction details
    title VARCHAR(255) NOT NULL,
    description TEXT,
    amount DECIMAL(15,2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'IDR',
    transaction_type VARCHAR(20) CHECK (transaction_type IN ('income', 'expense', 'transfer')),
    transaction_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Location data
    location_name VARCHAR(255),
    location_address TEXT,
    location_coordinates POINT,
    
    -- Metadata
    receipt_url TEXT,
    reference_number VARCHAR(100),
    tags TEXT[],
    notes TEXT,
    
    -- Recurring transaction
    is_recurring BOOLEAN DEFAULT false,
    recurrence_pattern JSONB,
    parent_transaction_id UUID REFERENCES public.transactions(id) ON DELETE CASCADE,
    
    -- System fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Budget planning table
CREATE TABLE public.budgets (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    category_id UUID REFERENCES public.transaction_categories(id) ON DELETE CASCADE,
    
    -- Budget details
    name VARCHAR(255) NOT NULL,
    description TEXT,
    budget_amount DECIMAL(15,2) NOT NULL,
    spent_amount DECIMAL(15,2) DEFAULT 0,
    currency VARCHAR(3) DEFAULT 'IDR',
    
    -- Period
    period_type VARCHAR(20) CHECK (period_type IN ('daily', 'weekly', 'monthly', 'yearly', 'custom')),
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    
    -- Alerts
    alert_percentage INTEGER DEFAULT 80, -- Alert when spent reaches this percentage
    alert_enabled BOOLEAN DEFAULT true,
    
    -- System fields
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Financial goals table
CREATE TABLE public.financial_goals (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    
    -- Goal details
    name VARCHAR(255) NOT NULL,
    description TEXT,
    target_amount DECIMAL(15,2) NOT NULL,
    current_amount DECIMAL(15,2) DEFAULT 0,
    currency VARCHAR(3) DEFAULT 'IDR',
    
    -- Timeline
    target_date DATE,
    created_date DATE DEFAULT CURRENT_DATE,
    
    -- Goal type
    goal_type VARCHAR(20) CHECK (goal_type IN ('saving', 'debt_payoff', 'investment', 'purchase', 'emergency_fund')),
    priority VARCHAR(20) DEFAULT 'medium' CHECK (priority IN ('low', 'medium', 'high')),
    
    -- Status
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'completed', 'paused', 'cancelled')),
    completed_at TIMESTAMP WITH TIME ZONE,
    
    -- System fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- 5. HEALTH MONITORING
-- =====================================================

-- System metrics history table
CREATE TABLE public.system_metrics (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    device_id VARCHAR(255), -- Device identifier

    -- System metrics
    cpu_usage DECIMAL(5,2), -- Percentage
    memory_usage DECIMAL(10,2), -- MB
    memory_total DECIMAL(10,2), -- MB
    battery_level INTEGER, -- Percentage
    battery_status VARCHAR(20), -- charging, discharging, full, etc.
    storage_used DECIMAL(15,2), -- GB
    storage_total DECIMAL(15,2), -- GB

    -- Network metrics
    network_type VARCHAR(20), -- wifi, mobile, ethernet
    network_speed_download DECIMAL(10,2), -- Mbps
    network_speed_upload DECIMAL(10,2), -- Mbps
    network_latency INTEGER, -- ms
    data_usage_mobile DECIMAL(15,2), -- MB
    data_usage_wifi DECIMAL(15,2), -- MB

    -- App metrics
    app_memory_usage DECIMAL(10,2), -- MB
    app_cpu_usage DECIMAL(5,2), -- Percentage
    app_startup_time INTEGER, -- ms
    app_crash_count INTEGER DEFAULT 0,

    -- Device info
    device_model VARCHAR(100),
    os_version VARCHAR(50),
    app_version VARCHAR(20),

    -- Timestamp
    recorded_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- API health check logs table
CREATE TABLE public.api_health_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,

    -- API details
    api_name VARCHAR(100) NOT NULL,
    api_url TEXT NOT NULL,
    http_method VARCHAR(10) DEFAULT 'GET',

    -- Health check results
    status_code INTEGER,
    response_time INTEGER, -- ms
    is_healthy BOOLEAN,
    error_message TEXT,
    response_size INTEGER, -- bytes

    -- Request/Response data
    request_headers JSONB,
    request_body TEXT,
    response_headers JSONB,
    response_body TEXT,

    -- Metadata
    check_type VARCHAR(20) DEFAULT 'manual' CHECK (check_type IN ('manual', 'scheduled', 'automated')),
    location_coordinates POINT,

    -- Timestamp
    checked_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Performance monitoring data table
CREATE TABLE public.performance_metrics (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,

    -- Performance metrics
    metric_name VARCHAR(100) NOT NULL,
    metric_value DECIMAL(15,4),
    metric_unit VARCHAR(20), -- ms, mb, percentage, count, etc.
    metric_category VARCHAR(50), -- startup, memory, network, ui, etc.

    -- Context
    screen_name VARCHAR(100),
    action_name VARCHAR(100),
    session_id UUID,

    -- Device context
    device_model VARCHAR(100),
    os_version VARCHAR(50),
    app_version VARCHAR(20),

    -- Timestamp
    recorded_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Weather data cache table
CREATE TABLE public.weather_data (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,

    -- Location
    location_name VARCHAR(255),
    location_coordinates POINT NOT NULL,
    country_code VARCHAR(2),
    timezone VARCHAR(50),

    -- Current weather
    temperature DECIMAL(5,2), -- Celsius
    feels_like DECIMAL(5,2), -- Celsius
    humidity INTEGER, -- Percentage
    pressure DECIMAL(7,2), -- hPa
    visibility DECIMAL(5,2), -- km
    uv_index DECIMAL(3,1),

    -- Weather conditions
    weather_main VARCHAR(50), -- Clear, Clouds, Rain, etc.
    weather_description VARCHAR(100),
    weather_icon VARCHAR(10),

    -- Wind
    wind_speed DECIMAL(5,2), -- m/s
    wind_direction INTEGER, -- degrees
    wind_gust DECIMAL(5,2), -- m/s

    -- Additional data
    sunrise_time TIMESTAMP WITH TIME ZONE,
    sunset_time TIMESTAMP WITH TIME ZONE,
    cloud_coverage INTEGER, -- Percentage

    -- Data source and freshness
    data_source VARCHAR(50) DEFAULT 'openweathermap',
    api_response JSONB, -- Full API response for reference
    expires_at TIMESTAMP WITH TIME ZONE,

    -- Timestamp
    fetched_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- 6. LOCATION SERVICES
-- =====================================================

-- Saved locations table
CREATE TABLE public.saved_locations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,

    -- Location details
    name VARCHAR(255) NOT NULL,
    description TEXT,
    address TEXT,
    coordinates POINT NOT NULL,
    altitude DECIMAL(10,2), -- meters
    accuracy DECIMAL(8,2), -- meters

    -- Location metadata
    location_type VARCHAR(50) DEFAULT 'custom', -- home, work, favorite, custom
    category VARCHAR(100), -- restaurant, hospital, school, etc.
    tags TEXT[],

    -- Additional info
    phone VARCHAR(20),
    website TEXT,
    opening_hours JSONB,
    rating DECIMAL(2,1) CHECK (rating >= 0 AND rating <= 5),
    notes TEXT,

    -- Privacy and sharing
    is_private BOOLEAN DEFAULT true,
    is_favorite BOOLEAN DEFAULT false,

    -- Visit tracking
    visit_count INTEGER DEFAULT 0,
    last_visited_at TIMESTAMP WITH TIME ZONE,

    -- System fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Location history table
CREATE TABLE public.location_history (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,

    -- Location data
    coordinates POINT NOT NULL,
    altitude DECIMAL(10,2), -- meters
    accuracy DECIMAL(8,2), -- meters
    speed DECIMAL(8,2), -- m/s
    heading DECIMAL(5,2), -- degrees

    -- Context
    activity_type VARCHAR(50), -- walking, driving, stationary, etc.
    confidence_level INTEGER, -- 0-100
    address TEXT,

    -- Tracking metadata
    tracking_source VARCHAR(20) DEFAULT 'gps', -- gps, network, passive
    battery_level INTEGER,
    is_mock_location BOOLEAN DEFAULT false,

    -- Timestamp
    recorded_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Geofencing rules table
CREATE TABLE public.geofences (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    saved_location_id UUID REFERENCES public.saved_locations(id) ON DELETE CASCADE,

    -- Geofence configuration
    name VARCHAR(255) NOT NULL,
    description TEXT,
    center_coordinates POINT NOT NULL,
    radius INTEGER NOT NULL, -- meters

    -- Trigger configuration
    trigger_on_enter BOOLEAN DEFAULT true,
    trigger_on_exit BOOLEAN DEFAULT true,
    trigger_on_dwell BOOLEAN DEFAULT false,
    dwell_time INTEGER DEFAULT 300, -- seconds

    -- Actions
    notification_title VARCHAR(255),
    notification_message TEXT,
    webhook_url TEXT,
    action_data JSONB,

    -- Status
    is_active BOOLEAN DEFAULT true,
    last_triggered_at TIMESTAMP WITH TIME ZONE,
    trigger_count INTEGER DEFAULT 0,

    -- System fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Geofence events table
CREATE TABLE public.geofence_events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    geofence_id UUID REFERENCES public.geofences(id) ON DELETE CASCADE,

    -- Event details
    event_type VARCHAR(20) CHECK (event_type IN ('enter', 'exit', 'dwell')),
    coordinates POINT NOT NULL,
    accuracy DECIMAL(8,2), -- meters

    -- Context
    activity_type VARCHAR(50),
    confidence_level INTEGER,
    battery_level INTEGER,

    -- Processing
    notification_sent BOOLEAN DEFAULT false,
    webhook_called BOOLEAN DEFAULT false,
    processing_status VARCHAR(20) DEFAULT 'pending',
    error_message TEXT,

    -- Timestamp
    triggered_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    processed_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- 7. API DEBUG TOOLS
-- =====================================================

-- API endpoint configurations table
CREATE TABLE public.api_endpoints (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,

    -- Endpoint details
    name VARCHAR(255) NOT NULL,
    description TEXT,
    base_url TEXT NOT NULL,
    endpoint_path TEXT NOT NULL,
    http_method VARCHAR(10) DEFAULT 'GET' CHECK (http_method IN ('GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'HEAD', 'OPTIONS')),

    -- Configuration
    headers JSONB DEFAULT '{}',
    query_parameters JSONB DEFAULT '{}',
    request_body TEXT,
    content_type VARCHAR(100) DEFAULT 'application/json',

    -- Authentication
    auth_type VARCHAR(20) DEFAULT 'none' CHECK (auth_type IN ('none', 'bearer', 'basic', 'api_key', 'oauth')),
    auth_config JSONB DEFAULT '{}',

    -- Organization
    category VARCHAR(100) DEFAULT 'general',
    tags TEXT[],
    is_favorite BOOLEAN DEFAULT false,

    -- Usage tracking
    usage_count INTEGER DEFAULT 0,
    last_used_at TIMESTAMP WITH TIME ZONE,

    -- System fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- API request/response history table
CREATE TABLE public.api_request_history (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    endpoint_id UUID REFERENCES public.api_endpoints(id) ON DELETE SET NULL,

    -- Request details
    request_url TEXT NOT NULL,
    http_method VARCHAR(10) NOT NULL,
    request_headers JSONB,
    request_body TEXT,

    -- Response details
    status_code INTEGER,
    response_headers JSONB,
    response_body TEXT,
    response_time INTEGER, -- ms
    response_size INTEGER, -- bytes

    -- Error handling
    error_message TEXT,
    error_type VARCHAR(50), -- network, timeout, parsing, etc.

    -- Context
    session_id UUID,
    location_coordinates POINT,

    -- Metadata
    notes TEXT,
    is_successful BOOLEAN,

    -- Timestamp
    executed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Debug session logs table
CREATE TABLE public.debug_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,

    -- Session details
    session_name VARCHAR(255),
    description TEXT,
    session_type VARCHAR(50) DEFAULT 'manual', -- manual, automated, load_test

    -- Configuration
    target_endpoints TEXT[], -- Array of endpoint URLs
    test_duration INTEGER, -- seconds
    concurrent_requests INTEGER DEFAULT 1,
    request_interval INTEGER DEFAULT 1000, -- ms

    -- Results summary
    total_requests INTEGER DEFAULT 0,
    successful_requests INTEGER DEFAULT 0,
    failed_requests INTEGER DEFAULT 0,
    average_response_time DECIMAL(10,2), -- ms
    min_response_time INTEGER, -- ms
    max_response_time INTEGER, -- ms

    -- Status
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'completed', 'failed', 'cancelled')),
    started_at TIMESTAMP WITH TIME ZONE,
    completed_at TIMESTAMP WITH TIME ZONE,

    -- System fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- 8. SYSTEM TABLES & UTILITIES
-- =====================================================

-- App notifications table
CREATE TABLE public.notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,

    -- Notification content
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    notification_type VARCHAR(50) DEFAULT 'info', -- info, warning, error, success
    category VARCHAR(100), -- system, todo, transaction, location, etc.

    -- Metadata
    action_url TEXT,
    action_data JSONB,
    image_url TEXT,

    -- Delivery
    delivery_method VARCHAR(20) DEFAULT 'push' CHECK (delivery_method IN ('push', 'email', 'sms', 'in_app')),
    is_read BOOLEAN DEFAULT false,
    read_at TIMESTAMP WITH TIME ZONE,

    -- Scheduling
    scheduled_at TIMESTAMP WITH TIME ZONE,
    delivered_at TIMESTAMP WITH TIME ZONE,
    expires_at TIMESTAMP WITH TIME ZONE,

    -- System fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- App settings table
CREATE TABLE public.app_settings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,

    -- Setting details
    setting_key VARCHAR(100) NOT NULL,
    setting_value JSONB,
    setting_type VARCHAR(20) DEFAULT 'string' CHECK (setting_type IN ('string', 'number', 'boolean', 'object', 'array')),

    -- Metadata
    category VARCHAR(50), -- ui, privacy, notifications, etc.
    description TEXT,
    is_system BOOLEAN DEFAULT false,

    -- System fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, setting_key)
);

-- Audit logs table
CREATE TABLE public.audit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES public.users(id) ON DELETE SET NULL,

    -- Action details
    action VARCHAR(100) NOT NULL, -- create, update, delete, login, logout, etc.
    resource_type VARCHAR(100), -- user, todo, transaction, etc.
    resource_id UUID,

    -- Change details
    old_values JSONB,
    new_values JSONB,
    changes JSONB, -- Specific fields that changed

    -- Context
    ip_address INET,
    user_agent TEXT,
    session_id UUID,
    location_coordinates POINT,

    -- Metadata
    severity VARCHAR(20) DEFAULT 'info' CHECK (severity IN ('debug', 'info', 'warning', 'error', 'critical')),
    description TEXT,

    -- Timestamp
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
