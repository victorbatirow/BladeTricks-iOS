//
//  FileSettingsService.swift
//  BladeTricks
//
//  Created by Victor on 2025-03-28.
//

import Foundation
import Combine

class SettingsService {
    // MARK: - Constants
    private enum StorageKeys {
        static let customSettings = "customDifficultySettings"
        static let selectedDifficultyLevel = "selectedDifficultyLevel"
    }
    
    // MARK: - Published properties
    private let settingsChangedSubject = PassthroughSubject<Void, Never>()
    var settingsChanged: AnyPublisher<Void, Never> {
        settingsChangedSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Singleton instance
    static let shared = SettingsService()
    
    private init() {}
    
    // MARK: - Settings Management
    
    /// Save custom difficulty settings to persistent storage
    func saveCustomSettings(_ settings: Difficulty) {
        guard let encoded = try? JSONEncoder().encode(settings) else {
            print("Error encoding custom settings")
            return
        }
        
        // Debug logging
        print("Saving custom settings: inSpin=\(settings.settings.inSpinMaxDegree)°, outSpin=\(settings.settings.outSpinMaxDegree)°, switchUp=\(settings.settings.switchUpSpinMaxDegree)°")
        
        UserDefaults.standard.set(encoded, forKey: StorageKeys.customSettings)
        settingsChangedSubject.send()
    }
    
    /// Load custom difficulty settings from persistent storage
    func loadCustomSettings() -> Difficulty? {
        guard let savedData = UserDefaults.standard.data(forKey: StorageKeys.customSettings) else {
            print("No saved custom settings found")
            return nil
        }
        
        do {
            let loadedSettings = try JSONDecoder().decode(Difficulty.self, from: savedData)
            print("Loaded custom settings: inSpin=\(loadedSettings.settings.inSpinMaxDegree)°, outSpin=\(loadedSettings.settings.outSpinMaxDegree)°, switchUp=\(loadedSettings.settings.switchUpSpinMaxDegree)°")
            return loadedSettings
        } catch {
            print("Error decoding custom settings: \(error)")
            return nil
        }
    }
    
    /// Save the selected difficulty level
    func saveSelectedDifficultyLevel(level: String) {
        print("Saving selected difficulty level: \(level)")
        UserDefaults.standard.set(level, forKey: StorageKeys.selectedDifficultyLevel)
        settingsChangedSubject.send()
    }
    
    /// Load the selected difficulty level
    func loadSelectedDifficultyLevel() -> String? {
        let level = UserDefaults.standard.string(forKey: StorageKeys.selectedDifficultyLevel)
        print("Loaded selected difficulty level: \(level ?? "nil")")
        return level
    }
    
    /// Reset all settings to default values
    func resetAllSettings() {
        UserDefaults.standard.removeObject(forKey: StorageKeys.customSettings)
        UserDefaults.standard.removeObject(forKey: StorageKeys.selectedDifficultyLevel)
        print("All settings reset to defaults")
        settingsChangedSubject.send()
    }
}
