import Foundation
import CoreData
import Combine

@MainActor
class PortfolioViewModel: ObservableObject {
    @Published var coins: [Coin] = []
    @Published var totalPortfolioValue: Double = 0
    @Published var totalProfitLoss: Double = 0
    @Published var totalProfitLossPercentage: Double = 0
    @Published var isPrivacyModeEnabled = false
    @Published var selectedCurrency: AppCurrency = .usd
    @Published var sortOption: SortOption = .value
    @Published var selectedTags: Set<String> = []
    @Published var isLoadingPrices = false
    @Published var lastUpdateTime: Date?
    @Published var hasNetworkError = false
    
    private let coreDataManager = CoreDataManager.shared
    private var cancellables = Set<AnyCancellable>()
    private lazy var coinGeckoAPI = CoinGeckoAPI()
    private var autoRefreshTimer: Timer?
    
    enum AppCurrency: String, CaseIterable {
        case usd = "USD"
        case eur = "EUR"
        case gbp = "GBP"
        
        var symbol: String {
            switch self {
            case .usd: return "$"
            case .eur: return "€"
            case .gbp: return "£"
            }
        }
        
        var name: String {
            switch self {
            case .usd: return "US Dollar"
            case .eur: return "Euro"
            case .gbp: return "British Pound"
            }
        }
        
        var coinGeckoId: String {
            switch self {
            case .usd: return "usd"
            case .eur: return "eur"
            case .gbp: return "gbp"
            }
        }
    }
    
    enum SortOption: String, CaseIterable {
        case name = "Name"
        case value = "Value"
        case profitLoss = "Profit/Loss"
        case percentage = "Percentage"
    }
    
    init() {
        loadCoins()
        setupBindings()
        
        // Delay API call to ensure proper initialization
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.updatePricesFromAPI()
        }
        
