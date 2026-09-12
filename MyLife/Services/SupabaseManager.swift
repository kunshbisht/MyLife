//
//  SupabaseManager.swift
//  MyLife
//
//  Created by kunsh macbook on 12/9/26.
//

import Supabase

let supabase = SupabaseClient(
    supabaseURL: SupabaseConfig.url,
    supabaseKey: SupabaseConfig.key,
    options: .init(
        auth: .init(
            emitLocalSessionAsInitialSession: true
        )
    )
)
