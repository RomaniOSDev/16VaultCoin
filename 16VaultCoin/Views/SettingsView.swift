import SwiftUI
import StoreKit

struct SettingsView: View {
    @EnvironmentObject var portfolioViewModel: PortfolioViewModel
    @State private var showingResetAlert = false
    @State private var isUpdatingCurrency = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        PrivacyModeSection()
                        CurrencySelectionSection()
                        PrivacyPolicySection()
                        RateAppSection()
                        ResetDataSection(showingResetAlert: $showingResetAlert)
                        ResetOnboardingSection()
                    }
                    .padding()
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .alert("Reset All Data", isPresented: $showingResetAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    portfolioViewModel.resetData()
                }
            } message: {
                Text("This will permanently delete all your coins, transactions, and price history. This action cannot be undone.")
            }

        }
    }
}

struct PrivacyModeSection: View {
    @EnvironmentObject var portfolioViewModel: PortfolioViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Privacy Mode")
                .font(.headline)
                .foregroundColor(.yellow)
            
            HStack {
                Text("Hide sensitive data")
                    .foregroundColor(.yellow.opacity(0.8))
                Spacer()
                Toggle("", isOn: $portfolioViewModel.isPrivacyModeEnabled)
                    .toggleStyle(SwitchToggleStyle(tint: .yellow))
            }
        }
        .padding()
        .background(Color.black.opacity(0.8))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
        )
    }
}

struct CurrencySelectionSection: View {
    @EnvironmentObject var portfolioViewModel: PortfolioViewModel
    @State private var isUpdatingCurrency = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Currency")
                .font(.headline)
                .foregroundColor(.yellow)
            
            HStack(spacing: 0) {
                ForEach(PortfolioViewModel.AppCurrency.allCases, id: \.self) { currency in
                    currencyButton(currency: currency)
                    
                    if currency != PortfolioViewModel.AppCurrency.allCases.last {
                        Rectangle()
                            .fill(Color.yellow.opacity(0.3))
                            .frame(width: 1, height: 20)
                    }
                }
            }
            .padding(4)
            .background(Color.black.opacity(0.5))
            .cornerRadius(12)
        }
        .padding()
        .background(Color.black.opacity(0.8))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
        )
    }
    
    private func currencyButton(currency: PortfolioViewModel.AppCurrency) -> some View {
        Button(action: {
            handleCurrencySelection(currency: currency)
        }) {
            HStack(spacing: 4) {
                Text(currency.name)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(portfolioViewModel.selectedCurrency == currency ? .black : .yellow)
                
                if portfolioViewModel.selectedCurrency == currency && isUpdatingCurrency {
                    ProgressView()
                        .scaleEffect(0.6)
                        .progressViewStyle(CircularProgressViewStyle(tint: .black))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(portfolioViewModel.selectedCurrency == currency ? Color.yellow : Color.clear)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func handleCurrencySelection(currency: PortfolioViewModel.AppCurrency) {
        withAnimation(.easeInOut(duration: 0.3)) {
            portfolioViewModel.selectedCurrency = currency
            isUpdatingCurrency = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            portfolioViewModel.refreshPrices()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                isUpdatingCurrency = false
            }
        }
    }
}

struct PrivacyPolicySection: View {
    
    var body: some View {
        Button(action: {
            openPrivacyPolicyInBrowser()
        }) {
            HStack {
                Image(systemName: "doc.text")
                    .foregroundColor(.yellow)
                Text("Privacy Policy")
                    .foregroundColor(.yellow)
                Spacer()
                Image(systemName: "arrow.up.right.square")
                    .foregroundColor(.yellow.opacity(0.6))
                    .font(.system(size: 12))
            }
            .padding()
            .background(Color.black.opacity(0.8))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
            )
        }
    }
    
    private func openPrivacyPolicyInBrowser() {
        // You can replace this with your actual privacy policy URL
        // For now, using a placeholder that opens a privacy policy generator
        if let url = URL(string: "https://www.termsfeed.com/live/f0e92d7c-fea0-4bc5-8c93-487b0dc59acf") {
            UIApplication.shared.open(url) 
        }
    }
}

struct RateAppSection: View {
    var body: some View {
        Button(action: {
            rateApp()
        }) {
            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                Text("Rate App")
                    .foregroundColor(.yellow)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.yellow.opacity(0.6))
                    .font(.system(size: 12))
            }
            .padding()
            .background(Color.black.opacity(0.8))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
            )
        }
    }
    
    private func rateApp() {
        // Try to show the in-app review prompt first
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        } else {
            // Fallback to App Store URL
            if let url = URL(string: "https://apps.apple.com/app/id1234567890") {
                UIApplication.shared.open(url)
            }
        }
    }
}

struct ResetDataSection: View {
    @EnvironmentObject var portfolioViewModel: PortfolioViewModel
    @Binding var showingResetAlert: Bool
    
    var body: some View {
        Button(action: {
            showingResetAlert = true
        }) {
            HStack {
                Image(systemName: "trash")
                    .foregroundColor(.red)
                Text("Reset All Data")
                    .foregroundColor(.red)
                Spacer()
            }
            .padding()
            .background(Color.black.opacity(0.8))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.red.opacity(0.3), lineWidth: 1)
            )
        }
    }
}

struct TermsOfServiceSection: View {
    var body: some View {
        Button(action: {
            openTermsOfServiceInBrowser()
        }) {
            HStack {
                Image(systemName: "doc.text.fill")
                    .foregroundColor(.yellow)
                Text("Terms of Service")
                    .foregroundColor(.yellow)
                Spacer()
                Image(systemName: "arrow.up.right.square")
                    .foregroundColor(.yellow.opacity(0.6))
                    .font(.system(size: 12))
            }
            .padding()
            .background(Color.black.opacity(0.8))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
            )
        }
    }
    
    private func openTermsOfServiceInBrowser() {
        // You can replace this with your actual terms of service URL
        if let url = URL(string: "https://www.termsofservicegenerator.info/live.php?token=YOUR_APP_TOKEN") {
            UIApplication.shared.open(url) { success in
                if !success {
                    // Fallback to a simple terms of service page
                    if let fallbackUrl = URL(string: "https://www.termsofservicegenerator.info/") {
                        UIApplication.shared.open(fallbackUrl)
                    }
                }
            }
        }
    }
}

struct ResetOnboardingSection: View {
    @AppStorage("isOnboardingComplete") private var isOnboardingComplete = true
    @State private var showingResetOnboardingAlert = false
    
    var body: some View {
        Button(action: {
            showingResetOnboardingAlert = true
        }) {
            HStack {
                Image(systemName: "arrow.clockwise")
                    .foregroundColor(.yellow)
                Text("Show Onboarding Again")
                    .foregroundColor(.yellow)
                Spacer()
            }
            .padding()
            .background(Color.black.opacity(0.8))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
            )
        }
        .alert("Show Onboarding", isPresented: $showingResetOnboardingAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Show", role: .destructive) {
                isOnboardingComplete = false
            }
        } message: {
            Text("This will show the onboarding screens again when you restart the app.")
        }
    }
} 
