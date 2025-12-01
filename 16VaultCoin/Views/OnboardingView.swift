import SwiftUI

struct OnboardingView: View {
    @Binding var isOnboardingComplete: Bool
    @State private var currentPage = 0
    @State private var isAnimating = false
    
    private let pages = [
        OnboardingPage(
            icon: "lock.shield.fill",
            title: "Welcome to VaultCoin",
            subtitle: "Your Private Crypto Portfolio",
            description: "Track your cryptocurrency investments with complete privacy and control. No accounts, no sync, no tracking.",
            backgroundColor: Color.yellow.opacity(0.1)
        ),
        OnboardingPage(
            icon: "chart.line.uptrend.xyaxis",
            title: "Real-time Tracking",
            subtitle: "Live Portfolio Updates",
            description: "Get real-time prices and portfolio value updates every 5 minutes. Stay informed about your investments.",
            backgroundColor: Color.green.opacity(0.1)
        ),
        OnboardingPage(
            icon: "globe",
            title: "Global Market Data",
            subtitle: "60+ Cryptocurrencies",
            description: "Access live market data for over 60 popular cryptocurrencies. From Bitcoin to the latest DeFi tokens.",
            backgroundColor: Color.blue.opacity(0.1)
        ),
        OnboardingPage(
            icon: "chart.pie",
            title: "Advanced Analytics",
            subtitle: "Smart Insights",
            description: "View detailed analytics, profit/loss tracking, and portfolio performance with beautiful charts.",
            backgroundColor: Color.purple.opacity(0.1)
        ),
        OnboardingPage(
            icon: "eye.slash",
            title: "Privacy First",
            subtitle: "Your Data Stays Local",
            description: "All your data is stored locally on your device. No cloud sync, no tracking, complete privacy.",
            backgroundColor: Color.red.opacity(0.1)
        )
    ]
    
    var body: some View {
        ZStack {
            // Animated background
            Color.black
                .ignoresSafeArea()
            
            // Dynamic gradient overlay based on current page
            LinearGradient(
                gradient: Gradient(colors: [
                    pages[currentPage].backgroundColor,
                    Color.clear,
                    pages[currentPage].backgroundColor.opacity(0.5)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.8), value: currentPage)
            
            VStack(spacing: 0) {
                // Page content
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageView(page: pages[index], isAnimating: isAnimating)
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.5), value: currentPage)
                
                // Bottom section with pagination and buttons
                VStack(spacing: 20) {
                    // Page indicators
                    HStack(spacing: 8) {
                        ForEach(0..<pages.count, id: \.self) { index in
                            Circle()
                                .fill(index == currentPage ? Color.yellow : Color.yellow.opacity(0.3))
                                .frame(width: index == currentPage ? 12 : 8, height: index == currentPage ? 12 : 8)
                                .scaleEffect(index == currentPage ? 1.2 : 1.0)
                                .animation(.easeInOut(duration: 0.3), value: currentPage)
                        }
                    }
                    .padding(.top, 20)
                    
                    // Navigation buttons
                    HStack(spacing: 20) {
                        if currentPage > 0 {
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    currentPage -= 1
                                }
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "chevron.left")
                                        .font(.system(size: 16, weight: .medium))
                                    Text("Previous")
                                        .font(.system(size: 16, weight: .medium))
                                }
                                .foregroundColor(.yellow)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.yellow.opacity(0.1))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
                                        )
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        
                        Spacer()
                        
                        if currentPage < pages.count - 1 {
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    currentPage += 1
                                }
                            }) {
                                HStack(spacing: 8) {
                                    Text("Next")
                                        .font(.system(size: 16, weight: .medium))
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 16, weight: .medium))
                                }
                                .foregroundColor(.black)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.yellow)
                                        .shadow(color: .yellow.opacity(0.3), radius: 4, x: 0, y: 2)
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        } else {
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    isOnboardingComplete = true
                                }
                            }) {
                                HStack(spacing: 8) {
                                    Text("Get Started")
                                        .font(.system(size: 16, weight: .bold))
                                    Image(systemName: "arrow.right")
                                        .font(.system(size: 16, weight: .bold))
                                }
                                .foregroundColor(.black)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.yellow)
                                        .shadow(color: .yellow.opacity(0.3), radius: 4, x: 0, y: 2)
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                            .scaleEffect(isAnimating ? 1.05 : 1.0)
                            .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isAnimating)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}

struct OnboardingPage {
    let icon: String
    let title: String
    let subtitle: String
    let description: String
    let backgroundColor: Color
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    let isAnimating: Bool
    @State private var showContent = false
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Icon with animation
            ZStack {
                Circle()
                    .fill(page.backgroundColor)
                    .frame(width: 140, height: 140)
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: isAnimating)
                
                Image(systemName: page.icon)
                    .font(.system(size: 60))
                    .foregroundColor(.yellow)
                    .scaleEffect(isAnimating ? 1.05 : 1.0)
                    .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isAnimating)
            }
            .opacity(showContent ? 1.0 : 0.0)
            .scaleEffect(showContent ? 1.0 : 0.8)
            .animation(.easeInOut(duration: 0.8).delay(0.2), value: showContent)
            
            // Text content
            VStack(spacing: 16) {
                Text(page.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.yellow)
                    .multilineTextAlignment(.center)
                    .opacity(showContent ? 1.0 : 0.0)
                    .animation(.easeInOut(duration: 0.8).delay(0.4), value: showContent)
                
                Text(page.subtitle)
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(.yellow.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .opacity(showContent ? 1.0 : 0.0)
                    .animation(.easeInOut(duration: 0.8).delay(0.6), value: showContent)
                
                Text(page.description)
                    .font(.body)
                    .foregroundColor(.yellow.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .padding(.horizontal, 40)
                    .opacity(showContent ? 1.0 : 0.0)
                    .animation(.easeInOut(duration: 0.8).delay(0.8), value: showContent)
            }
            
            Spacer()
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.5)) {
                showContent = true
            }
        }
        .onDisappear {
            showContent = false
        }
    }
}

#Preview {
    OnboardingView(isOnboardingComplete: .constant(false))
} 