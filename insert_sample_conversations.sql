-- Sample data for testing messaging system
-- Run this in Supabase SQL Editor after you have at least one client and one producer

-- FIRST, check which users you have with their roles:
-- SELECT id, full_name, role FROM profiles ORDER BY role, full_name;

-- IMPORTANT: You need at least one user with role='producer' in the profiles table
-- If you don't have any, you need to either:
-- 1. Create a producer account through the app's registration
-- 2. Update an existing user's role: UPDATE profiles SET role='producer' WHERE id='USER_UUID_HERE';

-- Current UUIDs found (verify these exist in YOUR database):
-- Leo (client): 3ba73474-dc62-4c5a-86a3-d70069097d17
-- Producer UUID: REPLACE_WITH_ACTUAL_PRODUCER_UUID

-- Insert sample conversation
-- Leo (client) talking to Luisa (acting as producer for testing)
INSERT INTO conversations (client_id, producer_id, is_active, last_message_at)
VALUES 
  ('3ba73474-dc62-4c5a-86a3-d70069097d17'::uuid, 'f91b0019-9a47-40d5-a89c-f24baa40d109'::uuid, true, NOW());

-- Get the conversation ID that was just created
-- You'll need this for inserting messages

-- Insert sample messages
-- After running the conversation insert, get the conversation_id with:
-- SELECT id FROM conversations ORDER BY created_at DESC LIMIT 1;
-- Then replace CONVERSATION_UUID_HERE below with that ID

INSERT INTO messages (conversation_id, sender_id, content, message_type, is_read, created_at)
VALUES
  -- First message from Leo (client)
  ('CONVERSATION_UUID_HERE'::uuid, '3ba73474-dc62-4c5a-86a3-d70069097d17'::uuid, 'Hola! Me interesa tu café. ¿Tienes disponibilidad?', 'text', true, NOW() - INTERVAL '2 days'),
  
  -- Response from Luisa (producer)
  ('CONVERSATION_UUID_HERE'::uuid, 'f91b0019-9a47-40d5-a89c-f24baa40d109'::uuid, 'Hola! Sí, tengo café recién cosechado. ¿Qué cantidad necesitas?', 'text', true, NOW() - INTERVAL '2 days' + INTERVAL '30 minutes'),
  
  -- Leo response
  ('CONVERSATION_UUID_HERE'::uuid, '3ba73474-dc62-4c5a-86a3-d70069097d17'::uuid, 'Me gustaría probar 5kg primero. ¿Cuál es el precio?', 'text', true, NOW() - INTERVAL '1 day'),
  
  -- Luisa response
  ('CONVERSATION_UUID_HERE'::uuid, 'f91b0019-9a47-40d5-a89c-f24baa40d109'::uuid, 'Perfecto! El precio es $250 por kg. Son $1,250 en total. ¿Te parece bien?', 'text', true, NOW() - INTERVAL '1 day' + INTERVAL '1 hour'),
  
  -- Leo confirmation
  ('CONVERSATION_UUID_HERE'::uuid, '3ba73474-dc62-4c5a-86a3-d70069097d17'::uuid, 'Excelente! ¿Cuándo lo puedes enviar?', 'text', true, NOW() - INTERVAL '4 hours'),
  
  -- Luisa final message
  ('CONVERSATION_UUID_HERE'::uuid, 'f91b0019-9a47-40d5-a89c-f24baa40d109'::uuid, 'Lo envío mañana por la mañana. Te llegará en 2-3 días 🚚☕', 'text', false, NOW() - INTERVAL '2 hours');

-- Update the conversation's last_message_at
UPDATE conversations 
SET last_message_at = NOW() - INTERVAL '2 hours'
WHERE id = 'CONVERSATION_UUID_HERE'::uuid;

-- INSTRUCTIONS:
-- 1. First, update Luisa to be a producer (temporary for testing):
--    UPDATE profiles SET role='producer' WHERE id='f91b0019-9a47-40d5-a89c-f24baa40d109';
--
-- 2. Run the INSERT INTO conversations statement
--
-- 3. Get the new conversation ID:
--    SELECT id FROM conversations ORDER BY created_at DESC LIMIT 1;
--
-- 4. Replace ALL instances of CONVERSATION_UUID_HERE with the ID from step 3
--
-- 5. Run the INSERT INTO messages statement
--
-- 6. Run the UPDATE conversations statement
--
-- UUIDs being used:
-- Leo (client): 3ba73474-dc62-4c5a-86a3-d70069097d17
-- Luisa (acting as producer): f91b0019-9a47-40d5-a89c-f24baa40d109
--
-- NOTE: Para usar Café de Coatepec en el futuro, necesitas crear su perfil en profiles primero:
-- INSERT INTO profiles (id, full_name, email, role) 
-- VALUES ('8761e0c0-e049-4d1e-b936-5af5dfce2d5f', 'Café de Coatepec', 'cafe@coatepec.com', 'producer');

