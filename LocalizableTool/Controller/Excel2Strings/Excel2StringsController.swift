//
//  Excel2StringsController.swift
//  LocalizableTool
//
//  Created by zhujt on 2025/10/23.
//

import UIKit
import SwifterSwift
import UniformTypeIdentifiers
import CoreXLSX
import ProgressHUD

class Excel2StringsController: UIViewController, UIDocumentPickerDelegate {
    
    var excelPath: URL?
    var stringsFolder: URL?
    
    @IBOutlet weak var logTV: UITextView!
    @IBOutlet weak var stringsFolderBtn: UIButton!
    @IBOutlet weak var excelbtn: UIButton!
    
    @IBAction func selectExcelFile(_ sender: Any) {
        log("开始选择Excel文件")
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.item], asCopy: false)
        picker.title = "excel"
        picker.delegate = self
        picker.allowsMultipleSelection = false
        present(picker, animated: true)
    }
    
    @IBAction func selectStringFolder(_ sender: Any) {
        log("开始选择本地国际化所在的文件夹")
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.folder], asCopy: false)
        picker.title = "strings"
        picker.delegate = self
        picker.allowsMultipleSelection = false
        present(picker, animated: true)
    }
    
    
    @IBAction func mergeToStrings(_ sender: Any) {
        if excelPath == nil {
            log("未选择excel文件")
            excelbtn.shake()
            return
        }
        
        if stringsFolder == nil {
            log("未选择Localized文件夹")
            stringsFolderBtn.shake()
            return
        }
        log("开始处理excel")
        let newTranslate = anaylzeExcel()
        if newTranslate.isEmpty {
            return
        }
        log("excel包含\(newTranslate.count)种语言，分别为--\(newTranslate.keys.joined(separator: ", "))。 共有\(newTranslate.first!.value.count)个待更新的key,分别为--\(newTranslate.first!.value.keys.joined(separator: ", "))")
        log("开始写入Strings文件")
        for (lang, value) in newTranslate {
            log("写入\(lang).lproj")
            let result = LocalizationWriter.writeLocalization(to: stringsFolder!, language: lang, newTranslate: value)
            result ? log("写入成功") : log("写入失败")
        }
        log("全部写入Strings文件")
        
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let folderURL = urls.first else {
            return
        }
        
        if controller.title == "excel" {
            if folderURL.pathExtension != "xlsx" {
                log("当前选择的文件不是excel (.xlsx)")
                excelbtn.shake()
            }else {
                log("Excel文件路径：\(folderURL.relativePath)")
                excelPath = folderURL
            }
        }
        
        if controller.title == "strings" {
            log("本地国际化文件夹路径：\(folderURL.relativePath)")
            stringsFolder = folderURL
        }

    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
    }
    
}

extension Excel2StringsController {
    func log(_ message: String) {
        logTV.appendLog(message)
    }
    /// 解析excel 获取新翻译  {语言：{key: value}}
    func anaylzeExcel() -> [String: [String: String]] {
        let filepath = excelPath?.relativePath ?? ""
        guard let file = XLSXFile(filepath: filepath) else {
          fatalError("XLSX file at \(filepath) is corrupted or does not exist")
        }
        
        // [lang: [[key: value]]]
        var newTranslate = [String: [String: String]]()
        if let workbooks = try? file.parseWorkbooks(), let sharedStrings = try? file.parseSharedStrings() {
            for wbk in workbooks {
                if let tuples = try? file.parseWorksheetPathsAndNames(workbook: wbk) {
                    for (name, path) in tuples {
                        if let worksheetName = name {
                            print("This worksheet has a name: \(worksheetName)")
                        }
                        if let worksheet = try? file.parseWorksheet(at: path) {
                            // 语言列表
                            var langs = [String]()
                            print("rows 数量--\(worksheet.data?.rows.count)" )
                            for (index, row) in (worksheet.data?.rows ?? []).enumerated() {
                                if index == 0 {
                                    langs = row.cells.map({$0.stringValue(sharedStrings) ?? ""})
                                }else {
                                    var key = ""
                                    for (i, c) in row.cells.enumerated() {
                                        let value = c.stringValue(sharedStrings) ?? ""
                                        if i == 0 {
                                            key = value
                                        }else {
                                            if var langDict = newTranslate[langs[i]] {
                                                langDict[key] = value
                                                newTranslate[langs[i]] = langDict
                                            }else {
                                                newTranslate[langs[i]] = [key: value]
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        return newTranslate
    }
}
