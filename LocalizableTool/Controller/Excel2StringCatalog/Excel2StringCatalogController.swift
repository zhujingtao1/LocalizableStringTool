//
//  Excel2StringCatalogController.swift
//  LocalizableTool
//
//  Created by zhujt on 2025/10/24.
//

import UIKit
import SwifterSwift
import UniformTypeIdentifiers
import CoreXLSX
import ProgressHUD

class Excel2StringCatalogController: UIViewController, UIDocumentPickerDelegate {
    
    var excelPath: URL?
    var stringCatalogPath: URL?
    
    @IBOutlet weak var logTV: UITextView!
    @IBOutlet weak var stringCatalogBtn: UIButton!
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
        log("开始选择本地国际化文件")
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.item], asCopy: false)
        picker.title = "stringCatalog"
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
        
        if stringCatalogPath == nil {
            log("未选择stringCatalog文件")
            stringCatalogBtn.shake()
            return
        }
        log("开始处理excel")
        let newTranslate = anaylzeExcel()
        if newTranslate.isEmpty {
            return
        }
        log("excel共有\(newTranslate.count)个待更新的key，分别为--\(newTranslate.keys.joined(separator: ", "))")
        log("开始写入stringCatalog文件")
        let result = XcstringsFileWriter.writeLocalization(to: stringCatalogPath!, newTranslate: newTranslate)
        result ? log("写入成功") : log("写入失败")
        log("全部写入stringCatalog")
        
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
        
        if controller.title == "stringCatalog" {
            if folderURL.pathExtension != "xcstrings" {
                log("当前选择的文件不是stringcatalog (.xcstrings)")
                stringCatalogBtn.shake()
            }else {
                log("本地国际化文件路径：\(folderURL.relativePath)")
                stringCatalogPath = folderURL
            }
            
        }

    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
    }
    
}

extension Excel2StringCatalogController {
    func log(_ message: String) {
        logTV.appendLog(message)
    }
    /// 解析excel 获取新翻译  {key：{lang: value}}
    func anaylzeExcel() -> [String: [String: String]] {
        let filepath = excelPath?.relativePath ?? ""
        guard let file = XLSXFile(filepath: filepath) else {
          fatalError("XLSX file at \(filepath) is corrupted or does not exist")
        }
        
        // [key: [lang: value]]
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
                                            if var keyDict = newTranslate[key] {
                                                keyDict[langs[i]] = value
                                                newTranslate[key] = keyDict
                                            }else {
                                                newTranslate[key] = [langs[i]: value]
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

