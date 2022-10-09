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
    
    static func loadTrainCache() -> [Train] {
        let json = UserDefaults.standard.data(forKey: "trainCache")
        let decoder = JSONDecoder()
        
        if let data = json {
            do {
                let trains: [Train] = try decoder.decode([Train].self, from: data)
                                
                return trains
            } catch {
                print("Error while loading train cache")
            }
        }
        
        return []
    }
    
    static func saveTrainCache(toCache: [Train]) -> Void {
        let encoder = JSONEncoder()
        
        do {
            let data = try encoder.encode(toCache)
            
            UserDefaults.standard.set(data, forKey: "trainCache")
        } catch {
            print("Error while save train cache")
        }
    }
    
    static func formatTrainNumber(train: Train) -> String {
        return train.trainType + (train.trainLine ?? String(train.trainNumber))
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
}
