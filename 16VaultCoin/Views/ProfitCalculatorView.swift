import SwiftUI

struct ProfitCalculatorView: View {
    @EnvironmentObject var portfolioViewModel: PortfolioViewModel
    @State private var initialInvestment: String = ""
    @State private var currentValue: String = ""
    @State private var holdingPeriod: String = ""
    @State private var selectedPeriod = "days"
    @State private var selectedTaxRate: String = "15"
    @State private var isLongTerm = true
    @State private var showingDCA = false
    
    private var profitCalculation: ProfitCalculation {
        let initial = Double(initialInvestment) ?? 0
        let current = Double(currentValue) ?? 0
        let period = Double(holdingPeriod) ?? 0
        
        return ProfitCalculation(
            initialInvestment: initial,
            currentValue: current,
            holdingPeriod: period,
            periodType: selectedPeriod,
            taxRate: Double(selectedTaxRate) ?? 15,
            isLongTerm: isLongTerm
        )
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 8) {
                            Text("Profit Calculator")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.yellow)
                            
                            Text("Calculate your crypto investment returns")
                                .font(.caption)
                                .foregroundColor(.yellow.opacity(0.7))
                        }
                        .padding(.top)
                        
                        // Input Section
                        VStack(spacing: 16) {
                            Text("Investment Details")
                                .font(.headline)
                                .foregroundColor(.yellow)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            // Initial Investment
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Initial Investment")
                                    .font(.subheadline)
                                    .foregroundColor(.yellow.opacity(0.8))
                                
                                ZStack(alignment: .leading) {
                                    if initialInvestment.isEmpty {
                                        Text("Enter amount")
                                            .foregroundColor(.yellow.opacity(0.6))
                                            .padding()
                                    }
                                    TextField("", text: $initialInvestment)
                                        .padding()
                                        .background(Color.black.opacity(0.6))
                                        .cornerRadius(8)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.yellow.opacity(0.2), lineWidth: 1)
                                        )
                                        .foregroundColor(.yellow)
                                }
                            }
                            
                            // Current Value
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Current Value")
                                    .font(.subheadline)
                                    .foregroundColor(.yellow.opacity(0.8))
                                
                                ZStack(alignment: .leading) {
                                    if currentValue.isEmpty {
                                        Text("Enter current value")
                                            .foregroundColor(.yellow.opacity(0.6))
                                            .padding()
                                    }
                                    TextField("", text: $currentValue)
                                        .padding()
                                        .background(Color.black.opacity(0.6))
                                        .cornerRadius(8)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.yellow.opacity(0.2), lineWidth: 1)
                                        )
                                        .foregroundColor(.yellow)
                                }
                            }
                            
                            // Holding Period
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Holding Period")
                                    .font(.subheadline)
                                    .foregroundColor(.yellow.opacity(0.8))
                                
                                HStack {
                                    ZStack(alignment: .leading) {
                                        if holdingPeriod.isEmpty {
                                            Text("Enter period")
                                                .foregroundColor(.yellow.opacity(0.6))
                                                .padding()
                                        }
                                        TextField("", text: $holdingPeriod)
                                            .padding()
                                            .background(Color.black.opacity(0.6))
                                            .cornerRadius(8)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .stroke(Color.yellow.opacity(0.2), lineWidth: 1)
                                            )
                                            .foregroundColor(.yellow)
                                    }
                                    
                                    Picker("Period", selection: $selectedPeriod) {
                                        Text("Days").tag("days")
                                        Text("Months").tag("months")
                                        Text("Years").tag("years")
                                    }
                                    .pickerStyle(SegmentedPickerStyle())
                                    .frame(width: 120)
                                }
                            }
                        }
                        .padding()
                        .background(Color.black.opacity(0.8))
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
                        )
                        
                        // Tax Settings
                        VStack(spacing: 16) {
                            Text("Tax Settings")
                                .font(.headline)
                                .foregroundColor(.yellow)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("Tax Rate (%)")
                                        .foregroundColor(.yellow.opacity(0.8))
                                    Spacer()
                                    ZStack(alignment: .leading) {
                                        if selectedTaxRate.isEmpty {
                                            Text("15")
                                                .foregroundColor(.yellow.opacity(0.6))
                                                .padding()
                                        }
                                        TextField("", text: $selectedTaxRate)
                                            .padding()
                                            .background(Color.black.opacity(0.6))
                                            .cornerRadius(8)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .stroke(Color.yellow.opacity(0.2), lineWidth: 1)
                                            )
                                            .foregroundColor(.yellow)
                                            .frame(width: 80)
                                    }
                                }
                                
                                HStack {
                                    Text("Long-term holding (>1 year)")
                                        .foregroundColor(.yellow.opacity(0.8))
                                    Spacer()
                                    Toggle("", isOn: $isLongTerm)
                                        .toggleStyle(SwitchToggleStyle(tint: .yellow))
                                }
                            }
                        }
                        .padding()
                        .background(Color.black.opacity(0.8))
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
                        )
                        
                        // Results Section
                        if !initialInvestment.isEmpty && !currentValue.isEmpty {
                            VStack(spacing: 16) {
                                Text("Results")
                                    .font(.headline)
                                    .foregroundColor(.yellow)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                VStack(spacing: 12) {
                                    ResultRow(
                                        title: "Total Profit/Loss",
                                        value: profitCalculation.totalProfitLoss,
                                        isCurrency: true,
                                        isPositive: profitCalculation.totalProfitLoss >= 0
                                    )
                                    
                                    ResultRow(
                                        title: "ROI",
                                        value: profitCalculation.roi,
                                        isCurrency: false,
                                        isPositive: profitCalculation.roi >= 0,
                                        suffix: "%"
                                    )
                                    
                                    ResultRow(
                                        title: "Annualized ROI",
                                        value: profitCalculation.annualizedRoi,
                                        isCurrency: false,
                                        isPositive: profitCalculation.annualizedRoi >= 0,
                                        suffix: "%"
                                    )
                                    
                                    ResultRow(
                                        title: "Taxes Owed",
                                        value: profitCalculation.taxesOwed,
                                        isCurrency: true,
                                        isPositive: false
                                    )
                                    
                                    ResultRow(
                                        title: "Net Profit",
                                        value: profitCalculation.netProfit,
                                        isCurrency: true,
                                        isPositive: profitCalculation.netProfit >= 0
                                    )
                                }
                            }
                            .padding()
                            .background(Color.black.opacity(0.8))
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
                            )
                        }
                        
                        // DCA Calculator Button
                        Button(action: {
                            showingDCA = true
                        }) {
                            HStack {
                                Image(systemName: "chart.line.uptrend.xyaxis")
                                Text("DCA Calculator")
                            }
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.yellow)
                            .cornerRadius(12)
                        }
                        
                        Spacer(minLength: 50)
                    }
                    .padding()
                }
            }
            .navigationTitle("Profit Calculator")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingDCA) {
                DCACalculatorView()
            }
        }
    }
}

