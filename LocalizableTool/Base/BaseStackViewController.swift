//
//  BaseStackViewController.swift
//  LocalizableTool
//
//  Created by zhujt on 2025/9/16.
//

import UIKit
import SnapKit

open class BaseStackViewController: UIViewController {
    
    public let scrollView = UIScrollView()
    public let contentView = UIView()
    public let stackView = UIStackView()
    
    /// 内容内边距
    public var contentPadding: UIEdgeInsets = .zero {
        didSet { updatePadding() }
    }
    
    // MARK: - Lifecycle
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    // MARK: - Setup
    
    private func setupViews() {
        view.backgroundColor = .systemBackground
        
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .center
        stackView.distribution = .fill
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(stackView)
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView.snp.width) // 保证竖直滚动
        }
        
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(contentPadding)
        }
    }
    
    private func updatePadding() {
        stackView.snp.remakeConstraints { make in
            make.edges.equalToSuperview().inset(contentPadding)
        }
    }
    
    // MARK: - Public API
    
    public func addArrangedSubview(_ view: UIView) {
        stackView.addArrangedSubview(view)
    }
    
    public func addArrangedSubviews(_ views: [UIView]) {
        views.forEach{ stackView.addArrangedSubview($0) }        
    }
    
    public func insertArrangedSubview(_ view: UIView, at index: Int) {
        stackView.insertArrangedSubview(view, at: index)
    }
    
    public func removeArrangedSubview(_ view: UIView) {
        stackView.removeArrangedSubview(view)
        view.removeFromSuperview()
    }
}