        startAutoRefresh()
    }
    
    private func setupBindings() {
        $coins
            .sink { [weak self] coins in
                self?.updatePortfolioStats()
            }
            .store(in: &cancellables)
    }
    
    func loadCoins() {
        let request: NSFetchRequest<Coin> = Coin.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Coin.createdAt, ascending: false)]
        
        do {
            coins = try coreDataManager.context.fetch(request)
        } catch {
            print("Error fetching coins: \(error)")
        }
    }
    
    private func updatePortfolioStats() {
        let filteredCoins = getFilteredCoins()
        
        // Debug: Print coin details
        print("=== Portfolio Stats Update ===")
        for coin in filteredCoins {
            print("Coin: \(coin.displayName) (\(coin.displayTicker))")
            print("  Amount: \(coin.amount)")
            print("  Current Price: \(coin.currentPrice)")
            print("  Average Price: \(coin.averagePrice)")
            print("  Total Value: \(coin.totalValue)")
            print("  Profit/Loss: \(coin.profitLoss)")
        }
        
        totalPortfolioValue = filteredCoins.reduce(0) { $0 + $1.totalValue }
        totalProfitLoss = filteredCoins.reduce(0) { $0 + $1.profitLoss }
        
        let totalCost = filteredCoins.reduce(0) { $0 + ($1.amount * $1.averagePrice) }
        totalProfitLossPercentage = totalCost > 0 ? (totalProfitLoss / totalCost) * 100 : 0
        
        print("Total Portfolio Value: \(totalPortfolioValue)")
        print("Total Profit/Loss: \(totalProfitLoss)")
        print("Total Cost: \(totalCost)")
        print("Total Profit/Loss %: \(totalProfitLossPercentage)")
        print("===============================")
        
        // Goals functionality removed
    }
    
    func getFilteredCoins() -> [Coin] {
        var filtered = coins
        
        // Filter by tags
        if !selectedTags.isEmpty {
            filtered = filtered.filter { coin in
                !Set(coin.tagArray).isDisjoint(with: selectedTags)
            }
        }
        
        // Sort
        filtered.sort { coin1, coin2 in
            switch sortOption {
            case .name:
                return coin1.displayName < coin2.displayName
            case .value:
                return coin1.totalValue > coin2.totalValue
            case .profitLoss:
                return coin1.profitLoss > coin2.profitLoss
            case .percentage:
                return coin1.profitLossPercentage > coin2.profitLossPercentage
            }
        }
        
        return filtered
    }
    
    func addCoin(name: String, ticker: String, amount: Double, price: Double, tags: [String] = [], notes: String = "") {
        let coin = Coin(context: coreDataManager.context)
        coin.id = UUID()
        coin.name = name
        coin.ticker = ticker
        coin.amount = amount
        coin.averagePrice = price
        coin.currentPrice = price // Initially set to purchase price
        coin.createdAt = Date()
        coin.notes = notes
        coin.tags = tags.joined(separator: ",")
        
        print("=== Adding New Coin ===")
        print("Name: \(name)")
        print("Ticker: \(ticker)")
        print("Amount: \(amount)")
        print("Price: \(price)")
        print("Initial currentPrice: \(coin.currentPrice)")
        print("=======================")
        
        // Add initial transaction
        let transaction = Transaction(context: coreDataManager.context)
        transaction.id = UUID()
        transaction.type = "buy"
        transaction.amount = amount
        transaction.price = price
        transaction.date = Date()
        transaction.notes = "Initial purchase"
        transaction.coin = coin
        
        // Add initial price history
        let priceHistory = PriceHistory(context: coreDataManager.context)
        priceHistory.id = UUID()
        priceHistory.price = price
        priceHistory.date = Date()
        priceHistory.coin = coin
        
        coreDataManager.save()
        loadCoins()
        
        // Force price update for the new coin
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.updatePricesFromAPI()
        }
    }
    
    func updateCoinPrice(_ coin: Coin, newPrice: Double) {
        coin.currentPrice = newPrice
        
        // Add to price history
        let priceHistory = PriceHistory(context: coreDataManager.context)
        priceHistory.id = UUID()
        priceHistory.price = newPrice
        priceHistory.date = Date()
        priceHistory.coin = coin
        
        coreDataManager.save()
        loadCoins()
    }
    
    func addTransaction(to coin: Coin, type: String, amount: Double, price: Double, date: Date, notes: String = "", tags: String = "") {
        let transaction = Transaction(context: coreDataManager.context)
        transaction.id = UUID()
        transaction.type = type
        transaction.amount = amount
        transaction.price = price
        transaction.date = date
        transaction.notes = notes
        transaction.tags = tags
        transaction.coin = coin
        
        // Update coin amount
        if type == "buy" {
            coin.amount += amount
        } else if type == "sell" {
            coin.amount -= amount
        }
        
        // Update average price for buys
        if type == "buy" {
            coin.updateAveragePrice()
        }
        
        coreDataManager.save()
        loadCoins()
    }
    
    func deleteCoin(_ coin: Coin) {
        coreDataManager.delete(coin)
        loadCoins()
    }
    
    func getAllTags() -> [String] {
        let allTags = coins.flatMap { $0.tagArray }
        return Array(Set(allTags)).sorted()
    }
    
    func togglePrivacyMode() {
        isPrivacyModeEnabled.toggle()
    }
    
    func formatCurrency(_ value: Double) -> String {
        if isPrivacyModeEnabled {
            return "••••"
        }
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = selectedCurrency.rawValue
        formatter.maximumFractionDigits = 2
        
        return formatter.string(from: NSNumber(value: value)) ?? "\(selectedCurrency.symbol)\(value)"
    }
    
    func formatPercentage(_ value: Double) -> String {
        if isPrivacyModeEnabled {
            return "•••"
        }
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 2
        
        return formatter.string(from: NSNumber(value: value / 100)) ?? "\(value)%"
    }
    
    func resetData() {
        // Delete all coins
        for coin in coins {
            coreDataManager.delete(coin)
        }
        
        // Delete all transactions
        let transactionRequest: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        do {
            let transactions = try coreDataManager.context.fetch(transactionRequest)
            for transaction in transactions {
                coreDataManager.delete(transaction)
            }
        } catch {
            print("Error deleting transactions: \(error)")
        }
        
        // Delete all price history
        let priceHistoryRequest: NSFetchRequest<PriceHistory> = PriceHistory.fetchRequest()
        do {
            let priceHistories = try coreDataManager.context.fetch(priceHistoryRequest)
            for priceHistory in priceHistories {
                coreDataManager.delete(priceHistory)
            }
        } catch {
            print("Error deleting price histories: \(error)")
        }
        
        coreDataManager.save()
        loadCoins()
    }
    
    // MARK: - Online Price Updates
    func updatePricesFromAPI() {
        guard !coins.isEmpty else { return }
        
        isLoadingPrices = true
        
        // Get unique tickers and convert to CoinGecko IDs
        let tickers = Array(Set(coins.compactMap { $0.ticker?.lowercased() }))
        let coinGeckoIds = tickers.compactMap { CoinGeckoAPI.getCoinGeckoId(for: $0) }
        
        // Only proceed if we have valid IDs
        guard !coinGeckoIds.isEmpty else {
            isLoadingPrices = false
            return
        }
        
        Task {
            do {
                let prices = try await coinGeckoAPI.getPrices(for: coinGeckoIds, currency: selectedCurrency.coinGeckoId)
                
                await MainActor.run {
                    var updatedCount = 0
                    for coin in coins {
                        if let ticker = coin.ticker?.lowercased(),
                           let coinGeckoId = CoinGeckoAPI.getCoinGeckoId(for: ticker),
                           let price = prices[coinGeckoId] {
                            
                            coin.currentPrice = price
                            updatedCount += 1
                            
                            // Add to price history
                            let priceHistory = PriceHistory(context: coreDataManager.context)
                            priceHistory.id = UUID()
                            priceHistory.price = price
                            priceHistory.date = Date()
                            priceHistory.coin = coin
                        }
                    }
                    
                    if updatedCount > 0 {
                        coreDataManager.save()
                        loadCoins()
                        hasNetworkError = false
                    }
                    
                    isLoadingPrices = false
                    lastUpdateTime = Date()
                }
            } catch {
                await MainActor.run {
                    isLoadingPrices = false
                    // Only show network error if we don't have any recent prices
                    if lastUpdateTime == nil || Date().timeIntervalSince(lastUpdateTime!) > 300 { // 5 minutes
                        hasNetworkError = true
                    }
                }
            }
        }
    }
    
    func refreshPrices() {
        updatePricesFromAPI()
    }
    
    func clearNetworkError() {
        hasNetworkError = false
    }
    
    private func startAutoRefresh() {
        // Update prices every 5 minutes instead of 2 minutes to avoid rate limiting
        autoRefreshTimer = Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.updatePricesFromAPI()
            }
        }
    }
    
    deinit {
        autoRefreshTimer?.invalidate()
    }
}

