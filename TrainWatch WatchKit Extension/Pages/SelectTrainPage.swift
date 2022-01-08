//
//  SelectTrainPage.swift
//  TrainWatch WatchKit Extension
//
//  Created by Manuel on 03.01.22.
//

import SwiftUI

struct SelectTrainPage: View {
    
    @Binding var pushed: Bool
    @Binding var station: Station
    @Binding var hour: Int
    @State var trains: [Train] = []
    @State var isNoTrainFound = false
    @State var isDuplicate = false
    @State var onlyLongDistanceTraffic = false
    
    var body: some View {
        VStack {
            if isNoTrainFound {
                Text("Sorry, no train has been found.")
            } else if !isNoTrainFound && trains.count == 0 {
                ProgressView()
            } else {
                if hasLongDistanceTraffice(trains: trains) {
                    Toggle("Only long-distance traffic", isOn: $onlyLongDistanceTraffic)
                }
                List {
                    ForEach(trains, id: \.trainId) { train in
                        if onlyLongDistanceTraffic {
                            if train.tripType == "F" {
                                Button("\(DateManager.formatDate(isoString: train.departure)) to \(train.stations.last ?? "?")") {
                                    let hour = Calendar.current.component(.hour, from: DateManager.parseDate(isoString: train.departure))
                                    let minute = Calendar.current.component(.minute, from: DateManager.parseDate(isoString: train.departure))

                                    let trainData: TrainData = TrainData(stationId: station.EVA_NR, hour: hour, minute: minute, trainNumber: train.trainNumber)

                                    print(trainData)

                                    if !TrainStorageManager.existsTrain(toCheck: trainData) {
                                        TrainStorageManager.addTrain(toAdd: trainData)
                                        self.pushed = false
                                    } else {
                                        self.isDuplicate = true
                                    }
                                }
                            }
                        } else {
                            Button("\(DateManager.formatDate(isoString: train.departure)) to \(train.stations.last ?? "?")") {
                                let hour = Calendar.current.component(.hour, from: DateManager.parseDate(isoString: train.departure))
                                let minute = Calendar.current.component(.minute, from: DateManager.parseDate(isoString: train.departure))

                                let trainData: TrainData = TrainData(stationId: station.EVA_NR, hour: hour, minute: minute, trainNumber: train.trainNumber)

                                print(trainData)

                                if !TrainStorageManager.existsTrain(toCheck: trainData) {
                                    TrainStorageManager.addTrain(toAdd: trainData)
                                    self.pushed = false
                                } else {
                                    self.isDuplicate = true
                                }
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            guard let url = URL(string: "https://api-trainwatch.manuelschuler.dev/timetable/" + String(self.station.EVA_NR) + "/" + String(self.hour)) else { return }
            
            URLSession.shared.dataTask(with: url) { data, _, _ in
                let trains = try! JSONDecoder().decode([Train].self, from: data!)
                
                self.trains = trains
                
                self.trains = self.trains.sorted { $0.departure < $1.departure }
                
                if self.trains.count == 0 {
                    isNoTrainFound = true
                }
            }.resume()
        }
        .alert(isPresented: $isDuplicate) {
            Alert(
                title: Text("This train is already on your list.")
            )
        }
    }
    
    func hasLongDistanceTraffice(trains: [Train]) -> Bool {
        var status: Bool = false
        
        trains.forEach { train in
            if train.tripType == "F" {
                status = true
            }
        }
        
        return status
    }
    
}

//struct SelectTrainPage_Previews: PreviewProvider {
//    static var previews: some View {
//        SelectTrainPage()
//    }
//}
