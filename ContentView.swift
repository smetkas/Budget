import SwiftUI
import AVFoundation

struct ContentView: View {
    @StateObject private var store = TransactionStore()
    @State private var showingInput = false
    @State private var amount = ""
    @State private var isAddition = true
    
    let numberPadButtons = [
        ["7", "8", "9"],
        ["4", "5", "6"],
        ["1", "2", "3"],
        ["0", "00", "."]
    ]
    
    func playSound() {
        AudioServicesPlaySystemSound(1104)
    }
    
    // Calculate days until next payday (11th of next month)
    func daysUntilPayday() -> Int {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.year, .month, .day], from: now)
        
        var nextPayday = DateComponents()
        nextPayday.year = components.year
        nextPayday.month = components.month
        nextPayday.day = 11
        
        var nextPaydayDate = calendar.date(from: nextPayday)!
        
        // If we're past the 11th, move to next month
        if components.day! > 11 {
            nextPaydayDate = calendar.date(byAdding: .month, value: 1, to: nextPaydayDate)!
        }
        
        let days = calendar.dateComponents([.day], from: now, to: nextPaydayDate).day!
        return days == 0 ? 1 : days // Avoid division by zero
    }
    
    // Calculate daily budget
    var dailyBudget: Double {
        let days = Double(daysUntilPayday())
        return store.currentBalance / days
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 40) {
                // Title and Daily Budget
                HStack {
                    Text("Budget")
                        .foregroundColor(.gray)
                    Spacer()
                    
                    // Daily budget display
                    VStack(alignment: .trailing) {
                        Text("\(Int(dailyBudget))/day")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.green)
                        Text("\(daysUntilPayday()) days left")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Main Balance Display
                Text("\(store.currentBalance, specifier: "%.0f")")
                    .font(.system(size: 80, weight: .medium))
                    .foregroundColor(store.currentBalance >= 0 ? .green : .green)
                    .monospacedDigit()
                Text("CZK")
                    .foregroundColor(.gray)
                    .font(.title3)
                
                Spacer()
                
                // Control Buttons
                HStack(spacing: 20) {
                    // Add Button
                    Button(action: {
                        playSound()
                        isAddition = true
                        showingInput = true
                    }) {
                        Text("+")
                            .font(.system(size: 60, weight: .medium))
                            .frame(width: 100, height: 100)
                            .background(Color(red: 0, green: 0.3, blue: 0))
                            .foregroundColor(.green)
                            .cornerRadius(50)
                            .offset(y: -5)
                    }
                    
                    // Subtract Button
                    Button(action: {
                        playSound()
                        isAddition = false
                        showingInput = true
                    }) {
                        Text("-")
                            .font(.system(size: 60, weight: .medium))
                            .frame(width: 100, height: 100)
                            .background(Color(red: 0.3, green: 0, blue: 0))
                            .foregroundColor(.red)
                            .cornerRadius(50)
                            .offset(y: -8)
                    }
                }
                .padding(.bottom, 50)
            }
            .padding()
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showingInput) {
            NavigationView {
                VStack(spacing: 20) {
                    // Display amount
                    Text(amount.isEmpty ? "0" : amount)
                        .font(.system(size: 50, weight: .medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding()
                    
                    // Number pad
                    VStack(spacing: 15) {
                        ForEach(numberPadButtons, id: \.self) { row in
                            HStack(spacing: 15) {
                                ForEach(row, id: \.self) { button in
                                    Button(action: {
                                        playSound()
                                        if button == "." && amount.contains(".") { return }
                                        amount += button
                                    }) {
                                        Text(button)
                                            .font(.title)
                                            .frame(maxWidth: .infinity)
                                            .frame(height: 70)
                                            .background(Color(.systemGray6))
                                            .foregroundColor(.white)
                                            .cornerRadius(15)
                                    }
                                }
                            }
                        }
                        
                        // Bottom row with clear and enter
                        HStack(spacing: 15) {
                            Button(action: {
                                playSound()
                                amount = String(amount.dropLast())
                            }) {
                                Image(systemName: "delete.left")
                                    .font(.title)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 70)
                                    .background(Color(.systemGray6))
                                    .foregroundColor(.white)
                                    .cornerRadius(15)
                            }
                            
                            Button(action: {
                                playSound()
                                if let amountValue = Double(amount) {
                                    let transaction = Transaction(
                                        amount: amountValue,
                                        isAddition: isAddition
                                    )
                                    store.addTransaction(transaction)
                                    amount = ""
                                    showingInput = false
                                }
                            }) {
                                Text("Enter")
                                    .font(.title)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 70)
                                    .background(isAddition ? Color.green : Color.red)
                                    .foregroundColor(.white)
                                    .cornerRadius(15)
                            }
                        }
                    }
                    .padding()
                }
                .navigationTitle(isAddition ? "Add Money" : "Subtract Money")
                .navigationBarItems(
                    leading: Button("Cancel") {
                        playSound()
                        showingInput = false
                        amount = ""
                    }
                )
            }
            .preferredColorScheme(.dark)
        }
    }
}

#Preview {
    ContentView()
}

