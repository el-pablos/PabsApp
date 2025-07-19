-- =====================================================
-- PabsApp Sample Data for Testing
-- Author: Tamas dari TamsHub
-- Version: 1.0.0
-- Created: 2025-01-19
-- =====================================================

-- Note: This script assumes you have a test user in auth.users
-- Replace 'your-auth-user-id' with actual auth user ID

-- =====================================================
-- SAMPLE USER DATA
-- =====================================================

-- Insert sample user (replace with actual auth.users ID)
INSERT INTO public.users (
    id,
    auth_user_id,
    username,
    email,
    full_name,
    bio,
    location,
    theme_preference,
    is_active,
    is_verified
) VALUES (
    '550e8400-e29b-41d4-a716-446655440000',
    '550e8400-e29b-41d4-a716-446655440000', -- Replace with actual auth user ID
    'tamas',
    'tamas@tamshub.com',
    'Tamas dari TamsHub',
    'Lead Developer & Architect of PabsApp',
    'Jakarta, Indonesia',
    'system',
    true,
    true
) ON CONFLICT (username) DO NOTHING;

-- Sample user preferences
INSERT INTO public.user_preferences (user_id, preference_key, preference_value) VALUES
('550e8400-e29b-41d4-a716-446655440000', 'language', '"id"'),
('550e8400-e29b-41d4-a716-446655440000', 'timezone', '"Asia/Jakarta"'),
('550e8400-e29b-41d4-a716-446655440000', 'auto_backup', 'true'),
('550e8400-e29b-41d4-a716-446655440000', 'location_tracking', 'true'),
('550e8400-e29b-41d4-a716-446655440000', 'push_notifications', 'true')
ON CONFLICT (user_id, preference_key) DO NOTHING;

-- =====================================================
-- SAMPLE TODO DATA
-- =====================================================

-- Sample todo categories
INSERT INTO public.todo_categories (id, user_id, name, description, color, icon) VALUES
('660e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440000', 'Pekerjaan', 'Tugas-tugas pekerjaan', '#2196F3', 'work'),
('660e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440000', 'Pribadi', 'Kegiatan pribadi', '#4CAF50', 'person'),
('660e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440000', 'Belanja', 'Daftar belanja', '#FF9800', 'shopping_cart'),
('660e8400-e29b-41d4-a716-446655440004', '550e8400-e29b-41d4-a716-446655440000', 'Kesehatan', 'Aktivitas kesehatan', '#E91E63', 'health_and_safety')
ON CONFLICT (user_id, name) DO NOTHING;

-- Sample todos
INSERT INTO public.todos (id, user_id, category_id, title, description, priority, status, due_date, location_name, location_coordinates) VALUES
('770e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440000', '660e8400-e29b-41d4-a716-446655440001', 'Selesaikan dokumentasi PabsApp', 'Lengkapi README.md dan dokumentasi API', 'high', 'in_progress', NOW() + INTERVAL '2 days', 'Kantor TamsHub', POINT(106.8456, -6.2088)),
('770e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440000', '660e8400-e29b-41d4-a716-446655440002', 'Beli groceries', 'Beli bahan makanan untuk minggu ini', 'medium', 'pending', NOW() + INTERVAL '1 day', 'Supermarket Indomaret', POINT(106.8500, -6.2100)),
('770e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440000', '660e8400-e29b-41d4-a716-446655440004', 'Medical checkup', 'Pemeriksaan kesehatan rutin', 'high', 'pending', NOW() + INTERVAL '3 days', 'RS Siloam', POINT(106.8400, -6.2000)),
('770e8400-e29b-41d4-a716-446655440004', '550e8400-e29b-41d4-a716-446655440000', '660e8400-e29b-41d4-a716-446655440001', 'Code review Flutter app', 'Review kode aplikasi Flutter terbaru', 'medium', 'completed', NOW() - INTERVAL '1 day', NULL, NULL)
ON CONFLICT (id) DO NOTHING;

-- =====================================================
-- SAMPLE FINTECH DATA
-- =====================================================