// MARK: - CoinGecko API
class CoinGeckoAPI {
    private let baseURL = "https://api.coingecko.com/api/v3"
    private let fallbackURL = "https://api.coingecko.com/api/v3"
    
    // Mapping of common tickers to CoinGecko IDs
    private static let tickerToId: [String: String] = [
        "btc": "bitcoin",
        "eth": "ethereum",
        "usdt": "tether",
        "usdc": "usd-coin",
        "bnb": "binancecoin",
        "sol": "solana",
        "ada": "cardano",
        "xrp": "ripple",
        "avax": "avalanche-2",
        "dot": "polkadot",
        "doge": "dogecoin",
        "matic": "matic-network",
        "ltc": "litecoin",
        "bch": "bitcoin-cash",
        "link": "chainlink",
        "uni": "uniswap",
        "atom": "cosmos",
        "etc": "ethereum-classic",
        "xlm": "stellar",
        "vet": "vechain",
        "icp": "internet-computer",
        "fil": "filecoin",
        "near": "near",
        "algo": "algorand",
        "apt": "aptos",
        "arb": "arbitrum",
        "op": "optimism",
        "mkr": "maker",
        "aave": "aave",
        "sushi": "sushi",
        "comp": "compound-governance-token",
        "yfi": "yearn-finance",
        "crv": "curve-dao-token",
        "bal": "balancer",
        "1inch": "1inch",
        "grt": "the-graph",
        "enj": "enjincoin",
        "sand": "the-sandbox",
        "mana": "decentraland",
        "axs": "axie-infinity",
        "gala": "gala",
        "chz": "chiliz",
        "hot": "holochain",
        "bat": "basic-attention-token",
        "zil": "zilliqa",
        "hbar": "hedera-hashgraph",
        "xmr": "monero",
        "dash": "dash",
        "neo": "neo",
        "eos": "eos",
        "trx": "tron",
        "xem": "nem",
        "waves": "waves",
        "qtum": "qtum",
        "omg": "omisego",
        "zec": "zcash",
        "btt": "bittorrent",
        "icx": "icon",
        "nano": "nano",
        "sc": "siacoin",
        "dcr": "decred",
        "xvg": "verge",
        "bts": "bitshares",
        "steem": "steem",
        "bcn": "bytecoin",
        "pivx": "pivx",
        "btg": "bitcoin-gold",
        "bcd": "bitcoin-diamond",
        "bsv": "bitcoin-sv"
    ]
    
