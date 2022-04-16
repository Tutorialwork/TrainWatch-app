//
//  Train.swift
//  TrainWatch WatchKit Extension
//
//  Created by Manuel on 02.01.22.
//

import Foundation

/**
 Model that is used to save trains
 */
struct TrainData: Codable {
    
    var stationId: Int
    var hour: Int
    var minute: Int
    var trainNumber: String
    var secondsSinceMidnight: Int = 0
    
}
