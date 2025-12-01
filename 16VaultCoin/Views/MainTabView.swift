import SwiftUI

struct MainTabView: View {
    @StateObject private var portfolioViewModel = PortfolioViewModel()
    @State private var showingAddCoin = false
    @State private var selectedTab = 0
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            // Animated background
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Main content area with transition
                ZStack {
                    switch selectedTab {
                    case 0:
                        PortfolioView()
                            .environmentObject(portfolioViewModel)
                            .transition(.asymmetric(
                                insertion: .move(edge: .leading).combined(with: .opacity),
                                removal: .move(edge: .trailing).combined(with: .opacity)
                            ))
                    case 1:
                        AnalyticsView()
                            .environmentObject(portfolioViewModel)
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .move(edge: .leading).combined(with: .opacity)
                            ))
                    case 2:
                        ProfitCalculatorView()
                            .environmentObject(portfolioViewModel)
                            .transition(.asymmetric(
                                insertion: .move(edge: .bottom).combined(with: .opacity),
                                removal: .move(edge: .top).combined(with: .opacity)
                            ))
                    case 3:
                        TransactionsView()
                            .environmentObject(portfolioViewModel)
                            .transition(.asymmetric(
                                insertion: .move(edge: .bottom).combined(with: .opacity),
                                removal: .move(edge: .top).combined(with: .opacity)
                            ))
                    case 4:
                        SettingsView()
                            .environmentObject(portfolioViewModel)
                            .transition(.asymmetric(
                                insertion: .move(edge: .top).combined(with: .opacity),
                                removal: .move(edge: .bottom).combined(with: .opacity)
                            ))
                    default:
                        PortfolioView()
                            .environmentObject(portfolioViewModel)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .animation(.easeInOut(duration: 0.3), value: selectedTab)
                
                // Enhanced Tab Bar
                VStack(spacing: 0) {
                    // Tab indicator
                    HStack(spacing: 0) {
                        ForEach(0..<5) { index in
                            Rectangle()
                                .fill(selectedTab == index ? Color.yellow : Color.clear)
                                .frame(height: 3)
                                .animation(.easeInOut(duration: 0.3), value: selectedTab)
                        }
                    }
                    
                    // Tab buttons
                    HStack(spacing: 0) {
                        ForEach(0..<5) { index in
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    selectedTab = index
                                }
                            }) {
                                VStack(spacing: 6) {
                                    Image(systemName: selectedTab == index ? tabItems[index].selectedIcon : tabItems[index].icon)
                                        .font(.system(size: 22, weight: selectedTab == index ? .semibold : .medium))
                                        .foregroundColor(selectedTab == index ? .yellow : .yellow.opacity(0.3))
                                        .scaleEffect(selectedTab == index ? 1.1 : 1.0)
                                        .animation(.easeInOut(duration: 0.2), value: selectedTab)
                                    
                                    Text(tabItems[index].title)
                                        .font(.system(size: 11, weight: selectedTab == index ? .semibold : .medium))
                                        .foregroundColor(selectedTab == index ? .yellow : .yellow.opacity(0.3))
                                        .opacity(selectedTab == index ? 1.0 : 0.7)
                                        .animation(.easeInOut(duration: 0.2), value: selectedTab)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(selectedTab == index ? Color.yellow.opacity(0.1) : Color.clear)
                                        .animation(.easeInOut(duration: 0.2), value: selectedTab)
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.black.opacity(0.95))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.yellow.opacity(0.2), lineWidth: 1)
                            )
                    )
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
                }
            }
            
            // Enhanced Floating Action Button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            showingAddCoin = true
                        }
                    }) {
                        ZStack {
                            // Background glow
                            Circle()
                                .fill(Color.yellow.opacity(0.2))
                                .frame(width: 70, height: 70)
                                .scaleEffect(isAnimating ? 1.2 : 1.0)
                                .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isAnimating)
                            
                            // Main button
                            Circle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.yellow, Color.yellow.opacity(0.8)]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 56, height: 56)
                                .shadow(color: .yellow.opacity(0.4), radius: 12, x: 0, y: 6)
                            
                            // Icon
                            Image(systemName: "plus")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.black)
                                .scaleEffect(isAnimating ? 1.1 : 1.0)
                                .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isAnimating)
                        }
                    }
                    .scaleEffect(isAnimating ? 1.05 : 1.0)
                    .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: isAnimating)
                    .padding(.trailing, 20)
                    .padding(.bottom, 100)
                }
            }
        }
        .sheet(isPresented: $showingAddCoin) {
            AddCoinView()
                .environmentObject(portfolioViewModel)
        }
        .onAppear {
            isAnimating = true
        }
    }
    
    private let tabItems = [
        TabItem(icon: "chart.pie", selectedIcon: "chart.pie.fill", title: "Portfolio"),
        TabItem(icon: "chart.bar", selectedIcon: "chart.bar.fill", title: "Analytics"),
        TabItem(icon: "plus.forwardslash.minus", selectedIcon: "plus.forwardslash.minus", title: "Calculator"),
        TabItem(icon: "list.bullet", selectedIcon: "list.bullet.circle.fill", title: "Transactions"),
        TabItem(icon: "gearshape", selectedIcon: "gearshape.fill", title: "Settings")
    ]
}

struct TabItem {
    let icon: String
    let selectedIcon: String
    let title: String
}

#Preview {
    MainTabView()
} 