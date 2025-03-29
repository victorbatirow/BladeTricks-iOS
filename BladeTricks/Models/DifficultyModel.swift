//
//  DifficultyModel.swift
//  BladeTricks
//
//  Created by Victor on 2024-04-28.
//

import Foundation

enum DifficultyLevel: String, Codable, CaseIterable {
    case customSettings = "Custom Settings"
    case rookie = "Rookie"
    case novice = "Novice"
    case apprentice = "Apprentice"
    case adept = "Adept"
    case elite = "Elite"
    case veteran = "Veteran"
    case master = "Master"
    case sage = "Sage"
    case legend = "Legend"
    case myth = "Myth"
    
    // Helper to get numeric difficulty level (1-10) for preset difficulties
    var numericLevel: Int {
        switch self {
        case .customSettings: return 0  // Special case handled separately
        case .rookie: return 1
        case .novice: return 2
        case .apprentice: return 3
        case .adept: return 4
        case .elite: return 5
        case .veteran: return 6
        case .master: return 7
        case .sage: return 8
        case .legend: return 9
        case .myth: return 10
        }
    }
}

struct Difficulty: Equatable, Identifiable, Codable {
    
    var id = UUID()
    var level: String
    var difficultyLevel: DifficultyLevel
    var settings: DifficultySettings
    var isCustom: Bool // Determines if the settings are custom
    
    // Helper to get numeric difficulty level (1-10)
    var numericLevel: Int {
        if isCustom {
            return 10 // Custom settings can access everything by default
        } else {
            return difficultyLevel.numericLevel
        }
    }
    
    struct DifficultySettings: Codable, Equatable {
        var difficultyStamp: String
        var fakieChance: Double
        var topsideChance: Double
        var negativeChance: Double
        var rewindOutChance: Double
        var switchUpRewindAllowed: Bool
        var tricksCAP: Int
        
        // Max degree settings for custom settings mode
        var inSpinMaxDegree: Int = 180
        var outSpinMaxDegree: Int = 180
        var switchUpSpinMaxDegree: Int = 180
    }
    
    var icon: String {
        switch difficultyLevel {
        case .customSettings:
            return "IconCustom"
        case .rookie:
            return "IconLvl1"
        case .novice:
            return "IconLvl2"
        case .apprentice:
            return "IconLvl3"
        case .adept:
            return "IconLvl4"
        case .elite:
            return "IconLvl5"
        case .veteran:
            return "IconLvl6"
        case .master:
            return "IconLvl7"
        case .sage:
            return "IconLvl8"
        case .legend:
            return "IconLvl9"
        case .myth:
            return "IconLvl10"
        }
    }
}

extension Difficulty {
    // Default template with reasonable starting values
    static let customTemplate = Difficulty(
        level: "Own",
        difficultyLevel: .customSettings,
        settings: DifficultySettings(
            difficultyStamp: "Custom Settings",
            fakieChance: 0,
            topsideChance: 0,
            negativeChance: 0,
            rewindOutChance: 0,
            switchUpRewindAllowed: false,
            tricksCAP: 6,
            inSpinMaxDegree: 180,
            outSpinMaxDegree: 180,
            switchUpSpinMaxDegree: 180
        ),
        isCustom: true
    )
    
