//
//  SupabaseClientManager.swift
//  KapitosApp
//

import Foundation
import Supabase

final class SupabaseClientManager {

    static let shared = SupabaseClientManager()

    let client: SupabaseClient

    private init() {
        client = SupabaseClient(
            supabaseURL: URL(string: "https://vhjxtygfviesnyepsujw.supabase.co")!,
            supabaseKey: "sb_publishable_JawMYouxwX8apRA2F2s_5w_xy1LbFDb"
        )
    }
}

