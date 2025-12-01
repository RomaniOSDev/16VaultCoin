import SwiftUI

enum Field {
    case amount, price, notes
    
    var description: String {
        switch self {
        case .amount: return "amount"
        case .price: return "price"
        case .notes: return "notes"
        }
    }
}

struct AddCoinView: View {
    @EnvironmentObject var portfolioViewModel: PortfolioViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var ticker = ""
    @State private var amount = ""
    @State private var price = ""
    @State private var notes = ""
    @State private var isAnimating = false
    @State private var showingValidationError = false
    @State private var validationMessage = ""
    @State private var showingExamples = false
    @State private var showingCoinPicker = false
    @State private var searchText = ""
    @FocusState private var focusedField: Field?
    
    private var isFormValid: Bool {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedTicker = ticker.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedAmount = amount.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPrice = price.trimmingCharacters(in: .whitespacesAndNewlines)
        
        return !trimmedName.isEmpty &&
               !trimmedTicker.isEmpty &&
               !trimmedAmount.isEmpty &&
               !trimmedPrice.isEmpty &&
               Double(trimmedAmount) != nil &&
               Double(trimmedPrice) != nil
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black
                    .ignoresSafeArea()
                    .onTapGesture {
                        focusedField = nil
                        hideKeyboard()
                    }
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(Color.yellow.opacity(0.1))
                                    .frame(width: 80, height: 80)
                                    .scaleEffect(isAnimating ? 1.1 : 1.0)
                                    .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: isAnimating)
                                
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.yellow)
                                    .scaleEffect(isAnimating ? 1.05 : 1.0)
                                    .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isAnimating)
                            }
                            
                            Text("Add New Coin")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.yellow)
                            
                            Text("Enter the details of your cryptocurrency purchase")
                                .font(.body)
                                .foregroundColor(.yellow.opacity(0.8))
                                .multilineTextAlignment(.center)
                            
                            // Quick Examples Button
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    showingExamples.toggle()
                                }
                            }) {
                                HStack(spacing: 6) {
                                    Image(systemName: "lightbulb")
                                        .font(.system(size: 12))
                                    
                                    Text("Show Examples")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                }
                                .foregroundColor(.yellow.opacity(0.8))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.yellow.opacity(0.1))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
                                        )
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                            

                        }
                        .padding(.top, 20)
                        
                        // Examples Section
                        if showingExamples {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Quick Examples")
                                    .font(.headline)
                                    .foregroundColor(.yellow)
                                
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                                    ExampleCard(
                                        name: "Bitcoin",
                                        ticker: "BTC",
                                        amount: "0.5",
                                        price: "45000",
                                        notes: "Bought during dip",
                                        action: { fillExample("Bitcoin", "BTC", "0.5", "45000", "Bought during dip") }
                                    )
                                    
                                    ExampleCard(
                                        name: "Ethereum",
                                        ticker: "ETH",
                                        amount: "2.5",
                                        price: "2800",
                                        notes: "Long-term hold",
                                        action: { fillExample("Ethereum", "ETH", "2.5", "2800", "Long-term hold") }
                                    )
                                    
                                    ExampleCard(
                                        name: "Cardano",
                                        ticker: "ADA",
                                        amount: "1000",
                                        price: "0.45",
                                        notes: "DCA purchase",
                                        action: { fillExample("Cardano", "ADA", "1000", "0.45", "DCA purchase") }
                                    )
                                    
                                    ExampleCard(
                                        name: "Solana",
                                        ticker: "SOL",
                                        amount: "10",
                                        price: "120",
                                        notes: "Staking rewards",
                                        action: { fillExample("Solana", "SOL", "10", "120", "Staking rewards") }
                                    )
                                }
                            }
                            .padding()
                            .background(Color.black.opacity(0.8))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
                            )
                            .transition(.opacity.combined(with: .scale))
                            .animation(.easeInOut(duration: 0.3), value: showingExamples)
                        }
                        
                        // Form Fields
                        VStack(spacing: 20) {
                            // Coin Selection Button
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Image(systemName: "bitcoinsign.circle")
                                        .foregroundColor(.yellow)
                                        .font(.system(size: 16))
                                    
                                    Text("Select Cryptocurrency")
                                        .font(.headline)
                                        .foregroundColor(.yellow)
                                }
                                
                                Button(action: {
                                    showingCoinPicker = true
                                }) {
                                    HStack {
                                        if name.isEmpty && ticker.isEmpty {
                                            Text("Choose from popular cryptocurrencies...")
                                                .foregroundColor(.yellow.opacity(0.7))
                                                .font(.system(size: 16))
                                        } else {
                                            HStack(spacing: 8) {
                                                Image(systemName: getIconForTicker(ticker.lowercased()))
                                                    .foregroundColor(.yellow)
                                                    .font(.system(size: 16))
                                                
                                                VStack(alignment: .leading, spacing: 2) {
                                                    Text(name)
                                                        .foregroundColor(.yellow)
                                                        .font(.system(size: 16, weight: .medium))
                                                    
                                                    Text(ticker)
                                                        .foregroundColor(.yellow.opacity(0.7))
                                                        .font(.system(size: 14))
                                                }
                                            }
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.yellow.opacity(0.6))
                                            .font(.system(size: 12))
                                    }
                                    .padding()
                                    .background(Color.yellow.opacity(0.1))
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.yellow.opacity(0.4), lineWidth: 1.5)
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            
                            // Amount Field
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Image(systemName: "number.circle")
                                        .foregroundColor(.yellow)
                                        .font(.system(size: 16))
                                    
                                    Text("Amount")
                                        .font(.headline)
                                        .foregroundColor(.yellow)
                                }
                                
                                ZStack(alignment: .leading) {
                                    if amount.isEmpty {
                                        Text("e.g., 0.5, 2.5, 100")
                                            .foregroundColor(.yellow.opacity(0.7))
                                            .font(.system(size: 18, weight: .bold))
                                            .shadow(color: .black, radius: 2, x: 0, y: 1)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 12)
                                    }
                                    
                                    TextField("", text: $amount)
                                        .foregroundColor(.yellow)
                                        .keyboardType(.decimalPad)
                                        .focused($focusedField, equals: .amount)
                                        .padding()
                                        .background(Color.yellow.opacity(0.1))
                                        .cornerRadius(12)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(focusedField == .amount ? Color.yellow.opacity(0.8) : Color.yellow.opacity(0.4), lineWidth: focusedField == .amount ? 2 : 1.5)
                                        )
                                        .scaleEffect(focusedField == .amount ? 1.02 : 1.0)
                                        .animation(.easeInOut(duration: 0.2), value: focusedField == .amount)
                                }
                            }
                            
                            // Price Field
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Image(systemName: "dollarsign.circle")
                                        .foregroundColor(.yellow)
                                        .font(.system(size: 16))
                                    
                                    Text("Price per Coin")
                                        .font(.headline)
                                        .foregroundColor(.yellow)
                                }
                                
                                ZStack(alignment: .leading) {
                                    if price.isEmpty {
                                        Text("e.g., 45000, 2800, 0.45")
                                            .foregroundColor(.yellow.opacity(0.7))
                                            .font(.system(size: 18, weight: .bold))
                                            .shadow(color: .black, radius: 2, x: 0, y: 1)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 12)
                                    }
                                    
                                    TextField("", text: $price)
                                        .foregroundColor(.yellow)
                                        .keyboardType(.decimalPad)
                                        .focused($focusedField, equals: .price)
                                        .padding()
                                        .background(Color.yellow.opacity(0.1))
                                        .cornerRadius(12)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(focusedField == .price ? Color.yellow.opacity(0.8) : Color.yellow.opacity(0.4), lineWidth: focusedField == .price ? 2 : 1.5)
                                        )
                                        .scaleEffect(focusedField == .price ? 1.02 : 1.0)
                                        .animation(.easeInOut(duration: 0.2), value: focusedField == .price)
                                }
                            }
                            
                            // Notes Field
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Image(systemName: "note.text")
                                        .foregroundColor(.yellow)
                                        .font(.system(size: 16))
                                    
                                    Text("Notes (Optional)")
                                        .font(.headline)
                                        .foregroundColor(.yellow)
                                }
                                
                                ZStack(alignment: .topLeading) {
                                    if notes.isEmpty {
                                        Text("e.g., Bought during dip, Long-term hold, DCA purchase...")
                                            .foregroundColor(.yellow.opacity(0.7))
                                            .font(.system(size: 18, weight: .bold))
                                            .shadow(color: .black, radius: 2, x: 0, y: 1)
                                            .padding(.horizontal, 16)
                                            .padding(.top, 12)
                                    }
                                    
                                    TextEditor(text: $notes)
                                        .foregroundColor(.yellow)
                                        .background(Color.black)
                                        .frame(minHeight: 80)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .scrollContentBackground(.hidden)
                                        .focused($focusedField, equals: .notes)
                                }
                                .background(Color.yellow.opacity(0.1))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(focusedField == .notes ? Color.yellow.opacity(0.8) : Color.yellow.opacity(0.4), lineWidth: focusedField == .notes ? 2 : 1.5)
                                )
                                .scaleEffect(focusedField == .notes ? 1.02 : 1.0)
                                .animation(.easeInOut(duration: 0.2), value: focusedField == .notes)
                            }
                        }
                        
                        // Total Value Preview
                        if let amountValue = Double(amount), let priceValue = Double(price), amountValue > 0, priceValue > 0 {
                            VStack(spacing: 8) {
                                Text("Total Value")
                                    .font(.caption)
                                    .foregroundColor(.yellow.opacity(0.8))
                                
                                Text(portfolioViewModel.formatCurrency(amountValue * priceValue))
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.yellow)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.yellow.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
                                    )
                            )
                            .transition(.opacity.combined(with: .scale))
                            .animation(.easeInOut(duration: 0.3), value: amountValue * priceValue)
                        }
                        
                        // Action Buttons
                        VStack(spacing: 12) {
                            Button(action: addCoin) {
                                HStack(spacing: 8) {
                                    if portfolioViewModel.isLoadingPrices {
                                        ProgressView()
                                            .scaleEffect(0.8)
                                            .progressViewStyle(CircularProgressViewStyle(tint: .black))
                                    } else {
                                        Image(systemName: "plus")
                                            .font(.headline)
                                    }
                                    
                                    Text("Add Coin")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                }
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(isFormValid ? Color.yellow : Color.yellow.opacity(0.3))
                                        .shadow(color: isFormValid ? .yellow.opacity(0.3) : .clear, radius: 8, x: 0, y: 4)
                                )
                            }
                            .disabled(!isFormValid || portfolioViewModel.isLoadingPrices)
                            .scaleEffect(isFormValid ? 1.0 : 0.98)
                            .animation(.easeInOut(duration: 0.2), value: isFormValid)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Add Coin")
            .navigationBarTitleDisplayMode(.inline)
            .onTapGesture {
                focusedField = nil
                hideKeyboard()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.yellow)
                    .font(.system(size: 16, weight: .medium))
                }
                
                ToolbarItem(placement: .principal) {
                    Text("Add Coin")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.yellow)
                }
            }
            .toolbarBackground(Color.black, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .alert("Validation Error", isPresented: $showingValidationError) {
                Button("OK") { }
            } message: {
                Text(validationMessage)
            }
        }
        .onAppear {
            isAnimating = true
        }
        .sheet(isPresented: $showingCoinPicker) {
            CoinPickerView(name: $name, ticker: $ticker)
        }
    }
    
    private func addCoin() {
        guard isFormValid else {
            validationMessage = "Please fill in all required fields with valid values."
            showingValidationError = true
            return
        }
        
        guard let amountValue = Double(amount), amountValue > 0 else {
            validationMessage = "Please enter a valid amount greater than 0."
            showingValidationError = true
            return
        }
        
        guard let priceValue = Double(price), priceValue > 0 else {
            validationMessage = "Please enter a valid price greater than 0."
            showingValidationError = true
            return
        }
        
        withAnimation(.easeInOut(duration: 0.3)) {
            portfolioViewModel.addCoin(
                name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                ticker: ticker.trimmingCharacters(in: .whitespacesAndNewlines).uppercased(),
                amount: amountValue,
                price: priceValue,
                notes: notes.trimmingCharacters(in: .whitespacesAndNewlines)
            )
            dismiss()
        }
    }
    
    private func fillExample(_ coinName: String, _ coinTicker: String, _ coinAmount: String, _ coinPrice: String, _ coinNotes: String) {
        withAnimation(.easeInOut(duration: 0.3)) {
            name = coinName
            ticker = coinTicker
            amount = coinAmount
            price = coinPrice
            notes = coinNotes
            showingExamples = false
        }
    }
    
    private func getIconForTicker(_ ticker: String) -> String {
        // Use the same icon mapping as PortfolioView
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
    
    private func hideKeyboard() {
        // Method 1: Clear focus state
        focusedField = nil
        
        // Method 2: Using resignFirstResponder
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        
        // Method 3: Force end editing
        DispatchQueue.main.async {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                window.endEditing(true)
            }
        }
    }
}



