//
//  HealthManager.swift
//  Grace
//
//  Created by Эвелина Пенькова on 13.02.2024.
//

import Foundation
import HealthKit



class HealthManager: ObservableObject {
    var caloriesToday: Int = 0
    var stepsToday: Int = 0
    static let shared = HealthManager()
    
    init () {
        requestAuthorization()
    }
    
    var healthStore = HKHealthStore()
    
    func requestAuthorization() {
        let dataToRead = Set([
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!
        ])
        
        guard  HKHealthStore.isHealthDataAvailable() else {
            print("Health data is not Available")
            return
        }
        healthStore.requestAuthorization(toShare: nil, read: dataToRead) { success, failure in
            if success {
                self.fetchAllData()
            } else {
               print("error getting authorization")
            }
        }
    }
    
    func fetchAllData() {
        guard let stepCount = HKQuantityType.quantityType(forIdentifier: .stepCount),
        let calorieCount = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else { return }
        
        let now = Date()
        let startDate = Calendar.current.startOfDay(for: now)
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: now, options: .strictStartDate)
        
        let stepsQuery = HKStatisticsQuery(quantityType: stepCount, quantitySamplePredicate: predicate) { _, result, error in
            guard let result = result, let sum = result.sumQuantity() else {
                print("Fail to fetch users stepr with err: \(error?.localizedDescription ?? " ")")
                return
            }
            
            let steps = Int(sum.doubleValue(for: HKUnit.count()))
            
            self.stepsToday = steps
            
            print("\(self.stepsToday)")
        }
        
        let calorieQuery = HKStatisticsQuery(quantityType: calorieCount, quantitySamplePredicate: predicate) { _, result, error in
                guard let result = result, let sum = result.sumQuantity() else {
                    print("Failed to fetch user's calories with error: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                let calories = Int(sum.doubleValue(for: HKUnit.kilocalorie()))
                
            self.caloriesToday = calories
                print("Calories today: \(calories)")
            }
        
        healthStore.execute(stepsQuery)
        healthStore.execute(calorieQuery)
    }
    
}


