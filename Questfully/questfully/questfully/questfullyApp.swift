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
    @StateObject private var journeyThemesViewModel: JourneyThemesViewModel

    init() {
        let sharedSubscriptionManager = SubscriptionManager()
        let sharedDataStore = ContentDataStore()
        _subscriptionManager = StateObject(wrappedValue: sharedSubscriptionManager)
        _categoryViewModel = StateObject(wrappedValue: CategoryViewModel(dataStore: sharedDataStore, subscriptionManager: sharedSubscriptionManager))
        _journeyThemesViewModel = StateObject(wrappedValue: JourneyThemesViewModel(dataStore: sharedDataStore))
    }

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(favoritesManager)
                .environmentObject(authManager)
                .environmentObject(subscriptionManager)
                .environmentObject(categoryViewModel)
                .environmentObject(journeyThemesViewModel)
        }
    }
}
