//
//  Astro.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/7/13.
//

import Foundation

struct Astro: Codable {
    
    let riseTime: TimeInterval?
    let setTime: TimeInterval?
    
    init(riseTime: TimeInterval?, setTime: TimeInterval?) {
        self.riseTime = riseTime
        self.setTime = setTime
    }
    
    func isValid() -> Bool {
        return riseTime != nil && setTime != nil
    }
    
    func formateRiseTime(twelveHour: Bool) -> String {
        if let time = riseTime {
            return formateTime(timeIntervalSine1970: time, twelveHour: twelveHour)
        } else {
            return ""
        }
    }
    
    func formateSetTime(twelveHour: Bool) -> String {
        if let time = setTime {
            return formateTime(timeIntervalSine1970: time, twelveHour: twelveHour)
        } else {
            return ""
        }
    }
}
