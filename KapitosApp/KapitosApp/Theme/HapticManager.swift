//
//  HapticManager.swift
//  KapitosApp
//
//  Manager para feedback háptico consistente en toda la app
//

import UIKit

class HapticManager {
    static let shared = HapticManager()
    
    private init() {}
    
    // MARK: - Feedback Types
    
    /// Feedback ligero para interacciones simples (tap en botones, selecciones)
    func light() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    /// Feedback medio para acciones importantes (abrir sheets, cambiar tabs)
    func medium() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    /// Feedback fuerte para acciones significativas (eliminar, confirmar)
    func heavy() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }
    
    /// Feedback suave para interacciones muy ligeras
    func soft() {
        let generator = UIImpactFeedbackGenerator(style: .soft)
        generator.impactOccurred()
    }
    
    /// Feedback rígido para acciones definitivas
    func rigid() {
        let generator = UIImpactFeedbackGenerator(style: .rigid)
        generator.impactOccurred()
    }
    
    // MARK: - Notification Feedback
    
    /// Feedback de éxito (checkmark, guardado exitoso)
    func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    /// Feedback de advertencia (validación fallida)
    func warning() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }
    
    /// Feedback de error (operación fallida)
    func error() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
    
    // MARK: - Selection Feedback
    
    /// Feedback para cambios de selección (pickers, segmented controls)
    func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
    
    // MARK: - Convenience Methods
    
    /// Feedback para enviar mensaje
    func messageSent() {
        soft()
    }
    
    /// Feedback para aprobar/confirmar
    func approve() {
        success()
    }
    
    /// Feedback para rechazar/cancelar
    func reject() {
        warning()
    }
    
    /// Feedback para eliminar
    func delete() {
        heavy()
    }
    
    /// Feedback para subir/guardar
    func upload() {
        medium()
    }
    
    /// Feedback para tap en botón
    func buttonTap() {
        light()
    }
    
    /// Feedback para abrir sheet/modal
    func sheetPresent() {
        medium()
    }
    
    /// Feedback para cerrar sheet/modal
    func sheetDismiss() {
        light()
    }
    
    /// Feedback para cambiar página/tab
    func pageChange() {
        selection()
    }
}
