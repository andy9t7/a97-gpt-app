//
//  Model.swift
//  ChatGPT
//
//  Created by Andy Huynh on 15/12/2022.
//

import Foundation
import FirebaseFirestoreSwift

struct Message: Codable, Hashable {
    var id = UUID()
    let sender: String
    let text: String
    
}

struct MessageLog: Codable {
    var id = UUID()
    @ServerTimestamp var created: Date?
    var messageLog: [Message]
}
