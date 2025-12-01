import SwiftUI

private func formatCurrency(_ value: Double) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = "USD"
    return formatter.string(from: NSNumber(value: value)) ?? "$0.00"
}

struct AnalyticsView: View {
    @EnvironmentObject var portfolioViewModel: PortfolioViewModel
    @State private var selectedTimeframe: Timeframe = .all
    @State private var isAnimating = false
    @State private var searchText = ""
    @State private var selectedSortOption: SortOption = .value
    @State private var showingExportSheet = false
    @State private var showingCoinDetails = false
    @State private var selectedCoin: Coin?
    
    enum SortOption: String, CaseIterable {
        case value = "Value"
        case performance = "Performance"
        case name = "Name"
        case volatility = "Volatility"
    }
    
    enum Timeframe: String, CaseIterable {
        case week = "1W"
        case month = "1M"
        case quarter = "3M"
        case year = "1Y"
        case all = "All"
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        headerStatsCards
                        timeframeSelector
                        searchAndSortControls
                        portfolioDistributionChart
                        performanceChart
                        portfolioInsights
                        detailedCoinList
                    }
                    .padding()
                }
            }
            .navigationTitle("Analytics")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingExportSheet) {
                ExportAnalyticsView(coins: getFilteredAndSortedCoins())
            }
            .sheet(isPresented: $showingCoinDetails) {
                if let coin = selectedCoin {
                    CoinAnalyticsDetailView(coin: coin)
                }
            }
        }
    }
    
    // MARK: - Header Stats Cards
    private var headerStatsCards: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
            totalValueCard
            totalProfitLossCard
            profitLossPercentageCard
            coinsCountCard
        }
    }
    
    private var totalValueCard: some View {
        StatCard(
            title: "Total Value",
            value: portfolioViewModel.formatCurrency(portfolioViewModel.totalPortfolioValue),
            subtitle: "Portfolio Value",
            color: .yellow,
            icon: "dollarsign.circle.fill"
        )
        .scaleEffect(isAnimating ? 1.05 : 1.0)
        .animation(.easeInOut(duration: 0.3), value: isAnimating)
    }
    
    private var totalProfitLossCard: some View {
        let isPositive = portfolioViewModel.totalProfitLoss >= 0
        return StatCard(
            title: "Total P/L",
            value: portfolioViewModel.formatCurrency(portfolioViewModel.totalProfitLoss),
            subtitle: "Profit/Loss",
            color: isPositive ? .green : .red,
            icon: isPositive ? "arrow.up.right.circle.fill" : "arrow.down.right.circle.fill"
        )
        .scaleEffect(isAnimating ? 1.05 : 1.0)
        .animation(.easeInOut(duration: 0.3).delay(0.1), value: isAnimating)
    }
    
    private var profitLossPercentageCard: some View {
        let isPositive = portfolioViewModel.totalProfitLossPercentage >= 0
        return StatCard(
            title: "P/L %",
            value: portfolioViewModel.formatPercentage(portfolioViewModel.totalProfitLossPercentage),
            subtitle: "Percentage",
            color: isPositive ? .green : .red,
            icon: isPositive ? "chart.line.uptrend.xyaxis" : "chart.line.downtrend.xyaxis"
        )
        .scaleEffect(isAnimating ? 1.05 : 1.0)
        .animation(.easeInOut(duration: 0.3).delay(0.2), value: isAnimating)
    }
    
    private var coinsCountCard: some View {
        StatCard(
            title: "Coins",
            value: "\(portfolioViewModel.coins.count)",
            subtitle: "Total Coins",
            color: .yellow,
            icon: "bitcoinsign.circle.fill"
        )
        .scaleEffect(isAnimating ? 1.05 : 1.0)
        .animation(.easeInOut(duration: 0.3).delay(0.3), value: isAnimating)
    }
    
    // MARK: - Timeframe Selector
    private var timeframeSelector: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Timeframe")
                .font(.headline)
                .foregroundColor(.yellow)
            
            HStack(spacing: 0) {
                ForEach(Timeframe.allCases, id: \.self) { timeframe in
                    timeframeButton(timeframe: timeframe)
                    
                    if timeframe != Timeframe.allCases.last {
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
    
    private func timeframeButton(timeframe: Timeframe) -> some View {
        Button(action: {
            handleTimeframeSelection(timeframe: timeframe)
        }) {
            Text(timeframe.rawValue)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(selectedTimeframe == timeframe ? .black : .yellow)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(selectedTimeframe == timeframe ? Color.yellow : Color.clear)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func handleTimeframeSelection(timeframe: Timeframe) {
        withAnimation(.easeInOut(duration: 0.3)) {
            selectedTimeframe = timeframe
            isAnimating.toggle()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.easeInOut(duration: 0.3)) {
                isAnimating = false
            }
        }
    }
    
    // MARK: - Search and Sort Controls
    private var searchAndSortControls: some View {
        VStack(spacing: 12) {
            searchBar
            sortOptions
        }
        .padding()
        .background(Color.black.opacity(0.8))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
        )
    }
    
    private var searchBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.yellow.opacity(0.6))
                .font(.system(size: 14))
            
            ZStack(alignment: .leading) {
                if searchText.isEmpty {
                    Text("Search coins...")
                        .foregroundColor(.yellow.opacity(0.6))
                        .font(.system(size: 14))
                }
                TextField("", text: $searchText)
                    .foregroundColor(.yellow)
                    .font(.system(size: 14))
                    .textFieldStyle(PlainTextFieldStyle())
            }
            
            if !searchText.isEmpty {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        searchText = ""
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.yellow.opacity(0.6))
                        .font(.system(size: 16))
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.black.opacity(0.6))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.yellow.opacity(0.2), lineWidth: 1)
        )
    }
    
    private var sortOptions: some View {
        HStack {
            Text("Sort by:")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.yellow.opacity(0.8))
            
            Spacer()
            
            ForEach(SortOption.allCases, id: \.self) { option in
                sortOptionButton(option: option)
            }
        }
    }
    
    private func sortOptionButton(option: SortOption) -> some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.3)) {
                selectedSortOption = option
            }
        }) {
            Text(option.rawValue)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(selectedSortOption == option ? .black : .yellow.opacity(0.7))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(selectedSortOption == option ? Color.yellow : Color.clear)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Portfolio Distribution Chart
    private var portfolioDistributionChart: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Portfolio Distribution")
                .font(.headline)
                .foregroundColor(.yellow)
            
            SimpleDistributionChart(coins: getFilteredCoinsForTimeframe())
        }
        .padding()
        .background(Color.black.opacity(0.8))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
        )
        .transition(.opacity.combined(with: .scale))
        .animation(.easeInOut(duration: 0.5), value: selectedTimeframe)
    }
    
    // MARK: - Performance Chart
    private var performanceChart: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Performance")
                .font(.headline)
                .foregroundColor(.yellow)
            
            SimplePerformanceChart(coins: getFilteredCoinsForTimeframe())
        }
        .transition(.opacity.combined(with: .scale))
        .animation(.easeInOut(duration: 0.5).delay(0.1), value: selectedTimeframe)
        .padding()
        .background(Color.black.opacity(0.8))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
        )
    }
    
    // MARK: - Portfolio Insights
    private var portfolioInsights: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Portfolio Insights")
                .font(.headline)
                .foregroundColor(.yellow)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                bestPerformerCard
                worstPerformerCard
                largestPositionCard
                volatilityCard
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
    
    private var bestPerformerCard: some View {
        InsightCard(
            title: "Best Performer",
            value: getBestPerformer(),
            subtitle: "Top Coin",
            color: .green,
            icon: "star.fill"
        )
        .transition(.opacity.combined(with: .scale))
        .animation(.easeInOut(duration: 0.4), value: selectedTimeframe)
    }
    
    private var worstPerformerCard: some View {
        InsightCard(
            title: "Worst Performer",
            value: getWorstPerformer(),
            subtitle: "Bottom Coin",
            color: .red,
            icon: "exclamationmark.triangle.fill"
        )
        .transition(.opacity.combined(with: .scale))
        .animation(.easeInOut(duration: 0.4).delay(0.1), value: selectedTimeframe)
    }
    
    private var largestPositionCard: some View {
        InsightCard(
            title: "Largest Position",
            value: getLargestPosition(),
            subtitle: "By Value",
            color: .yellow,
            icon: "chart.pie.fill"
        )
        .transition(.opacity.combined(with: .scale))
        .animation(.easeInOut(duration: 0.4).delay(0.2), value: selectedTimeframe)
    }
    
    private var volatilityCard: some View {
        InsightCard(
            title: "Volatility",
            value: calculateVolatility(),
            subtitle: "Portfolio Risk",
            color: .orange,
            icon: "waveform.path.ecg"
        )
        .transition(.opacity.combined(with: .scale))
        .animation(.easeInOut(duration: 0.4).delay(0.3), value: selectedTimeframe)
    }
    
    // MARK: - Detailed Coin List
    private var detailedCoinList: some View {
        VStack(alignment: .leading, spacing: 16) {
            coinListHeader
            coinListContent
        }
        .padding()
        .background(Color.black.opacity(0.8))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
        )
    }
    
    private var coinListHeader: some View {
        HStack {
            Text("Coin Details")
                .font(.headline)
                .foregroundColor(.yellow)
            
            Spacer()
            
            Button(action: {
                showingExportSheet = true
            }) {
                Image(systemName: "square.and.arrow.up")
                    .foregroundColor(.yellow)
                    .font(.system(size: 16))
            }
        }
    }
    
    @ViewBuilder
    private var coinListContent: some View {
        if getFilteredAndSortedCoins().isEmpty {
            emptyCoinListState
        } else {
            LazyVStack(spacing: 12) {
                ForEach(getFilteredAndSortedCoins(), id: \.id) { coin in
                    AnalyticsCoinRow(coin: coin) {
                        selectedCoin = coin
                        showingCoinDetails = true
                    }
                    .transition(.opacity.combined(with: .scale))
                }
            }
        }
    }
    
    private var emptyCoinListState: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.bar.doc.horizontal")
                .font(.system(size: 48))
                .foregroundColor(.yellow.opacity(0.5))
            
            Text("No coins found")
                .font(.headline)
                .foregroundColor(.yellow.opacity(0.7))
            
            Text("Add some coins to see analytics")
                .font(.subheadline)
                .foregroundColor(.yellow.opacity(0.5))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
    
    // MARK: - Helper Functions
    private func getFilteredAndSortedCoins() -> [Coin] {
        var coins = getFilteredCoinsForTimeframe()
        
        // Filter by search
        if !searchText.isEmpty {
            coins = coins.filter { coin in
                coin.displayName.localizedCaseInsensitiveContains(searchText) ||
                coin.displayTicker.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Sort by selected option
        switch selectedSortOption {
        case .value:
            coins.sort { $0.totalValue > $1.totalValue }
        case .performance:
            coins.sort { $0.profitLossPercentage > $1.profitLossPercentage }
        case .name:
            coins.sort { $0.displayName < $1.displayName }
        case .volatility:
            coins.sort { 
                let vol1 = Calculator.calculateVolatility(prices: $0.sortedPriceHistory.map { $0.price })
                let vol2 = Calculator.calculateVolatility(prices: $1.sortedPriceHistory.map { $0.price })
                return vol1 > vol2
            }
        }
        
        return coins
    }
    
    private func getFilteredCoinsForTimeframe() -> [Coin] {
        let allCoins = portfolioViewModel.getFilteredCoins()
        
        switch selectedTimeframe {
        case .week:
            let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
            return allCoins.filter { coin in
                coin.createdAt ?? Date.distantPast >= weekAgo
            }
        case .month:
            let monthAgo = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
            return allCoins.filter { coin in
                coin.createdAt ?? Date.distantPast >= monthAgo
            }
        case .quarter:
            let quarterAgo = Calendar.current.date(byAdding: .month, value: -3, to: Date()) ?? Date()
            return allCoins.filter { coin in
                coin.createdAt ?? Date.distantPast >= quarterAgo
            }
        case .year:
            let yearAgo = Calendar.current.date(byAdding: .year, value: -1, to: Date()) ?? Date()
            return allCoins.filter { coin in
                coin.createdAt ?? Date.distantPast >= yearAgo
            }
        case .all:
            return allCoins
        }
    }
    
    private func getBestPerformer() -> String {
        let coins = getFilteredCoinsForTimeframe()
        guard let best = coins.max(by: { $0.profitLossPercentage < $1.profitLossPercentage }) else {
            return "N/A"
        }
        return "\(best.displayTicker) +\(portfolioViewModel.formatPercentage(best.profitLossPercentage))"
    }
    
    private func getWorstPerformer() -> String {
        let coins = getFilteredCoinsForTimeframe()
        guard let worst = coins.min(by: { $0.profitLossPercentage < $1.profitLossPercentage }) else {
            return "N/A"
        }
        return "\(worst.displayTicker) \(portfolioViewModel.formatPercentage(worst.profitLossPercentage))"
    }
    
    private func getLargestPosition() -> String {
        let coins = getFilteredCoinsForTimeframe()
        guard let largest = coins.max(by: { $0.totalValue < $1.totalValue }) else {
            return "N/A"
        }
        return "\(largest.displayTicker) \(portfolioViewModel.formatCurrency(largest.totalValue))"
    }
    
    private func calculateVolatility() -> String {
        let coins = getFilteredCoinsForTimeframe()
        let prices = coins.flatMap { coin in
            coin.sortedPriceHistory.map { $0.price }
        }
        
        let volatility = Calculator.calculateVolatility(prices: prices)
        return String(format: "%.1f%%", volatility)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(color)
                
                Spacer()
            }
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.yellow)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.yellow.opacity(0.8))
            
            Text(subtitle)
                .font(.caption2)
                .foregroundColor(.yellow.opacity(0.6))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.black.opacity(0.8))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
    }
}

