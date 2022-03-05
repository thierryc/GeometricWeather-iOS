//
//  HomeViewController.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2021/8/1.
//

import UIKit
import GeometricWeatherBasic

class HomeViewController: UIViewController,
                            DragSwitchDelegate,
                            UIScrollViewDelegate {
        
    // MARK: - view models.

    let vmWeakRef: MainViewModelWeakRef
    
    // MARK: - inner data.
    
    // state values.
    
    let splitView: Bool
    
    var previewOffset = 0 {
        didSet {
            DispatchQueue.main.async {
                self.updatePreviewableSubviews()
            }
        }
    }
    var statusBarStyle = UIStatusBarStyle.lightContent {
        didSet {
            self.setNeedsStatusBarAppearanceUpdate()
            self.navigationController?.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    var blurNavigationBar = false {
        didSet {
            self.updateNavigationBarTintColor()
            
            self.navigationBarBackground.layer.removeAllAnimations()
            let targetAlpha = self.blurNavigationBar ? 1.0 : 0.0
            UIView.animate(
                withDuration: 0.3,
                delay: 0,
                options: [.beginFromCurrentState, .curveEaseInOut]
            ) { [weak self] in
                self?.navigationBarBackground.alpha = targetAlpha
            } completion: { _ in
                // do nothing.
            }
        }
    }
        
    // cells.
    
    var cellKeyList = [String]()
    var headerCache = MainTableViewHeaderView(frame: .zero)
    var timeBarCache = MainTimeBarView(frame: .zero)
    var cellCache = Dictionary<String, AbstractMainItem>()
    var cellHeightCache = Dictionary<String, CGFloat>()
    var cellAnimationHelper = StaggeredCellAnimationHelper()
    
    // timers.
    
    var hideIndicatorTimer: Timer?
    
    // MARK: - subviews.
    
    let weatherViewController = ThemeManager.shared.weatherThemeDelegate.getWeatherViewController()
    
    let dragSwitchView = DragSwitchView(frame: .zero)
    let tableView = AutoHideKeyboardTableView(frame: .zero, style: .grouped)
    
    let navigationBarTitleView = MainNavigationBarTitleView(frame: .zero)
    let navigationBarBackground = UIVisualEffectView(
        effect: UIBlurEffect(style: .systemUltraThinMaterial)
    )
    
    let indicator = DotPagerIndicator(frame: .zero)
        
    // MARK: - life cycle.
    
    init(vmWeakRef: MainViewModelWeakRef, splitView: Bool) {
        self.vmWeakRef = vmWeakRef
        self.splitView = splitView
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.initSubviewsAndLayoutThem()
        
        // observe theme changed.
        
        ThemeManager.shared.homeOverrideUIStyle.addObserver(
            self
        ) { [weak self] newValue in
            self?.overrideUserInterfaceStyle = newValue
            self?.updateNavigationBarTintColor()
            
            self?.indicator.selectedColor = newValue == .light
            ? UIColor.black.cgColor
            : UIColor.white.cgColor
            self?.indicator.unselectedColor = newValue == .light
            ? UIColor.black.withAlphaComponent(0.2).cgColor
            : UIColor.white.withAlphaComponent(0.2).cgColor
        }
        ThemeManager.shared.daylight.addObserver(self) { [weak self] _ in
            self?.updatePreviewableSubviews()
        }
        
        // observe live data.
        
        self.vmWeakRef.vm?.currentLocation.addObserver(self) { [weak self] newValue in
            self?.updatePreviewableSubviews()
            self?.updateTableView()
        }
        self.vmWeakRef.vm?.loading.addObserver(self) { [weak self] newValue in
            if newValue == self?.tableView.refreshControl?.isRefreshing {
                return
            }
            if newValue {
                self?.tableView.refreshControl?.beginRefreshingWithOffset()
            } else {
                self?.tableView.refreshControl?.endRefreshing()
            }
        }
        self.vmWeakRef.vm?.indicator.addObserver(self) { [weak self] newValue in
            if self?.indicator.selectedIndex != newValue.index {
                self?.indicator.selectedIndex = newValue.index
            }
            if self?.indicator.totalIndex != newValue.total {
                self?.indicator.totalIndex = newValue.total
            }
            
            self?.dragSwitchView.dragEnabled = newValue.total > 1
        }
        
        self.vmWeakRef.vm?.toastMessage.addObserver(self) { [weak self] newValue in
            if let message = newValue {
                self?.showToastMessage(message)
            }
        }
        
        // observe app enter foreground.
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.viewWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
        
        // register event observers.
        
        self.registerEventObservers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.updatePreviewableSubviews()
        self.updateNavigationBarTintColor()
    }
    
    override func viewWillTransition(
        to size: CGSize,
        with coordinator: UIViewControllerTransitionCoordinator
    ) {
        super.viewWillTransition(to: size, with: coordinator)
        self.cellHeightCache.removeAll()
    }
    
    @objc private func viewWillEnterForeground() {
        self.vmWeakRef.vm?.checkToUpdate()
    }
    
    override func encodeRestorableState(with coder: NSCoder) {
        super.encodeRestorableState(with: coder)
        self.vmWeakRef.vm?.encodeRestorableState(with: coder)
    }
    
    override func decodeRestorableState(with coder: NSCoder) {
        super.decodeRestorableState(with: coder)
        self.vmWeakRef.vm?.decodeRestorableState(with: coder)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if let titleView = self.navigationItem.titleView {
            self.navigationItem.titleView = nil
            self.navigationItem.titleView = titleView
        }
    }
    
    // MARK: - UI.
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return self.statusBarStyle
    }
    
    private func updatePreviewableSubviews() {
        guard let location = self.vmWeakRef.vm?.getValidLocation(
            offset: self.previewOffset
        ) else {
            return
        }
        
        let daylight = self.previewOffset == 0
        ? ThemeManager.shared.daylight.value
        : isDaylight(location: location)
        
        self.navigationBarTitleView.title = getLocationText(location: location)
        self.navigationBarTitleView.showCurrentPositionIcon = location.currentPosition
        self.weatherViewController.update(
            weatherKind: weatherCodeToWeatherKind(
                code: location.weather?.current.weatherCode ?? .clear
            ),
            daylight: daylight
        )
    }
    
    private func updateNavigationBarTintColor() {
        var uiStyle = self.overrideUserInterfaceStyle
        if uiStyle == .unspecified {
            uiStyle = self.view.traitCollection.userInterfaceStyle
        }
        
        let darkContent = self.blurNavigationBar && uiStyle == .light
        
        self.statusBarStyle = darkContent ? .darkContent : .lightContent
        let color: UIColor = darkContent ? .black : .white
        
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.tintColor = color
        self.navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: color
        ]
        self.navigationController?.navigationBar.setBackgroundImage(
            UIImage(),
            for: .default
        )
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationBarTitleView.tintColor = color
    }
    
    // MARK: - toast.
    
    func showToastMessage(_ message: MainToastMessage) {
        switch message {
        case .backgroundUpdate:
            ToastHelper.showToastMessage(
                NSLocalizedString("feedback_updated_in_background", comment: ""),
                inWindowOfView: self.view
            )
            return
            
        case .locationFailed:
            ToastHelper.showToastMessage(
                NSLocalizedString("feedback_location_failed", comment: ""),
                inWindowOfView: self.view
            )
            return
            
        case .weatherRequestFailed:
            ToastHelper.showToastMessage(
                NSLocalizedString("feedback_get_weather_failed", comment: ""),
                inWindowOfView: self.view
            )
            return
        }
    }
    
    // MARK: - actions.
    
    @objc func onManagementButtonClicked() {
        if self.navigationController?.presentedViewController != nil {
            return
        }
        
        self.navigationController?.present(
            PresentManagementViewController(
                param: MainViewModelWeakRef(vm: self.vmWeakRef.vm)
            ),
            animated: true,
            completion: nil
        )
    }
    
    @objc func onSettingsButtonClicked() {
        self.navigationController?.pushViewController(
            SettingsViewController(param: ()),
            animated: true
        )
    }
    
    @objc func onPullRefresh() {
        self.vmWeakRef.vm?.updateWithUpdatingChecking()

        if let refreshControl = self.tableView.refreshControl {
            refreshControl.endRefreshing()
        }
    }
    
    // MARK: - delegates.
    
    // drag switch.
    
    func onSwiped(_ progress: Double, isDragging: Bool) {
        if self.previewOffset != 0 && fabs(progress) <= 1 {
            // cancel preview.
            self.previewOffset = 0
        } else if self.previewOffset == 0 && fabs(progress) > 1 {
            // start preview.
            self.previewOffset = progress > 0 ? 1 : -1
        }
        
        if isDragging {
            self.showPageIndicator()
        }
    }
    
    func onSwitched(_ indexOffset: Int) {
        self.previewOffset = 0
        
        self.hideHeaderAndCells()
        if !(
            self.vmWeakRef.vm?.offsetLocation(
                offset: indexOffset
            ) ?? false
        ) {
            self.updateTableView()
        }
        
        self.delayHidePageIndicator()
    }
    
    func onRebounded() {
        self.delayHidePageIndicator()
    }
    
    // scroll.
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.showPageIndicator()
        EventBus.shared.post(HideKeyboardEvent())
    }
    
    func scrollViewDidEndDragging(
        _ scrollView: UIScrollView,
        willDecelerate decelerate: Bool
    ) {
        self.delayHidePageIndicator()
    }
}
