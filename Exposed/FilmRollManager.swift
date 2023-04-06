//
//  filmRollManager.swift
//  Exposed
//
//  Created by Melissa Rimsza on 11/9/22.
//
import Foundation
import UIKit

class FilmRollManager {
    
    var filmRollArray: [FilmRoll]
    
    static private var plistURL: URL {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documents.appendingPathComponent("FilmRollStorage.plist")
    }

    init() {
        filmRollArray = []
    }
    
    func load() {
        let decoder = PropertyListDecoder()
        
        //GETTING THE DATE
        let now = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd"
        let timestamp = formatter.string(from: now)

        do {
            //takes film rolls in plist and adds them all to filmRollArray
            let data = try Data.init(contentsOf: FilmRollManager.plistURL)
            //what if the decode fails from bad data - this is bad and its lurking - worry about this later
            filmRollArray = try decoder.decode([FilmRoll].self, from: data)
        } catch {
            print("entered catch")
            //if todays doesnt exist then make it
            filmRollArray.append(FilmRoll(title: timestamp, takenDate: timestamp))
        }
    }
    
    func workingRoll() -> FilmRoll {
        //GETTING THE DATE
        let now = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd"
        let date = formatter.string(from: now)
        
        //slightly more efficient way of checking if the roll exists
        if filmRollArray.last?.title == date {
            print("I found the roll for today")
            return filmRollArray.last!
        }
        
        //if it doesn't exits, make the new roll
        let newRoll = FilmRoll(title: date, takenDate: date)
        //adding the roll to the array
        filmRollArray.append(newRoll)
        
        print("making new roll")
        
        //returning the new roll
        return newRoll
    }
    
    func giveMeRoll(thisOne: Int) -> FilmRoll {
        return filmRollArray[thisOne]
    }

    //taking the data from filmRollArray and putting back into the plist
    func write() {
        let encoder = PropertyListEncoder()

        if let data = try? encoder.encode(filmRollArray) {
            try? data.write(to: FilmRollManager.plistURL)
        } else {
            print("there was a problem encoding the array")
        }
    }
}

