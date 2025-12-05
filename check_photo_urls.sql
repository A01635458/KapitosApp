-- Verificar los photo_url en la tabla profiles
SELECT 
    id,
    full_name,
    email,
    role,
    photo_url,
    CASE 
        WHEN photo_url IS NULL THEN '❌ NULL'
        WHEN photo_url = '' THEN '⚠️ EMPTY STRING'
        ELSE '✅ HAS VALUE'
    END as photo_url_status
FROM public.profiles
ORDER BY created_at DESC;

-- Ver cuántos perfiles tienen foto
SELECT 
    COUNT(*) as total_profiles,
    COUNT(photo_url) as profiles_with_photo,
    COUNT(*) - COUNT(photo_url) as profiles_without_photo
FROM public.profiles;
