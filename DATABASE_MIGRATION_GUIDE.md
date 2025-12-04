# 📍 Guía de Migración de Base de Datos - Coordenadas de Ubicación

## Paso 1: Conectar a Supabase

1. Abre tu proyecto en [Supabase Dashboard](https://supabase.com/dashboard)
2. Ve a la sección **SQL Editor**
3. Crea una nueva query

## Paso 2: Ejecutar la Migración

Copia y pega este SQL en el editor:

```sql
-- ========================================
-- Migración: Agregar coordenadas de ubicación
-- Tabla: producers
-- Fecha: 2025-12-04
-- ========================================

-- Agregar columnas latitude y longitude
ALTER TABLE public.producers
ADD COLUMN IF NOT EXISTS latitude numeric,
ADD COLUMN IF NOT EXISTS longitude numeric;

-- Agregar restricciones de rango válido
-- Latitud: -90 a 90 grados
ALTER TABLE public.producers
ADD CONSTRAINT latitude_range 
CHECK (latitude IS NULL OR (latitude >= -90 AND latitude <= 90));

-- Longitud: -180 a 180 grados
ALTER TABLE public.producers
ADD CONSTRAINT longitude_range 
CHECK (longitude IS NULL OR (longitude >= -180 AND longitude <= 180));

-- Crear índice para consultas espaciales (opcional pero recomendado)
CREATE INDEX IF NOT EXISTS idx_producers_coordinates 
ON public.producers(latitude, longitude);

-- Agregar comentarios para documentación
COMMENT ON COLUMN public.producers.latitude 
IS 'Farm latitude coordinate in decimal degrees (WGS84)';

COMMENT ON COLUMN public.producers.longitude 
IS 'Farm longitude coordinate in decimal degrees (WGS84)';

-- Verificar que las columnas se agregaron correctamente
SELECT 
    column_name, 
    data_type, 
    is_nullable
FROM information_schema.columns
WHERE table_name = 'producers' 
AND column_name IN ('latitude', 'longitude');
```

## Paso 3: Ejecutar y Verificar

1. Haz clic en **Run** o presiona `Cmd/Ctrl + Enter`
2. Verifica que no haya errores
3. Deberías ver las columnas `latitude` y `longitude` en la tabla `producers`

## Paso 4: Verificar la Estructura

Ejecuta esta query para confirmar:

```sql
SELECT 
    column_name,
    data_type,
    character_maximum_length,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_name = 'producers'
ORDER BY ordinal_position;
```

## 🔍 Queries Útiles

### Ver todos los productores con ubicación:
```sql
SELECT 
    id,
    farm_name,
    latitude,
    longitude,
    municipality
FROM producers
WHERE latitude IS NOT NULL 
AND longitude IS NOT NULL;
```

### Calcular distancia entre dos puntos:
```sql
-- Función para calcular distancia en km usando fórmula Haversine
CREATE OR REPLACE FUNCTION calculate_distance(
    lat1 numeric, lon1 numeric,
    lat2 numeric, lon2 numeric
)
RETURNS numeric AS $$
DECLARE
    earth_radius numeric := 6371; -- Radio de la Tierra en km
    dlat numeric;
    dlon numeric;
    a numeric;
    c numeric;
BEGIN
    dlat := radians(lat2 - lat1);
    dlon := radians(lon2 - lon1);
    
    a := sin(dlat/2) * sin(dlat/2) +
         cos(radians(lat1)) * cos(radians(lat2)) *
         sin(dlon/2) * sin(dlon/2);
    
    c := 2 * atan2(sqrt(a), sqrt(1-a));
    
    RETURN earth_radius * c;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- Ejemplo de uso: productores a menos de 50km de Ciudad de México
SELECT 
    farm_name,
    municipality,
    calculate_distance(
        latitude, longitude,
        19.4326, -99.1332  -- Coordenadas CDMX
    ) as distance_km
FROM producers
WHERE latitude IS NOT NULL
ORDER BY distance_km
LIMIT 10;
```

### Encontrar productores en un área rectangular:
```sql
-- Ejemplo: productores en Chiapas
SELECT 
    farm_name,
    latitude,
    longitude,
    municipality
FROM producers
WHERE latitude BETWEEN 14.5 AND 17.5
AND longitude BETWEEN -93.5 AND -90.5
ORDER BY farm_name;
```

### Actualizar coordenadas de un productor específico:
```sql
UPDATE producers
SET 
    latitude = 19.4518,
    longitude = -96.9570,
    municipality = 'Coatepec, Veracruz'
WHERE id = 'uuid-del-productor';
```

## 🔒 Configuración de RLS (Row Level Security)

Si usas RLS, asegúrate de que las políticas permitan leer y escribir estas columnas:

```sql
-- Ver políticas actuales
SELECT * FROM pg_policies WHERE tablename = 'producers';

-- Si necesitas actualizar políticas, ejemplo:
-- (Ajusta según tus necesidades de seguridad)

-- Permitir que los productores actualicen su propia ubicación
CREATE POLICY "Producers can update own location"
ON producers
FOR UPDATE
USING (auth.uid() = id)
WITH CHECK (auth.uid() = id);

-- Permitir que todos lean ubicaciones de productores aprobados
CREATE POLICY "Anyone can view approved producer locations"
ON producers
FOR SELECT
USING (status = 'approved');
```

## 📊 Datos de Ejemplo para Testing

Puedes insertar algunos datos de prueba:

```sql
-- Ejemplo: Finca en Chiapas
INSERT INTO producers (
    farm_name, 
    latitude, 
    longitude, 
    municipality, 
    state,
    status
) VALUES (
    'Finca El Triunfo',
    15.1150,
    -92.0868,
    'Angel Albino Corzo',
    'Chiapas',
    'approved'
);

-- Ejemplo: Finca en Veracruz
INSERT INTO producers (
    farm_name,
    latitude,
    longitude,
    municipality,
    state,
    status
) VALUES (
    'Café de Coatepec',
    19.4518,
    -96.9570,
    'Coatepec',
    'Veracruz',
    'approved'
);

-- Ejemplo: Finca en Oaxaca
INSERT INTO producers (
    farm_name,
    latitude,
    longitude,
    municipality,
    state,
    status
) VALUES (
    'Pluma Hidalgo Coffee',
    15.9254,
    -96.4169,
    'Pluma Hidalgo',
    'Oaxaca',
    'approved'
);
```

## ⚠️ Rollback (si necesitas revertir)

Si algo sale mal, puedes revertir los cambios:

```sql
-- Eliminar índice
DROP INDEX IF EXISTS idx_producers_coordinates;

-- Eliminar restricciones
ALTER TABLE producers DROP CONSTRAINT IF EXISTS latitude_range;
ALTER TABLE producers DROP CONSTRAINT IF EXISTS longitude_range;

-- Eliminar columnas
ALTER TABLE producers DROP COLUMN IF EXISTS latitude;
ALTER TABLE producers DROP COLUMN IF EXISTS longitude;
```

## ✅ Checklist Post-Migración

- [ ] Columnas `latitude` y `longitude` creadas
- [ ] Restricciones de rango aplicadas
- [ ] Índice creado para optimización
- [ ] Políticas RLS actualizadas (si aplica)
- [ ] Datos de prueba insertados (opcional)
- [ ] App puede insertar nuevos productores con coordenadas
- [ ] App puede leer coordenadas existentes

## 🆘 Troubleshooting

### Error: "permission denied"
- Verifica que tengas permisos de administrador en Supabase
- Verifica las políticas RLS

### Error: "constraint violation"
- Verifica que las coordenadas estén en el rango correcto
- Latitud: -90 a 90
- Longitud: -180 a 180

### Error: "column already exists"
- Es normal si ejecutas el script múltiples veces
- El `IF NOT EXISTS` previene errores

## 📚 Referencias

- [Supabase SQL Editor](https://supabase.com/docs/guides/database/overview)
- [PostGIS para PostgreSQL](https://postgis.net/) (para funciones geoespaciales avanzadas)
- [WGS84 Coordinate System](https://en.wikipedia.org/wiki/World_Geodetic_System)

---

**Última actualización:** 4 de diciembre, 2025