-- Sample transaction categories
INSERT INTO public.transaction_categories (id, user_id, name, description, category_type, color, icon) VALUES
('880e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440000', 'Gaji', 'Pendapatan dari gaji', 'income', '#4CAF50', 'payments'),
('880e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440000', 'Makanan', 'Pengeluaran untuk makanan', 'expense', '#FF5722', 'restaurant'),
('880e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440000', 'Transportasi', 'Biaya transportasi', 'expense', '#2196F3', 'directions_car'),
('880e8400-e29b-41d4-a716-446655440004', '550e8400-e29b-41d4-a716-446655440000', 'Hiburan', 'Pengeluaran hiburan', 'expense', '#9C27B0', 'movie'),
('880e8400-e29b-41d4-a716-446655440005', '550e8400-e29b-41d4-a716-446655440000', 'Freelance', 'Pendapatan freelance', 'income', '#00BCD4', 'work')
ON CONFLICT (user_id, name, category_type) DO NOTHING;

-- Sample payment methods
INSERT INTO public.payment_methods (id, user_id, name, method_type, provider, currency, balance, is_default) VALUES
('990e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440000', 'Cash', 'cash', NULL, 'IDR', 500000, true),
('990e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440000', 'BCA Debit', 'debit_card', 'BCA', 'IDR', 2500000, false),
('990e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440000', 'GoPay', 'e_wallet', 'gopay', 'IDR', 150000, false),
('990e8400-e29b-41d4-a716-446655440004', '550e8400-e29b-41d4-a716-446655440000', 'OVO', 'e_wallet', 'ovo', 'IDR', 75000, false)
ON CONFLICT (user_id, name) DO NOTHING;

-- Sample transactions
INSERT INTO public.transactions (id, user_id, category_id, payment_method_id, title, description, amount, transaction_type, transaction_date, location_name, location_coordinates) VALUES
('aa0e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440000', '880e8400-e29b-41d4-a716-446655440001', '990e8400-e29b-41d4-a716-446655440002', 'Gaji Januari 2025', 'Gaji bulanan dari TamsHub', 8500000, 'income', NOW() - INTERVAL '5 days', 'TamsHub Office', POINT(106.8456, -6.2088)),
('aa0e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440000', '880e8400-e29b-41d4-a716-446655440002', '990e8400-e29b-41d4-a716-446655440003', 'Makan siang', 'Warteg Bahari', 25000, 'expense', NOW() - INTERVAL '1 day', 'Warteg Bahari', POINT(106.8500, -6.2100)),
('aa0e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440000', '880e8400-e29b-41d4-a716-446655440003', '990e8400-e29b-41d4-a716-446655440003', 'Ojek online', 'Perjalanan ke kantor', 15000, 'expense', NOW() - INTERVAL '2 hours', 'Jalan Sudirman', POINT(106.8200, -6.2200)),
('aa0e8400-e29b-41d4-a716-446655440004', '550e8400-e29b-41d4-a716-446655440000', '880e8400-e29b-41d4-a716-446655440005', '990e8400-e29b-41d4-a716-446655440002', 'Project Flutter', 'Pembayaran project aplikasi mobile', 3500000, 'income', NOW() - INTERVAL '3 days', NULL, NULL)
ON CONFLICT (id) DO NOTHING;

-- Sample budget
INSERT INTO public.budgets (id, user_id, category_id, name, description, budget_amount, spent_amount, period_type, start_date, end_date) VALUES
('bb0e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440000', '880e8400-e29b-41d4-a716-446655440002', 'Budget Makanan Januari', 'Budget untuk makanan bulan Januari', 1500000, 450000, 'monthly', '2025-01-01', '2025-01-31'),
('bb0e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440000', '880e8400-e29b-41d4-a716-446655440003', 'Budget Transportasi Januari', 'Budget untuk transportasi bulan Januari', 800000, 250000, 'monthly', '2025-01-01', '2025-01-31')
ON CONFLICT (id) DO NOTHING;

-- Sample financial goals
INSERT INTO public.financial_goals (id, user_id, name, description, target_amount, current_amount, target_date, goal_type, priority) VALUES
('cc0e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440000', 'Emergency Fund', 'Dana darurat untuk 6 bulan', 50000000, 15000000, '2025-12-31', 'emergency_fund', 'high'),
('cc0e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440000', 'Laptop Baru', 'Beli MacBook Pro untuk development', 35000000, 8500000, '2025-06-30', 'purchase', 'medium')
ON CONFLICT (id) DO NOTHING;

-- =====================================================
-- SAMPLE LOCATION DATA
-- =====================================================

