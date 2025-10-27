//
//  MissingStatisticsController.swift
//  LocalizableTool
//
//  Created by zhujt on 2025/9/16.
//

import UIKit
import SnapKit

class MissingStatisticsController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "缺失统计"
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
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return LM.languages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseId", for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.textProperties.font =  UIFont.boldSystemFont(ofSize: 18)
        content.text = LM.languages[indexPath.row]
        content.secondaryText = "相对于参照语种-\(LM.baseLanguage)，缺少\(LM.baseLanguageKeys.count - LM.loadLanguageKeys(with: LM.languages[indexPath.row]).count)个key"
        content.secondaryTextProperties.color = .secondaryLabel
        content.secondaryTextProperties.numberOfLines = 0
        content.secondaryTextProperties.font =  UIFont.boldSystemFont(ofSize: 24)
        cell.contentConfiguration = content
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = MissingKeyController()
        vc.currentLang = LM.languages[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
    
}
