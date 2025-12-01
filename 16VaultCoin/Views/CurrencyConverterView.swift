import SwiftUI

struct CurrencyConverterView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var amount = ""
    @State private var fromCurrency: PortfolioViewModel.AppCurrency = .usd
    @State private var toCurrency: PortfolioViewModel.AppCurrency = .eur
    @State private var convertedAmount = ""
    @State private var isAnimating = false
    @State private var isConverting = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black
                    .ignoresSafeArea()
                
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
                                
                                Image(systemName: "arrow.left.arrow.right.circle.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.yellow)
                                    .scaleEffect(isAnimating ? 1.05 : 1.0)
                                    .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isAnimating)
                            }
                            
                            Text("Currency Converter")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.yellow)
                            
                            Text("Convert between different currencies instantly")
                                .font(.body)
                                .foregroundColor(.yellow.opacity(0.8))
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 20)
                        
                        // Amount Input
                        VStack(alignment: .leading, spacing: 12) {
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
                                    Text("Enter amount to convert")
                                        .foregroundColor(.yellow.opacity(0.6))
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 12)
                                }
                                TextField("", text: $amount)
                                    .keyboardType(.decimalPad)
                                    .foregroundColor(.yellow)
                                    .font(.system(size: 18, weight: .medium))
                                    .onChange(of: amount) { _ in
                                        convertCurrency()
                                    }
                                    .padding()
                                    .background(Color.black.opacity(0.8))
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
                                    )
                            }
                        }
                        
                        // Currency Selection
                        VStack(spacing: 16) {
                            // From Currency
                            VStack(alignment: .leading, spacing: 8) {
                                Text("From")
                                    .font(.subheadline)
                                    .foregroundColor(.yellow.opacity(0.8))
                                
                                HStack(spacing: 12) {
                                    CurrencyPickerButton(
                                        currency: fromCurrency,
                                        isSelected: true,
                                        action: {
                                            // Future: Show currency picker
                                        }
                                    )
                                    
                                    // Swap Button
                                    Button(action: {
                                        withAnimation(.easeInOut(duration: 0.3)) {
                                            let temp = fromCurrency
                                            fromCurrency = toCurrency
                                            toCurrency = temp
                                            convertCurrency()
                                        }
                                    }) {
                                        ZStack {
                                            Circle()
                                                .fill(Color.yellow.opacity(0.2))
                                                .frame(width: 40, height: 40)
                                            
                                            Image(systemName: "arrow.left.arrow.right")
                                                .font(.system(size: 16, weight: .medium))
                                                .foregroundColor(.yellow)
                                        }
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    
                                    CurrencyPickerButton(
                                        currency: toCurrency,
                                        isSelected: true,
                                        action: {
                                            // Future: Show currency picker
                                        }
                                    )
                                }
                            }
                        }
                        
                        // Conversion Result
                        if !convertedAmount.isEmpty && !amount.isEmpty {
                            VStack(spacing: 16) {
                                // Result Card
                                VStack(spacing: 12) {
                                    Text("Converted Amount")
                                        .font(.subheadline)
                                        .foregroundColor(.yellow.opacity(0.8))
                                    
                                    Text(convertedAmount)
                                        .font(.system(size: 32, weight: .bold, design: .rounded))
                                        .foregroundColor(.yellow)
                                        .scaleEffect(isConverting ? 1.05 : 1.0)
                                        .animation(.easeInOut(duration: 0.3), value: isConverting)
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.yellow.opacity(0.1))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
                                        )
                                )
                                
                                // Exchange Rate
                                if let amountValue = Double(amount), amountValue > 0 {
                                    VStack(spacing: 8) {
                                        Text("Exchange Rate")
                                            .font(.caption)
                                            .foregroundColor(.yellow.opacity(0.6))
                                        
                                        Text("1 \(fromCurrency.rawValue) = \(getExchangeRate()) \(toCurrency.rawValue)")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(.yellow.opacity(0.8))
                                    }
                                    .padding()
                                    .background(Color.black.opacity(0.6))
                                    .cornerRadius(8)
                                }
                            }
                            .transition(.opacity.combined(with: .scale))
                            .animation(.easeInOut(duration: 0.5), value: convertedAmount)
                        }
                        
                        // Quick Conversion Buttons
                        VStack(spacing: 12) {
                            Text("Quick Conversions")
                                .font(.headline)
                                .foregroundColor(.yellow)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                                QuickConversionButton(
                                    from: .usd,
                                    to: .eur,
                                    amount: "100",
                                    action: {
                                        amount = "100"
                                        fromCurrency = .usd
                                        toCurrency = .eur
                                        convertCurrency()
                                    }
                                )
                                
                                QuickConversionButton(
                                    from: .eur,
                                    to: .usd,
                                    amount: "100",
                                    action: {
                                        amount = "100"
                                        fromCurrency = .eur
                                        toCurrency = .usd
                                        convertCurrency()
                                    }
                                )
                                
                                QuickConversionButton(
                                    from: .usd,
                                    to: .gbp,
                                    amount: "100",
                                    action: {
                                        amount = "100"
                                        fromCurrency = .usd
                                        toCurrency = .gbp
                                        convertCurrency()
                                    }
                                )
                                
                                QuickConversionButton(
                                    from: .gbp,
                                    to: .usd,
                                    amount: "100",
                                    action: {
                                        amount = "100"
                                        fromCurrency = .gbp
                                        toCurrency = .usd
                                        convertCurrency()
                                    }
                                )
                            }
                        }
                        
                        Spacer(minLength: 100)
                    }
                    .padding()
                }
            }
            .navigationTitle("Converter")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.yellow)
                }
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
    
    private func convertCurrency() {
        guard let amountValue = Double(amount), amountValue > 0 else {
            convertedAmount = ""
            return
        }
        
        isConverting = true
        
        // Simulate conversion delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let rate = getExchangeRate()
            let converted = amountValue * rate
            convertedAmount = formatCurrency(converted, currency: toCurrency)
            isConverting = false
        }
    }
    
    private func getExchangeRate() -> Double {
        // Simplified exchange rates (in real app, these would come from API)
        switch (fromCurrency, toCurrency) {
        case (.usd, .eur): return 0.85
        case (.usd, .gbp): return 0.73
        case (.eur, .usd): return 1.18
        case (.eur, .gbp): return 0.86
        case (.gbp, .usd): return 1.37
        case (.gbp, .eur): return 1.16
        default: return 1.0
        }
    }
    
    private func formatCurrency(_ value: Double, currency: PortfolioViewModel.AppCurrency) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency.rawValue
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: value)) ?? "\(currency.symbol)\(value)"
    }
}

struct CurrencyPickerButton: View {
    let currency: PortfolioViewModel.AppCurrency
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Text(currency.symbol)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.black)
                
                Text(currency.rawValue)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.black)
                
                Image(systemName: "chevron.down")
                    .font(.system(size: 12))
                    .foregroundColor(.black)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.yellow)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct QuickConversionButton: View {
    let from: PortfolioViewModel.AppCurrency
    let to: PortfolioViewModel.AppCurrency
    let amount: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                HStack(spacing: 4) {
                    Text(from.symbol)
                        .font(.system(size: 14, weight: .medium))
                    Text(amount)
                        .font(.system(size: 14, weight: .medium))
                    Image(systemName: "arrow.right")
                        .font(.system(size: 12))
                    Text(to.symbol)
                        .font(.system(size: 14, weight: .medium))
                }
                .foregroundColor(.yellow)
                
                Text("\(from.rawValue) → \(to.rawValue)")
                    .font(.system(size: 10))
                    .foregroundColor(.yellow.opacity(0.7))
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
        }
        .buttonStyle(PlainButtonStyle())
    }
}



#Preview {
    CurrencyConverterView()
} 