-- Migration: Add location coordinates to producers table
-- Date: 2025-12-04
-- Description: Adds latitude and longitude fields for precise farm location

ALTER TABLE public.producers
ADD COLUMN IF NOT EXISTS latitude numeric,
ADD COLUMN IF NOT EXISTS longitude numeric;

-- Add constraints to ensure valid coordinate ranges
ALTER TABLE public.producers
ADD CONSTRAINT latitude_range CHECK (latitude IS NULL OR (latitude >= -90 AND latitude <= 90));

ALTER TABLE public.producers
ADD CONSTRAINT longitude_range CHECK (longitude IS NULL OR (longitude >= -180 AND longitude <= 180));

-- Add index for spatial queries (optional but recommended)
CREATE INDEX IF NOT EXISTS idx_producers_coordinates ON public.producers(latitude, longitude);

-- Comment the columns for documentation
COMMENT ON COLUMN public.producers.latitude IS 'Farm latitude coordinate (decimal degrees)';
COMMENT ON COLUMN public.producers.longitude IS 'Farm longitude coordinate (decimal degrees)';
