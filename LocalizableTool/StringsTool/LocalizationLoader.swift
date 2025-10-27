//
//  LocalizationLoader.swift
//  LocalizableTool
//
//  Created by zhujt on 2025/9/15.
//

import Foundation

class LocalizationLoader {
    func loadLocalization(from rootURL: URL) -> ([LocalizationEntry], [String]) {
        let fileManager = FileManager.default
        guard let langsDir = try? fileManager.contentsOfDirectory(atPath: rootURL.path).filter({ $0.hasSuffix(".lproj") }) else {
            return ([], [])
        }
        let langs = langsDir.map({$0.replacingOccurrences(of: ".lproj", with: "")})
        var langDicts = [String: [String: String]]()
        for lang in langs {
            let fileURL = rootURL.appendingPathComponent("\(lang).lproj/Localizable.strings")
            langDicts[lang] = StringsFileParser.parseStringsFile(at: fileURL)
        }

        guard let enDict = langDicts["en"] else { return ([], []) }

        let languages = ["en"] + langs.filter { $0 != "en" }

        var entries: [LocalizationEntry] = []
        for key in enDict.keys {
            var values = [String: String]()
            for lang in languages {
                values[lang] = langDicts[lang]?[key]
            }
            entries.append(LocalizationEntry(key: key, values: values))
        }

        return (entries.sorted { $0.key < $1.key }, languages)
    }
}