    static func getCoinGeckoId(for ticker: String) -> String? {
        let lowercasedTicker = ticker.lowercased()
        return tickerToId[lowercasedTicker]
    }
    
    func getPrices(for tickers: [String], currency: String) async throws -> [String: Double] {
        guard !tickers.isEmpty else {
            throw APIError.invalidURL
        }
        
        let tickerString = tickers.joined(separator: ",")
        let urlString = "\(baseURL)/simple/price?ids=\(tickerString)&vs_currencies=\(currency)"
        
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }
        
        // Create a custom URLSession configuration with much longer timeout
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 60  // Increased from 30 to 60 seconds
        config.timeoutIntervalForResource = 120 // Increased from 60 to 120 seconds
        config.waitsForConnectivity = true // Wait for connectivity
        let session = URLSession(configuration: config)
        
        do {
            let (data, response) = try await session.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            // Handle different HTTP status codes
            switch httpResponse.statusCode {
            case 200:
                let decoder = JSONDecoder()
                let result = try decoder.decode([String: [String: Double]].self, from: data)
                
                var prices: [String: Double] = [:]
                for (ticker, priceData) in result {
                    if let price = priceData[currency] {
                        prices[ticker] = price
                    }
                }
                
                return prices
                
            case 429:
                // Rate limit exceeded - wait and retry once
                try await Task.sleep(nanoseconds: 3_000_000_000) // Wait 3 seconds
                let (retryData, retryResponse) = try await session.data(from: url)
                
                guard let retryHttpResponse = retryResponse as? HTTPURLResponse,
                      retryHttpResponse.statusCode == 200 else {
                    throw APIError.rateLimitExceeded
                }
                
                let decoder = JSONDecoder()
                let result = try decoder.decode([String: [String: Double]].self, from: retryData)
                
                var prices: [String: Double] = [:]
                for (ticker, priceData) in result {
                    if let price = priceData[currency] {
                        prices[ticker] = price
                    }
                }
                
                return prices
                
            case 404:
                throw APIError.notFound
            case 500...599:
                throw APIError.serverError
            default:
                throw APIError.invalidResponse
            }
            
        } catch {
            // If it's already an APIError, rethrow it
            if error is APIError {
                throw error
            }
            // Otherwise, throw a generic network error
            throw APIError.networkError(error)
        }
    }
    
    func getCoinInfo(for ticker: String) async throws -> CoinInfo? {
        let urlString = "\(baseURL)/search?query=\(ticker)"
        
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }
        
        let decoder = JSONDecoder()
        let result = try decoder.decode(SearchResponse.self, from: data)
        
        return result.coins.first { $0.symbol.lowercased() == ticker.lowercased() }
    }
}

// MARK: - API Models
struct SearchResponse: Codable {
    let coins: [CoinInfo]
}

struct CoinInfo: Codable {
    let id: String
    let symbol: String
    let name: String
}

enum APIError: Error {
    case invalidURL
    case invalidResponse
    case decodingError
    case rateLimitExceeded
    case notFound
    case serverError
    case networkError(Error)
} 