struct ExampleCard: View {
    let name: String
    let ticker: String
    let amount: String
    let price: String
    let notes: String
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(ticker)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.yellow)
                    
                    Spacer()
                    
                    Image(systemName: "arrow.right.circle")
                        .font(.system(size: 12))
                        .foregroundColor(.yellow.opacity(0.7))
                }
                
                Text(name)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.yellow.opacity(0.8))
                    .lineLimit(1)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(amount) @ $\(price)")
                        .font(.system(size: 10))
                        .foregroundColor(.yellow.opacity(0.7))
                    
                    Text(notes)
                        .font(.system(size: 9))
                        .foregroundColor(.yellow.opacity(0.6))
                        .lineLimit(1)
                }
            }
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.yellow.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.yellow.opacity(0.2), lineWidth: 1)
                    )
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

// Popular cryptocurrencies list
struct PopularCrypto {
    static let coins = [
        CryptoCoin(ticker: "BTC", name: "Bitcoin", icon: "bitcoinsign.circle.fill"),
        CryptoCoin(ticker: "ETH", name: "Ethereum", icon: "network"),
        CryptoCoin(ticker: "USDT", name: "Tether", icon: "dollarsign.circle.fill"),
        CryptoCoin(ticker: "USDC", name: "USD Coin", icon: "dollarsign.circle"),
        CryptoCoin(ticker: "BNB", name: "BNB", icon: "flame.fill"),
        CryptoCoin(ticker: "SOL", name: "Solana", icon: "bolt.fill"),
        CryptoCoin(ticker: "ADA", name: "Cardano", icon: "leaf.fill"),
        CryptoCoin(ticker: "XRP", name: "XRP", icon: "wave.3.right"),
        CryptoCoin(ticker: "DOT", name: "Polkadot", icon: "circle.grid.cross.fill"),
        CryptoCoin(ticker: "DOGE", name: "Dogecoin", icon: "dog.fill"),
        CryptoCoin(ticker: "MATIC", name: "Polygon", icon: "hexagon.fill"),
        CryptoCoin(ticker: "LINK", name: "Chainlink", icon: "link.circle.fill"),
        CryptoCoin(ticker: "UNI", name: "Uniswap", icon: "arrow.triangle.2.circlepath"),
        CryptoCoin(ticker: "LTC", name: "Litecoin", icon: "l.square.fill"),
        CryptoCoin(ticker: "XLM", name: "Stellar", icon: "star.fill"),
        CryptoCoin(ticker: "ATOM", name: "Cosmos", icon: "atom"),
        CryptoCoin(ticker: "FTM", name: "Fantom", icon: "sparkles"),
        CryptoCoin(ticker: "AVAX", name: "Avalanche", icon: "snowflake"),
        CryptoCoin(ticker: "NEAR", name: "NEAR Protocol", icon: "n.square.fill"),
        CryptoCoin(ticker: "ALGO", name: "Algorand", icon: "a.square.fill"),
        CryptoCoin(ticker: "ICP", name: "Internet Computer", icon: "network.badge.shield.half.filled"),
        CryptoCoin(ticker: "FIL", name: "Filecoin", icon: "doc.fill"),
        CryptoCoin(ticker: "APT", name: "Aptos", icon: "a.circle.fill"),
        CryptoCoin(ticker: "ARB", name: "Arbitrum", icon: "arrow.left.arrow.right"),
        CryptoCoin(ticker: "OP", name: "Optimism", icon: "o.circle.fill"),
        CryptoCoin(ticker: "MKR", name: "Maker", icon: "m.square.fill"),
        CryptoCoin(ticker: "AAVE", name: "Aave", icon: "a.circle"),
        CryptoCoin(ticker: "SUSHI", name: "SushiSwap", icon: "fish.fill"),
        CryptoCoin(ticker: "COMP", name: "Compound", icon: "c.square.fill"),
        CryptoCoin(ticker: "YFI", name: "yearn.finance", icon: "y.square.fill"),
        CryptoCoin(ticker: "CRV", name: "Curve DAO Token", icon: "c.circle.fill"),
        CryptoCoin(ticker: "BAL", name: "Balancer", icon: "b.circle.fill"),
        CryptoCoin(ticker: "1INCH", name: "1inch", icon: "1.circle.fill"),
        CryptoCoin(ticker: "GRT", name: "The Graph", icon: "g.square.fill"),
        CryptoCoin(ticker: "ENJ", name: "Enjin Coin", icon: "e.square.fill"),
        CryptoCoin(ticker: "SAND", name: "The Sandbox", icon: "s.circle.fill"),
        CryptoCoin(ticker: "MANA", name: "Decentraland", icon: "m.circle"),
        CryptoCoin(ticker: "AXS", name: "Axie Infinity", icon: "a.circle"),
        CryptoCoin(ticker: "GALA", name: "Gala", icon: "g.circle.fill"),
        CryptoCoin(ticker: "CHZ", name: "Chiliz", icon: "c.circle"),
        CryptoCoin(ticker: "HOT", name: "Holo", icon: "h.square.fill"),
        CryptoCoin(ticker: "BAT", name: "Basic Attention Token", icon: "b.circle"),
        CryptoCoin(ticker: "ZIL", name: "Zilliqa", icon: "z.square.fill"),
        CryptoCoin(ticker: "HBAR", name: "Hedera", icon: "h.circle.fill"),
        CryptoCoin(ticker: "XMR", name: "Monero", icon: "m.circle"),
        CryptoCoin(ticker: "DASH", name: "Dash", icon: "d.square.fill"),
        CryptoCoin(ticker: "NEO", name: "Neo", icon: "n.circle.fill"),
        CryptoCoin(ticker: "EOS", name: "EOS", icon: "e.circle.fill"),
        CryptoCoin(ticker: "TRX", name: "TRON", icon: "t.square.fill"),
        CryptoCoin(ticker: "XEM", name: "NEM", icon: "x.circle.fill"),
        CryptoCoin(ticker: "WAVES", name: "Waves", icon: "wave.3.right.circle.fill"),
        CryptoCoin(ticker: "QTUM", name: "Qtum", icon: "q.square.fill"),
        CryptoCoin(ticker: "OMG", name: "OMG Network", icon: "o.square.fill"),
        CryptoCoin(ticker: "ZEC", name: "Zcash", icon: "z.circle.fill"),
        CryptoCoin(ticker: "BTT", name: "BitTorrent", icon: "b.circle"),
        CryptoCoin(ticker: "ICX", name: "ICON", icon: "i.square.fill"),
        CryptoCoin(ticker: "NANO", name: "Nano", icon: "n.circle"),
        CryptoCoin(ticker: "SC", name: "Siacoin", icon: "s.square.fill"),
        CryptoCoin(ticker: "DCR", name: "Decred", icon: "d.circle.fill"),
        CryptoCoin(ticker: "XVG", name: "Verge", icon: "v.circle"),
        CryptoCoin(ticker: "BTS", name: "BitShares", icon: "b.square"),
        CryptoCoin(ticker: "STEEM", name: "Steem", icon: "s.circle"),
        CryptoCoin(ticker: "BCN", name: "Bytecoin", icon: "b.circle"),
        CryptoCoin(ticker: "PIVX", name: "PIVX", icon: "p.square.fill"),
        CryptoCoin(ticker: "BTG", name: "Bitcoin Gold", icon: "b.circle.fill"),
        CryptoCoin(ticker: "BCD", name: "Bitcoin Diamond", icon: "b.square"),
        CryptoCoin(ticker: "BCH", name: "Bitcoin Cash", icon: "b.circle"),
        CryptoCoin(ticker: "BSV", name: "Bitcoin SV", icon: "b.square.fill"),
        CryptoCoin(ticker: "ETC", name: "Ethereum Classic", icon: "e.square.fill")
    ]
}

