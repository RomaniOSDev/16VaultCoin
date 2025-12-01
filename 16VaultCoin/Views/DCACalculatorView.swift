import SwiftUI

struct DCACalculatorView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var monthlyInvestment: String = ""
    @State private var investmentPeriod: String = ""
    @State private var selectedPeriod = "months"
    @State private var expectedReturn: String = "10"
    @State private var showingResults = false
    
    private var dcaCalculation: DCACalculation {
        let monthly = Double(monthlyInvestment) ?? 0
        let period = Double(investmentPeriod) ?? 0
        let returnRate = Double(expectedReturn) ?? 10
        
        return DCACalculation(
            monthlyInvestment: monthly,
            investmentPeriod: period,
            periodType: selectedPeriod,
            expectedReturn: returnRate
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
                            Text("DCA Calculator")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.yellow)
                            
                            Text("Dollar Cost Averaging Strategy")
                                .font(.caption)
                                .foregroundColor(.yellow.opacity(0.7))
                        }
                        .padding(.top)
                        
                        // Input Section
                        VStack(spacing: 16) {
                            Text("Investment Plan")
                                .font(.headline)
                                .foregroundColor(.yellow)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            // Monthly Investment
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Monthly Investment")
                                    .font(.subheadline)
                                    .foregroundColor(.yellow.opacity(0.8))
                                
                                ZStack(alignment: .leading) {
                                    if monthlyInvestment.isEmpty {
                                        Text("Enter amount")
                                            .foregroundColor(.yellow.opacity(0.6))
                                            .padding()
                                    }
                                    TextField("", text: $monthlyInvestment)
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
                            
                            // Investment Period
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Investment Period")
                                    .font(.subheadline)
                                    .foregroundColor(.yellow.opacity(0.8))
                                
                                HStack {
                                    ZStack(alignment: .leading) {
                                        if investmentPeriod.isEmpty {
                                            Text("Enter period")
                                                .foregroundColor(.yellow.opacity(0.6))
                                                .padding()
                                        }
                                        TextField("", text: $investmentPeriod)
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
                                        Text("Months").tag("months")
                                        Text("Years").tag("years")
                                    }
                                    .pickerStyle(SegmentedPickerStyle())
                                    .frame(width: 100)
                                }
                            }
                            
                            // Expected Return
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Expected Annual Return (%)")
                                    .font(.subheadline)
                                    .foregroundColor(.yellow.opacity(0.8))
                                
                                ZStack(alignment: .leading) {
                                    if expectedReturn.isEmpty {
                                        Text("10")
                                            .foregroundColor(.yellow.opacity(0.6))
                                            .padding()
                                    }
                                    TextField("", text: $expectedReturn)
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
                        }
                        .padding()
                        .background(Color.black.opacity(0.8))
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
                        )
                        
                        // Calculate Button
                        Button(action: {
                            showingResults = true
                        }) {
                            HStack {
                                Image(systemName: "calculator")
                                Text("Calculate DCA Strategy")
                            }
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.yellow)
                            .cornerRadius(12)
                        }
                        .disabled(monthlyInvestment.isEmpty || investmentPeriod.isEmpty)
                        
                        // Results Section
                        if showingResults && !monthlyInvestment.isEmpty && !investmentPeriod.isEmpty {
                            VStack(spacing: 16) {
                                Text("DCA Results")
                                    .font(.headline)
                                    .foregroundColor(.yellow)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                VStack(spacing: 12) {
                                    ResultRow(
                                        title: "Total Invested",
                                        value: dcaCalculation.totalInvested,
                                        isCurrency: true,
                                        isPositive: true
                                    )
                                    
                                    ResultRow(
                                        title: "Total Value",
                                        value: dcaCalculation.totalValue,
                                        isCurrency: true,
                                        isPositive: true
                                    )
                                    
                                    ResultRow(
                                        title: "Total Profit",
                                        value: dcaCalculation.totalProfit,
                                        isCurrency: true,
                                        isPositive: dcaCalculation.totalProfit >= 0
                                    )
                                    
                                    ResultRow(
                                        title: "ROI",
                                        value: dcaCalculation.roi,
                                        isCurrency: false,
                                        isPositive: dcaCalculation.roi >= 0,
                                        suffix: "%"
                                    )
                                    
                                    ResultRow(
                                        title: "Average Cost",
                                        value: dcaCalculation.averageCost,
                                        isCurrency: true,
                                        isPositive: true
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
                        
                        // Info Section
                        VStack(spacing: 12) {
                            Text("About DCA")
                                .font(.headline)
                                .foregroundColor(.yellow)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                InfoRow(
                                    icon: "chart.line.uptrend.xyaxis",
                                    title: "Reduces Volatility",
                                    description: "Buying regularly smooths out price fluctuations"
                                )
                                
                                InfoRow(
                                    icon: "dollarsign.circle",
                                    title: "Disciplined Investing",
                                    description: "Automates your investment strategy"
                                )
                                
                                InfoRow(
                                    icon: "clock",
                                    title: "Time in Market",
                                    description: "Focuses on long-term growth over timing"
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
                        
                        Spacer(minLength: 50)
                    }
                    .padding()
                }
            }
            .navigationTitle("DCA Calculator")
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

struct InfoRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.yellow)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.yellow)
                
                Text(description)
                    .font(.system(size: 12))
                    .foregroundColor(.yellow.opacity(0.7))
            }
            
            Spacer()
        }
    }
}

struct DCACalculation {
    let monthlyInvestment: Double
    let investmentPeriod: Double
    let periodType: String
    let expectedReturn: Double
    
    var totalMonths: Double {
        switch periodType {
        case "years":
            return investmentPeriod * 12
        default:
            return investmentPeriod
        }
    }
    
    var totalInvested: Double {
        return monthlyInvestment * totalMonths
    }
    
    var totalValue: Double {
        guard totalMonths > 0 else { return totalInvested }
        
        let monthlyRate = expectedReturn / 100 / 12
        let futureValue = monthlyInvestment * ((pow(1 + monthlyRate, totalMonths) - 1) / monthlyRate)
        
        return futureValue
    }
    
    var totalProfit: Double {
        return totalValue - totalInvested
    }
    
    var roi: Double {
        guard totalInvested > 0 else { return 0 }
        return (totalProfit / totalInvested) * 100
    }
    
    var averageCost: Double {
        guard totalMonths > 0 else { return monthlyInvestment }
        return totalInvested / totalMonths
    }
}

#Preview {
    DCACalculatorView()
} 