struct InsightCard: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(color)
                
                Spacer()
            }
            
            Text(value)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.yellow)
                .lineLimit(1)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.yellow.opacity(0.8))
            
            Text(subtitle)
                .font(.caption2)
                .foregroundColor(.yellow.opacity(0.6))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.black.opacity(0.8))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
    }
}

struct SimpleDistributionChart: View {
    let coins: [Coin]
    
    var body: some View {
        VStack(spacing: 16) {
            if coins.isEmpty {
                Text("No data available")
                    .foregroundColor(.yellow.opacity(0.6))
                    .frame(height: 200)
            } else {
                // Simple bar chart
                VStack(spacing: 8) {
                    ForEach(coins.prefix(5), id: \.id) { coin in
                        HStack {
                            Text(coin.displayTicker)
                                .font(.caption)
                                .foregroundColor(.yellow)
                                .frame(width: 40, alignment: .leading)
                            
                            GeometryReader { geometry in
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.yellow)
                                    .frame(width: geometry.size.width * CGFloat(coin.totalValue / maxValue))
                            }
                            .frame(height: 20)
                            
                            Text("\(coin.totalValue, specifier: "%.0f")")
                                .font(.caption)
                                .foregroundColor(.yellow.opacity(0.8))
                                .frame(width: 60, alignment: .trailing)
                        }
                    }
                }
            }
        }
    }
    
    private var maxValue: Double {
        coins.map { $0.totalValue }.max() ?? 1
    }
}

