import Foundation
import CoreData

extension Coin {
    var totalValue: Double {
        // Ensure currentPrice is not 0, fallback to averagePrice if needed
        let price = currentPrice > 0 ? currentPrice : averagePrice
        return amount * price
    }
    
    var profitLoss: Double {
        totalValue - (amount * averagePrice)
    }
    
    var profitLossPercentage: Double {
        guard averagePrice > 0 else { return 0 }
        return ((currentPrice - averagePrice) / averagePrice) * 100
    }
    
    var displayName: String {
        name ?? ticker ?? "Unknown"
    }
    
    var displayTicker: String {
        ticker?.uppercased() ?? ""
    }
    
    var tagArray: [String] {
        guard let tags = tags, !tags.isEmpty else { return [] }
        return tags.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
    }
    
    var sortedTransactions: [Transaction] {
        let transactions = (self.transactions?.allObjects as? [Transaction]) ?? []
        return transactions.sorted { ($0.date ?? Date.distantPast) > ($1.date ?? Date.distantPast) }
    }
    
    var sortedPriceHistory: [PriceHistory] {
        let history = (self.priceHistory?.allObjects as? [PriceHistory]) ?? []
        return history.sorted { ($0.date ?? Date.distantPast) > ($1.date ?? Date.distantPast) }
    }
    
    func updateAveragePrice() {
        let buyTransactions = sortedTransactions.filter { $0.type == "buy" }
        let totalAmount = buyTransactions.reduce(0) { $0 + $1.amount }
        let totalValue = buyTransactions.reduce(0) { $0 + ($1.amount * $1.price) }
        
        if totalAmount > 0 {
            averagePrice = totalValue / totalAmount
        }
    }
    
    func addTag(_ tag: String) {
        var currentTags = tagArray
        if !currentTags.contains(tag) {
            currentTags.append(tag)
            tags = currentTags.joined(separator: ", ")
        }
    }
    
    func removeTag(_ tag: String) {
        var currentTags = tagArray
        currentTags.removeAll { $0 == tag }
        tags = currentTags.joined(separator: ", ")
    }
} 