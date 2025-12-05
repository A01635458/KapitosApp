import Foundation

/// Configuración centralizada de la aplicación
/// IMPORTANTE: En producción, estas credenciales deben moverse a variables de entorno
struct AppConfig {
    
    // MARK: - Supabase Configuration
    
    /// URL del proyecto Supabase
    /// TODO: Mover a variable de entorno en producción
    static let supabaseURL = URL(string: "https://vhjxtygfviesnyepsujw.supabase.co")!
    
    /// Clave pública (anon key) de Supabase
    /// TODO: Mover a variable de entorno en producción
    /// ADVERTENCIA: Esta es la clave PÚBLICA. Nunca incluir la service_role key en el cliente.
    static let supabaseAnonKey = "sb_publishable_JawMYouxwX8apRA2F2s_5w_xy1LbFDb"
    
    // MARK: - App Information
    
    static let appName = "KapitosApp"
    static let appVersion = "1.0.0"
    static let buildNumber = "1"
    
    // MARK: - Feature Flags
    
    /// Habilitar logs de debug en producción
    static let enableDebugLogs = false
    
    /// Habilitar analytics
    static let enableAnalytics = true
    
    // MARK: - API Configuration
    
    /// Timeout para requests (en segundos)
    static let requestTimeout: TimeInterval = 30
    
    /// Máximo de reintentos para requests fallidos
    static let maxRetries = 3
}
