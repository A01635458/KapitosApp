-- Script para agregar conversaciones y mensajes para Leo
-- Cliente: Leo (3ba73474-dc62-4c5a-86a3-d70069097d17)
-- Productor: Finca El Triunfo (2ab61eee-44d1-4451-b70a-fc249308acf9)

-- NOTA: Este script simula la aprobación de Finca El Triunfo
-- Normalmente esto se haría desde ProducerApprovalView

-- PASO 0: Limpiar datos anteriores si existen
DELETE FROM messages WHERE conversation_id = '11111111-1111-1111-1111-111111111111';
DELETE FROM conversations WHERE id = '11111111-1111-1111-1111-111111111111';

-- PASO 0.5: Simular aprobación de Finca El Triunfo
-- Primero, crear el usuario en auth.users (esto normalmente lo hace signUp)
-- NOTA: No podemos crear usuarios directamente en auth.users desde SQL
-- Por lo tanto, creamos el perfil manualmente asumiendo que el UUID ya existe en auth.users

-- Crear o actualizar perfil de Finca El Triunfo
INSERT INTO profiles (id, full_name, email, role, created_at)
VALUES (
    '2ab61eee-44d1-4451-b70a-fc249308acf9',
    'Finca El Triunfo',
    'finca.triunfo@example.com',
    'producer',
    NOW()
)
ON CONFLICT (email) DO UPDATE 
SET role = 'producer', full_name = 'Finca El Triunfo';

-- Actualizar estado del productor a aprobado
UPDATE producers 
SET status = 'approved'
WHERE id = '2ab61eee-44d1-4451-b70a-fc249308acf9';

-- PASO 1: Crear conversación entre Leo (cliente) y Finca El Triunfo (productor)
INSERT INTO conversations (id, client_id, producer_id, last_message_at, is_active, created_at)
VALUES (
    '11111111-1111-1111-1111-111111111111',
    '3ba73474-dc62-4c5a-86a3-d70069097d17',  -- Leo (cliente)
    '2ab61eee-44d1-4451-b70a-fc249308acf9',  -- Finca El Triunfo (productor)
    NOW(),
    true,
    NOW()
);

-- PASO 2: Agregar mensajes a la conversación
-- Mensaje 1: Finca saluda a Leo
INSERT INTO messages (id, conversation_id, sender_id, content, created_at, is_read, is_deleted)
VALUES (
    '22222222-2222-2222-2222-222222222221',
    '11111111-1111-1111-1111-111111111111',
    '2ab61eee-44d1-4451-b70a-fc249308acf9',  -- Finca El Triunfo
    '¡Hola Leo! Gracias por tu interés en nuestro café 🌱',
    NOW() - INTERVAL '2 hours',
    true,
    false
);

-- Mensaje 2: Leo responde
INSERT INTO messages (id, conversation_id, sender_id, content, created_at, is_read, is_deleted)
VALUES (
    '22222222-2222-2222-2222-222222222222',
    '11111111-1111-1111-1111-111111111111',
    '3ba73474-dc62-4c5a-86a3-d70069097d17',  -- Leo
    'Hola, me gustaría saber más sobre tu café de altura',
    NOW() - INTERVAL '1 hour 45 minutes',
    true,
    false
);

-- Mensaje 3: Finca explica
INSERT INTO messages (id, conversation_id, sender_id, content, created_at, is_read, is_deleted)
VALUES (
    '22222222-2222-2222-2222-222222222223',
    '11111111-1111-1111-1111-111111111111',
    '2ab61eee-44d1-4451-b70a-fc249308acf9',  -- Finca El Triunfo
    'Nuestro café es 100% arábica cultivado en las montañas. Tenemos tueste medio y oscuro disponible. ☕',
    NOW() - INTERVAL '1 hour 30 minutes',
    true,
    false
);

-- Mensaje 4: Leo pregunta precio
INSERT INTO messages (id, conversation_id, sender_id, content, created_at, is_read, is_deleted)
VALUES (
    '22222222-2222-2222-2222-222222222224',
    '11111111-1111-1111-1111-111111111111',
    '3ba73474-dc62-4c5a-86a3-d70069097d17',  -- Leo
    '¿Cuál es el precio por kg?',
    NOW() - INTERVAL '1 hour',
    true,
    false
);

-- Mensaje 5: Finca responde precio
INSERT INTO messages (id, conversation_id, sender_id, content, created_at, is_read, is_deleted)
VALUES (
    '22222222-2222-2222-2222-222222222225',
    '11111111-1111-1111-1111-111111111111',
    '2ab61eee-44d1-4451-b70a-fc249308acf9',  -- Finca El Triunfo
    'El precio es de $350 por kg para tueste medio y $380 para oscuro. Incluye envío gratis en pedidos mayores a 2kg 📦',
    NOW() - INTERVAL '45 minutes',
    true,
    false
);

-- Mensaje 6: Leo interesado
INSERT INTO messages (id, conversation_id, sender_id, content, created_at, is_read, is_deleted)
VALUES (
    '22222222-2222-2222-2222-222222222226',
    '11111111-1111-1111-1111-111111111111',
    '3ba73474-dc62-4c5a-86a3-d70069097d17',  -- Leo
    'Me interesa hacer un pedido de 3kg de tueste medio',
    NOW() - INTERVAL '30 minutes',
    true,
    false
);

-- Mensaje 7: Finca confirma (ÚLTIMO MENSAJE - NO LEÍDO)
INSERT INTO messages (id, conversation_id, sender_id, content, created_at, is_read, is_deleted)
VALUES (
    '22222222-2222-2222-2222-222222222227',
    '11111111-1111-1111-1111-111111111111',
    '2ab61eee-44d1-4451-b70a-fc249308acf9',  -- Finca El Triunfo
    '¡Perfecto! Tu pedido está confirmado. Te llega en 2-3 días hábiles 🙌',
    NOW() - INTERVAL '10 minutes',
    false,  -- NO LEÍDO por Leo
    false
);

-- PASO 3: Actualizar last_message_at de la conversación
UPDATE conversations 
SET last_message_at = NOW() - INTERVAL '10 minutes'
WHERE id = '11111111-1111-1111-1111-111111111111';

-- Verificar los datos insertados
SELECT 'Conversación creada:' as status;
SELECT id, client_id, producer_id, last_message_at FROM conversations 
WHERE id = '11111111-1111-1111-1111-111111111111';

SELECT 'Mensajes creados:' as status;
SELECT id, sender_id, content, created_at, is_read FROM messages 
WHERE conversation_id = '11111111-1111-1111-1111-111111111111'
ORDER BY created_at;
