-- Script para verificar productores disponibles

-- Ver todos los perfiles con rol producer
SELECT 'Productores en profiles:' as check_name;
SELECT id, full_name, email, role, created_at 
FROM profiles 
WHERE role = 'producer'
ORDER BY full_name;

-- Ver todos los perfiles (cualquier rol)
SELECT 'Todos los perfiles:' as check_name;
SELECT id, full_name, email, role 
FROM profiles 
ORDER BY role, full_name;

-- Verificar si Finca El Triunfo existe en producers
SELECT 'Finca El Triunfo en tabla producers:' as check_name;
SELECT id, farm_name, phone, status
FROM producers
WHERE id = '2ab61eee-44d1-4451-b70a-fc249308acf9';
