//
//  SearchTrainPage.swift
//  TrainWatch WatchKit Extension
//
//  Created by Manuel on 03.01.22.
//

import SwiftUI

struct SearchTrainPage: View {
        
    @Binding var pushed: Bool
    @State var showStationSearch = false
    @State var selectedStation: Station = Station(EVA_NR: 0, DS100: "", IFOPT: "", NAME: "", Verkehr: "", Laenge: "", Breite: "", Betreiber_Name: "", Betreiber_Nr: 0, Status: "")
    @State var currentHour: Int = 7
    @State var hoursOfDay: [String] = ["0:00", "1:00", "2:00", "3:00", "4:00", "5:00", "6:00", "7:00", "8:00", "9:00", "10:00", "11:00", "12:00", "13:00", "14:00", "15:00", "16:00", "17:00", "18:00", "19:00", "20:00", "21:00", "22:00", "23:00"]
    
    var body: some View {
        ScrollView {
            Text("Start station")
                .bold()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            if self.selectedStation.NAME.count != 0 {
                HStack {
                    if selectedStation.NAME.count > 0 {
                        Text(selectedStation.NAME)
                            .lineLimit(1)
                    }
                    Spacer()
                    Button {
                        showStationSearch = !showStationSearch
                    } label: {
                        Image(systemName: "pencil")
                    }
                    .frame(width: 50, height: 50, alignment: .center)
                }
            } else {
                Button {
                    showStationSearch = !showStationSearch
                } label: {
                    Image(systemName: "tram")
                    Text("Select station")
                }
            }
            Text("Hour of depature")
                .bold()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            HStack {
                Picker(selection: $currentHour) {
                    ForEach(0 ..< hoursOfDay.count) { index in
                        Text(self.hoursOfDay[index])
                    }
                } label: {
                    Text("Hour")
                }
                .frame(height: 50)
            }
            NavigationLink(destination: SelectTrainPage(
                pushed: $pushed,
                station: $selectedStation,
                hour: $currentHour
            ), label: {
                HStack {
                    Image(systemName: "magnifyingglass")
                    Text("Search")
                }
            })
            .disabled(self.selectedStation.NAME.count == 0)
        }
        .sheet(isPresented: $showStationSearch) {
            
        } content: {
            SelectStationPage { station in
                showStationSearch = false
                self.selectedStation = station
            }
        }
    }
}

//struct SearchTrainPage_Previews: PreviewProvider {
//    static var previews: some View {
//        SearchTrainPage()
//    }
//}
