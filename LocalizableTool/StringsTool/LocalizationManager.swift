//
//  LocalizationManager.swift
//  LocalizableTool
//
//  Created by zhujt on 2025/9/16.
//

import Foundation

let LM = LocalizationManager.shared

class LocalizationManager {
    static let shared = LocalizationManager()
    
    var entries: [LocalizationEntry] = []
    var languages: [String] = []
    
    var baseLanguage = "en" {
        didSet {
            baseLanguageKeys = loadLanguageKeys(with: baseLanguage)
        }
    }
    
    var baseLanguageKeys = Set<String>()
    
    func loadLocalized(with folder: URL) {
        let loader = LocalizationLoader()
        (self.entries, self.languages) = loader.loadLocalization(from: folder)
    }
    
    func loadLanguageKeys(with languageCode: String) -> Set<String> {
        var langKeys = Set<String>()
        for entry in entries {
            if entry.values.keys.contains(languageCode), let _ = entry.values[languageCode] {
                langKeys.insert(entry.key)
            }
        }
        return langKeys
    }
}