-- Sample saved locations
INSERT INTO public.saved_locations (id, user_id, name, description, address, coordinates, location_type, category, is_favorite) VALUES
('dd0e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440000', 'Rumah', 'Rumah pribadi', 'Jl. Kebon Jeruk No. 123, Jakarta Barat', POINT(106.7800, -6.1800), 'home', 'residence', true),
('dd0e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440000', 'Kantor TamsHub', 'Kantor tempat bekerja', 'Jl. Sudirman No. 456, Jakarta Pusat', POINT(106.8456, -6.2088), 'work', 'office', true),
('dd0e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440000', 'Starbucks Senayan', 'Tempat favorit untuk meeting', 'Senayan City Mall, Jakarta Selatan', POINT(106.8000, -6.2300), 'favorite', 'cafe', true),
('dd0e8400-e29b-41d4-a716-446655440004', '550e8400-e29b-41d4-a716-446655440000', 'Gym Fitness First', 'Tempat olahraga rutin', 'Plaza Indonesia, Jakarta Pusat', POINT(106.8200, -6.1950), 'custom', 'fitness', false)
ON CONFLICT (id) DO NOTHING;

-- Sample location history (last 24 hours)
INSERT INTO public.location_history (user_id, coordinates, accuracy, activity_type, recorded_at) VALUES
('550e8400-e29b-41d4-a716-446655440000', POINT(106.7800, -6.1800), 10.5, 'stationary', NOW() - INTERVAL '8 hours'),
('550e8400-e29b-41d4-a716-446655440000', POINT(106.7850, -6.1850), 15.2, 'walking', NOW() - INTERVAL '7 hours'),
('550e8400-e29b-41d4-a716-446655440000', POINT(106.8200, -6.2000), 8.7, 'driving', NOW() - INTERVAL '6 hours'),
('550e8400-e29b-41d4-a716-446655440000', POINT(106.8456, -6.2088), 12.3, 'stationary', NOW() - INTERVAL '4 hours'),
('550e8400-e29b-41d4-a716-446655440000', POINT(106.8400, -6.2050), 9.8, 'walking', NOW() - INTERVAL '2 hours')
ON CONFLICT (id) DO NOTHING;

-- =====================================================
-- SAMPLE API DEBUG DATA
-- =====================================================

-- Sample API endpoints
INSERT INTO public.api_endpoints (id, user_id, name, description, base_url, endpoint_path, http_method, category, is_favorite) VALUES
('ee0e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440000', 'Weather API', 'OpenWeatherMap current weather', 'https://api.openweathermap.org', '/data/2.5/weather', 'GET', 'weather', true),
('ee0e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440000', 'JSONPlaceholder Posts', 'Test API for posts', 'https://jsonplaceholder.typicode.com', '/posts', 'GET', 'testing', false),
('ee0e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440000', 'GitHub User API', 'Get GitHub user info', 'https://api.github.com', '/users/el-pablos', 'GET', 'github', true),
('ee0e8400-e29b-41d4-a716-446655440004', '550e8400-e29b-41d4-a716-446655440000', 'Supabase Health Check', 'Check Supabase status', 'https://status.supabase.com', '/api/v2/status.json', 'GET', 'database', false)
ON CONFLICT (id) DO NOTHING;

-- Sample API request history
INSERT INTO public.api_request_history (id, user_id, endpoint_id, request_url, http_method, status_code, response_time, is_successful, executed_at) VALUES
('ff0e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440000', 'ee0e8400-e29b-41d4-a716-446655440001', 'https://api.openweathermap.org/data/2.5/weather?q=Jakarta', 'GET', 200, 1250, true, NOW() - INTERVAL '1 hour'),
('ff0e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440000', 'ee0e8400-e29b-41d4-a716-446655440002', 'https://jsonplaceholder.typicode.com/posts', 'GET', 200, 850, true, NOW() - INTERVAL '2 hours'),
('ff0e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440000', 'ee0e8400-e29b-41d4-a716-446655440003', 'https://api.github.com/users/el-pablos', 'GET', 200, 650, true, NOW() - INTERVAL '3 hours'),
('ff0e8400-e29b-41d4-a716-446655440004', '550e8400-e29b-41d4-a716-446655440000', 'ee0e8400-e29b-41d4-a716-446655440004', 'https://status.supabase.com/api/v2/status.json', 'GET', 200, 450, true, NOW() - INTERVAL '30 minutes')
ON CONFLICT (id) DO NOTHING;

