//
//  SummaryHeaderView.swift
//  TaskMVVM
//
//  Copyright (c) 2025 Jeremy All rights reserved.
    

import UIKit

final class SummaryHeaderView: UICollectionReusableView {
    
    // MARK: Property(s)
    
    private var tasksCount: Int = 0
    
    private let labelStackView: UIStackView = .init()
    private let completedLabel: UILabel = .init()
    private let resultLabel: UILabel = .init()
    private let systemAccessoriesLayoutGuide = UILayoutGuide()
    
    // MARK: Override(s)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Function(s)
    
    func update(tasksCount: Int) {
        self.tasksCount = tasksCount
        if tasksCount == .zero {
            resultLabel.text = "👏"
            resultLabel.backgroundColor = .systemGreen.withAlphaComponent(0.43)
        } else {
            resultLabel.text = "\(tasksCount)"
            resultLabel.backgroundColor = .systemRed.withAlphaComponent(0.43)
        }
    }
    
    // MARK: Private Function(s)
    
    private func configureLayout() {
        let contentConfiguration = UIListContentConfiguration.valueCell()
        let contentMargins = contentConfiguration.directionalLayoutMargins
        
        addSubview(labelStackView)
        labelStackView.alignment = .center
        labelStackView.addArrangedSubview(completedLabel)
        labelStackView.addArrangedSubview(resultLabel)
        labelStackView.addLayoutGuide(systemAccessoriesLayoutGuide)
        labelStackView.isLayoutMarginsRelativeArrangement = true
        
        completedLabel.text = "Todo"
        completedLabel.font = .boldSystemFont(ofSize: 17)
        
        resultLabel.backgroundColor = .systemRed.withAlphaComponent(0.43)
        resultLabel.font = UIFont.preferredFont(forTextStyle: .title3)
        resultLabel.textAlignment = .center
        
        resultLabel.layer.borderColor = UIColor.secondaryLabel.cgColor
        resultLabel.layer.masksToBounds = true
        resultLabel.layer.borderWidth = 0.33
        resultLabel.layer.cornerRadius = 8
        
        labelStackView.directionalLayoutMargins = contentMargins
        labelStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            labelStackView.topAnchor.constraint(equalTo: topAnchor),
            labelStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            labelStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            labelStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            systemAccessoriesLayoutGuide.trailingAnchor.constraint(equalTo: labelStackView.trailingAnchor),
            systemAccessoriesLayoutGuide.leadingAnchor.constraint(equalTo: labelStackView.trailingAnchor),
            systemAccessoriesLayoutGuide.widthAnchor.constraint(equalToConstant: 44),
            
            resultLabel.leadingAnchor.constraint(equalTo: systemAccessoriesLayoutGuide.leadingAnchor),
            resultLabel.heightAnchor.constraint(equalTo: labelStackView.layoutMarginsGuide.heightAnchor, multiplier: 0.9),
            resultLabel.widthAnchor.constraint(equalTo: resultLabel.heightAnchor),
        ])
    }
}
