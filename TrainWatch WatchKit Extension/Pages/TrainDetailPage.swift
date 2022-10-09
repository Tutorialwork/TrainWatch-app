//
//  TrainDetailPage.swift
//  TrainWatch WatchKit Extension
//
//  Created by Manuel on 04.01.22.
//

import SwiftUI

struct TrainDetailPage: View {
    
    @State var train: Train
    
    var body: some View {
        ScrollView {
            VStack {
                Text("Depature")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
                if train.tripStatus != TripStatus.CANCELED {
                    HStack {
                        Text(DateManager.formatDate(isoString: train.departure))
                        Spacer()
                        if train.tripStatus == TripStatus.PLANNED {
                            if getDelayString(train: train) != "On time" {
                                Text(getDelayString(train: train))
                                    .bold()
                            } else {
                                Text("On time")
                                    .bold()
                            }
                        }
                    }
                } else {
                    Text("Journey has been canceled")
                        .foregroundColor(.red)
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            if train.tripStatus != TripStatus.NOT_SCHEDULED {
                VStack {
                    Text("Platform")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    if train.changedPlatform != nil {
                        HStack {
                            Text(train.platform)
                                .strikethrough()
                            Text(train.changedPlatform ?? "?")
                                .foregroundColor(.red)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    } else {
                        Text(train.platform)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                VStack {
                    Text("Destination")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("\(TrainStorageManager.formatTrainNumber(train: train)) to \(train.stations.last ?? "End")")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                if let messages = train.messages {
                    if messages.count > 0 {
                        VStack {
                            Text("Messages")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            ForEach(messages, id: \.self) { message in
                                Text("• " + message.message)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            } else {
                Spacer()
                Text("Information")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("This train is today not scheduled. If this occurs longer the timetable may has been changed.")
            }
        }
    }
    
    func getDelayString(train: Train) -> String {
        return DateManager.calulateDelay(
            plannedDeparture: DateManager.parseDate(isoString: train.departure),
            actualDeparture: DateManager.parseDate(isoString: train.changedDeparture ?? train.departure)
        )
    }
    
}

//struct TrainDetailPage_Previews: PreviewProvider {
//    static var previews: some View {
//        TrainDetailPage()
//    }
//}