-- =====================================================
-- SAMPLE SYSTEM DATA
-- =====================================================

-- Sample notifications
INSERT INTO public.notifications (id, user_id, title, message, notification_type, category, is_read) VALUES
('110e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440000', 'Selamat Datang!', 'Selamat datang di PabsApp! Mulai jelajahi fitur-fitur menarik.', 'success', 'system', false),
('110e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440000', 'Todo Deadline', 'Todo "Medical checkup" akan jatuh tempo dalam 1 hari.', 'warning', 'todo', false),
('110e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440000', 'Budget Alert', 'Budget makanan sudah mencapai 30% dari limit bulanan.', 'info', 'transaction', true),
('110e8400-e29b-41d4-a716-446655440004', '550e8400-e29b-41d4-a716-446655440000', 'Location Update', 'Anda telah tiba di lokasi favorit: Starbucks Senayan.', 'info', 'location', true)
ON CONFLICT (id) DO NOTHING;

-- Sample app settings
INSERT INTO public.app_settings (user_id, setting_key, setting_value, setting_type, category) VALUES
('550e8400-e29b-41d4-a716-446655440000', 'auto_backup_enabled', 'true', 'boolean', 'backup'),
('550e8400-e29b-41d4-a716-446655440000', 'backup_frequency', '"daily"', 'string', 'backup'),
('550e8400-e29b-41d4-a716-446655440000', 'location_tracking_enabled', 'true', 'boolean', 'privacy'),
('550e8400-e29b-41d4-a716-446655440000', 'location_accuracy', '"high"', 'string', 'privacy'),
('550e8400-e29b-41d4-a716-446655440000', 'push_notifications_enabled', 'true', 'boolean', 'notifications'),
('550e8400-e29b-41d4-a716-446655440000', 'email_notifications_enabled', 'false', 'boolean', 'notifications'),
('550e8400-e29b-41d4-a716-446655440000', 'theme_mode', '"system"', 'string', 'ui'),
('550e8400-e29b-41d4-a716-446655440000', 'language', '"id"', 'string', 'ui'),
('550e8400-e29b-41d4-a716-446655440000', 'currency', '"IDR"', 'string', 'fintech'),
('550e8400-e29b-41d4-a716-446655440000', 'default_todo_priority', '"medium"', 'string', 'todo')
ON CONFLICT (user_id, setting_key) DO NOTHING;

-- =====================================================
-- SAMPLE HEALTH MONITORING DATA
-- =====================================================

-- Sample system metrics (last 24 hours)
INSERT INTO public.system_metrics (user_id, device_id, cpu_usage, memory_usage, memory_total, battery_level, network_type, app_memory_usage, device_model, os_version, app_version, recorded_at) VALUES
('550e8400-e29b-41d4-a716-446655440000', 'M2102J20SG', 45.2, 3200.5, 8192.0, 85, 'wifi', 150.2, 'Xiaomi Redmi Note 10', 'Android 11', '1.0.0', NOW() - INTERVAL '1 hour'),
('550e8400-e29b-41d4-a716-446655440000', 'M2102J20SG', 38.7, 3150.8, 8192.0, 82, 'wifi', 148.7, 'Xiaomi Redmi Note 10', 'Android 11', '1.0.0', NOW() - INTERVAL '2 hours'),
('550e8400-e29b-41d4-a716-446655440000', 'M2102J20SG', 52.1, 3400.2, 8192.0, 78, 'mobile', 155.3, 'Xiaomi Redmi Note 10', 'Android 11', '1.0.0', NOW() - INTERVAL '4 hours'),
('550e8400-e29b-41d4-a716-446655440000', 'M2102J20SG', 41.8, 3100.1, 8192.0, 75, 'mobile', 145.9, 'Xiaomi Redmi Note 10', 'Android 11', '1.0.0', NOW() - INTERVAL '6 hours')
ON CONFLICT (id) DO NOTHING;

-- Sample weather data
INSERT INTO public.weather_data (user_id, location_name, location_coordinates, temperature, feels_like, humidity, weather_main, weather_description, data_source, expires_at) VALUES
('550e8400-e29b-41d4-a716-446655440000', 'Jakarta', POINT(106.8456, -6.2088), 28.5, 32.1, 75, 'Clouds', 'Berawan sebagian', 'openweathermap', NOW() + INTERVAL '1 hour')
ON CONFLICT (id) DO NOTHING;
