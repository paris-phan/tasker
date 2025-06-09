//
//  Item.swift
//  Tasker
//
//  Created by Paris Phan on 6/8/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
