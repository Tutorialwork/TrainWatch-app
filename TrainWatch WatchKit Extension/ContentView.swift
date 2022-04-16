//
//  ContentView.swift
//  TrainWatch WatchKit Extension
//
//  Created by Manuel on 29.12.21.
//

import SwiftUI
import UserNotifications

struct ContentView: View {
    
    let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()

    @State var trains: [Train] = TrainStorageManager.loadTrainCache()
    @State var pushed: Bool = false
    @State var downloadFailed: Bool = false
    @State var isRetrying: Bool = false
    
    var body: some View {
        if (downloadFailed) {
            OfflinePage(isRetrying: $isRetrying) {
                fetchData()
            }
        }
        VStack {
            if trains.count != 0 {
                List {
                    ForEach(trains, id: \.trainId) { train in
                        NavigationLink {
                            TrainDetailPage(train: train)
                        } label: {
                            VStack {
                                HStack {
                                    Text(DateManager.formatDate(isoString: train.departure))
                                    Spacer()
                                    if train.tripStatus == TripStatus.PLANNED {
                                        if !TrainStorageManager.checkIfTripIsCanceld(toCheck: train) {
                                            if getDelayString(train: train) != "On time" {
                                                Text(getDelayString(train: train))
                                                    .bold()
                                            } else {
                                                Text("On time")
                                                    .bold()
                                            }
                                        } else {
                                            Text("Canceled")
                                                .foregroundColor(.red)
                                                .bold()
                                        }
                                    }
                                }
                                if train.tripStatus == TripStatus.PLANNED {
                                    Text("\(TrainStorageManager.formatTrainNumber(train: train)) to \(train.stations.last ?? "End")")
                                        .lineLimit(1)
                                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                                } else {
                                    Text("Today not scheduled")
                                        .bold()
                                        .lineLimit(1)
                                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                                }
                            }
                        }
                    }
                    .onDelete(perform: deleteTrain)
                }
            } else {
                ScrollView {
                    Text("Hello 👋 \nStart tracking your trains by adding your first to your watchlist.")
                        .fixedSize(horizontal: false, vertical: true)
                    NavigationLink(destination: SearchTrainPage(pushed: $pushed), isActive: $pushed, label: {
                        Image(systemName: "plus.circle.fill")
                        Text("Add first train")
                    })
                }
            }
        }
        .onAppear(perform: {
            fetchData()
        })
        .onReceive(timer, perform: { _ in
            fetchData()
        })
        .navigationTitle("Watchlist")
        .toolbar {
            if trains.count != 0 {
                NavigationLink(destination: SearchTrainPage(pushed: $pushed), isActive: $pushed, label: {
                    Image(systemName: "plus.circle.fill")
                    Text("Add train")
                })
                .padding(.vertical)
            }
        }
    }
    
    func fetchData() -> Void {
        let trainRequestData: [TrainData] = TrainStorageManager.loadTrains()
        
        TrainStorageManager.loadCurrentTrainData(toRequestTrains: trainRequestData) { trainList in
            if var trainList = trainList {
                trainRequestData.forEach { requestedTrain in
                    let isTrainFound: Bool = trainList.contains { train in
                        return train.trainNumber == requestedTrain.trainNumber
                    }
                    /** Add train listing with not scheduled status to inform the user that maybe the timetable has been changed. */
                    if (!isTrainFound) {
                        let departure: Date = DateManager.generateDateFromHourAndMinute(hour: requestedTrain.hour, minute: requestedTrain.minute) ?? Date()
                        let isoDepartureString: String = DateManager.toIso8601DateString(date: departure)
                        
                        trainList.append(Train(trainId: "", trainType: "", trainNumber: requestedTrain.trainNumber, departure: isoDepartureString, platform: "", stations: [], tripStatus: TripStatus.NOT_SCHEDULED))
                    }
                }
                                
                downloadFailed = false
                self.trains = trainList
                self.trains = self.trains.sorted { $0.departure < $1.departure }
                TrainStorageManager.saveTrainCache(toCache: self.trains)
            } else {
                downloadFailed = true
                isRetrying = false
            }
        }
    }
    
    func deleteTrain(at offsets: IndexSet) {
        var trainDataList: [TrainData] = TrainStorageManager.loadTrains()
                
        var index: Int = 0
        trainDataList.forEach { trainData in
            trainDataList[index].secondsSinceMidnight = (trainData.hour * 3600) + (trainData.minute * 60)
            index += 1
        }
        trainDataList = trainDataList.sorted(by: { $0.secondsSinceMidnight < $1.secondsSinceMidnight })
        trainDataList.remove(atOffsets: offsets)
        
        TrainStorageManager.saveTrains(toSave: trainDataList)
        fetchData()
    }
    
    func getDelayString(train: Train) -> String {
        return DateManager.calulateDelay(
            plannedDeparture: DateManager.parseDate(isoString: train.departure),
            actualDeparture: DateManager.parseDate(isoString: train.changedDeparture ?? train.departure)
        )
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
