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
    case appretice = "Appretice"
    case adept = "Adept"
    case elite = "Elite"
    case veteran = "Veteran"
    case master = "Master"
    case sage = "Sage"
    case legend = "Legend"
    case mythic = "Mythic"
}

struct Difficulty: Equatable, Identifiable {
    
    var id = UUID()
    var level: String
    var difficultyLevel: DifficultyLevel
    var settings: DifficultySettings
    var isCustom: Bool // Add this to determine if the settings are custom
    
    struct DifficultySettings : Codable {
        var difficultyStamp: String
        var fakieChance: Double
        var topsideChance: Double
        var negativeChance: Double
        var rewindOutChance: Double
        var switchUpRewindAllowed: Bool
        var tricksCAP: Int
        var soulplateForwardInSpinsCAP: Int
        var soulplateFakieInSpinsCAP: Int
        var soulplateForwardOutSpinsCAP: Int
        var soulplateFakieOutSpinsCAP: Int
        var grooveForwardInSpinsCAP: Int
        var grooveFakieInSpinsCAP: Int
        var grooveSidewaysOutSpinsCAP: Int
        var grooveFSToSoulplateSpinsCAP: Int
        var grooveBSToSoulplateSpinsCAP: Int
        var grooveFSToGrooveSpinsCAP: Int
        var grooveBSToGrooveSpinsCAP: Int
        
    }
    
    var icon: String {
        switch difficultyLevel {
        case .customSettings:
            return "IconCustom"
        case .rookie:
            return "IconLvl1"
        case .novice:
            return "IconLvl2"
        case .appretice:
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
        case .mythic:
            return "IconLvl10"
        }
    }
}

extension Difficulty {
    
