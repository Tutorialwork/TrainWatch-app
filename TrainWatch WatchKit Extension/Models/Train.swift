//
//  Train.swift
//  TrainWatch WatchKit Extension
//
//  Created by Manuel on 03.01.22.
//

import Foundation

/**
 Model that is used to save all information about trains (platform, depature delays and more...)
 */
struct Train: Codable {
    
    var trainId: String
    var trainType: String
    var trainNumber: String
    var trainLine: String?
    var departure: String
    var changedDeparture: String?
    var platform: String
    var changedPlatform: String?
    var stations: [String]
    var changedStations: [String]?
    var tripType: String? // because international trains like the ECE don't have this attribute
    var tripStatus: String
    var messages: [Message]?
    
}
