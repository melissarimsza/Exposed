//
//  FilmRoll.swift
//  Exposed
//
//  Created by Melissa Rimsza on 10/27/22.
//

import Foundation
import UIKit

class FilmRoll: Codable {
    var title: String
    //delete if issues
    //var availableDate: String
    
    var available: Bool = false
    
    var takenDate: String
    
    var photos: [URL] = []
    
    var names: [String] = []
    
    var size: Int {
         return photos.count
    }
    
    init(title: String, takenDate: String) {
        self.title = title
        self.takenDate = takenDate
    }
}
