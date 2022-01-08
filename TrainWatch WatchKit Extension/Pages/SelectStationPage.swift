//
//  SetHomeStationPage.swift
//  TrainWatch WatchKit Extension
//
//  Created by Manuel on 29.12.21.
//

import SwiftUI

struct SelectStationPage: View {
    
    @State var stationSearchQuery: String = ""
    @State var searchResults: [Station] = []
    @State var recentStations: [Station] = []
    let onSelect: (Station) -> ()

    var body: some View {
        VStack {
            if searchResults.count == 0 && recentStations.count == 0 {
                VStack {
                    Image(systemName: "magnifyingglass")
                        .resizable()
                        .frame(width: 32, height: 32, alignment: .center)
                    Text("Search")
                        .font(.title3)
                    Text("Please type below your start station and select it.")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.center)
                }
                .padding()
            }
            TextField("Station", text: $stationSearchQuery)
                .onSubmit {
                    self.searchResults = []
                    loadStations().forEach { station in
                        if station.NAME.lowercased().contains(stationSearchQuery.lowercased()) {
                            searchResults.append(station)
                        }
                    }
                }
            if searchResults.count != 0 {
                List {
                    ForEach(searchResults, id: \.EVA_NR) { result in
                        Button(result.NAME) {
                            selectStation(toSelectStation: result)
                        }
                    }
                }
            } else if recentStations.count > 0 {
                HStack {
                    Text("Recently used")
                        .bold()
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                    Spacer()
                    Button {
                        self.recentStations = []
                        
                        saveRecentStations(toSave: recentStations)
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                    }
                    .frame(width: 50, height: 50, alignment: .center)
                }
                List {
                    ForEach(recentStations, id: \.EVA_NR) { result in
                        Button(result.NAME) {
                            selectStation(toSelectStation: result)
                        }
                    }
                }
            }
        }
        .onAppear {
            recentStations = loadRecentStations()
        }
    }
    
    func selectStation(toSelectStation: Station) -> Void {
        var found: Bool = false
        
        recentStations.forEach { station in
            if station.EVA_NR == toSelectStation.EVA_NR {
                found = true
            }
        }
        
        if !found {
            recentStations.append(toSelectStation)
            saveRecentStations(toSave: recentStations)
        }
        
        onSelect(toSelectStation)
    }
    
    func loadStations() -> [Station] {
        if let url = Bundle.main.url(forResource: "TrainStationsList", withExtension: "json") {
               do {
                   let data = try Data(contentsOf: url)
                   let decoder = JSONDecoder()
                   let jsonData = try decoder.decode([Station].self, from: data)
                   return jsonData
               } catch {
                   print("error:\(error)")
               }
           }
           return []
    }
    
    func loadRecentStations() -> [Station] {
        let json = UserDefaults.standard.data(forKey: "recentStationSearch")
        let decoder = JSONDecoder()
        
        if let data = json {
            do {
                let stations: [Station] = try decoder.decode([Station].self, from: data)
                
                return stations
            } catch {
                print("Error while load recent stations")
            }
        }
        
        return []
    }
    
    func saveRecentStations(toSave: [Station]) -> Void {
        let encoder = JSONEncoder()
        
        do {
            let data = try encoder.encode(toSave)
            
            UserDefaults.standard.set(data, forKey: "recentStationSearch")
        } catch {
            print("Error while saving recent sations")
        }
    }
    
    
}

struct SetHomeStationPage_Previews: PreviewProvider {
    static var previews: some View {
        SelectStationPage { station in
            print("Selected station number is " + station.NAME)
        }
    }
}
