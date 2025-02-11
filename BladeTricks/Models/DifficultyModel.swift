//
//  DifficultyModel.swift
//  BladeTricks
//
//  Created by Victor on 2024-04-28.
//

import Foundation

enum DifficultyLevel: String, CaseIterable {
    case aleatory = "aleatory"
    case rookie = "Rookie"
    case apprentice = "Apprentice"
    case initiate = "Initiate"
    case adept = "Adept"
    case elite = "Elite"
    case veteran = "Veteran"
    case master = "Master"
    case sage = "Sage"
    case legend = "Legend"
    case myth = "Myth"
}

struct Difficulty: Equatable, Identifiable {
    
    var id = UUID()
    var level: String
    var difficultyLevel: DifficultyLevel
    var probability: Int
    var settings: DifficultySettings
    
    struct DifficultySettings {
            var difficultyStamp: String
            var fakieChance: Double
            var topsideChance: Double
            var negativeChance: Double
            var rewindChance: Double
            var tricksCAP: Int
            var soulplateForwardInSpinsCAP: Int
            var soulplateFakieInSpinsCAP: Int
            var soulplateForwardOutSpinsCAP: Int
            var soulplateFakieOutSpinsCAP: Int
            var grooveForwardInSpinsCAP: Int
            var grooveFakieInSpinsCAP: Int
            var grooveSidewaysOutSpinsCAP: Int
            
        }
    