struct SimplePerformanceChart: View {
    let coins: [Coin]
    
    var body: some View {
        VStack(spacing: 16) {
            if coins.isEmpty {
                Text("No data available")
                    .foregroundColor(.yellow.opacity(0.6))
                    .frame(height: 200)
            } else {
                // Simple performance bars
                VStack(spacing: 8) {
                    ForEach(coins.prefix(5), id: \.id) { coin in
                        HStack {
                            Text(coin.displayTicker)
                                .font(.caption)
                                .foregroundColor(.yellow)
                                .frame(width: 40, alignment: .leading)
                            
                            GeometryReader { geometry in
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(coin.profitLossPercentage >= 0 ? Color.green : Color.red)
                                    .frame(width: geometry.size.width * min(abs(coin.profitLossPercentage) / 100, 1))
                            }
                            .frame(height: 20)
                            
                            Text("\(coin.profitLossPercentage, specifier: "%.1f")%")
                                .font(.caption)
                                .foregroundColor(coin.profitLossPercentage >= 0 ? .green : .red)
                                .frame(width: 60, alignment: .trailing)
                        }
                    }
                }
            }
        }
    }
} 

struct AnalyticsCoinRow: View {
    let coin: Coin
    let onTap: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Coin icon
                ZStack {
                    Circle()
                        .fill(Color.yellow.opacity(0.2))
                        .frame(width: 40, height: 40)
                    
                    Text(coin.displayTicker.prefix(2).uppercased())
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.yellow)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(coin.displayName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.yellow)
                    
