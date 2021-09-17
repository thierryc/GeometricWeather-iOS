//
//  Theme.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/7/24.
//

import UIKit

// MARK: - constants.

let navBarHeight = 44.0
let navBarOpacity = 0.5

let cardRadius = 18.0

let littleMargin = 12.0
let normalMargin = 24.0

let colorLevel1 = UIColor.colorFromRGB(0x72d572);
let colorLevel2 = UIColor.colorFromRGB(0xffca28);
let colorLevel3 = UIColor.colorFromRGB(0xffa726);
let colorLevel4 = UIColor.colorFromRGB(0xe52f35);
let colorLevel5 = UIColor.colorFromRGB(0x99004c);
let colorLevel6 = UIColor.colorFromRGB(0x7e0023);

let designTitleFont = UIFont.systemFont(ofSize: 128.0, weight: .ultraLight)
let largeTitleFont = UIFont.systemFont(ofSize: 18.0, weight: .bold)
let titleFont = UIFont.systemFont(ofSize: 16.0, weight: .semibold)
let bodyFont = UIFont.systemFont(ofSize: 14.0, weight: .semibold)
let captionFont = UIFont.systemFont(ofSize: 14.0, weight: .medium)
let miniCaptionFont = UIFont.systemFont(ofSize: 12.0, weight: .medium)
let tinyCaptionFont = UIFont.systemFont(ofSize: 10.0, weight: .medium)

// MARK: - data.

class ThemeManager {
    
    // singleton.
    
    static var shared = ThemeManager(
        darkMode: SettingsManager.shared.darkMode
    )
    
    private init(darkMode: DarkMode) {
        self.homeOverrideUIStyle = EqualtableLiveData(
            Self.generateHomeUIUserInterfaceStyle(
                darkMode: darkMode,
                daylight: isDaylight()
            )
        )
        self.globalOverrideUIStyle = EqualtableLiveData(
            Self.generateGlobalUIUserInterfaceStyle(
                darkMode: darkMode,
                daylight: isDaylight()
            )
        )
        self.daylight = EqualtableLiveData(isDaylight())
        
        self.weatherThemeDelegate = MaterialWeatherThemeDelegate()
        
        self.darkMode = darkMode
    }
    
    // properties.
    
    let homeOverrideUIStyle: EqualtableLiveData<UIUserInterfaceStyle>
    let globalOverrideUIStyle: EqualtableLiveData<UIUserInterfaceStyle>
    let daylight: EqualtableLiveData<Bool>
    
    var weatherThemeDelegate: WeatherThemeDelegate
    
    private var darkMode: DarkMode
    
    // interfaces.
    
    func update(
        darkMode: DarkMode? = nil,
        location: Location? = nil
    ) {
        if let loc = location {
            self.daylight.value = isDaylight(location: loc)
        }
        if let dm = darkMode {
            self.darkMode = dm
        }
        
        homeOverrideUIStyle.value = Self.generateHomeUIUserInterfaceStyle(
            darkMode: self.darkMode,
            daylight: self.daylight.value
        )
        globalOverrideUIStyle.value = Self.generateGlobalUIUserInterfaceStyle(
            darkMode: self.darkMode,
            daylight: self.daylight.value
        )
    }
    
    private static func generateHomeUIUserInterfaceStyle(
        darkMode: DarkMode,
        daylight: Bool
    ) -> UIUserInterfaceStyle {
        if darkMode.key == "dark_mode_system" {
            return .unspecified
        } else if darkMode.key == "dark_mode_light" {
            return .light
        } else if darkMode.key == "dark_mode_dark" {
            return .dark
        } else {
            return daylight ? .light : .dark
        }
    }
    
    private static func generateGlobalUIUserInterfaceStyle(
        darkMode: DarkMode,
        daylight: Bool
    ) -> UIUserInterfaceStyle {
        if darkMode.key == "dark_mode_system" {
            return .unspecified
        } else if darkMode.key == "dark_mode_light" {
            return .light
        } else if darkMode.key == "dark_mode_dark" {
            return .dark
        } else {
            return .unspecified
        }
    }
}
