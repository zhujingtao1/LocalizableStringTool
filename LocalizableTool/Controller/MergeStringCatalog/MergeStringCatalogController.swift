//
//  MergeStringCatalogController.swift
//  LocalizableTool
//
//  Created by zhujt on 2025/10/24.
//

import UIKit
import SwifterSwift
import UniformTypeIdentifiers
import CoreXLSX
import ProgressHUD

class MergeStringCatalogController: UIViewController, UIDocumentPickerDelegate {
    
    var stringCatalogPath1: URL?
    var stringCatalogPath2: URL?
//    var outputFolderPath: URL?
    
    @IBOutlet weak var logTV: UITextView!
    @IBOutlet weak var stringCatalogBtn2: UIButton!
    @IBOutlet weak var stringCatalogBtn1: UIButton!
    
    @IBAction func selectStringCatalog1(_ sender: Any) {
        log("开始选择本地国际化文件1")
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.item], asCopy: false)
        picker.title = "stringCatalog1"
        picker.delegate = self
        picker.allowsMultipleSelection = false
        present(picker, animated: true)
    }
    
    @IBAction func selectStringCatalog2(_ sender: Any) {
        log("开始选择本地国际化文件2")
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.item], asCopy: false)
        picker.title = "stringCatalog2"
        picker.delegate = self
        picker.allowsMultipleSelection = false
        present(picker, animated: true)
    }
    
    
    @IBAction func mergeToStringCatalog(_ sender: Any) {
        if stringCatalogPath1 == nil {
            log("未选择stringCatalog文件1")
            stringCatalogBtn1.shake()
            return
        }
        
        if stringCatalogPath2 == nil {
            log("未选择stringCatalog文件2")
            stringCatalogBtn2.shake()
            return
        }
        
        log("开始选择存储的文件夹")
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.folder], asCopy: false)
        picker.title = "output"
        picker.delegate = self
        picker.allowsMultipleSelection = false
        present(picker, animated: true)
        log("开始处理excel")
//        let newTranslate = anaylzeExcel()
//        if newTranslate.isEmpty {
//            return
//        }
//        log("excel共有\(newTranslate.count)个待更新的key，分别为--\(newTranslate.keys.joined(separator: ", "))")
//        log("开始写入stringCatalog文件")
//        let result = XcstringsFileWriter.writeLocalization(to: stringCatalogPath!, newTranslate: newTranslate)
//        result ? log("写入成功") : log("写入失败")
//        log("全部写入stringCatalog")
        
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let folderURL = urls.first else {
            return
        }
        
        if controller.title == "stringCatalog1" {
            if folderURL.pathExtension != "xcstrings" {
                log("当前选择的文件不是stringcatalog (.xcstrings)")
                stringCatalogBtn1.shake()
            }else {
                log("Excel文件路径：\(folderURL.relativePath)")
                stringCatalogPath1 = folderURL
            }
        }
        
        if controller.title == "stringCatalog2" {
            if folderURL.pathExtension != "xcstrings" {
                log("当前选择的文件不是stringcatalog (.xcstrings)")
                stringCatalogBtn2.shake()
            }else {
                log("本地国际化文件路径：\(folderURL.relativePath)")
                stringCatalogPath2 = folderURL
            }
            
        }
        
        if controller.title == "output" {
            log("选择存储的文件夹路径：\(folderURL.relativePath)")
            log("开始合并")
            let result = XcstringsMerger.mergeXcstringsFiles(at: stringCatalogPath1!, and: stringCatalogPath2!, outputRoot: folderURL)
            result ? log("合并成功") : log("合并失败")
            if result {
                UIApplication.shared.open(folderURL)
            }
        }

    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
    }
    
}

extension MergeStringCatalogController {
    func log(_ message: String) {
        logTV.appendLog(message)
    }
}


