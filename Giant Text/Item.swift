//
//  Item.swift
//  Giant Text
//
//  Created by Nathan Fennel on 7/27/25.
//

import Foundation
import SwiftData

@Model
final class TextDocument {
    var text: String
    var richTextData: Data?
    var lastModified: Date
    
    init(text: String = "GIANT TEXT") {
        self.text = text
        self.richTextData = nil
        self.lastModified = Date()
    }
}