    // All predefined levels (excluding custom)
    static let predefinedLevels: [Difficulty] = [
        Difficulty(level: "lvl. 1", difficultyLevel: .rookie, settings: DifficultySettings(
            difficultyStamp: "Rookie",
            fakieChance: 0,
            topsideChance: 0,
            negativeChance: 0,
            rewindOutChance: 0,
            switchUpRewindAllowed: false,
            tricksCAP: 6,
            inSpinMaxDegree: 180,
            outSpinMaxDegree: 180,
            switchUpSpinMaxDegree: 90
        ), isCustom: false),
        
        Difficulty(level: "lvl. 2", difficultyLevel: .novice, settings: DifficultySettings(
            difficultyStamp: "Novice",
            fakieChance: 0,
            topsideChance: 0,
            negativeChance: 0,
            rewindOutChance: 0,
            switchUpRewindAllowed: false,
            tricksCAP: 9,
            inSpinMaxDegree: 180,
            outSpinMaxDegree: 180,
            switchUpSpinMaxDegree: 180
        ), isCustom: false),
        
        Difficulty(level: "lvl. 3", difficultyLevel: .apprentice, settings: DifficultySettings(
            difficultyStamp: "Apprentice",
            fakieChance: 0.2,
            topsideChance: 0,
            negativeChance: 0,
            rewindOutChance: 0,
            switchUpRewindAllowed: false,
            tricksCAP: 10,
            inSpinMaxDegree: 180,
            outSpinMaxDegree: 180,
            switchUpSpinMaxDegree: 180
        ), isCustom: false),
        
        Difficulty(level: "lvl. 4", difficultyLevel: .adept, settings: DifficultySettings(
            difficultyStamp: "Adept",
            fakieChance: 0.25,
            topsideChance: 0.1,
            negativeChance: 0,
            rewindOutChance: 0,
            switchUpRewindAllowed: false,
            tricksCAP: 12,
            inSpinMaxDegree: 270,
            outSpinMaxDegree: 270,
            switchUpSpinMaxDegree: 270
        ), isCustom: false),
        
        Difficulty(level: "lvl. 5", difficultyLevel: .elite, settings: DifficultySettings(
            difficultyStamp: "Elite",
            fakieChance: 0.3,
            topsideChance: 0.2,
            negativeChance: 0,
            rewindOutChance: 0.1,
            switchUpRewindAllowed: true,
            tricksCAP: 13,
            inSpinMaxDegree: 360,
            outSpinMaxDegree: 270,
            switchUpSpinMaxDegree: 270
        ), isCustom: false),
        
        Difficulty(level: "lvl. 6", difficultyLevel: .veteran, settings: DifficultySettings(
            difficultyStamp: "Veteran",
            fakieChance: 0.35,
            topsideChance: 0.3,
            negativeChance: 0.05,
            rewindOutChance: 0.15,
            switchUpRewindAllowed: true,
            tricksCAP: 13,
            inSpinMaxDegree: 360,
            outSpinMaxDegree: 360,
            switchUpSpinMaxDegree: 360
        ), isCustom: false),
        
        Difficulty(level: "lvl. 7", difficultyLevel: .master, settings: DifficultySettings(
            difficultyStamp: "Master",
            fakieChance: 0.4,
            topsideChance: 0.4,
            negativeChance: 0.05,
            rewindOutChance: 0.2,
            switchUpRewindAllowed: true,
            tricksCAP: 16,
            inSpinMaxDegree: 450,
            outSpinMaxDegree: 360,
            switchUpSpinMaxDegree: 360
        ), isCustom: false),
        
        Difficulty(level: "lvl. 8", difficultyLevel: .sage, settings: DifficultySettings(
            difficultyStamp: "Sage",
            fakieChance: 0.4,
            topsideChance: 0.5,
            negativeChance: 0.075,
            rewindOutChance: 0.25,
            switchUpRewindAllowed: true,
            tricksCAP: 19,
            inSpinMaxDegree: 450,
            outSpinMaxDegree: 450,
            switchUpSpinMaxDegree: 450
        ), isCustom: false),
        
        Difficulty(level: "lvl. 9", difficultyLevel: .legend, settings: DifficultySettings(
            difficultyStamp: "Legend",
            fakieChance: 0.5,
            topsideChance: 0.5,
            negativeChance: 0.10,
            rewindOutChance: 0.3,
            switchUpRewindAllowed: true,
            tricksCAP: 21,
            inSpinMaxDegree: 540,
            outSpinMaxDegree: 450,
            switchUpSpinMaxDegree: 450
        ), isCustom: false),
        
        Difficulty(level: "lvl. 10", difficultyLevel: .myth, settings: DifficultySettings(
            difficultyStamp: "Myth",
            fakieChance: 0.5,
            topsideChance: 0.5,
            negativeChance: 0.20,
            rewindOutChance: 0.4,
            switchUpRewindAllowed: true,
            tricksCAP: 22,
            inSpinMaxDegree: 540,
            outSpinMaxDegree: 540,
            switchUpSpinMaxDegree: 540
        ), isCustom: false)
    ]
    
    // Combined list for UI display
    static var levels: [Difficulty] {
        let customSettings = SettingsService.shared.loadCustomSettings() ?? customTemplate
        return [customSettings] + predefinedLevels
    }
    
    // Get the current custom settings (for editing)
    static var currentCustomSettings: Difficulty {
        return SettingsService.shared.loadCustomSettings() ?? customTemplate
    }
    
    // Update custom settings
    static func updateCustomSettings(_ updatedSettings: Difficulty) {
        var settings = updatedSettings
        settings.isCustom = true
        settings.difficultyLevel = .customSettings
        SettingsService.shared.saveCustomSettings(settings)
    }
}
