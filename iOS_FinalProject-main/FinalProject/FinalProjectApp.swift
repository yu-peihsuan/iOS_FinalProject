//
//  FinalProjectApp.swift
//  FinalProject
//
//  Created by g509user on 2026/5/12.
//

import SwiftUI

@main
struct FinalProjectApp: App {
    @State private var store = FavoritesStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(store)
        }
    }
}
