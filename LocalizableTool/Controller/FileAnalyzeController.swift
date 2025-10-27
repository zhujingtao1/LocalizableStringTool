//
//  FilePathController.swift
//  LocalizableTool
//
//  Created by zhujt on 2025/9/15.
//

import UIKit
import SnapKit

class FileAnalyzeController: BaseStackViewController {
    var selectedFolderURL: URL!
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        navigationController?.setNavigationBarHidden(true, animated: true)
//    }
//    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        navigationController?.setNavigationBarHidden(false, animated: true)
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contentPadding = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
        
        let subViews = [folderPathRow, languageCount, languageCode, baseLanguage, baseLanguageKeyCount]
        
        addArrangedSubviews(subViews)
        
        subViews.forEach({
            $0.snp.makeConstraints { make in
                make.width.equalToSuperview()
            }
        })
        
        let checkBtn = UIButton(type: .system)
        checkBtn.setTitle("根据参照语种检查缺失项", for: .normal)
        checkBtn.setTitleColor(.white, for: .normal)
        checkBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        checkBtn.backgroundColor = .systemBlue
        checkBtn.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        checkBtn.addTarget(self, action: #selector(checkAction), for: .touchUpInside)
        addArrangedSubview(checkBtn)
        
        folderPathRow.setValue(selectedFolderURL.path)
        
        baseLanguage.setValue(LM.baseLanguage + "--\(langDict[LM.baseLanguage] ?? "未知")")
        
        let changeBaseLangTap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        changeBaseLangTap.numberOfTapsRequired = 2
        baseLanguage.isUserInteractionEnabled = true
        baseLanguage.addGestureRecognizer(changeBaseLangTap)
        
        loadLocalization()
    }
    
    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
//        let vc = UIpickviewcon()
//        vc.
    }
    
    func loadLocalization() {
        LocalizationManager.shared.loadLocalized(with: selectedFolderURL)
        initViewData()
    }
    
    func initViewData() {
        LM.baseLanguage = "en"
        languageCount.setValue("\(LM.languages.count)")
        languageCode.setValue(LM.languages.map({$0 + "--\(langDict[$0] ?? "未知")"}).joined(separator: "          "))
        
        baseLanguageKeyCount.setValue("\(LM.baseLanguageKeys.count)")
        
//        for lang in LM.languages {
//            let langKeys = countLanguageKeys(with: lang)
//            let row = InfoRow(title: "\(lang)--\(langDict[lang] ?? "未知") Key数量：", value: "\(langKeys.count)")
//            addArrangedSubview(row)
//        }
    }
    
    @objc func checkAction() {
        let vc = MissingStatisticsController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    let folderPathRow = InfoRow(title: "文件路径：")
    let languageCount = InfoRow(title: "多语言数量：")
    let languageCode = InfoRow(title: "多语言种类：")
    let baseLanguage = InfoRow(title: "参照语种：")
    let baseLanguageKeyCount = InfoRow(title: "参照语种Key数量：")
    
}
