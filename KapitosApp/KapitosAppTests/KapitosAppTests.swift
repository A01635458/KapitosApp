//
//  KapitosAppTests.swift
//  KapitosAppTests
//
//  Created by Leobardo Navarro Márquez on 26/11/25.
//

import Testing
import Foundation
@testable import KapitosApp

@Suite("Example Tests")
struct ExampleTests {
    @Test("Basic test")
    func exampleTest() async {
        #expect(1 + 1 == 2)
    }
}
