import Foundation
import CoreData

extension Transaction {
    var totalValue: Double {
        amount * price
    }
    
    var displayType: String {
        type?.capitalized ?? "Unknown"
    }
    
    var tagArray: [String] {
        guard let tags = tags, !tags.isEmpty else { return [] }
        return tags.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
    }
    
    var isBuy: Bool {
        type == "buy"
    }
    
    var isSell: Bool {
        type == "sell"
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