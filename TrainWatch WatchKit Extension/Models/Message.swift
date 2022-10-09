//
//  Message.swift
//  TrainWatch WatchKit Extension
//
//  Created by Manuel on 07.01.22.
//

import Foundation

struct Message: Codable, Hashable {
    
    var code: Int
    var message: String
    var createdAt: String
    
}
