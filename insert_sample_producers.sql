-- ========================================
-- Script de Datos de Ejemplo: Productores Cafetaleros Mexicanos
-- Fecha: 2025-12-04
-- Descripción: 5 productores de diferentes regiones cafetaleras de México
-- ========================================

-- IMPORTANTE: Ejecuta primero la migración de coordenadas si no lo has hecho
-- (add_location_coordinates.sql)

-- ========================================
-- PRODUCTOR 1: Chiapas (Principal productor de México)
-- ========================================
INSERT INTO public.producers (
    farm_name,
    phone,
    farm_size_ha,
    municipality,
    state,
    country,
    latitude,
    longitude,
    altitude,
    shade_type,
    annual_production_kg,
    last_harvest_date,
    yield_per_ha,
    price_per_kg,
    current_buyers,
    min_contract_volume,
    open_to_export,
    sells_online,
    needs,
    has_tourist_area,
    tourist_accessible,
    varieties,
    processes,
    certifications,
    status
) VALUES (
    'Finca El Triunfo',
    '9191234567',
    25.5,
    'Ángel Albino Corzo',
    'Chiapas',
    'México',
    15.1150,
    -92.0868,
    1850,
    'Sombra natural con árboles de plátano',
    12000,
    '2024-03-01',
    470.59,
    85.50,
    'Cooperativa Regional, Exportadores locales',
    500,
    true,
    false,
    'Financiamiento para certificación orgánica',
    true,
    true,
    ARRAY['Typica', 'Bourbon', 'Caturra'],
    ARRAY['Lavado', 'Natural'],
    ARRAY['Comercio Justo', 'Orgánico'],
    'approved'
);

-- ========================================
-- PRODUCTOR 2: Veracruz (Región de Coatepec - famosa por café)
-- ========================================
INSERT INTO public.producers (
    farm_name,
    phone,
    farm_size_ha,
    municipality,
    state,
    country,
    latitude,
    longitude,
    altitude,
    shade_type,
    annual_production_kg,
    last_harvest_date,
    yield_per_ha,
    price_per_kg,
    current_buyers,
    min_contract_volume,
    open_to_export,
    sells_online,
    online_store_url,
    needs,
    has_tourist_area,
    tourist_accessible,
    tourism_details,
    varieties,
    processes,
    certifications,
    status
) VALUES (
    'Café de Coatepec',
    '2281234567',
    18.0,
    'Coatepec',
    'Veracruz',
    'México',
    19.4518,
    -96.9570,
    1200,
    'Sombra mixta con cítricos',
    8500,
    '2024-02-15',
    472.22,
    95.00,
    'Cafeterías especializadas, Tiendas gourmet',
    300,
    true,
    true,
    'https://cafedcoatepec.com',
    'Marketing digital y empaque mejorado',
    true,
    true,
    'Tours de café con degustación, Taller de barismo',
    ARRAY['Arabica', 'Mundo Novo', 'Garnica'],
    ARRAY['Lavado', 'Honey', 'Natural'],
    ARRAY['Denominación de Origen', 'Rainforest Alliance'],
    'approved'
);

-- ========================================
-- PRODUCTOR 3: Oaxaca (Pluma Hidalgo - café de altura)
-- ========================================
INSERT INTO public.producers (
    farm_name,
    phone,
    farm_size_ha,
    municipality,
    state,
    country,
    latitude,
    longitude,
    altitude,
    shade_type,
    annual_production_kg,
    last_harvest_date,
    yield_per_ha,
    price_per_kg,
    current_buyers,
    min_contract_volume,
    open_to_export,
    sells_online,
    needs,
    has_tourist_area,
    tourist_accessible,
    varieties,
    processes,
    certifications,
    status
) VALUES (
    'Pluma Oro del Sur',
    '9581234567',
    32.0,
    'Pluma Hidalgo',
    'Oaxaca',
    'México',
    15.9254,
    -96.4169,
    1650,
    'Sombra densa con árboles nativos',
    15000,
    '2024-01-20',
    468.75,
    110.00,
    'Tostadores de especialidad, Exportación Europa',
    1000,
    true,
    false,
    'Equipo de secado solar, Capacitación en catación',
    false,
    false,
    ARRAY['Typica', 'Pluma', 'Geisha'],
    ARRAY['Lavado', 'Semi-lavado'],
    ARRAY['Orgánico', 'Bird Friendly', 'UTZ'],
    'approved'
);

-- ========================================
-- PRODUCTOR 4: Puebla (Sierra Norte - café orgánico)
-- ========================================
INSERT INTO public.producers (
    farm_name,
    phone,
    farm_size_ha,
    municipality,
    state,
    country,
    latitude,
    longitude,
    altitude,
    shade_type,
    annual_production_kg,
    last_harvest_date,
    yield_per_ha,
    price_per_kg,
    current_buyers,
    min_contract_volume,
    open_to_export,
    sells_online,
    needs,
    has_tourist_area,
    tourist_accessible,
    varieties,
    processes,
    certifications,
    status
) VALUES (
    'Finca Sierra Verde',
    '2211234567',
    15.5,
    'Cuetzalan del Progreso',
    'Puebla',
    'México',
    20.0278,
    -97.5217,
    1100,
    'Sombra orgánica policultivo',
    6500,
    '2024-03-10',
    419.35,
    88.00,
    'Cooperativa estatal, Mercado local',
    250,
    false,
    true,
    'Acceso a mercados de especialidad, Certificación adicional',
    true,
    true,
    ARRAY['Bourbon', 'Caturra', 'Marsellesa'],
    ARRAY['Lavado', 'Natural'],
    ARRAY['Orgánico', 'Comercio Justo'],
    'approved'
);

-- ========================================
-- PRODUCTOR 5: Guerrero (Productor pequeño en proceso)
-- ========================================
INSERT INTO public.producers (
    farm_name,
    phone,
    farm_size_ha,
    municipality,
    state,
    country,
    latitude,
    longitude,
    altitude,
    shade_type,
    annual_production_kg,
    last_harvest_date,
    yield_per_ha,
    price_per_kg,
    current_buyers,
    min_contract_volume,
    open_to_export,
    sells_online,
    needs,
    has_tourist_area,
    tourist_accessible,
    varieties,
    processes,
    certifications,
    status
) VALUES (
    'Café Montaña de Guerrero',
    '7471234567',
    8.5,
    'Atoyac de Álvarez',
    'Guerrero',
    'México',
    17.2063,
    -100.4269,
    950,
    'Sombra parcial',
    3200,
    '2024-02-28',
    376.47,
    75.00,
    'Intermediarios locales',
    150,
    false,
    false,
    'Asesoría técnica, Mejoras en infraestructura, Acceso a financiamiento',
    false,
    false,
    ARRAY['Robusta', 'Caturra'],
    ARRAY['Natural'],
    ARRAY[]::text[],
    'pending'
);

-- ========================================
-- VERIFICAR INSERCIONES
-- ========================================
SELECT 
    farm_name,
    state,
    municipality,
    latitude,
    longitude,
    status,
    created_at
FROM public.producers
ORDER BY created_at DESC
LIMIT 5;

-- ========================================
-- ESTADÍSTICAS DE LOS PRODUCTORES INSERTADOS
-- ========================================
SELECT 
    state,
    COUNT(*) as total_productores,
    SUM(farm_size_ha) as hectareas_totales,
    SUM(annual_production_kg) as produccion_total_kg,
    AVG(price_per_kg) as precio_promedio,
    AVG(altitude) as altitud_promedia
FROM public.producers
GROUP BY state
ORDER BY produccion_total_kg DESC;
