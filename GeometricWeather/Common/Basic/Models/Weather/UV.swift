//
//  File.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/7/13.
//

import Foundation

struct UV: Codable {
    
    let index: Int?
    let level: String?
    let description: String?

    static let uvIndexLevelLow = 2
    static let uvIndexLevelMiddle = 5
    static let uvIndexLevelHigh = 7
    static let uvIndexLevelExcessive = 10
    
    init(index: Int?, level: String?, description: String?) {
        self.index = index
        self.level = level
        self.description = description
    }
    
    func isValid() -> Bool {
        return index != nil || level != nil || description != nil
    }
    
    func getUVDescription() -> String {
        var str = ""
        
        if (index != nil) {
            str += "\(index!)"
        }
        if (level != nil && level != "") {
            str += " \(level!)"
        }
        if (description != nil && description != "") {
            str += " \(description!)"
        }
        
        return str
    }

    func getShortUVDescription() -> String {
        var str = ""
        
        if (index != nil) {
            str += "\(index!)"
        }
        if (level != nil && level != "") {
            str += " \(level!)"
        }
        
        return str
    }

    func getUVLevel() -> Int {
        if (index == nil) {
            return 1
        } else if (index! <= Self.uvIndexLevelLow) {
            return 1
        } else if (index! <= Self.uvIndexLevelMiddle) {
            return 2
        } else if (index! <= Self.uvIndexLevelHigh) {
            return 3
        } else if (index! <= Self.uvIndexLevelExcessive) {
            return 4
        } else {
            return 5
        }
    }
}
