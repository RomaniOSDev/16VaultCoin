import SwiftUI

struct PortfolioView: View {
    @EnvironmentObject var portfolioViewModel: PortfolioViewModel
    @State private var showingAddCoin = false
    @State private var searchText = ""
    @State private var isAnimating = false
    @State private var showingSortOptions = false
    
    var filteredCoins: [Coin] {
        let coins = portfolioViewModel.getFilteredCoins()
        
        if searchText.isEmpty {
            return coins
        } else {
            return coins.filter { coin in
                coin.displayName.localizedCaseInsensitiveContains(searchText) ||
                coin.displayTicker.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        headerStatsCard
                        searchAndSortBar
                        sortOptionsView
                        coinsListView
                        emptyStateView
                    }
                    .padding()
                }
            }
            .navigationTitle("Portfolio")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    toolbarButtons
                }
            }
        }
        .sheet(isPresented: $showingAddCoin) {
            AddCoinView()
                .environmentObject(portfolioViewModel)
        }
        .sheet(isPresented: $showingSortOptions) {
            SortOptionsView(portfolioViewModel: portfolioViewModel)
        }
        .onAppear {
            isAnimating = true
        }
    }
    
    // MARK: - Header Stats Card
    private var headerStatsCard: some View {
        VStack(spacing: 20) {
            HStack {
                totalPortfolioSection
                Spacer()
                priceUpdateSection
                networkErrorSection
            }
            progressBar
        }
        .padding()
        .background(headerBackground)
    }
    
    private var totalPortfolioSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Total Portfolio")
                .font(.subheadline)
                .foregroundColor(.yellow.opacity(0.8))
            
            Text(portfolioViewModel.formatCurrency(portfolioViewModel.totalPortfolioValue))
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(.yellow)
                .scaleEffect(isAnimating ? 1.05 : 1.0)
                .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isAnimating)
        }
    }
    
    private var priceUpdateSection: some View {
        VStack(alignment: .trailing, spacing: 4) {
            priceUpdateIndicator
            portfolioChangeIndicator
            profitLossPercentageText
        }
    }
    
    private var priceUpdateIndicator: some View {
        HStack(spacing: 4) {
            if portfolioViewModel.isLoadingPrices {
                ProgressView()
                    .scaleEffect(0.8)
                    .progressViewStyle(CircularProgressViewStyle(tint: .yellow))
            } else if let lastUpdate = portfolioViewModel.lastUpdateTime {
                Image(systemName: "clock")
                    .font(.caption)
                    .foregroundColor(.yellow.opacity(0.7))
                
                Text(lastUpdate, style: .relative)
                    .font(.caption)
                    .foregroundColor(.yellow.opacity(0.7))
            }
            
            Button(action: {
                portfolioViewModel.refreshPrices()
            }) {
                Image(systemName: "arrow.clockwise")
                    .font(.caption)
                    .foregroundColor(.yellow.opacity(0.7))
            }
            .disabled(portfolioViewModel.isLoadingPrices)
        }
    }
    
    private var portfolioChangeIndicator: some View {
        HStack(spacing: 4) {
            let isPositive = portfolioViewModel.totalProfitLoss >= 0
            Image(systemName: isPositive ? "arrow.up.right" : "arrow.down.right")
                .font(.caption)
                .foregroundColor(isPositive ? .green : .red)
            
            Text(portfolioViewModel.formatCurrency(portfolioViewModel.totalProfitLoss))
                .font(.headline)
                .foregroundColor(isPositive ? .green : .red)
        }
    }
    
    private var profitLossPercentageText: some View {
        let isPositive = portfolioViewModel.totalProfitLossPercentage >= 0
        return Text("\(portfolioViewModel.totalProfitLossPercentage, specifier: "%.1f")%")
            .font(.caption)
            .foregroundColor(isPositive ? .green : .red)
    }
    
    @ViewBuilder
    private var networkErrorSection: some View {
        if portfolioViewModel.hasNetworkError {
            HStack(spacing: 4) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.caption2)
                    .foregroundColor(.red)
                Text("Network error")
                    .font(.caption2)
                    .foregroundColor(.red)
                
                Button(action: {
                    portfolioViewModel.clearNetworkError()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.caption2)
                        .foregroundColor(.red.opacity(0.7))
                }
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(Color.red.opacity(0.1))
            .cornerRadius(4)
        }
    }
    
    private var progressBar: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.yellow.opacity(0.1))
                    .frame(height: 4)
                    .cornerRadius(2)
                
                progressBarFill(geometry: geometry)
            }
        }
        .frame(height: 4)
    }
    
    private func progressBarFill(geometry: GeometryProxy) -> some View {
        let isPositive = portfolioViewModel.totalProfitLoss >= 0
        let gradientColors = isPositive ? [Color.green, Color.green.opacity(0.6)] : [Color.red, Color.red.opacity(0.6)]
        let progressWidth = geometry.size.width * min(abs(portfolioViewModel.totalProfitLossPercentage) / 100, 1)
        
        return Rectangle()
            .fill(LinearGradient(
                gradient: Gradient(colors: gradientColors),
                startPoint: .leading,
                endPoint: .trailing
            ))
            .frame(width: progressWidth, height: 4)
            .cornerRadius(2)
            .animation(.easeInOut(duration: 0.8), value: portfolioViewModel.totalProfitLossPercentage)
    }
    
    private var headerBackground: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color.black.opacity(0.8))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.yellow.opacity(0.3), Color.yellow.opacity(0.1)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
    }
    
    // MARK: - Search and Sort Bar
    private var searchAndSortBar: some View {
        HStack(spacing: 12) {
            searchBar
            sortButton
        }
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
    
    private var sortButton: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.3)) {
                showingSortOptions.toggle()
            }
        }) {
            HStack(spacing: 4) {
                Image(systemName: "arrow.up.arrow.down")
                    .font(.system(size: 12))
                Text("Sort")
                    .font(.system(size: 12, weight: .medium))
            }
            .foregroundColor(.yellow)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.black.opacity(0.6))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.yellow.opacity(0.2), lineWidth: 1)
            )
        }
    }
    
    // MARK: - Sort Options View
    @ViewBuilder
    private var sortOptionsView: some View {
        if showingSortOptions {
            VStack(spacing: 8) {
                ForEach(PortfolioViewModel.SortOption.allCases, id: \.self) { option in
                    sortOptionButton(option: option)
                }
            }
            .padding()
            .background(Color.black.opacity(0.8))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
            )
            .transition(.opacity.combined(with: .move(edge: .top)))
        }
    }
    
    private func sortOptionButton(option: PortfolioViewModel.SortOption) -> some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.3)) {
                portfolioViewModel.sortOption = option
                showingSortOptions = false
            }
        }) {
            HStack {
                Text(option.rawValue)
                    .font(.system(size: 14))
                    .foregroundColor(portfolioViewModel.sortOption == option ? .black : .yellow)
                Spacer()
                if portfolioViewModel.sortOption == option {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.black)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(portfolioViewModel.sortOption == option ? Color.yellow : Color.clear)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Coins List View
    private var coinsListView: some View {
        LazyVStack(spacing: 12) {
            ForEach(Array(filteredCoins.enumerated()), id: \.element.id) { index, coin in
                EnhancedCoinRowView(coin: coin)
                    .transition(.opacity.combined(with: .scale))
                    .animation(.easeInOut(duration: 0.3).delay(Double(index) * 0.1), value: filteredCoins)
            }
        }
    }
    
    // MARK: - Empty State View
    @ViewBuilder
    private var emptyStateView: some View {
        if filteredCoins.isEmpty {
            VStack(spacing: 20) {
                emptyStateIcon
                emptyStateText
                addFirstCoinButton
            }
            .padding(.top, 60)
        }
    }
    
    private var emptyStateIcon: some View {
        ZStack {
            Circle()
                .fill(Color.yellow.opacity(0.1))
                .frame(width: 100, height: 100)
                .scaleEffect(isAnimating ? 1.1 : 1.0)
                .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: isAnimating)
            
            Image(systemName: "plus.circle.fill")
                .font(.system(size: 48))
                .foregroundColor(.yellow)
                .scaleEffect(isAnimating ? 1.05 : 1.0)
                .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isAnimating)
        }
    }
    
    private var emptyStateText: some View {
        VStack(spacing: 8) {
            Text("No coins yet")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.yellow)
            
            Text("Add your first cryptocurrency to start tracking your portfolio")
                .font(.body)
                .foregroundColor(.yellow.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
    
    private var addFirstCoinButton: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                showingAddCoin = true
            }
        }) {
            HStack(spacing: 8) {
                Image(systemName: "plus")
                    .font(.headline)
                Text("Add Your First Coin")
                    .font(.headline)
                    .fontWeight(.bold)
            }
            .foregroundColor(.black)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.yellow)
                    .shadow(color: .yellow.opacity(0.3), radius: 8, x: 0, y: 4)
            )
        }
        .scaleEffect(isAnimating ? 1.05 : 1.0)
        .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isAnimating)
    }
    
    // MARK: - Toolbar Buttons
    private var toolbarButtons: some View {
        HStack(spacing: 16) {
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    showingSortOptions.toggle()
                }
            }) {
                Image(systemName: "arrow.up.arrow.down")
                    .foregroundColor(.yellow)
            }
            
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    portfolioViewModel.refreshPrices()
                }
            }) {
                toolbarRefreshButton
            }
            .disabled(portfolioViewModel.isLoadingPrices)
        }
    }
    
    private var toolbarRefreshButton: some View {
        ZStack {
            if portfolioViewModel.isLoadingPrices {
                ProgressView()
                    .scaleEffect(0.8)
                    .progressViewStyle(CircularProgressViewStyle(tint: .yellow))
            } else {
                Image(systemName: "arrow.clockwise")
                    .foregroundColor(.yellow)
                    .rotationEffect(.degrees(isAnimating ? 360 : 0))
                    .animation(.linear(duration: 1.0).repeatForever(autoreverses: false), value: isAnimating)
            }
        }
    }
}

