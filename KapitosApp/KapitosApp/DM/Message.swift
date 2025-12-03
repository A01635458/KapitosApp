//
//  Message.swift
//  KapitosApp
//
//  Created by Luisa Cardona on 03/12/25.
//

import Foundation

struct Message: Identifiable, Equatable {
    let id = UUID()
    let text: String
    let isMe: Bool
}
