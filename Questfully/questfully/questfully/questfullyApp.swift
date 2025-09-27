//
//  questfullyApp.swift
//  questfully
//
//  Created by Daniel on 9/27/25.
//

import SwiftUI

@main
struct questfullyApp: App {
    @StateObject private var favoritesManager = FavoritesManager()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(favoritesManager)
        }
    }
}