struct EnhancedCoinRowView: View {
    let coin: Coin
    @State private var isPressed = false
    
    private var coinIcon: String {
        let ticker = coin.displayTicker.lowercased()
        return getIconForTicker(ticker)
    }
    
    private func getIconForTicker(_ ticker: String) -> String {
        // Use a simple dictionary lookup instead of complex functions
        let iconMap: [String: String] = [
            "btc": "bitcoinsign.circle.fill",
            "bitcoin": "bitcoinsign.circle.fill",
            "eth": "network",
            "ethereum": "network",
            "usdt": "dollarsign.circle.fill",
            "tether": "dollarsign.circle.fill",
            "usdc": "dollarsign.circle",
            "bnb": "flame.fill",
            "binance": "flame.fill",
            "sol": "bolt.fill",
            "solana": "bolt.fill",
            "ada": "leaf.fill",
            "cardano": "leaf.fill",
            "xrp": "wave.3.right",
            "ripple": "wave.3.right",
            "dot": "circle.grid.cross.fill",
            "polkadot": "circle.grid.cross.fill",
            "doge": "dog.fill",
            "dogecoin": "dog.fill",
            "matic": "hexagon.fill",
            "polygon": "hexagon.fill",
            "link": "link.circle.fill",
            "chainlink": "link.circle.fill",
            "uni": "arrow.triangle.2.circlepath",
            "uniswap": "arrow.triangle.2.circlepath",
            "ltc": "l.square.fill",
            "litecoin": "l.square.fill",
            "xlm": "star.fill",
            "stellar": "star.fill",
            "atom": "atom",
            "cosmos": "atom",
            "ftm": "sparkles",
            "fantom": "sparkles",
            "avax": "snowflake",
            "avalanche": "snowflake",
            "near": "n.square.fill",
            "algo": "a.square.fill",
            "algorand": "a.square.fill",
            "icp": "network.badge.shield.half.filled",
            "internetcomputer": "network.badge.shield.half.filled",
            "fil": "doc.fill",
            "filecoin": "doc.fill",
            "apt": "a.circle.fill",
            "aptos": "a.circle.fill",
            "arb": "arrow.left.arrow.right",
            "arbitrum": "arrow.left.arrow.right",
            "op": "o.circle.fill",
            "optimism": "o.circle.fill",
            "mkr": "m.square.fill",
            "maker": "m.square.fill",
            "aave": "a.circle",
            "sushi": "fish.fill",
            "comp": "c.square.fill",
            "compound": "c.square.fill",
            "yfi": "y.square.fill",
            "yearn": "y.square.fill",
            "crv": "c.circle.fill",
            "curve": "c.circle.fill",
            "bal": "b.circle.fill",
            "balancer": "b.circle.fill",
            "1inch": "1.circle.fill",
            "grt": "g.square.fill",
            "thegraph": "g.square.fill",
            "enj": "e.square.fill",
            "enjin": "e.square.fill",
            "sand": "s.circle.fill",
            "sandbox": "s.circle.fill",
            "mana": "m.circle",
            "decentraland": "m.circle",
            "axs": "a.circle",
            "axieinfinity": "a.circle",
            "gala": "g.circle.fill",
            "chz": "c.circle",
            "chiliz": "c.circle",
            "hot": "h.square.fill",
            "holochain": "h.square.fill",
            "bat": "b.circle",
            "brave": "b.circle",
            "zil": "z.square.fill",
            "zilliqa": "z.square.fill",
            "hbar": "h.circle.fill",
            "hedera": "h.circle.fill",
            "xmr": "m.circle",
            "monero": "m.circle",
            "dash": "d.square.fill",
            "neo": "n.circle.fill",
            "eos": "e.circle.fill",
            "trx": "t.square.fill",
            "tron": "t.square.fill",
            "xem": "x.circle.fill",
            "nem": "x.circle.fill",
            "waves": "wave.3.right.circle.fill",
            "qtum": "q.square.fill",
            "omg": "o.square.fill",
            "omisego": "o.square.fill",
            "zec": "z.circle.fill",
            "zcash": "z.circle.fill",
            "btt": "b.circle",
            "bittorrent": "b.circle",
            "icx": "i.square.fill",
            "icon": "i.square.fill",
            "nano": "n.circle",
            "sc": "s.square.fill",
            "siacoin": "s.square.fill",
            "dcr": "d.circle.fill",
            "decred": "d.circle.fill",
            "xvg": "v.circle",
            "verge": "v.circle",
            "bts": "b.square",
            "bitshares": "b.square",
            "steem": "s.circle",
            "bcn": "b.circle",
            "bytecoin": "b.circle",
            "pivx": "p.square.fill",
            "btg": "b.circle.fill",
            "bitcoingold": "b.circle.fill",
            "bcd": "b.square",
            "bitcoindiamond": "b.square",
            "bch": "b.circle",
            "bitcoincash": "b.circle",
            "bsv": "b.square.fill",
            "bitcoinsv": "b.square.fill",
            "etc": "e.square.fill",
            "ethereumclassic": "e.square.fill"
        ]
        
        return iconMap[ticker.lowercased()] ?? "circle.fill"
    }
    

    
    private var coinIconText: String {
        let ticker = coin.displayTicker
        if ticker.count >= 2 {
            let prefix = ticker.prefix(2)
            let prefixString = String(prefix)
            return prefixString.uppercased()
        } else {
            return ticker.uppercased()
        }
    }
    
