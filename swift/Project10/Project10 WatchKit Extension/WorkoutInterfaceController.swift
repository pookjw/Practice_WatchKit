//
//  WorkoutInterfaceController.swift
//  Project10 WatchKit Extension
//
//  Created by Jinwoo Kim on 1/28/21.
//

import WatchKit
import Foundation
import HealthKit

enum DisplayMode {
    case distance, energy, heartRate
}

class WorkoutInterfaceController: WKInterfaceController {
    @IBOutlet weak var quantityLabel: WKInterfaceLabel!
    @IBOutlet weak var unitLabel: WKInterfaceLabel!
    @IBOutlet weak var stopButton: WKInterfaceButton!
    @IBOutlet weak var resumeButton: WKInterfaceButton!
    @IBOutlet weak var endButton: WKInterfaceButton!
    
    var healthStore: HKHealthStore?
    var distanceType = HKQuantityTypeIdentifier.distanceCycling
    
    var workoutStartDate = Date()
    var workoutEndDate = Date()
    var activeDataQueries = [HKQuery]()
    
    var workoutSession: HKWorkoutSession?
    
    var displayMode = DisplayMode.distance
    var totalEnergyBurned = HKQuantity(unit: HKUnit.kilocalorie(), doubleValue: 0)
    var totalDistance = HKQuantity(unit: HKUnit.meter(), doubleValue: 0)
    var lastHeartRate = 0.0
    let countPerMinuteUnit = HKUnit(from: "count/min")
    var workoutIsActive = true
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        guard let activity = context as? HKWorkoutActivityType else { return }
        
        switch activity {
        case .cycling:
            distanceType = .distanceCycling
        case .running:
            distanceType = .distanceWalkingRunning
        case .swimming:
            distanceType = .distanceSwimming
        default:
            distanceType = .distanceWheelchair
        }
        
        // configure the values we want to write
        let sampleTypes: Set<HKSampleType> = [
            .workoutType(),
            HKSampleType.quantityType(forIdentifier: .heartRate)!,
            HKSampleType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKSampleType.quantityType(forIdentifier: .distanceCycling)!,
            HKSampleType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            HKSampleType.quantityType(forIdentifier: .distanceSwimming)!,
            HKSampleType.quantityType(forIdentifier: .distanceWheelchair)!
        ]
        
        // create our health store
        healthStore = HKHealthStore()
        
