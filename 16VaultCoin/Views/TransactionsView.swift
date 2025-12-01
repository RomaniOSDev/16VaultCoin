import SwiftUI

enum TransactionFilter: String, CaseIterable {
    case all = "All"
    case buy = "Buy"
    case sell = "Sell"
    
    var icon: String {
        switch self {
        case .all: return "list.bullet"
        case .buy: return "arrow.down.circle"
        case .sell: return "arrow.up.circle"
        }
    }
}

struct TransactionsView: View {
    @EnvironmentObject var portfolioViewModel: PortfolioViewModel
    @State private var isAnimating = false
    @State private var selectedFilter: TransactionFilter = .all
    @State private var searchText = ""
    
    var filteredTransactions: [Transaction] {
        let allTransactions = portfolioViewModel.coins.flatMap { coin in
            coin.sortedTransactions
        }.sorted { $0.date ?? Date.distantPast > $1.date ?? Date.distantPast }
        
        var filtered = allTransactions
        
        // Filter by type
        if selectedFilter != .all {
            let filterType = selectedFilter.rawValue.lowercased()
            filtered = filtered.filter { $0.type == filterType }
        }
        
        // Filter by search
        if !searchText.isEmpty {
            filtered = filtered.filter { transaction in
                let coinName = transaction.coin?.displayName ?? ""
                let coinTicker = transaction.coin?.displayTicker ?? ""
                let notes = transaction.notes ?? ""
                
                return coinName.localizedCaseInsensitiveContains(searchText) ||
                       coinTicker.localizedCaseInsensitiveContains(searchText) ||
                       notes.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return filtered
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header Stats
                    VStack(spacing: 16) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Total Transactions")
                                    .font(.subheadline)
                                    .foregroundColor(.yellow.opacity(0.8))
                                
                                Text("\(filteredTransactions.count)")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.yellow)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 4) {
                                Text("Total Coins")
                                    .font(.subheadline)
                                    .foregroundColor(.yellow.opacity(0.8))
                                
                                Text("\(portfolioViewModel.coins.count)")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.yellow)
                            }
                        }
                        
                        // Filter Pills
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(TransactionFilter.allCases, id: \.self) { filter in
                                    FilterButton(
                                        filter: filter,
                                        isSelected: selectedFilter == filter,
                                        action: {
                                            withAnimation(.easeInOut(duration: 0.3)) {
                                                selectedFilter = filter
                                            }
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.black.opacity(0.8))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
                            )
                    )
                    .padding(.horizontal)
                    .padding(.top)
                    
                    // Search Bar
                    HStack(spacing: 12) {
                        HStack(spacing: 8) {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.yellow.opacity(0.6))
                                .font(.system(size: 14))
                            
                            ZStack(alignment: .leading) {
                                if searchText.isEmpty {
                                    Text("Search transactions...")
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
                    .padding(.horizontal)
                    .padding(.top, 12)
                    
                    // Transactions List
                    if filteredTransactions.isEmpty {
                        VStack(spacing: 20) {
                            Spacer()
                            
                            ZStack {
                                Circle()
                                    .fill(Color.yellow.opacity(0.1))
                                    .frame(width: 100, height: 100)
                                    .scaleEffect(isAnimating ? 1.1 : 1.0)
                                    .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: isAnimating)
                                
                                Image(systemName: "list.bullet.circle")
                                    .font(.system(size: 48))
                                    .foregroundColor(.yellow)
                                    .scaleEffect(isAnimating ? 1.05 : 1.0)
                                    .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isAnimating)
                            }
                            
                            VStack(spacing: 8) {
                                Text("No transactions found")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.yellow)
                                
                                Text(searchText.isEmpty ? "Add some coins to see your transaction history" : "Try adjusting your search or filters")
                                    .font(.body)
                                    .foregroundColor(.yellow.opacity(0.8))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 40)
                            }
                            
                            Spacer()
                        }
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(Array(filteredTransactions.enumerated()), id: \.element.id) { index, transaction in
                                    EnhancedTransactionRowView(transaction: transaction)
                                        .transition(.opacity.combined(with: .scale))
                                        .animation(.easeInOut(duration: 0.3).delay(Double(index) * 0.05), value: filteredTransactions)
                                }
                            }
                            .padding()
                        }
                    }
                }
            }
            .navigationTitle("Transactions")
            .navigationBarTitleDisplayMode(.large)
        }
        .onAppear {
            isAnimating = true
        }
    }
}

struct EnhancedTransactionRowView: View {
    let transaction: Transaction
    @State private var isPressed = false
    
    private var transactionTypeColor: Color {
        transaction.type == "buy" ? .green : .red
    }
    
    private var transactionTypeIcon: String {
        transaction.type == "buy" ? "arrow.down.circle.fill" : "arrow.up.circle.fill"
    }
    
    private var transactionTypeText: String {
        transaction.type?.uppercased() ?? "UNKNOWN"
    }
    
    private var coinName: String {
        transaction.coin?.displayName ?? "Unknown"
    }
    
    private var totalValueText: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: transaction.totalValue)) ?? "$0.00"
    }
    
    private var amountPriceText: String {
        String(format: "%.4f @ %.2f", transaction.amount, transaction.price)
    }
    
    var body: some View {
        Button(action: {
            // Future: Show transaction details
        }) {
            HStack(spacing: 16) {
                // Transaction type icon
                ZStack {
                    Circle()
                        .fill(transactionTypeColor.opacity(0.2))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: transactionTypeIcon)
                        .font(.system(size: 20))
                        .foregroundColor(transactionTypeColor)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(coinName)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.yellow)
                        
                        Spacer()
                        
                        Text(totalValueText)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.yellow)
                    }
                    
                    HStack {
                        Text(amountPriceText)
                            .font(.system(size: 12))
                            .foregroundColor(.yellow.opacity(0.7))
                        
                        Spacer()
                        
                        Text(transactionTypeText)
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(transactionTypeColor)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(transactionTypeColor.opacity(0.2))
                            )
                    }
                    
                    if let notes = transaction.notes, !notes.isEmpty {
                        Text(notes)
                            .font(.system(size: 11))
                            .foregroundColor(.yellow.opacity(0.6))
                            .lineLimit(1)
                    }
                    
                    if let date = transaction.date {
                        Text(date, style: .relative)
                            .font(.system(size: 10))
                            .foregroundColor(.yellow.opacity(0.5))
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

struct FilterButton: View {
    let filter: TransactionFilter
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: filter.icon)
                    .font(.system(size: 12))
                
                Text(filter.rawValue)
                    .font(.system(size: 12, weight: .medium))
            }
            .foregroundColor(isSelected ? .black : .yellow)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? Color.yellow : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    TransactionsView()
        .environmentObject(PortfolioViewModel())
} 