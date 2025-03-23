//
//  Transaction.swift
//  BudgetCalculator
//
//  Created by Štěpán Šmétka on 23.03.2025.
//

import Foundation

struct Transaction: Identifiable, Codable {
    let id: UUID
    let amount: Double
    let isAddition: Bool
    
    init(id: UUID = UUID(), amount: Double, isAddition: Bool) {
        self.id = id
        self.amount = amount
        self.isAddition = isAddition
    }
}