struct ResultRow: View {
    let title: String
    let value: Double
    let isCurrency: Bool
    let isPositive: Bool
    let suffix: String
    
    init(title: String, value: Double, isCurrency: Bool, isPositive: Bool, suffix: String = "") {
        self.title = title
        self.value = value
        self.isCurrency = isCurrency
        self.isPositive = isPositive
        self.suffix = suffix
    }
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.yellow.opacity(0.8))
            
            Spacer()
            
            Text(formatValue())
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(isPositive ? .green : .red)
        }
    }
    
    private func formatValue() -> String {
        if isCurrency {
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.currencyCode = "USD"
            formatter.maximumFractionDigits = 2
            return formatter.string(from: NSNumber(value: value)) ?? "$\(value)"
        } else {
            return String(format: "%.2f%@", value, suffix)
        }
    }
}

struct ProfitCalculation {
    let initialInvestment: Double
    let currentValue: Double
    let holdingPeriod: Double
    let periodType: String
    let taxRate: Double
    let isLongTerm: Bool
    
    var totalProfitLoss: Double {
        return currentValue - initialInvestment
    }
    
    var roi: Double {
        guard initialInvestment > 0 else { return 0 }
        return (totalProfitLoss / initialInvestment) * 100
    }
    
    var annualizedRoi: Double {
        guard initialInvestment > 0 && holdingPeriod > 0 else { return 0 }
        
        let years: Double
        switch periodType {
        case "days":
            years = holdingPeriod / 365
        case "months":
            years = holdingPeriod / 12
        case "years":
            years = holdingPeriod
        default:
            years = holdingPeriod / 365
        }
        
        guard years > 0 else { return roi }
        
        let totalReturn = currentValue / initialInvestment
        return (pow(totalReturn, 1/years) - 1) * 100
    }
    
    var taxesOwed: Double {
        guard totalProfitLoss > 0 else { return 0 }
        
        let effectiveTaxRate = isLongTerm ? taxRate * 0.6 : taxRate // Long-term gains taxed at lower rate
        return totalProfitLoss * (effectiveTaxRate / 100)
    }
    
    var netProfit: Double {
        return totalProfitLoss - taxesOwed
    }
}

#Preview {
    ProfitCalculatorView()
        .environmentObject(PortfolioViewModel())
} 