                    Text("\(coin.amount, specifier: "%.4f") \(coin.displayTicker)")
                        .font(.system(size: 12))
                        .foregroundColor(.yellow.opacity(0.7))
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(formatCurrency(coin.totalValue))
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.yellow)
                    
                    HStack(spacing: 4) {
                        Image(systemName: coin.profitLossPercentage >= 0 ? "arrow.up.right" : "arrow.down.right")
                            .font(.system(size: 10))
                            .foregroundColor(coin.profitLossPercentage >= 0 ? .green : .red)
                        
                        Text("\(coin.profitLossPercentage, specifier: "%.1f")%")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(coin.profitLossPercentage >= 0 ? .green : .red)
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.black.opacity(0.8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.yellow.opacity(0.2), lineWidth: 1)
                    )
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

struct ExportAnalyticsView: View {
    let coins: [Coin]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Text("Export Analytics")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.yellow)
                    
                    Text("Export your portfolio analytics data")
                        .font(.subheadline)
                        .foregroundColor(.yellow.opacity(0.7))
                        .multilineTextAlignment(.center)
                    
                    Spacer()
                    
                    Button("Export as CSV") {
                        // TODO: Implement CSV export
                        dismiss()
                    }
                    .foregroundColor(.black)
                    .padding()
                    .background(Color.yellow)
                    .cornerRadius(12)
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.yellow)
                }
            }
        }
    }
}

