-- Script de verificación para los datos de Leo

-- 1. Verificar perfil de Leo
SELECT 'Perfil de Leo:' as check_name;
SELECT id, full_name, email, role 
FROM profiles 
WHERE id = '3ba73474-dc62-4c5a-86a3-d70069097d17';

-- 2. Verificar perfil de Luisa
SELECT 'Perfil de Luisa:' as check_name;
SELECT id, full_name, email, role 
FROM profiles 
WHERE id = 'f91b0019-9a47-40d5-a89c-f24baa40d109';

-- 3. Verificar conversación
SELECT 'Conversaciones donde Leo es participante:' as check_name;
SELECT id, client_id, producer_id, is_active, last_message_at, created_at 
FROM conversations 
WHERE client_id = '3ba73474-dc62-4c5a-86a3-d70069097d17' 
   OR producer_id = '3ba73474-dc62-4c5a-86a3-d70069097d17';

-- 4. Verificar mensajes
SELECT 'Mensajes en las conversaciones de Leo:' as check_name;
SELECT m.id, m.conversation_id, m.sender_id, m.content, m.is_read, m.is_deleted, m.created_at
FROM messages m
INNER JOIN conversations c ON m.conversation_id = c.id
WHERE c.client_id = '3ba73474-dc62-4c5a-86a3-d70069097d17' 
   OR c.producer_id = '3ba73474-dc62-4c5a-86a3-d70069097d17'
ORDER BY m.created_at;

-- 5. Contar mensajes no leídos para Leo
SELECT 'Mensajes no leídos para Leo:' as check_name;
SELECT COUNT(*) as unread_count
FROM messages m
INNER JOIN conversations c ON m.conversation_id = c.id
WHERE (c.client_id = '3ba73474-dc62-4c5a-86a3-d70069097d17' 
    OR c.producer_id = '3ba73474-dc62-4c5a-86a3-d70069097d17')
  AND m.is_read = false
  AND m.sender_id != '3ba73474-dc62-4c5a-86a3-d70069097d17'
  AND m.is_deleted = false;
