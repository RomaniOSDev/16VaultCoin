//
//  ContentView.swift
//  16VaultCoin
//
//  Created by Роман Главацкий on 28.11.2025.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("isOnboardingComplete") private var isOnboardingComplete = false
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            if isOnboardingComplete {
                MainTabView()
                    .environmentObject(PortfolioViewModel())
            } else {
                OnboardingView(isOnboardingComplete: $isOnboardingComplete)
            }
        }
    }
}

#Preview {
    ContentView()
}
