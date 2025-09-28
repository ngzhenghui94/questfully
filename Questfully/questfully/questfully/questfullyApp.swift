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
    @StateObject private var authManager = AuthManager()
    @StateObject private var subscriptionManager: SubscriptionManager
    @StateObject private var categoryViewModel: CategoryViewModel

    init() {
        let sharedSubscriptionManager = SubscriptionManager()
        _subscriptionManager = StateObject(wrappedValue: sharedSubscriptionManager)
        _categoryViewModel = StateObject(wrappedValue: CategoryViewModel(subscriptionManager: sharedSubscriptionManager))
    }

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(favoritesManager)
                .environmentObject(authManager)
                .environmentObject(subscriptionManager)
                .environmentObject(categoryViewModel)
        }
    }
}
