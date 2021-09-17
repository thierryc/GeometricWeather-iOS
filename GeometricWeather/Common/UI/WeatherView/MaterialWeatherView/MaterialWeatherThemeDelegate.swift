//
//  MaterialWeatherThemeDelegate.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/7/25.
//

import SwiftUI

private let headerHeightRatio: CGFloat = 0.66

class MaterialWeatherThemeDelegate: WeatherThemeDelegate {
    
    func getThemeColors(
        weatherKind: WeatherKind,
        daylight: Bool,
        lightTheme: Bool
    ) -> (main: UIColor, daytime: UIColor, nighttime: UIColor) {
        
        let backgroundColor = getBackgroundColor(
            weatherKind: weatherKind,
            daylight: daylight
        )
        
        return (
            backgroundColor * 0.75 + .white * 0.25,
            backgroundColor * 0.75 + .white * 0.25,
            backgroundColor * 0.75 + .white * 0.25
        )
    }
    
    private func getMainColor(
        weatherKind: WeatherKind,
        daylight: Bool
    ) -> UIColor {
        if weatherKind == .clear && daylight {
            return .orange
        } else if weatherKind == .clear {
            return .systemBlue
        } else if weatherKind == .cloud && daylight {
            return .systemBlue
        } else if weatherKind == .cloud {
            return .systemBlue
        } else if weatherKind == .cloudy && daylight {
            return .systemGray
        } else if weatherKind == .cloudy {
            return .systemGreen
        } else if weatherKind == .thunder {
            return .systemPurple
        } else if weatherKind == .fog {
            return .systemGray
        } else if weatherKind == .haze {
            return .systemGray
        } else if (weatherKind == .lightRainy
                   || weatherKind == .middleRainy
                   || weatherKind == .haveyRainy) && daylight {
            return .systemBlue
        } else if weatherKind == .lightRainy
                    || weatherKind == .middleRainy
                    || weatherKind == .haveyRainy {
            return .systemBlue
        } else if weatherKind == .sleet && daylight {
            return .systemBlue
        } else if weatherKind == .sleet {
            return .systemBlue
        } else if weatherKind == .thunderstorm {
            return .systemPurple
        } else if weatherKind == .snow {
            return .systemBlue
        } else if weatherKind == .hail {
            return .systemBlue
        } else if weatherKind == .wind {
            return .systemYellow
        } else {
            return .clear
        }
    }
    
    private func getBackgroundColor(
        weatherKind: WeatherKind,
        daylight: Bool
    ) -> UIColor {
        if weatherKind == .clear && daylight {
            return UIColor.colorFromRGB(0xfdbc4c)
        } else if weatherKind == .clear {
            return UIColor.colorFromRGB(0x141b2c)
        } else if weatherKind == .cloud && daylight {
            return UIColor.colorFromRGB(0x00a5d9)
        } else if weatherKind == .cloud {
            return UIColor.colorFromRGB(0x222d43)
        } else if weatherKind == .cloudy && daylight {
            return UIColor.colorFromRGB(0x607988)
        } else if weatherKind == .cloudy {
            return UIColor.colorFromRGB(0x263238)
        } else if weatherKind == .thunder {
            return UIColor.colorFromRGB(0x231739)
        } else if weatherKind == .fog {
            return UIColor.colorFromRGB(0x4f5d68)
        } else if weatherKind == .haze {
            return UIColor.colorFromRGB(0x424242)
        } else if (weatherKind == .lightRainy
                   || weatherKind == .middleRainy
                   || weatherKind == .haveyRainy) && daylight {
            return UIColor.colorFromRGB(0x4097e7)
        } else if weatherKind == .lightRainy
                    || weatherKind == .middleRainy
                    || weatherKind == .haveyRainy {
            return UIColor.colorFromRGB(0x264e8f)
        } else if weatherKind == .sleet && daylight {
            return UIColor.colorFromRGB(0x68baff)
        } else if weatherKind == .sleet {
            return UIColor.colorFromRGB(0x1a5b92)
        } else if weatherKind == .thunderstorm {
            return UIColor.colorFromRGB(0x2b1d45)
        } else if weatherKind == .snow {
            return daylight ? UIColor.colorFromRGB(0x68baff) : UIColor.colorFromRGB(0x1a5b92)
        } else if weatherKind == .hail {
            return daylight ? UIColor.colorFromRGB(0x68baff) : UIColor.colorFromRGB(0x1a5b92)
        } else if weatherKind == .wind {
            return UIColor.colorFromRGB(0xe99e3c)
        } else {
            return .clear
        }
    }
    
    func getHeaderHeight(_ viewHeight: CGFloat) -> CGFloat {
        return viewHeight * headerHeightRatio
    }
}
