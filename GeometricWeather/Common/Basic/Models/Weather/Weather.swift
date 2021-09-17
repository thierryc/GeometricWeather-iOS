//
//  Weather.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/7/12.
//

import Foundation

struct Weather: Codable, Equatable {
    
    let base: Base
    let current: Current
    
    let yesterday: History?
    
    let dailyForecasts: Array<Daily>
    let hourlyForecasts: Array<Hourly>
    let alerts: Array<Alert>
    
    init(
        base: Base,
        current: Current,
        yesterday: History?,
        dailyForecasts: Array<Daily>,
        hourlyForecasts: Array<Hourly>,
        alerts: Array<Alert>
    ) {
        self.base = base
        self.current = current
        self.yesterday = yesterday
        self.dailyForecasts = dailyForecasts
        self.hourlyForecasts = hourlyForecasts
        self.alerts = alerts
    }
    
    static func == (left: Weather, right: Weather) -> Bool {
        return left.base.timeStamp == right.base.timeStamp
    }
    
    func isValid(pollingIntervalHours: Double) -> Bool {
        let updateTime = base.updateTime
        let currentTime = Date().timeIntervalSince1970
    
        return currentTime >= updateTime
                && currentTime - updateTime < pollingIntervalHours * 60 * 60;
    }
    
    func isDaylight(timezone: TimeZone) -> Bool {
        if let riseTime = dailyForecasts[0].sun.riseTime,
           let setTime = dailyForecasts[0].sun.setTime {
            
            let timezoneDate = Date(
                timeIntervalSince1970: Date().timeIntervalSince1970 + Double(
                    timezone.secondsFromGMT() - TimeZone.current.secondsFromGMT()
                )
            )
            let timezoneHourMinutes = Calendar.current.component(
                .hour, from: timezoneDate
            ) * 60 + Calendar.current.component(
                .minute, from: timezoneDate
            )
            
            let sunriseDate = Date(timeIntervalSince1970: riseTime)
            let sunriseHourMinutes = Calendar.current.component(
                .hour, from: sunriseDate
            ) * 60 + Calendar.current.component(
                .minute, from: sunriseDate
            )
            
            let sunsetDate = Date(timeIntervalSince1970: setTime)
            let sunsetHourMinutes = Calendar.current.component(
                .hour, from: sunsetDate
            ) * 60 + Calendar.current.component(
                .minute, from: sunsetDate
            )
            
            return sunriseHourMinutes <= timezoneHourMinutes
                && timezoneHourMinutes < sunsetHourMinutes
        } else {
            let timezoneDate = Date(
                timeIntervalSince1970: Date().timeIntervalSince1970 + Double(
                    timezone.secondsFromGMT() - TimeZone.current.secondsFromGMT()
                )
            )
            let hour = Calendar.current.component(.hour, from: timezoneDate)
            return 6 <= hour && hour < 18;
        }
    }
}
