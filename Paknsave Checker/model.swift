//
//  model.swift
//  Paknsave Checker
//
//  Created by Charles on 6/04/20.
//  Copyright © 2020 SKY. All rights reserved.
//

import Foundation

struct model: Codable {
    var slots: [slot]

    struct slot: Codable {
        var timeSlots: [timeSlot]
    }

    struct timeSlot: Codable {
        var available: Int
    }

}