    private var amountText: String {
        let amountString = String(format: "%.4f", coin.amount)
        let tickerString = coin.displayTicker
        let result = amountString + " " + tickerString
        return result
    }
    
    private var totalValueText: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: coin.totalValue)) ?? "$0.00"
    }
    
    private var currentPriceText: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: coin.currentPrice)) ?? "$0.00"
    }
    
    private var profitLossIcon: String {
        coin.profitLossPercentage >= 0 ? "arrow.up.right" : "arrow.down.right"
    }
    
    private var profitLossColor: Color {
        coin.profitLossPercentage >= 0 ? .green : .red
    }
    
    private var profitLossText: String {
        let percentageString = String(format: "%.1f", coin.profitLossPercentage)
        let result = percentageString + "%"
        return result
    }
    
    var body: some View {
        Button(action: {
            // Future: Navigate to coin details
        }) {
            HStack(spacing: 16) {
                // Coin icon
                ZStack {
                    Circle()
                        .fill(Color.yellow.opacity(0.2))
                        .frame(width: 40, height: 40)
                    
                    if coinIcon == "circle.fill" {
                        // Fallback to text for unknown coins
                        Text(coinIconText)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.yellow)
                    } else {
                        // Use SF Symbol icon
                        Image(systemName: coinIcon)
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.yellow)
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(coin.displayName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.yellow)
                    
                    Text(amountText)
                        .font(.system(size: 12))
                        .foregroundColor(.yellow.opacity(0.7))
                    
                    Text("Price: \(currentPriceText)")
                        .font(.system(size: 10))
                        .foregroundColor(.yellow.opacity(0.6))
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(totalValueText)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.yellow)
                    
                    HStack(spacing: 4) {
                        Image(systemName: profitLossIcon)
                            .font(.system(size: 10))
                            .foregroundColor(profitLossColor)
                        
                        Text(profitLossText)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(profitLossColor)
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

struct SortOptionsView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var portfolioViewModel: PortfolioViewModel
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Text("Sort Options")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.yellow)
                        .padding(.top)
                    
                    VStack(spacing: 12) {
                        ForEach(PortfolioViewModel.SortOption.allCases, id: \.self) { option in
                            Button(action: {
                                portfolioViewModel.sortOption = option
                                dismiss()
                            }) {
                                HStack {
                                    Text(option.rawValue)
                                        .foregroundColor(.yellow)
                                        .font(.system(size: 16, weight: .medium))
                                    
                                    Spacer()
                                    
                                    if portfolioViewModel.sortOption == option {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.yellow)
                                            .font(.system(size: 14, weight: .bold))
                                    }
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(portfolioViewModel.sortOption == option ? Color.yellow.opacity(0.2) : Color.yellow.opacity(0.1))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.yellow.opacity(0.4), lineWidth: 1)
                                        )
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
            }
            .navigationTitle("Sort Options")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.yellow)
                }
            }
            .toolbarBackground(Color.black, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }
}

#Preview {
    PortfolioView()
        .environmentObject(PortfolioViewModel())
} 