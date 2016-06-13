

import Foundation
import HealthKit

class HealthManager {
    let healthKitStore: HKHealthStore = HKHealthStore()
    
    func authorizeHealthKit(completion: ((success:Bool, error:NSError!) -> Void)!)
    {
        let healthKitTypesToWrite = Set([
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierActiveEnergyBurned),
            HKQuantityType.workoutType()
            ])
        
        if !HKHealthStore.isHealthDataAvailable()
        {
            let error = NSError(domain: "com.sports.concierge", code: 2, userInfo: [NSLocalizedDescriptionKey:"HealthKit is not available in this Device"])
            if( completion != nil )
            {
                completion(success:false, error:error)
            }
            return;
        }
        
        healthKitStore.requestAuthorizationToShareTypes(healthKitTypesToWrite, readTypes: nil) { (success, error) -> Void in
            
            if( completion != nil )
            {
                completion(success:success,error:error)
            }
        }
    }
    
    func saveRunningWorkout(startDate:NSDate , endDate:NSDate, workoutType: Int, kiloCalories:Double,
        completion: ( (Bool, NSError!) -> Void)!) {
            let caloriesQuantity = HKQuantity(unit: HKUnit.kilocalorieUnit(), doubleValue: kiloCalories)
            let typeOfWorkout = getTypeOfWorkoutFromIndex(workoutType)
            let caloriesSample = HKQuantitySample(type: HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierActiveEnergyBurned), quantity: caloriesQuantity, startDate: startDate, endDate: endDate)
            
            let workout = HKWorkout(activityType: typeOfWorkout, startDate: startDate, endDate: endDate, duration: abs(endDate.timeIntervalSinceDate(startDate)), totalEnergyBurned: caloriesQuantity, totalDistance: nil, metadata: nil)
            healthKitStore.saveObject(workout, withCompletion: { (success, error) -> Void in
                if( error != nil  ) {
                    completion(success,error)
                }
                else {
                    self.healthKitStore.addSamples([caloriesSample], toWorkout: workout, completion: { (success, error ) -> Void in
                        completion(success, error)
                    })
                    
                }
            })
    }
    
    func getTypeOfWorkoutFromIndex(typeIndex: Int) -> HKWorkoutActivityType {
        switch(typeIndex) {
        case 0:
            return HKWorkoutActivityType.Tennis
        case 1:
            return HKWorkoutActivityType.TraditionalStrengthTraining
        case 2:
            return HKWorkoutActivityType.Cycling
        case 3:
            return HKWorkoutActivityType.Basketball
        case 4:
            return HKWorkoutActivityType.Soccer
        case 5:
            return HKWorkoutActivityType.Running
        default:
            return HKWorkoutActivityType.Running
            
        }
    }
}
