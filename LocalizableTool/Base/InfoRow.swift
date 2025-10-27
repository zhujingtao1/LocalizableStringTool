//
//  InfoRow.swift
//  LocalizableTool
//
//  Created by zhujt on 2025/9/16.
//

import UIKit
import SnapKit

class InfoRow: UIView {
    
    let titleLabel = UILabel()
    let valueLabel = UILabel()
    
    init(title: String? = nil, value: String? = nil) {
        super.init(frame: .zero)
        setupViews()
        titleLabel.text = title
        valueLabel.text = value
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        titleLabel.font = .systemFont(ofSize: 18, weight: .medium)
        titleLabel.textColor = .label
        titleLabel.setContentHuggingPriority(.required, for: .horizontal)
        titleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        valueLabel.font = .systemFont(ofSize: 24)
        valueLabel.textColor = .secondaryLabel
        valueLabel.numberOfLines = 0   // 允许换行
        
        addSubview(titleLabel)
        addSubview(valueLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
        }
        
        valueLabel.snp.makeConstraints { make in
            make.top.bottom.trailing.equalToSuperview()
            make.leading.equalTo(titleLabel.snp.trailing).offset(16)
            make.height.greaterThanOrEqualTo(56)
        }
    }
    
    /// 设置内容
    func setValue(_ value: String?) {
        valueLabel.text = value
    }
}
