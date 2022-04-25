//
//  Display.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/7/15.
//

import Foundation
import UIKit

// MARK: - constants.

public let maxPhoneAdaptiveWidth = 480.0
public let maxTabletAdaptiveWidth = 512.0

// MARK: - theme.

public func isDaylight() -> Bool {
    let hour = Calendar.current.component(.hour, from: Date())
    return 6 <= hour && hour < 18;
}

public func isDaylight(location: Location) -> Bool {
    return location.daylight
}

// MARK: - time.

public func formateTime(
    timeIntervalSine1970: TimeInterval,
    twelveHour: Bool,
    timezone: TimeZone = TimeZone.current
) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = twelveHour ? "h:mm aa" : "HH:mm"
    
    return formatter.string(
        from: Date(
            timeIntervalSince1970: timeIntervalSine1970 + Double(
                timezone.secondsFromGMT() - TimeZone.current.secondsFromGMT()
            )
        )
    )
}

public func isTwelveHour() -> Bool {
    if let formatter = DateFormatter.dateFormat(
        fromTemplate: "j",
        options: 0,
        locale: NSLocale.current
    ) {
        return formatter.contains("a")
    } else {
        return false
    }
}

// MARK: - tablet compat.

public func getUIOrientation() -> UIInterfaceOrientation {
    return UIApplication.shared
        .windows
        .first?
        .windowScene?
        .interfaceOrientation ?? .unknown
}

public func isTablet() -> Bool {
    return UIDevice.current.userInterfaceIdiom != UIUserInterfaceIdiom.phone
}

public func isLandscape() -> Bool {
    return UIApplication
        .shared
        .windows
        .first?
        .windowScene?
        .interfaceOrientation
        .isLandscape ?? false
}

public func getTabletAdaptiveWidth(maxWidth: Double) -> Double {
    if (!isTablet() && !isLandscape()) {
        return maxWidth
    }

    return getTabletAdaptiveWidth()
}

public func getTabletAdaptiveWidth() -> Double {
    return isTablet()
        ? maxTabletAdaptiveWidth
        : maxPhoneAdaptiveWidth
}

public func getTrendItemWidth(totalWidth: Double, margin: Double) -> Double {
    return (
        getTabletAdaptiveWidth(maxWidth: totalWidth) - 2 * margin
    ) / Double(
        getTrenItemDisplayCount()
    )
}

public func getTrenItemDisplayCount() -> Int {
    return isTablet() || isLandscape() ? 8 : 6
}

// MARK: - text.

public func getLocalizedText(_ key: String) -> String {
    let defaultValue = NSLocalizedString(
        key,
        tableName: "Default",
        bundle: .module,
        value: "",
        comment: ""
    )
    
    return NSLocalizedString(
        key,
        tableName: nil,
        bundle: .module,
        value: defaultValue,
        comment: ""
    )
}

public func getLocationText(location: Location) -> String {
    if !location.district.isEmpty {
        return location.district
    }
    if !location.city.isEmpty {
        return location.city
    }
    if !location.province.isEmpty {
        return location.province
    }
    if location.currentPosition {
        return getLocalizedText("current_location")
    }
    return ""
}

public func getWeekText(week: Int) -> String {
    return getLocalizedText("week_\(week)")
}

public func getHourText(hour: Int) -> String {
    return "\(hour)\(getLocalizedText("of_clock"))"
}

public func getAirQualityText(level: Int) -> String {
    if level < 1 || 6 < level {
        return ""
    }
    
    return getLocalizedText("aqi_\(level)")
}

public func getWindLevelText(level: Int) -> String {
    if level < 0 || 12 < level {
        return ""
    }
    
    return getLocalizedText("wind_\(level)")
}

public func getShortWindText(wind: Wind) -> String {
    var text = ""
    
    if let direction = wind.direction {
        text += direction + " "
    }
    
    return text + getWindLevelText(level: wind.level)
}

public func getWindText(wind: Wind, unit: SpeedUnit) -> String {
    var text = ""
    
    if let direction = wind.direction {
        text += direction + " "
    }
    
    if let speed = wind.speed {
        text += unit.formatValueWithUnit(
            speed,
            unit: getLocalizedText("speed_unit_kph")
        ) + " "
    }
    
    text += "(" + getWindLevelText(level: wind.level) + ")"
    
    if !wind.degree.noDirection {
        text += " " + wind.degree.getWindArrow()
    }
    
    return text
}

// reverse:   day / night
// otherwise: night / day
public func getDayNightTemperatureText(
    daytimeTemperature: Int,
    nighttimeTemperature: Int,
    unit: TemperatureUnit,
    reverseDayNightPosition: Bool,
    seperator: String = "/"
) -> String {
    let daytimeText = unit.formatValueWithUnit(
        daytimeTemperature,
        unit: "°"
    )
    let nighttimeText = unit.formatValueWithUnit(
        nighttimeTemperature,
        unit: "°"
    )
    
    if reverseDayNightPosition {
        return "\(daytimeText)\(seperator)\(nighttimeText)"
    } else {
        return "\(nighttimeText)\(seperator)\(daytimeText)"
    }
}

public func getPercentText(
    _ value: Double,
    decimal: Int
) -> String {
    return value.toString(decimal) + "%"
}

public func getPercentTextWithoutUnit(
    _ value: Double,
    decimal: Int
) -> String {
    return value.toString(decimal)
}

// MARK: - color.

public func getLevelColor(_ level: Int) -> UIColor {
    if (level < 2) {
        return colorLevel1
    }
    if (level < 3) {
        return colorLevel2
    }
    if (level < 4) {
        return colorLevel3
    }
    if (level < 5) {
        return colorLevel4
    }
    if (level < 6) {
        return colorLevel5
    }
    return colorLevel6
}