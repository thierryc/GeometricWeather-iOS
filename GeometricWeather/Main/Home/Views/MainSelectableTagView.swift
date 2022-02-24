//
//  MainSelectableTagView.swift
//  GeometricWeather
//
//  Created by 王大爷 on 2022/2/23.
//

import UIKit
import GeometricWeatherBasic

private let reuseId = "tag"

// MARK: - container.

protocol MainSelectableTagDelegate: NSObjectProtocol {
    
    func getSelectedColor() -> UIColor
    func getUnselectedColor() -> UIColor
    
    func onSelectedChanged(newSelectedIndex: Int)
}

class MainSelectableTagView: UICollectionView,
                                UICollectionViewDelegateFlowLayout,
                                UICollectionViewDataSource,
                                TagCellDelegate {
    
    // MARK: - inner data.
    
    var tagList = [String]() {
        didSet {
            self.reloadData()
            self.selectedIndex = 0
        }
    }
    private(set) var selectedIndex = 0 {
        didSet {
            self.selectItem(
                at: IndexPath(row: self.selectedIndex, section: 0),
                animated: false,
                scrollPosition: .centeredVertically
            )
            
            self.tagDelegate?.onSelectedChanged(
                newSelectedIndex: self.selectedIndex
            )
        }
    }
    
    weak var tagDelegate: MainSelectableTagDelegate?
    
    // MARK: - life cycle.
    
    init(frame: CGRect) {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = littleMargin
        layout.sectionInset = UIEdgeInsets(top: 0, left: littleMargin, bottom: 0, right: littleMargin)
        
        super.init(frame: frame, collectionViewLayout: layout)
        self.backgroundColor = .clear
        self.delegate = self
        self.dataSource = self
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        self.register(
            TagCell.self,
            forCellWithReuseIdentifier: reuseId
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - delegate.
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return self.tagList.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: reuseId,
            for: indexPath
        ) as! TagCell
        
        cell.delegate = self
        cell.title = self.tagList.get(indexPath.row)
        cell.isSelected = self.selectedIndex == indexPath.row
        
        return cell
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: reuseId,
            for: indexPath
        ) as! TagCell
        
        cell.title = self.tagList.get(indexPath.row)
        
        return cell.systemLayoutSizeFitting(.zero)
    }
    
    func getSelectedColor() -> UIColor {
        return self.tagDelegate?.getSelectedColor() ?? .systemBlue
    }
    
    func getUnselectedColor() -> UIColor {
        return self.tagDelegate?.getUnselectedColor() ?? .systemGray
    }
    
    func onSelectedChanged(cell: UICollectionViewCell) {
        if let indexPath = self.indexPath(for: cell) {
            self.selectedIndex = indexPath.row
        }
    }
}

// MARK: - cell.

private protocol TagCellDelegate: NSObjectProtocol {
    
    func getSelectedColor() -> UIColor
    func getUnselectedColor() -> UIColor
    
    func onSelectedChanged(cell: UICollectionViewCell)
}

private class TagCell: UICollectionViewCell {
    
    // MARK: - cell subviews.
    
    let tagView = CornerButton(frame: .zero, littleMargin: true)
    
    var title: String? {
        set {
            self.tagView.setTitle(newValue, for: .normal)
        }
        get {
            return self.tagView.title(for: .normal)
        }
    }
    
    override var isSelected: Bool {
        willSet {
            if newValue {
                self.tagView.backgroundColor = self.delegate?.getSelectedColor() ?? .systemBlue
                self.tagView.setTitleColor(.white, for: .normal)
            } else {
                self.tagView.backgroundColor = self.delegate?.getUnselectedColor() ?? .systemYellow
                self.tagView.setTitleColor(.label, for: .normal)
            }
            self.tagView.layer.shadowColor = self.tagView.backgroundColor?.cgColor
        }
    }
    
    weak var delegate: TagCellDelegate?
    
    // MARK: - cell life cycles.
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.tagView.titleLabel?.font = miniCaptionFont
        self.tagView.layer.cornerRadius = 6.0
        self.tagView.layer.shadowOpacity = 0.3
        self.tagView.layer.shadowOffset = CGSize(width: 0.0, height: 3.0)
        self.tagView.addTarget(
            self,
            action: #selector(self.onTap),
            for: .touchUpInside
        )
        self.contentView.addSubview(self.tagView)
        
        self.tagView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func onTap() {
        self.delegate?.onSelectedChanged(cell: self)
    }
}