    var icon: String {
        switch difficultyLevel {
        case .aleatory:
            return "custom"
        case .rookie:
            return "IconLvl1"
        case .apprentice:
            return "IconLvl2"
        case .initiate:
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
//    static let hour: TimeInterval = 60 * 60
//    static let day: TimeInterval = 60 * 60 * 24
    
    static let levels: [Difficulty] = [
//        Difficulty(level: "lvl. ?", difficultyLevel: .aleatory, probability: 0, settings: DifficultySettings(difficultyStamp: "Aleatory", fakieChance: 0.1, topsideChance: 0.1, negativeChance: 0.05, rewindChance: 0.1, tricksCAP: 10, soulplateForwardInSpinsCAP: 2, soulplateFakieInSpinsCAP: 1, soulplateForwardOutSpinsCAP: 2, soulplateFakieOutSpinsCAP: 1, grooveForwardInSpinsCAP: 1, grooveFakieInSpinsCAP: 1, grooveSidewaysOutSpinsCAP: 1)),
        Difficulty(level: "lvl. 1", difficultyLevel: .rookie, probability: 0, settings: DifficultySettings(difficultyStamp: "Rookie", fakieChance: 0, topsideChance: 0, negativeChance: 0, rewindChance: 0, tricksCAP: 6, soulplateForwardInSpinsCAP: 1, soulplateFakieInSpinsCAP: 1, soulplateForwardOutSpinsCAP: 1, soulplateFakieOutSpinsCAP: 1, grooveForwardInSpinsCAP: 1, grooveFakieInSpinsCAP: 1, grooveSidewaysOutSpinsCAP: 1)),
        Difficulty(level: "lvl. 2", difficultyLevel: .apprentice, probability: 0, settings: DifficultySettings(difficultyStamp: "Appretice", fakieChance: 0, topsideChance: 0, negativeChance: 0, rewindChance: 0, tricksCAP: 9, soulplateForwardInSpinsCAP: 2, soulplateFakieInSpinsCAP: 1, soulplateForwardOutSpinsCAP: 1, soulplateFakieOutSpinsCAP: 1, grooveForwardInSpinsCAP: 2, grooveFakieInSpinsCAP: 1, grooveSidewaysOutSpinsCAP: 2)),
        Difficulty(level: "lvl. 3", difficultyLevel: .initiate, probability: 0, settings: DifficultySettings(difficultyStamp: "Initiate", fakieChance: 0.2, topsideChance: 0, negativeChance: 0, rewindChance: 0, tricksCAP: 10, soulplateForwardInSpinsCAP: 2, soulplateFakieInSpinsCAP: 2, soulplateForwardOutSpinsCAP: 2, soulplateFakieOutSpinsCAP: 2, grooveForwardInSpinsCAP:2, grooveFakieInSpinsCAP: 1, grooveSidewaysOutSpinsCAP: 2)),
        Difficulty(level: "lvl. 4", difficultyLevel: .adept, probability: 0, settings: DifficultySettings(difficultyStamp: "Adept", fakieChance: 0.2, topsideChance: 0.1, negativeChance: 0, rewindChance: 0, tricksCAP: 12, soulplateForwardInSpinsCAP: 2, soulplateFakieInSpinsCAP: 2, soulplateForwardOutSpinsCAP: 2, soulplateFakieOutSpinsCAP: 2, grooveForwardInSpinsCAP: 2, grooveFakieInSpinsCAP:2, grooveSidewaysOutSpinsCAP: 3)),
        Difficulty(level: "lvl. 5", difficultyLevel: .elite, probability: 0, settings: DifficultySettings(difficultyStamp: "Elite", fakieChance: 0.3, topsideChance: 0.2, negativeChance: 0, rewindChance: 0.1, tricksCAP: 13, soulplateForwardInSpinsCAP: 3, soulplateFakieInSpinsCAP: 3, soulplateForwardOutSpinsCAP: 2, soulplateFakieOutSpinsCAP: 1, grooveForwardInSpinsCAP: 2, grooveFakieInSpinsCAP: 2, grooveSidewaysOutSpinsCAP: 3)),
        Difficulty(level: "lvl. 6", difficultyLevel: .veteran, probability: 0, settings: DifficultySettings(difficultyStamp: "Veteran", fakieChance: 0.3, topsideChance: 0.3, negativeChance: 0.05, rewindChance: 0.15, tricksCAP: 13, soulplateForwardInSpinsCAP: 3, soulplateFakieInSpinsCAP: 3, soulplateForwardOutSpinsCAP: 2, soulplateFakieOutSpinsCAP: 2, grooveForwardInSpinsCAP: 2, grooveFakieInSpinsCAP: 3, grooveSidewaysOutSpinsCAP: 4)),
        Difficulty(level: "lvl. 7", difficultyLevel: .master, probability: 0, settings: DifficultySettings(difficultyStamp: "Master", fakieChance: 0.4, topsideChance: 0.4, negativeChance: 0.05, rewindChance: 0.2, tricksCAP: 16, soulplateForwardInSpinsCAP: 3, soulplateFakieInSpinsCAP: 4, soulplateForwardOutSpinsCAP: 2, soulplateFakieOutSpinsCAP: 1, grooveForwardInSpinsCAP: 3, grooveFakieInSpinsCAP: 3, grooveSidewaysOutSpinsCAP: 5)),
        Difficulty(level: "lvl. 8", difficultyLevel: .sage, probability: 0, settings: DifficultySettings(difficultyStamp: "Sage", fakieChance: 0.4, topsideChance: 0.5, negativeChance: 0.07, rewindChance: 0.25, tricksCAP: 19, soulplateForwardInSpinsCAP: 4, soulplateFakieInSpinsCAP: 4, soulplateForwardOutSpinsCAP: 2, soulplateFakieOutSpinsCAP: 1, grooveForwardInSpinsCAP: 3, grooveFakieInSpinsCAP: 3, grooveSidewaysOutSpinsCAP: 5)),
        Difficulty(level: "lvl. 9", difficultyLevel: .legend, probability: 0, settings: DifficultySettings(difficultyStamp: "Legend", fakieChance: 0.5, topsideChance: 0.5, negativeChance: 0.10, rewindChance: 0.3, tricksCAP: 21, soulplateForwardInSpinsCAP: 4, soulplateFakieInSpinsCAP: 5, soulplateForwardOutSpinsCAP: 3, soulplateFakieOutSpinsCAP: 3, grooveForwardInSpinsCAP: 3, grooveFakieInSpinsCAP: 4, grooveSidewaysOutSpinsCAP: 6)),
        Difficulty(level: "lvl. 10", difficultyLevel: .myth, probability: 0, settings: DifficultySettings(difficultyStamp: "Myth", fakieChance: 0.5, topsideChance: 0.5, negativeChance: 0.20, rewindChance: 0.4, tricksCAP: 22, soulplateForwardInSpinsCAP: 5, soulplateFakieInSpinsCAP: 5, soulplateForwardOutSpinsCAP: 3, soulplateFakieOutSpinsCAP: 3, grooveForwardInSpinsCAP: 4, grooveFakieInSpinsCAP: 4, grooveSidewaysOutSpinsCAP: 6))
            
    ]
    
//    static let daily: [Forecast] = [
//        Forecast(date: "Lvl. 1", weather: .rainy, probability: 30, temperature: 19, high: 24, low: 18, location: "Montreal, Canada"),
//        Forecast(date: "Lvl. 2", weather: .rainy, probability: 0, temperature: 19, high: 24, low: 18, location: "Montreal, Canada"),
//        Forecast(date: "Lvl. 3", weather: .stormy, probability: 100, temperature: 19, high: 24, low: 18, location: "Montreal, Canada"),
//        Forecast(date: "Lvl. 4", weather: .stormy, probability: 50, temperature: 18, high: 24, low: 18, location: "Montreal, Canada"),
//        Forecast(date: "Lvl. 5", weather: .rainy, probability: 0, temperature: 19, high: 24, low: 18, location: "Montreal, Canada"),
//        Forecast(date: "Lvl. 6", weather: .rainy, probability: 0, temperature: 19, high: 24, low: 18, location: "Montreal, Canada"),
//        Forecast(date: "Lvl. 7", weather: .rainy, probability: 0, temperature: 19, high: 24, low: 18, location: "Montreal, Canada")
//    ]
    
//    static let cities: [Forecast] = [
//        Forecast(date: "Lvl. 1", weather: .rainy, probability: 0, temperature: 19, high: 24, low: 18, location: "Montreal, Canada"),
//        Forecast(date: "Lvl. 2", weather: .windy, probability: 0, temperature: 20, high: 21, low: 19, location: "Toronto, Canada"),
//        Forecast(date: "Lvl. 3", weather: .stormy, probability: 0, temperature: 13, high: 16, low: 8, location: "Tokyo, Japan"),
//        Forecast(date: "Lvl. 4", weather: .tornado, probability: 0, temperature: 23, high: 26, low: 16, location: "Tennessee, United States")
//    ]
}

extension Difficulty.DifficultySettings: Equatable {}
