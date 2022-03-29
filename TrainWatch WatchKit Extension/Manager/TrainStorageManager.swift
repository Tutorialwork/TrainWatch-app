//
//  TrainStorageManager.swift
//  TrainWatch WatchKit Extension
//
//  Created by Manuel on 04.01.22.
//

import Foundation

class TrainStorageManager {
    
    static func addTrain(toAdd: TrainData) -> Void {
        var trainList: [TrainData] = self.loadTrains()
        
        trainList.append(toAdd)
        
        self.saveTrains(toSave: trainList)
    }
    
    static func existsTrain(toCheck: TrainData) -> Bool {
        var foundTrain: Bool = false
        
        loadTrains().forEach { train in
            if train.hour == toCheck.hour && train.minute == toCheck.minute && train.stationId == toCheck.stationId && train.trainNumber == toCheck.trainNumber {
                foundTrain = true
            }
        }
        
        return foundTrain
    }
    
    static func loadTrains() -> [TrainData] {
        let json = UserDefaults.standard.data(forKey: "trains")
        let decoder = JSONDecoder()
        
        if let data = json {
            do {
                let trains: [TrainData] = try decoder.decode([TrainData].self, from: data)
                
                return trains
            } catch {
                print("Error while loading train list")
            }
        }
        
        return []
    }
    
    static func saveTrains(toSave: [TrainData]) -> Void {
        let encoder = JSONEncoder()
        
        do {
            let data = try encoder.encode(toSave)
            
            UserDefaults.standard.set(data, forKey: "trains")
        } catch {
            print("Error while save train list")
        }
    }
    
    static func formatTrainNumber(train: Train) -> String {
        return train.trainType + (train.trainLine ?? train.trainNumber)
    }
    
    static func loadCurrentTrainData(toRequestTrains: [TrainData], onFinish: @escaping ((_ trainList: [Train]?) -> Void)) -> Void {
        guard let url = URL(string: "https://api-trainwatch.manuelschuler.dev/trains") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        var requestTrainDataList: [TrainData] = []
        
        toRequestTrains.forEach { train in
            requestTrainDataList.append(TrainData(stationId: train.stationId, hour: train.hour, minute: train.minute, trainNumber: train.trainNumber))
        }
        
        let data = try! encoder.encode(requestTrainDataList)
        
        request.httpBody = data
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            var trains: [Train]? = []
            
            if let responseData = data {
                trains = try! JSONDecoder().decode([Train].self, from: responseData)
            } else {
                trains = nil
            }
            
            onFinish(trains)
        }
        task.resume()
    }
    
    /**
     When a train is canceld the changed station parameter is set with the following content: [""]
     */
    static func checkIfTripIsCanceld(toCheck: Train) -> Bool {
        if let newStations = toCheck.changedStations {
            if newStations.count == 1 && newStations[0].count == 0 {
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    }
    
}
