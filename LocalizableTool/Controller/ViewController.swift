import UIKit
import UniformTypeIdentifiers

class ViewController: UIViewController, UIDocumentPickerDelegate{


    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
    }

    @IBAction func selectFolderAction(_ sender: Any) {
        
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.folder], asCopy: false)
        picker.delegate = self
        picker.allowsMultipleSelection = false
        present(picker, animated: true)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let folderURL = urls.first else {
            return
        }
        
        let vc = FileAnalyzeController()
        vc.selectedFolderURL = folderURL
        self.navigationController?.pushViewController(vc, animated: true)

//        DispatchQueue.global(qos: .userInitiated).async {
//            let loader = LocalizationLoader()
//            let (loadedEntries, langs) = loader.loadLocalization(from: folderURL)
//
//            // 统计信息
//            let languages = langs
//            let entries = loadedEntries
//
//            // 以英文为基准统计 key 总数
//            let baseLang = "en.lproj"
//            var baseKeys = Set<String>()
//            for entry in entries {
//                if entry.values.keys.contains(baseLang) {
//                    baseKeys.insert(entry.key)
//                }
//            }
//            let totalKeys = baseKeys.count
//
//            // 统计缺失项（每个语言缺失的 key 数量）
//            var missingCounts: [String: Int] = [:]
//            for lang in languages {
//                var missingCount = 0
//                for key in baseKeys {
//                    if let entry = entries.first(where: { $0.key == key }) {
//                        if entry.values[lang] == nil || entry.values[lang]?.isEmpty == true {
//                            missingCount += 1
//                        }
//                    } else {
//                        missingCount += 1
//                    }
//                }
//                missingCounts[lang] = missingCount
//            }

//            DispatchQueue.main.async {
//                self.activityIndicator.stopAnimating()
//                self.selectFolderButton.isEnabled = true
//
//                self.entries = entries
//                self.languages = languages
//                self.filteredEntries = entries
//                self.isSearching = false
//
//                // 显示统计信息
//                var statsText = "目录: \(folderURL.path)\n"
//                statsText += "语言数量: \(languages.count)\n"
//                statsText += "基准语言（en）Key 总数: \(totalKeys)\n"
//                statsText += "缺失项统计:\n"
//                for lang in languages.sorted() {
//                    let missing = missingCounts[lang] ?? 0
//                    statsText += "  \(lang): \(missing) 个缺失\n"
//                }
//                self.statsLabel.text = statsText
//
//                // 预留 tableView，暂时隐藏
//                self.tableView.isHidden = true
//                self.searchBar.isHidden = true
//                self.pathLabel.isHidden = true
//            }
//        }
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
    }
    
}
