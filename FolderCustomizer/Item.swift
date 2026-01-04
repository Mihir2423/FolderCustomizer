//
//  Item.swift
//  FolderCustomizer
//
//  Created by Mihir Aman Raj on 04/01/26.
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
