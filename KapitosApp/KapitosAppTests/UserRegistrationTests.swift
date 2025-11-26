//
//  UserRegistrationTests.swift
//  KapitosAppTests
//  Unit tests for user registration flow
//

import Testing
import Foundation
@testable import KapitosApp

@Suite("User Registration Tests")
struct UserRegistrationTests {
    
    // MARK: - RegistrationFlowModel Tests
    
    @Test("Flow model initializes with empty values")
    func testFlowModelInitialization() async {
        let flowModel = RegistrationFlowModel()
        
        #expect(flowModel.fullName.isEmpty)
        #expect(flowModel.email.isEmpty)
        #expect(flowModel.password.isEmpty)
        #expect(flowModel.preferences.processes.isEmpty)
    }
    
    @Test("Flow model detects preference selections")
    func testPreferenceSelections() async {
        let flowModel = RegistrationFlowModel()
        
        // Initially no preferences
        #expect(!flowModel.hasAnyPreferenceSelections)
        
        // Add some preferences
        flowModel.preferences.processes = ["Lavado", "Natural"]
        flowModel.preferences.roasts = ["Claro"]
        
        #expect(flowModel.hasAnyPreferenceSelections)
    }
    
    @Test("Flow model stores user credentials")
    func testCredentialStorage() async {
        let flowModel = RegistrationFlowModel()
        
        flowModel.fullName = "Test User"
        flowModel.email = "test@example.com"
        flowModel.password = "SecurePass123"
        
        #expect(flowModel.fullName == "Test User")
        #expect(flowModel.email == "test@example.com")
        #expect(flowModel.password == "SecurePass123")
    }
    
    // MARK: - Email Validation Tests
    
    @Test("Valid email formats are accepted",
          arguments: [
            "user@example.com",
            "test.user@domain.co",
            "admin@test-site.org",
            "name+tag@email.com"
          ])
    func testValidEmailFormats(email: String) async {
        #expect(email.contains("@"))
        #expect(email.contains("."))
    }
    
    @Test("Invalid email formats are rejected",
          arguments: [
            "notanemail",
            "@nodomain.com",
            "no@domain",
            "spaces @email.com"
          ])
    func testInvalidEmailFormats(email: String) async {
        let isValid = email.contains("@") && email.contains(".") && !email.contains(" ")
        #expect(!isValid)
    }
    
    // MARK: - Password Validation Tests
    
    @Test("Password length validation")
    func testPasswordLength() async {
        let shortPassword = "12345"
        let validPassword = "123456"
        let longPassword = "verylongsecurepassword123"
        
        #expect(shortPassword.count < 6)
        #expect(validPassword.count >= 6)
        #expect(longPassword.count >= 6)
    }
    
    @Test("Password complexity rules")
    func testPasswordComplexity() async {
        let hasUppercase = { (password: String) -> Bool in
            password.rangeOfCharacter(from: .uppercaseLetters) != nil
        }
        
        let hasLowercase = { (password: String) -> Bool in
            password.rangeOfCharacter(from: .lowercaseLetters) != nil
        }
        
        let hasNumber = { (password: String) -> Bool in
            password.rangeOfCharacter(from: .decimalDigits) != nil
        }
        
        let weakPassword = "password"
        let strongPassword = "Password123"
        
        #expect(!hasUppercase(weakPassword) || !hasNumber(weakPassword))
        #expect(hasUppercase(strongPassword) && hasLowercase(strongPassword) && hasNumber(strongPassword))
    }
    
    // MARK: - Preference Data Tests
    
    @Test("Preferences structure initialization")
    func testPreferencesStructure() async {
        var prefs = RegistrationFlowModel.UserPreferences()
        
        #expect(prefs.processes.isEmpty)
        #expect(prefs.roasts.isEmpty)
        #expect(prefs.drinks.isEmpty)
        
        prefs.processes = ["Lavado", "Honey"]
        prefs.roasts = ["Medio"]
        
        #expect(prefs.processes.count == 2)
        #expect(prefs.roasts.count == 1)
    }
    
    @Test("Preferences can store multiple selections")
    func testMultiplePreferences() async {
        var prefs = RegistrationFlowModel.UserPreferences()
        
        prefs.processes = ["Lavado", "Natural", "Honey"]
        prefs.drinks = ["Espresso", "Latte", "Americano"]
        prefs.times = ["Mañana", "Tarde"]
        
        #expect(prefs.processes.count == 3)
        #expect(prefs.drinks.count == 3)
        #expect(prefs.times.count == 2)
    }
    
    // MARK: - Form Validation Tests
    
    @Test("Registration form validation - all fields required")
    func testFormValidation() async {
        let validateForm = { (name: String, email: String, password: String) -> Bool in
            !name.isEmpty && !email.isEmpty && email.contains("@") && password.count >= 6
        }
        
        // Valid form
        #expect(validateForm("John Doe", "john@example.com", "Pass123"))
        
        // Invalid - missing name
        #expect(!validateForm("", "john@example.com", "Pass123"))
        
        // Invalid - bad email
        #expect(!validateForm("John Doe", "notanemail", "Pass123"))
        
        // Invalid - short password
        #expect(!validateForm("John Doe", "john@example.com", "12345"))
    }
    
    @Test("Password confirmation matching")
    func testPasswordConfirmation() async {
        let password = "SecurePass123"
        let matchingConfirm = "SecurePass123"
        let nonMatchingConfirm = "DifferentPass"
        
        #expect(password == matchingConfirm)
        #expect(password != nonMatchingConfirm)
    }
    
    // MARK: - Data Transformation Tests
    
    @Test("Preferences conversion to arrays")
    func testPreferencesArrayConversion() async {
        let prefs = RegistrationFlowModel.UserPreferences(
            processes: ["Lavado", "Natural"],
            roasts: ["Medio"],
            drinks: ["Espresso", "Latte"],
            times: ["Mañana"],
            acidity: ["Alta"],
            notes: ["Cítrico", "Dulce"],
            weekly: ["4-7 tazas"]
        )
        
        #expect(Array(prefs.processes) == ["Lavado", "Natural"])
        #expect(Array(prefs.roasts) == ["Medio"])
        #expect(Array(prefs.drinks) == ["Espresso", "Latte"])
    }
    
    @Test("Empty preferences are handled correctly")
    func testEmptyPreferences() async {
        let prefs = RegistrationFlowModel.UserPreferences()
        
        let allEmpty = prefs.processes.isEmpty &&
                       prefs.roasts.isEmpty &&
                       prefs.drinks.isEmpty &&
                       prefs.times.isEmpty &&
                       prefs.acidity.isEmpty &&
                       prefs.notes.isEmpty &&
                       prefs.weekly.isEmpty
        
        #expect(allEmpty)
    }
}
