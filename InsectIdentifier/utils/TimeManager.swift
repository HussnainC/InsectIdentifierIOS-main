//
//  TimeManager.swift
//  InsectIdentifier
//
//  Created by Hussnain on 04/04/2025.
//


import Foundation

class TimeManager {
    
    static let shared = TimeManager()
    
    private let lastExecutionDateKey = "lastExecutionDate"
    
   
    private func getLastExecutionDate() -> Date? {
        return UserDefaults.standard.object(forKey: lastExecutionDateKey) as? Date
    }
    
     func setLastExecutionDate() {
        UserDefaults.standard.set(Date(), forKey: lastExecutionDateKey)
    }
    
    
    func isNewDay() -> Bool {
        guard let lastExecutionDate = getLastExecutionDate() else {
            return true
        }
        let calendar = Calendar.current
        let lastDay = calendar.startOfDay(for: lastExecutionDate)
        let currentDay = calendar.startOfDay(for: Date())
        return !calendar.isDate(lastDay, inSameDayAs: currentDay)
    }
    
  
}
