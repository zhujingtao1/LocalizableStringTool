//
//  KeyValuesController.swift
//  LocalizableTool
//
//  Created by zhujt on 2025/9/15.
//


import UIKit
import UniformTypeIdentifiers

class KeyValuesController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIDocumentPickerDelegate, UISearchBarDelegate {

    private let tableView = UITableView()
    private var entries: [LocalizationEntry] = []
    private var languages: [String] = []
    private var filteredEntries: [LocalizationEntry] = []
    private var isSearching = false
    private let searchBar = UISearchBar()
    private let pathLabel = UILabel()
    private var selectedFolderPath: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "文案检查工具"
        view.backgroundColor = .systemBackground

        // 移除导航栏右上角的 "选择目录" 按钮

        searchBar.delegate = self
        searchBar.sizeToFit()
        searchBar.placeholder = "搜索 Key 或 Value"
        // 不再放在 navigationItem.titleView
        // navigationItem.titleView = searchBar

        // 布局 pathLabel
        let safeTop = view.safeAreaInsets.top
        pathLabel.numberOfLines = 0
        pathLabel.font = .systemFont(ofSize: 12)
        pathLabel.textColor = .secondaryLabel
        pathLabel.frame = CGRect(x: 16, y: safeTop + 8, width: view.bounds.width - 32, height: 40)
        pathLabel.autoresizingMask = [.flexibleWidth]
        pathLabel.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(pathLabelTapped))
        pathLabel.addGestureRecognizer(tapGesture)
        view.addSubview(pathLabel)

        // 布局 searchBar 在 pathLabel 下方
        searchBar.frame = CGRect(x: 0, y: pathLabel.frame.maxY + 8, width: view.bounds.width, height: 44)
        searchBar.autoresizingMask = [.flexibleWidth]
        view.addSubview(searchBar)

        // 布局 tableView 在 searchBar 下方
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.frame = CGRect(
            x: 0,
            y: searchBar.frame.maxY + 8,
            width: view.bounds.width,
            height: view.bounds.height - (searchBar.frame.maxY + 8)
        )
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(tableView)
    }
    
    // MARK: - pathLabel 点击事件
    @objc private func pathLabelTapped() {
        selectFolder()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if selectedFolderPath == nil {
            selectFolder()
        }
    }

    // MARK: - 选择目录
    @objc func selectFolder() {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.folder], asCopy: false)
        picker.delegate = self
        picker.allowsMultipleSelection = false
        present(picker, animated: true)
    }

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let folderURL = urls.first else { return }
        print("选择目录：", folderURL.path)
        selectedFolderPath = folderURL.path
        pathLabel.text = "选中目录: \(folderURL.path)"

        let loader = LocalizationLoader()
        let (loadedEntries, langs) = loader.loadLocalization(from: folderURL)
        self.entries = loadedEntries
        self.languages = langs
        self.filteredEntries = loadedEntries
        self.isSearching = false

        tableView.reloadData()
    }

    // MARK: - UISearchBar Delegate
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        let text = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
//        if text.isEmpty {
//            isSearching = false
//            filteredEntries = entries
//        } else {
//            isSearching = true
//            filteredEntries = entries.filter { entry in
//                if entry.key.localizedCaseInsensitiveContains(text) {
//                    return true
//                }
//                for lang in languages {
//                    if let value = entry.values[lang], value?.localizedCaseInsensitiveContains(text) {
//                        return true
//                    }
//                }
//                return false
//            }
//        }
//        tableView.reloadData()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        isSearching = false
        filteredEntries = entries
        tableView.reloadData()
        searchBar.resignFirstResponder()
    }

    // MARK: - UITableView DataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return isSearching ? filteredEntries.count : entries.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return languages.count + 1 // Key + 各语言
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let entry = isSearching ? filteredEntries[section] : entries[section]
        return entry.key
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let entry = isSearching ? filteredEntries[indexPath.section] : entries[indexPath.section]
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        if indexPath.row == 0 {
            cell.textLabel?.text = "Key: \(entry.key)"
            cell.textLabel?.font = .boldSystemFont(ofSize: 14)
            cell.textLabel?.textColor = .label
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.lineBreakMode = .byWordWrapping
        } else {
            let lang = languages[indexPath.row - 1]
            let value = entry.values[lang] ?? "❌"
            cell.textLabel?.text = "\(lang): \(value)"
            cell.textLabel?.textColor = (value == "❌") ? .red : .label
            cell.textLabel?.font = .systemFont(ofSize: 13)
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.lineBreakMode = .byWordWrapping
        }
        return cell
    }

    // MARK: - UITableView Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let entry = isSearching ? filteredEntries[indexPath.section] : entries[indexPath.section]
        if indexPath.row > 0 {
            let lang = languages[indexPath.row - 1]
            print("点击: \(entry.key) → \(lang) = \(entry.values[lang] ?? "❌")")
        }
    }
}