        // use it to request authorization for our types
        healthStore?.requestAuthorization(toShare: sampleTypes, read: sampleTypes) { succsess, error in
            if succsess {
                // start workout!
                self.startWorkout(type: activity)
            }
        }
    }
    
    func startQuery(quantityTypeIdentifier: HKQuantityTypeIdentifier) {
        // we only want data points after our workout start date
        let datePredicate = HKQuery.predicateForSamples(withStart: workoutStartDate, end: nil, options: .strictStartDate)
        
        // we only want data points that come from our current
        let devicePredicate = HKQuery.predicateForObjects(from: [HKDevice.local()])
        
        // combine the two predicates into one
        let queryPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [datePredicate, devicePredicate])
        
        // write code to receive results from our query
        let updateHandler: (HKAnchoredObjectQuery, [HKSample]?, [HKDeletedObject]?, HKQueryAnchor?, Error?) -> Void = { (query, samples, deletedObjects, queryAnchor, error) in
            // safely typecast to a quantity sample so we can read values
            guard let samples = samples as? [HKQuantitySample] else { return }
            
            // just print them out for now
//            print(samples)
            self.process(samples, type: quantityTypeIdentifier)
        }
        
        // create the query out of our type (e.g. heart rate), predicate, and result handling code
        let query = HKAnchoredObjectQuery(
            type: HKObjectType.quantityType(forIdentifier: quantityTypeIdentifier)!,
            predicate: queryPredicate,
            anchor: nil,
            limit: HKObjectQueryNoLimit,
            resultsHandler: updateHandler
        )
        
        // tell HealthKit to re-run the code every time new data is available
        query.updateHandler = updateHandler
        
        // start the query running
        healthStore?.execute(query)
        
        // stash it away so we can stop it later
        activeDataQueries.append(query)
    }
    
    func startQueries() {
        startQuery(quantityTypeIdentifier: distanceType)
        startQuery(quantityTypeIdentifier: .activeEnergyBurned)
        startQuery(quantityTypeIdentifier: .heartRate)
        WKInterfaceDevice.current().play(.start)
        
        if distanceType == .distanceSwimming {
            WKInterfaceDevice.current().enableWaterLock()
        }
    }
    
    func startWorkout(type: HKWorkoutActivityType) {
        guard let healthStore = healthStore else {
            return
        }
        
        // 1: create a workout configuration
        let config = HKWorkoutConfiguration()
        config.activityType = type
        config.locationType = .outdoor
        
        // 2: create a workout session from that
        if let session = try? HKWorkoutSession(healthStore: healthStore, configuration: config) {
            workoutSession = session
            
            // 3: start the workout now
            session.startActivity(with: Date())
            
            // 4: register receive status updates
            session.delegate = self
        }
    }
    
    func updateLabels() {
        switch displayMode {
        case .distance:
            let meters = totalDistance.doubleValue(for: HKUnit.meter())
            let kilometers = meters / 1000
            let formattedKilometers = String(format: "%.2f", kilometers)
            
            quantityLabel.setText(formattedKilometers)
            unitLabel.setText("KILOMETERS")
        case .energy:
            let kilocalories = totalEnergyBurned.doubleValue(for: HKUnit.kilocalorie())
            let formattedKilocalories = String(format: "%.0f", kilocalories)
            quantityLabel.setText(formattedKilocalories)
            unitLabel.setText("CALORIES")
        case .heartRate:
            let heartRate = String(Int(lastHeartRate))
            quantityLabel.setText(heartRate)
            unitLabel.setText("BEATS / MINUTE")
        }
    }
    
    func process(_ samples: [HKQuantitySample], type: HKQuantityTypeIdentifier) {
        // ignore updates while we are paused
        guard workoutIsActive else { return }
        
        // loop over all the samples we've been sent
        for sample in samples {
            // this is a calorie count
            if type == .activeEnergyBurned {
                // find out how many calories were burned
                let newEnergy = sample.quantity.doubleValue(for: HKUnit.kilocalorie())
                
                // get our current total calorie burn
                let currentEnergy = totalEnergyBurned.doubleValue(for: HKUnit.kilocalorie())
                
                // add the two together and store it
                totalEnergyBurned = HKQuantity(unit: HKUnit.kilocalorie(), doubleValue: currentEnergy + newEnergy)
                
                // print out the new total for debugging purposes
                print("Total energy: \(totalEnergyBurned)")
            } else if type == .heartRate {
                // we got a heart rate - just update the property
                lastHeartRate = sample.quantity.doubleValue(for: countPerMinuteUnit)
                print("Last heart rate: \(lastHeartRate)")
            } else if type == distanceType {
                // we got a distance traveled value
                let newDistance = sample.quantity.doubleValue(for: HKUnit.meter())
                let currentDistance = totalDistance.doubleValue(for: HKUnit.meter())
                totalDistance = HKQuantity(unit: HKUnit.meter(), doubleValue: currentDistance + newDistance)
                print("Total distance: \(totalDistance)")
            }
        }
        
        // update our user interface
        updateLabels()
    }
    
    func cleanUpQueries() {
        for query in activeDataQueries {
            healthStore?.stop(query)
        }
        
        activeDataQueries.removeAll()
    }
    
    func save(_ workoutSession: HKWorkoutSession) {
        let config = workoutSession.workoutConfiguration
        let workout = HKWorkout(
            activityType: config.activityType,
            start: workoutStartDate,
            end: workoutEndDate,
            workoutEvents: nil,
            totalEnergyBurned: totalEnergyBurned,
            totalDistance: totalDistance,
            metadata: [HKMetadataKeyIndoorWorkout: false]
        )
        
        healthStore?.save(workout) { (success, error) in
            if success {
                DispatchQueue.main.async {
                    WKInterfaceController.reloadRootPageControllers(
                        withNames: ["InterfaceController"],
                        contexts: nil,
                        orientation: .horizontal,
                        pageIndex: 0
                    )
                }
            }
        }
    }

    @IBAction func changeDisplayMode() {
        switch displayMode {
        case .distance:
            displayMode = .energy
        case .energy:
            displayMode = .heartRate
        case .heartRate:
            displayMode = .distance
        }
        
        updateLabels()
    }
    
    @IBAction func stopWorkout() {
        guard let workoutSession = workoutSession else { return }
        
        stopButton.setHidden(true)
        resumeButton.setHidden(false)
        endButton.setHidden(false)
        
        workoutSession.pause()
    }
    
    @IBAction func resumeWorkout() {
        guard let workoutSession = workoutSession else { return }
        
        stopButton.setHidden(false)
        resumeButton.setHidden(true)
        endButton.setHidden(true)
        
        workoutSession.resume()
    }
    
    @IBAction func endWorkout() {
        guard let workoutSession = workoutSession else { return }
        workoutEndDate = Date()
        
        workoutSession.end()
    }
}

extension WorkoutInterfaceController: HKWorkoutSessionDelegate {
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        switch toState {
        case .running:
            if fromState == .notStarted {
                startQueries()
            } else {
                workoutIsActive = true
            }
        case .paused:
            workoutIsActive = false
        case .ended:
            workoutIsActive = false
            cleanUpQueries()
            save(workoutSession)
        default:
            break
        }
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        
    }
}
