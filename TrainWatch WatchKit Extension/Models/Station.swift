//
//  Station.swift
//  TrainWatch WatchKit Extension
//
//  Created by Manuel on 29.12.21.
//

import Foundation

/**
 Model for stations
 */
struct Station: Codable {
    
    var EVA_NR: Int
    var DS100: String
    var IFOPT: String
    var NAME: String
    var Verkehr: String
    var Laenge: String
    var Breite: String
    var Betreiber_Name: String
    var Betreiber_Nr: Int
    var Status: String
    
}
