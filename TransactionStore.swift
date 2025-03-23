//
//  TransactionStore.swift
//  BudgetCalculator
//
//  Created by Štěpán Šmétka on 23.03.2025.
//

import Foundation

class TransactionStore: ObservableObject {
    @Published var transactions: [Transaction] = []
    @Published var initialBudget: Double = 0
    
    private let saveKey = "transactions"
    private let budgetKey = "initialBudget"
    
    init() {
        loadData()
    }
    
    var currentBalance: Double {
        transactions.reduce(initialBudget) { balance, transaction in
            balance + (transaction.isAddition ? transaction.amount : -transaction.amount)
        }
    }
    
    func addTransaction(_ transaction: Transaction) {
        transactions.append(transaction)
        saveData()
    }
    
    func setInitialBudget(_ amount: Double) {
        initialBudget = amount
        saveData()
    }
    
    private func saveData() {
        if let encoded = try? JSONEncoder().encode(transactions) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
        UserDefaults.standard.set(initialBudget, forKey: budgetKey)
    }
    
    private func loadData() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([Transaction].self, from: data) {
            transactions = decoded
        }
        initialBudget = UserDefaults.standard.double(forKey: budgetKey)
    }
}
