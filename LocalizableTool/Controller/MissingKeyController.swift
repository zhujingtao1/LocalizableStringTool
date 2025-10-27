//
//  MissingKeyController.swift
//  LocalizableTool
//
//  Created by zhujt on 2025/9/16.
//

import UIKit
import SnapKit

class MissingKeyController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIEditMenuInteractionDelegate {
    
    
    var currentLang = ""
    
    var missingKeys = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "\(currentLang)缺失的key"
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 88
        tableView.separatorStyle = .none
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "reuseId")
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let currentLangKeys = LM.loadLanguageKeys(with: currentLang)
        missingKeys = Array(LM.baseLanguageKeys.subtracting(currentLangKeys)).sorted()
        
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return missingKeys.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseId", for: indexPath)
        cell.selectionStyle = .none
        var content = cell.defaultContentConfiguration()
        content.textProperties.font =  UIFont.boldSystemFont(ofSize: 24)
        content.textProperties.numberOfLines = 0
        content.text = missingKeys[indexPath.row]
        cell.contentConfiguration = content
        let interaction = UIEditMenuInteraction(delegate: self)
        cell.contentView.addInteraction(interaction)
        return cell
    }
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        UIPasteboard.general.string = missingKeys[indexPath.row]
//    }
    
    func editMenuInteraction(_ interaction: UIEditMenuInteraction, menuFor configuration: UIEditMenuConfiguration, suggestedActions: [UIMenuElement]) -> UIMenu? {

            // 获取要复制的文本
            guard let cell = interaction.view?.superview as? UITableViewCell,
                  let config = cell.contentConfiguration as? UIListContentConfiguration,
                  let text = config.text
                  else { return nil }

            // 创建复制操作
            let copyAction = UIAction(title: "复制") { _ in
                UIPasteboard.general.string = text
            }

            return UIMenu(title: "", children: [copyAction])
        }
    
}