struct CryptoCoin: Identifiable {
    let id = UUID()
    let ticker: String
    let name: String
    let icon: String
}

struct CoinPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var name: String
    @Binding var ticker: String
    @State private var searchText = ""
    
    var filteredCoins: [CryptoCoin] {
        if searchText.isEmpty {
            return PopularCrypto.coins
        } else {
            return PopularCrypto.coins.filter { coin in
                coin.name.localizedCaseInsensitiveContains(searchText) ||
                coin.ticker.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Search bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.yellow.opacity(0.7))
                        
                        TextField("Search cryptocurrencies...", text: $searchText)
                            .foregroundColor(.yellow)
                            .textFieldStyle(PlainTextFieldStyle())
                    }
                    .padding()
                    .background(Color.yellow.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .padding(.top)
                    
                    // Coin list
                    ScrollView {
                        LazyVStack(spacing: 8) {
                            ForEach(filteredCoins) { coin in
                                CoinRowView(coin: coin) {
                                    name = coin.name
                                    ticker = coin.ticker
                                    dismiss()
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Select Cryptocurrency")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
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

struct CoinRowView: View {
    let coin: CryptoCoin
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // Icon
                ZStack {
                    Circle()
                        .fill(Color.yellow.opacity(0.1))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: coin.icon)
                        .font(.system(size: 18))
                        .foregroundColor(.yellow)
                }
                
                // Info
                VStack(alignment: .leading, spacing: 2) {
                    Text(coin.name)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.yellow)
                    
                    Text(coin.ticker)
                        .font(.system(size: 14))
                        .foregroundColor(.yellow.opacity(0.7))
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.yellow.opacity(0.5))
                    .font(.system(size: 12))
            }
            .padding()
            .background(Color.black.opacity(0.8))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

#Preview {
    AddCoinView()
        .environmentObject(PortfolioViewModel())
} 