struct CoinAnalyticsDetailView: View {
    let coin: Coin
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Coin header
                        VStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(Color.yellow.opacity(0.2))
                                    .frame(width: 80, height: 80)
                                
                                Text(coin.displayTicker.prefix(2).uppercased())
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(.yellow)
                            }
                            
                            Text(coin.displayName)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.yellow)
                            
                            Text(coin.displayTicker)
                                .font(.subheadline)
                                .foregroundColor(.yellow.opacity(0.7))
                        }
                        
                        // Stats grid
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                            StatCard(
                                title: "Total Value",
                                value: formatCurrency(coin.totalValue),
                                subtitle: "Current Value",
                                color: .yellow,
                                icon: "dollarsign.circle.fill"
                            )
                            
                            StatCard(
                                title: "P/L",
                                value: formatCurrency(coin.profitLoss),
                                subtitle: "Profit/Loss",
                                color: coin.profitLoss >= 0 ? .green : .red,
                                icon: coin.profitLoss >= 0 ? "arrow.up.right.circle.fill" : "arrow.down.right.circle.fill"
                            )
                            
                            StatCard(
                                title: "P/L %",
                                value: String(format: "%.2f%%", coin.profitLossPercentage),
                                subtitle: "Percentage",
                                color: coin.profitLossPercentage >= 0 ? .green : .red,
                                icon: "chart.line.uptrend.xyaxis"
                            )
                            
                            StatCard(
                                title: "Amount",
                                value: String(format: "%.4f", coin.amount),
                                subtitle: "Holdings",
                                color: .yellow,
                                icon: "bitcoinsign.circle.fill"
                            )
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Coin Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.yellow)
                }
            }
        }
    }
} 