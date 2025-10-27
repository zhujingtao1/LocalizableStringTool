//
//  LocalizationWriter.swift
//  LocalizableTool
//
//  Created by zhujt on 2025/10/24.
//

import Foundation

class LocalizationWriter {
    static func writeLocalization(to rootURL: URL, language: String, newTranslate: [String: String]) -> Bool {
        // 1️⃣ 构建目标文件路径
        let dirURL = rootURL.appendingPathComponent("\(language).lproj", isDirectory: true)
        let fileURL = dirURL.appendingPathComponent("Localizable.strings")
        
        // 2️⃣ 读取原有翻译（如果有）
        var alreadyExistTrans = StringsFileParser.parseStringsFile(at: fileURL)
        
        // 3️⃣ 合并新翻译（新值覆盖旧值）
        alreadyExistTrans.merge(newTranslate) { _, new in new }
        
        // 4️⃣ 清空原文件内容
        try? FileManager.default.removeItem(at: fileURL)
        try? FileManager.default.createDirectory(at: dirURL, withIntermediateDirectories: true)
        
        // 5️⃣ 按 key 排序并重新生成内容
        let sortedKeys = alreadyExistTrans.keys.sorted(by: { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending })
        var output = ""
        
        for key in sortedKeys {
            if var value = alreadyExistTrans[key] {
                // ✳️ 转义双引号和换行符
                value = escapeQuotesAndNewlines(value)
                
                // ✳️ 转换 Android 占位符 → iOS 占位符
                value = convertAndroidPlaceholdersToiOS(value)
                
                
                output += "\"\(key)\" = \"\(value)\";\n"
            }
        }
        
        // 6️⃣ 写入新的 Localizable.strings 文件
        do {
            try output.write(to: fileURL, atomically: true, encoding: .utf8)
            print("✅ 写入成功：\(fileURL.path)")
            return true
        } catch {
            print("❌ 写入失败：\(error.localizedDescription)")
            return false
        }
    }

    private static func convertAndroidPlaceholdersToiOS(_ text: String) -> String {
        var result = text
        
        // 匹配 Android 常见占位符：%s, %d, %1$s, %2$d, %1$d 等
        let stringPatterns = [
            "%\\d*\\$s",  // %1$s, %2$s
            "%s"    // 普通 %s, %d
        ]
        
        for pattern in stringPatterns {
            result = result.replacingOccurrences(of: pattern, with: "%@", options: .regularExpression)
        }
        
        // 某些 Android 文案使用 %f → iOS 用 %f（保持不变）
        // 其他类型可扩展
        
        return result
    }
    
    private static func escapeQuotesAndNewlines(_ value: String) -> String {
        var result = ""
        var previousChar: Character? = nil
        
        for c in value {
            if c == "\"" {
                if previousChar != "\\" {
                    result.append("\\\"")
                } else {
                    result.append("\"")
                }
            } else if c == "\n" {
                result.append("\\n")
            } else {
                result.append(c)
            }
            previousChar = c
        }
        
        return result
    }
}
