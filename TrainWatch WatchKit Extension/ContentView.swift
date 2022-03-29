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

    @State var trains: [Train] = []
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
                                Text("\(TrainStorageManager.formatTrainNumber(train: train)) to \(train.stations.last ?? "End")")
                                    .lineLimit(1)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
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
        TrainStorageManager.loadCurrentTrainData(toRequestTrains: TrainStorageManager.loadTrains()) { trainList in
            if let trainList = trainList {
                downloadFailed = false
                self.trains = trainList
                self.trains = self.trains.sorted { $0.departure < $1.departure }
            } else {
                downloadFailed = true
                isRetrying = false
            }
        }
    }
    
    func deleteTrain(at offsets: IndexSet) {
        var trainDataList: [TrainData] = TrainStorageManager.loadTrains()
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
