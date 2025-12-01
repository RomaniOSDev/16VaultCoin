import Foundation

struct Calculator {
    
    // MARK: - Price Calculations
    static func calculateTotalValue(amount: Double, price: Double) -> Double {
        return amount * price
    }
    
    static func calculateProfitLoss(currentValue: Double, costBasis: Double) -> Double {
        return currentValue - costBasis
    }
    
    static func calculateProfitLossPercentage(currentValue: Double, costBasis: Double) -> Double {
        guard costBasis > 0 else { return 0 }
        return ((currentValue - costBasis) / costBasis) * 100
    }
    
    static func calculateAveragePrice(transactions: [(amount: Double, price: Double)]) -> Double {
        let totalAmount = transactions.reduce(0) { $0 + $1.amount }
        let totalValue = transactions.reduce(0) { $0 + ($1.amount * $1.price) }
        
        return totalAmount > 0 ? totalValue / totalAmount : 0
    }
    
    // MARK: - Portfolio Analytics
    static func calculatePortfolioAllocation(coins: [(name: String, value: Double)]) -> [(name: String, percentage: Double)] {
        let totalValue = coins.reduce(0) { $0 + $1.value }
        
        return coins.map { coin in
            let percentage = totalValue > 0 ? (coin.value / totalValue) * 100 : 0
            return (name: coin.name, percentage: percentage)
        }.sorted { $0.percentage > $1.percentage }
    }
    
    static func calculatePortfolioMetrics(coins: [(value: Double, costBasis: Double)]) -> (totalValue: Double, totalCost: Double, totalProfitLoss: Double, totalProfitLossPercentage: Double) {
        let totalValue = coins.reduce(0) { $0 + $1.value }
        let totalCost = coins.reduce(0) { $0 + $1.costBasis }
        let totalProfitLoss = totalValue - totalCost
        let totalProfitLossPercentage = totalCost > 0 ? (totalProfitLoss / totalCost) * 100 : 0
        
        return (totalValue, totalCost, totalProfitLoss, totalProfitLossPercentage)
    }
    
    // MARK: - Currency Conversion
    static func convertCurrency(amount: Double, from: PortfolioViewModel.AppCurrency, to: PortfolioViewModel.AppCurrency) -> Double {
        // Примерные курсы валют (в реальном приложении нужно получать актуальные)
        let exchangeRates: [PortfolioViewModel.AppCurrency: Double] = [
            .usd: 1.0,
            .eur: 0.85,
            .gbp: 0.73
        ]
        
        guard let fromRate = exchangeRates[from],
              let toRate = exchangeRates[to] else {
            return amount
        }
        
        let usdAmount = amount / fromRate
        return usdAmount * toRate
    }
    
    // MARK: - Risk Metrics
    static func calculateVolatility(prices: [Double]) -> Double {
        guard prices.count > 1 else { return 0 }
        
        let returns = zip(prices.dropFirst(), prices).map { current, previous in
            return (current - previous) / previous
        }
        
        let meanReturn = returns.reduce(0, +) / Double(returns.count)
        let squaredDifferences = returns.map { pow($0 - meanReturn, 2) }
        let variance = squaredDifferences.reduce(0, +) / Double(squaredDifferences.count)
        
        return sqrt(variance) * 100 // В процентах
    }
    
    static func calculateSharpeRatio(returns: [Double], riskFreeRate: Double = 0.02) -> Double {
        guard returns.count > 1 else { return 0 }
        
        let meanReturn = returns.reduce(0, +) / Double(returns.count)
        let excessReturn = meanReturn - riskFreeRate
        let volatility = calculateVolatility(prices: returns.map { $0 + 1 }) / 100
        
        return volatility > 0 ? excessReturn / volatility : 0
    }
    
    // MARK: - DCA Calculator
    static func calculateDCA(monthlyInvestment: Double, months: Int, averagePrice: Double) -> (totalInvested: Double, totalCoins: Double, averageCost: Double) {
        let totalInvested = monthlyInvestment * Double(months)
        let totalCoins = totalInvested / averagePrice
        let averageCost = totalInvested / totalCoins
        
        return (totalInvested, totalCoins, averageCost)
    }
    
    // MARK: - Tax Calculations
    static func calculateCapitalGains(transactions: [(type: String, amount: Double, price: Double, date: Date)]) -> Double {
        var totalGains = 0.0
        var remainingCoins = 0.0
        var averageCost = 0.0
        
        for transaction in transactions.sorted(by: { $0.date < $1.date }) {
            if transaction.type == "buy" {
                let newTotalCost = (remainingCoins * averageCost) + (transaction.amount * transaction.price)
                remainingCoins += transaction.amount
                averageCost = remainingCoins > 0 ? newTotalCost / remainingCoins : 0
            } else if transaction.type == "sell" {
                let gain = (transaction.price - averageCost) * transaction.amount
                totalGains += gain
                remainingCoins -= transaction.amount
            }
        }
        
        return totalGains
    }
}

 