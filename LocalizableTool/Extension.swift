//
//  Extension.swift
//  LocalizableTool
//
//  Created by zhujt on 2025/10/23.
//

import UIKit

extension UITextView {

    /// 在 TextView 中追加一条日志，带时间戳（精确到毫秒）
    /// - Parameters:
    ///   - message: 日志内容
    ///   - maxLines: 保留的最大日志条数（默认 1000）
    func appendLog(_ message: String, maxLines: Int = 1000) {
        // 1️⃣ 获取当前时间，格式化到毫秒
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        let timestamp = formatter.string(from: Date())
        
        // 2️⃣ 构建日志行
        let logLine = "[\(timestamp)] \(message)"
        
        // 3️⃣ 拆分现有内容为行数组
        var lines = self.text.components(separatedBy: "\n").filter { !$0.isEmpty }
        
        // 4️⃣ 添加新行
        lines.append(logLine)
        
        // 5️⃣ 保留最近 maxLines 条日志
        if lines.count > maxLines {
            lines = Array(lines.suffix(maxLines))
        }
        
        // 6️⃣ 拼接回文本
        self.text = lines.joined(separator: "\n")
        
        // 7️⃣ 滚动到最后
        let range = NSMakeRange(self.text.count, 0)
        self.scrollRangeToVisible(range)
    }
}
