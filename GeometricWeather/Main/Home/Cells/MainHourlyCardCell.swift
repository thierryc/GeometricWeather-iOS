//
//  MainHourlyCardCell.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/8/16.
//

import UIKit
import GeometricWeatherBasic

private let hourlyTrendViewHeight = 198.0
private let minutelyTrendViewHeight = 56.0

enum HourlyTag: String {
    
    case temperature = "hourly_temperature"
    case wind = "hourly_wind"
}

class MainHourlyCardCell: MainTableViewCell,
                            UICollectionViewDataSource,
                            UICollectionViewDelegateFlowLayout,
                            MainSelectableTagDelegate {
    
    // MARK: - data.
    
    private var weather: Weather?
    private var timezone: TimeZone?
    
    private var temperatureRange: ClosedRange<Int>?
    private var maxWindSpeed: Double?
    
    private var source: WeatherSource?
    
    private var tagList = [(tag: HourlyTag, title: String)]()
    private var currentTag = HourlyTag.temperature
    
    // MARK: - subviews.
    
    private let vstack = UIStackView(frame: .zero)
    
    private let summaryLabel = UILabel(frame: .zero)
    
    private let tagPaddingTop = UIView(frame: .zero)
    private let hourlyTagView = MainSelectableTagView(frame: .zero)
    
    private let hourlyTrendGroupView = UIView(frame: .zero)
    private let hourlyBackgroundView = HourlyTrendCellBackgroundView(frame: .zero)
    private let hourlyCollectionView = MainTrendShaderCollectionView(frame: .zero)
    
    private let minutelyTitleVibrancyContainer = UIVisualEffectView(
        effect: UIVibrancyEffect(
            blurEffect: UIBlurEffect(style: .prominent)
        )
    )
    private let minutelyTitle = UILabel(frame: .zero)
    
    private let minutelyView = BeizerPolylineView(frame: .zero)
    
    // MARK: - life cycle.
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
                
        self.cardTitle.text = NSLocalizedString("hourly_overview", comment: "")
        
        self.vstack.axis = .vertical
        self.vstack.alignment = .center
        self.vstack.spacing = 0
        self.cardContainer.contentView.addSubview(self.vstack)
        
        self.summaryLabel.font = miniCaptionFont;
        self.summaryLabel.textColor = .tertiaryLabel
        self.summaryLabel.numberOfLines = 0
        self.summaryLabel.lineBreakMode = .byWordWrapping
        self.vstack.addArrangedSubview(self.summaryLabel)
        
        self.vstack.addArrangedSubview(self.tagPaddingTop)
        
        self.hourlyTagView.tagDelegate = self
        self.vstack.addArrangedSubview(self.hourlyTagView)
        
        self.hourlyCollectionView.delegate = self
        self.hourlyCollectionView.dataSource = self
        self.hourlyCollectionView.register(
            HourlyTrendCollectionViewCell.self,
            forCellWithReuseIdentifier: HourlyTag.temperature.rawValue
        )
        self.hourlyCollectionView.register(
            HourlyWindCollectionViewCell.self,
            forCellWithReuseIdentifier: HourlyTag.wind.rawValue
        )
        self.hourlyTrendGroupView.addSubview(self.hourlyCollectionView)
        
        self.hourlyBackgroundView.isUserInteractionEnabled = false
        self.hourlyTrendGroupView.addSubview(self.hourlyBackgroundView)
        
        self.vstack.addArrangedSubview(self.hourlyTrendGroupView)
        
        self.minutelyTitle.text = NSLocalizedString(
            "precipitation_overview",
            comment: ""
        )
        self.minutelyTitle.font = titleFont
        self.minutelyTitleVibrancyContainer.contentView.addSubview(self.minutelyTitle)
        
        self.titleVibrancyContainer.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(normalMargin)
            make.leading.equalToSuperview().offset(normalMargin)
            make.trailing.equalToSuperview().offset(-normalMargin)
        }
        self.vstack.snp.makeConstraints { make in
            make.top.equalTo(self.titleVibrancyContainer.snp.bottom)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        self.summaryLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(normalMargin)
            make.trailing.equalToSuperview().offset(-normalMargin)
        }
        self.tagPaddingTop.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(littleMargin)
        }
        self.hourlyTagView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(44)
        }
        self.hourlyTrendGroupView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(hourlyTrendViewHeight + 2 * littleMargin)
        }
        self.hourlyBackgroundView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(hourlyTrendViewHeight)
        }
        self.hourlyCollectionView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(hourlyTrendViewHeight)
        }
        
        self.minutelyTitle.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(littleMargin)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-littleMargin)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func bindData(location: Location, timeBar: MainTimeBarView?) {
        super.bindData(location: location, timeBar: timeBar)
        
        self.minutelyTitleVibrancyContainer.removeFromSuperview()
        self.minutelyView.removeFromSuperview()
        
        if let weather = location.weather {
            self.weather = weather
            self.timezone = location.timezone
            
            var maxTemp = weather.yesterday?.daytimeTemperature ?? Int.min
            var minTemp = weather.yesterday?.nighttimeTemperature ?? Int.max
            var maxWind = 0.0
            for hourly in weather.hourlyForecasts {
                if maxTemp < hourly.temperature.temperature {
                    maxTemp = hourly.temperature.temperature
                }
                if minTemp > hourly.temperature.temperature {
                    minTemp = hourly.temperature.temperature
                }
                if maxWind < hourly.wind?.speed ?? 0.0 {
                    maxWind = hourly.wind?.speed ?? 0.0
                }
            }
            self.temperatureRange = minTemp...maxTemp
            self.maxWindSpeed = maxWind
            self.source = location.weatherSource

            self.summaryLabel.text = weather.current.hourlyForecast
            
            self.tagList = self.buildTagList(weather: weather)
            var titles = [String]()
            for tagPair in self.tagList {
                titles.append(tagPair.title)
            }
            self.hourlyTagView.tagList = titles
            
            self.hourlyBackgroundView.bindData(
                weather: weather,
                temperatureRange: self.temperatureRange ?? 0...0
            )
            
            // minutely.
            
            guard let minutely = weather.minutelyForecast else {
                return
            }
            if minutely.precipitationIntensityInPercentage.count < 2 {
                return
            }
            var allZero = true
            for value in minutely.precipitationIntensityInPercentage {
                if value >= radarPrecipitationIntensityLight {
                    allZero = false
                    break
                }
            }
            if allZero {
                return
            }
            
            self.vstack.addArrangedSubview(self.minutelyTitleVibrancyContainer)
            self.minutelyTitleVibrancyContainer.snp.makeConstraints { make in
                make.leading.equalToSuperview().offset(normalMargin)
                make.trailing.equalToSuperview().offset(-normalMargin)
            }
            
            self.minutelyView.polylineColor = ThemeManager.shared.weatherThemeDelegate.getThemeColors(
                weatherKind: weatherCodeToWeatherKind(code: weather.current.weatherCode),
                daylight: ThemeManager.shared.daylight.value
            ).daytime
            self.minutelyView.polylineValues = getPrecipitationIntensityInPercentage(
                intensityInRadarStandard: minutely.precipitationIntensityInPercentage
            )
            self.minutelyView.beginTime = formateTime(
                timeIntervalSine1970: minutely.beginTime,
                twelveHour: isTwelveHour()
            )
            self.minutelyView.endTime = formateTime(
                timeIntervalSine1970: minutely.endTime,
                twelveHour: isTwelveHour()
            )
            self.vstack.addArrangedSubview(self.minutelyView)
            self.minutelyView.snp.makeConstraints { make in
                make.leading.equalToSuperview()
                make.trailing.equalToSuperview()
                make.height.equalTo(minutelyTrendViewHeight)
            }
        }
    }
    
    override func traitCollectionDidChange(
        _ previousTraitCollection: UITraitCollection?
    ) {
        super.traitCollectionDidChange(previousTraitCollection)
        DispatchQueue.main.async {
            self.hourlyCollectionView.reloadData()
            
            if let weather = self.weather,
               let range = self.temperatureRange {
                self.hourlyBackgroundView.bindData(weather: weather, temperatureRange: range)
            }
        }
    }
    
    // MARK: - delegates.
    
    // collection view delegate flow layout.
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return self.hourlyCollectionView.cellSize
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        if let weather = self.weather,
            let timezone = self.timezone {
            HourlyDialog(
                weather: weather,
                timezone: timezone,
                index: indexPath.row
            ).showSelf(
                inWindowOfView: self
            )
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfigurationForItemAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        guard
            let weather = self.weather,
            let timezone = self.timezone
        else {
            return nil
        }
        
        return UIContextMenuConfiguration(
            identifier: NSNumber(value: indexPath.row)
        ) {
            let vc = HourlyViewController(
                param: (weather, timezone, indexPath.row)
            )
            vc.measureAndSetPreferredContentSize()
            return vc
        } actionProvider: { _ in
            return nil
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration
    ) -> UITargetedPreview? {
        guard let row = (configuration.identifier as? NSNumber)?.intValue else {
            return nil
        }
        guard let cell = collectionView.cellForItem(
            at: IndexPath(row: row, section: 0)
        ) else {
            return nil
        }
        
        let params = UIPreviewParameters()
        params.backgroundColor = .clear
        
        return UITargetedPreview(view: cell, parameters: params)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration
    ) -> UITargetedPreview? {
        return self.collectionView(
            collectionView,
            previewForHighlightingContextMenuWithConfiguration: configuration
        )
    }
    
    // data source.
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return weather?.hourlyForecasts.count ?? 0
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        return self.buildCell(
            collectionView: self.hourlyCollectionView,
            currentTag: self.currentTag,
            indexPath: indexPath,
            weather: self.weather,
            source: self.source,
            timezone: self.timezone ?? .current,
            temperatureRange: self.temperatureRange ?? 0...0,
            maxWindSpeed: self.maxWindSpeed ?? 0
        )
    }
    
    // selectable tag view.
    
    func getSelectedColor() -> UIColor {
        return .systemBlue
    }
    
    func getUnselectedColor() -> UIColor {
        return ThemeManager.shared.weatherThemeDelegate.getThemeColors(
            weatherKind: weatherCodeToWeatherKind(
                code: self.weather?.current.weatherCode ?? .clear
            ),
            daylight: ThemeManager.shared.daylight.value
        ).main.withAlphaComponent(0.33)
    }
    
    func onSelectedChanged(newSelectedIndex: Int) {
        self.currentTag = self.tagList[newSelectedIndex].tag
        self.hourlyBackgroundView.isHidden = self.tagList[newSelectedIndex].tag != .temperature
        
        self.hourlyCollectionView.scrollToItem(
            at: IndexPath(row: 0, section: 0),
            at: .left,
            animated: false
        )
        self.hourlyCollectionView.collectionViewLayout.invalidateLayout()
        self.hourlyCollectionView.reloadData()
    }
}
