//
//  AppThemeManager.swift
//  KapitosApp
//
//  Created by Luisa Cardona on 15/11/25.
//

import SwiftUI
import Combine

class AppThemeManager: ObservableObject {
    @Published var isDarkMode: Bool = false
    
    init() { }
}