    static let levels: [Difficulty] = [
        Difficulty(level: "Own", difficultyLevel: .customSettings, settings: DifficultySettings(difficultyStamp: "Custom Settings", fakieChance: 0.1, topsideChance: 0, negativeChance: 0, rewindOutChance: 0, switchUpRewindAllowed: false, tricksCAP: 3, soulplateForwardInSpinsCAP: 2, soulplateFakieInSpinsCAP: 1, soulplateForwardOutSpinsCAP: 2, soulplateFakieOutSpinsCAP: 1, grooveForwardInSpinsCAP: 1, grooveFakieInSpinsCAP: 1, grooveSidewaysOutSpinsCAP: 1, grooveFSToSoulplateSpinsCAP: 1, grooveBSToSoulplateSpinsCAP: 1, grooveFSToGrooveSpinsCAP: 1, grooveBSToGrooveSpinsCAP: 1), isCustom: true),
        Difficulty(level: "lvl. 1", difficultyLevel: .rookie, settings: DifficultySettings(difficultyStamp: "Rookie", fakieChance: 0, topsideChance: 0, negativeChance: 0, rewindOutChance: 0, switchUpRewindAllowed: false, tricksCAP: 6, soulplateForwardInSpinsCAP: 1, soulplateFakieInSpinsCAP: 1, soulplateForwardOutSpinsCAP: 1, soulplateFakieOutSpinsCAP: 1, grooveForwardInSpinsCAP: 1, grooveFakieInSpinsCAP: 1, grooveSidewaysOutSpinsCAP: 1, grooveFSToSoulplateSpinsCAP: 1, grooveBSToSoulplateSpinsCAP: 1, grooveFSToGrooveSpinsCAP: 1, grooveBSToGrooveSpinsCAP: 1), isCustom: false),
        Difficulty(level: "lvl. 2", difficultyLevel: .novice, settings: DifficultySettings(difficultyStamp: "Novice", fakieChance: 0, topsideChance: 0, negativeChance: 0, rewindOutChance: 0, switchUpRewindAllowed: false, tricksCAP: 9, soulplateForwardInSpinsCAP: 2, soulplateFakieInSpinsCAP: 1, soulplateForwardOutSpinsCAP: 1, soulplateFakieOutSpinsCAP: 1, grooveForwardInSpinsCAP: 2, grooveFakieInSpinsCAP: 1, grooveSidewaysOutSpinsCAP: 2, grooveFSToSoulplateSpinsCAP: 1, grooveBSToSoulplateSpinsCAP: 1, grooveFSToGrooveSpinsCAP: 1, grooveBSToGrooveSpinsCAP: 1), isCustom: false),
        Difficulty(level: "lvl. 3", difficultyLevel: .appretice, settings: DifficultySettings(difficultyStamp: "Appretice", fakieChance: 0.2, topsideChance: 0, negativeChance: 0, rewindOutChance: 0, switchUpRewindAllowed: false, tricksCAP: 10, soulplateForwardInSpinsCAP: 2, soulplateFakieInSpinsCAP: 2, soulplateForwardOutSpinsCAP: 2, soulplateFakieOutSpinsCAP: 2, grooveForwardInSpinsCAP:2, grooveFakieInSpinsCAP: 1, grooveSidewaysOutSpinsCAP: 2, grooveFSToSoulplateSpinsCAP: 1, grooveBSToSoulplateSpinsCAP: 1, grooveFSToGrooveSpinsCAP: 1, grooveBSToGrooveSpinsCAP: 1), isCustom: false),
        Difficulty(level: "lvl. 4", difficultyLevel: .adept, settings: DifficultySettings(difficultyStamp: "Adept", fakieChance: 0.2, topsideChance: 0.1, negativeChance: 0, rewindOutChance: 0, switchUpRewindAllowed: false, tricksCAP: 12, soulplateForwardInSpinsCAP: 2, soulplateFakieInSpinsCAP: 2, soulplateForwardOutSpinsCAP: 2, soulplateFakieOutSpinsCAP: 2, grooveForwardInSpinsCAP: 2, grooveFakieInSpinsCAP:2, grooveSidewaysOutSpinsCAP: 3, grooveFSToSoulplateSpinsCAP: 1, grooveBSToSoulplateSpinsCAP: 1, grooveFSToGrooveSpinsCAP: 1, grooveBSToGrooveSpinsCAP: 1), isCustom: false),
        Difficulty(level: "lvl. 5", difficultyLevel: .elite, settings: DifficultySettings(difficultyStamp: "Elite", fakieChance: 0.3, topsideChance: 0.2, negativeChance: 0, rewindOutChance: 0.1, switchUpRewindAllowed: false, tricksCAP: 13, soulplateForwardInSpinsCAP: 3, soulplateFakieInSpinsCAP: 3, soulplateForwardOutSpinsCAP: 2, soulplateFakieOutSpinsCAP: 1, grooveForwardInSpinsCAP: 2, grooveFakieInSpinsCAP: 2, grooveSidewaysOutSpinsCAP: 3, grooveFSToSoulplateSpinsCAP: 1, grooveBSToSoulplateSpinsCAP: 1, grooveFSToGrooveSpinsCAP: 1, grooveBSToGrooveSpinsCAP: 1), isCustom: false),
        Difficulty(level: "lvl. 6", difficultyLevel: .veteran, settings: DifficultySettings(difficultyStamp: "Veteran", fakieChance: 0.3, topsideChance: 0.3, negativeChance: 0.05, rewindOutChance: 0.15, switchUpRewindAllowed: false, tricksCAP: 13, soulplateForwardInSpinsCAP: 3, soulplateFakieInSpinsCAP: 3, soulplateForwardOutSpinsCAP: 2, soulplateFakieOutSpinsCAP: 2, grooveForwardInSpinsCAP: 2, grooveFakieInSpinsCAP: 3, grooveSidewaysOutSpinsCAP: 4, grooveFSToSoulplateSpinsCAP: 1, grooveBSToSoulplateSpinsCAP: 1, grooveFSToGrooveSpinsCAP: 1, grooveBSToGrooveSpinsCAP: 1), isCustom: false),
        Difficulty(level: "lvl. 7", difficultyLevel: .master, settings: DifficultySettings(difficultyStamp: "Master", fakieChance: 0.4, topsideChance: 0.4, negativeChance: 0.05, rewindOutChance: 0.2, switchUpRewindAllowed: false, tricksCAP: 16, soulplateForwardInSpinsCAP: 3, soulplateFakieInSpinsCAP: 4, soulplateForwardOutSpinsCAP: 2, soulplateFakieOutSpinsCAP: 1, grooveForwardInSpinsCAP: 3, grooveFakieInSpinsCAP: 3, grooveSidewaysOutSpinsCAP: 5, grooveFSToSoulplateSpinsCAP: 1, grooveBSToSoulplateSpinsCAP: 1, grooveFSToGrooveSpinsCAP: 1, grooveBSToGrooveSpinsCAP: 1), isCustom: false),
        Difficulty(level: "lvl. 8", difficultyLevel: .sage, settings: DifficultySettings(difficultyStamp: "Sage", fakieChance: 0.4, topsideChance: 0.5, negativeChance: 0.075, rewindOutChance: 0.25, switchUpRewindAllowed: false, tricksCAP: 19, soulplateForwardInSpinsCAP: 4, soulplateFakieInSpinsCAP: 4, soulplateForwardOutSpinsCAP: 2, soulplateFakieOutSpinsCAP: 1, grooveForwardInSpinsCAP: 3, grooveFakieInSpinsCAP: 3, grooveSidewaysOutSpinsCAP: 5, grooveFSToSoulplateSpinsCAP: 1, grooveBSToSoulplateSpinsCAP: 1, grooveFSToGrooveSpinsCAP: 1, grooveBSToGrooveSpinsCAP: 1), isCustom: false),
        Difficulty(level: "lvl. 9", difficultyLevel: .legend, settings: DifficultySettings(difficultyStamp: "Legend", fakieChance: 0.5, topsideChance: 0.5, negativeChance: 0.10, rewindOutChance: 0.3, switchUpRewindAllowed: false, tricksCAP: 21, soulplateForwardInSpinsCAP: 4, soulplateFakieInSpinsCAP: 5, soulplateForwardOutSpinsCAP: 3, soulplateFakieOutSpinsCAP: 3, grooveForwardInSpinsCAP: 6, grooveFakieInSpinsCAP: 6, grooveSidewaysOutSpinsCAP: 6, grooveFSToSoulplateSpinsCAP: 6, grooveBSToSoulplateSpinsCAP: 6, grooveFSToGrooveSpinsCAP: 3, grooveBSToGrooveSpinsCAP: 3), isCustom: false),
        Difficulty(level: "lvl. 10", difficultyLevel: .mythic, settings: DifficultySettings(difficultyStamp: "Mythic", fakieChance: 0.5, topsideChance: 0.5, negativeChance: 0.20, rewindOutChance: 0.4, switchUpRewindAllowed: true, tricksCAP: 22, soulplateForwardInSpinsCAP: 5, soulplateFakieInSpinsCAP: 5, soulplateForwardOutSpinsCAP: 3, soulplateFakieOutSpinsCAP: 3, grooveForwardInSpinsCAP: 6, grooveFakieInSpinsCAP: 6, grooveSidewaysOutSpinsCAP: 6, grooveFSToSoulplateSpinsCAP: 6, grooveBSToSoulplateSpinsCAP: 6, grooveFSToGrooveSpinsCAP: 3, grooveBSToGrooveSpinsCAP: 3), isCustom: false)
    ]
}

extension Difficulty.DifficultySettings: Equatable {}
