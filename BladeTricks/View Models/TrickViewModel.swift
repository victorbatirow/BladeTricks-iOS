//
//  TrickViewModel.swift
//  BladeTricks
//
//  Created by Victor on 2024-04-28.
//

// IDEA: new difficulty system control
// have a number for difficulty for each array, where the difficulty number is goes as length of array
// var trick = allTricks[Math.floor(Math.random()*allTricks.trickDifficulty )];


// TRICKS TO ADD:
// - Something is wrong with the misfits
//      -- zero spin top mistrail makes no sense
//      -- also  check the true  spin and cabs into misfits
// - Rough and Tough soulgrind variations (check book of grinds)
//      -- create isRough/isTough and roughStamp/toughStamp variables
//      -- this should apply to soulplate grinds only
//      -- make a choose rough/tough section, just like choose topside
//      -- if list of soulplate grinds contains the trick, randomly set rough or tough options
//      -- add roughStamp/toughStamp to the final step (set trick name)
// - Switch grind variations
//      -- create isSwitch and switchStamp variables
//      -- make a choose switch section, just like choose topside
//      -- add switchStamp to the final step (set trick name)
// - Grabbed grinds (only for one footed tricks)
//      -- create isGrabbed and grabStamp variables
//      -- make an array of grabbable grinds
//      -- make a choose grab section, just like choose topside
//      -- if list of grabbable grinds contains the trick, randomly set grab to true or false
//      -- add grabStamp to the final step (set trick name)
// - Illusion spins
// - Step Overs (would require next level logic for foot positions awareness)
// - Med spins
// - Quarter pipe option
//      -- A simple checkbox. if true, skater is skating a quarter pipe
//      -- Adjust spins in and out
//          --- Example:
//          --- Bs royale 270 to forward out - BECOMES -> Bs royale 360 out
//
// Fahrvergnugen

import Foundation
import Combine

class TrickViewModel: ObservableObject {
    
    // CONSTANTS: Trick Names -- Order: easy to hard
    let allTricks = ["Makio", "Grind", "Soul", "Mizou", "Porn Star", "Acid", "Fahrv", "Royale", "Unity", "X-Grind", "Torque Soul", "Mistrail", "Savannah", "UFO", "Torque", "Backslide", "Cab Driver", "Christ Makio", "Fastslide", "Stub Soul", "Tea Kettle", "Pudslide"]
    let soulplateTricks = ["Makio", "Soul", "Mizou", "Porn Star", "Acid", "X-Grind", "Torque Soul", "Mistrail", "Christ Makio", "Stub Soul", "Tea Kettle"]
    let grooveTricks = ["Grind", "Fahrvergnugen ", "Royale", "Unity", "Savannah", "Torque", "Backslide", "Cab Driver", "UFO", "Fastslide", "Pudslide"]
    let topsideNegativeTricks = ["Makio", "Soul", "Mizou", "Porn Star", "Acid", "Torque Soul", "Mistrail", "Christ Makio"]
    
    // CONSTANTS: Spins -- Order: easy to hard
    let soulplateForwardInSpins = ["", "Alley-Oop", "True Spin", "360", "Hurricane"]
    let soulplateFakieInSpins = ["In-Spin", "Out-Spin", "Zero Spin", "Cab Alley-Oop", "Cab True Spin"]
    let soulplateForwardOutSpins = ["", "to Fakie", "360 Out"]
    let soulplateFakieOutSpins = ["", "to Forward", "Cab Out"]
    let grooveForwardInSpins = ["FS", "BS", "270 BS", "270 FS"]
    let grooveFakieInSpins = ["FS", "BS", "270 BS", "270 FS"]
    let grooveSidewaysOutSpins = ["to Fakie", "to Forward", "270 Out", "270 Out to Fakie", "270 Out to Forward", "450 Out"]
    
    
    @Published var displayTrickName: String = "Press the button to generate a trick."
    @Published var currentDifficulty: Difficulty = Difficulty.levels[0]  // Default to first difficulty
    @Published var customSettings: Difficulty.DifficultySettings
    private var lastTricks: [String] = []  // This array will store the history of generated tricks


    init() {
        let defaultDifficulty = Difficulty.levels[0] // Default to first difficulty
        self.currentDifficulty = defaultDifficulty
        self.customSettings = defaultDifficulty.settings // Temporarily initialize with default settings

        // Now that all properties are initialized, you can safely use instance methods
        self.customSettings = loadCustomSettings() ?? defaultDifficulty.settings // Load custom settings or default

        let savedDifficultyLevel = UserDefaults.standard.string(forKey: "selectedDifficultyLevel") ?? defaultDifficulty.level
        if let savedDifficulty = Difficulty.levels.first(where: {$0.level == savedDifficultyLevel}) {
            currentDifficulty = savedDifficulty
        }
    }
    
    func loadCustomSettings() -> Difficulty.DifficultySettings? {
        if let settingsData = UserDefaults.standard.data(forKey: "customSettings"),
           let settings = try? JSONDecoder().decode(Difficulty.DifficultySettings.self, from: settingsData) {
            return settings
        }
        return nil
    }
    
    func saveCustomSettings() {
        if let settingsData = try? JSONEncoder().encode(customSettings) {
            UserDefaults.standard.set(settingsData, forKey: "customSettings")
        }
    }
    
    func applyCustomSettings() {
            currentDifficulty.settings = customSettings
            saveCustomSettings()
        }
    
    func generateTrick() {
        var uniqueTrickFound = false
        var newTrickName = ""
        
        while !uniqueTrickFound {
            // Generate a trick
            newTrickName = generateTrickName()  // Assuming this function generates the full trick name

            // Check if the trick has been generated in the last three attempts
            if !lastTricks.contains(newTrickName) {
                uniqueTrickFound = true
                lastTricks.append(newTrickName)
                
                // Keep only the last three entries in the history
                if lastTricks.count > 3 {
                    lastTricks.removeFirst()
                }
            } else {
                print("repeated trick found, re-generating....")
            }
        }
        
        displayTrickName = newTrickName
    }
    
    private func generateTrickName() -> String {
        
        // CONSTANTS: Trick Names -- Order: easy to hard
        let allTricks = ["Makio", "Grind", "Soul", "Mizou", "Porn Star", "Acid", "Fahrv", "Royale", "Unity", "X-Grind", "Torque Soul", "Mistrail", "Savannah", "UFO", "Torque", "Backslide", "Cab Driver", "Christ Makio", "Fastslide", "Stub Soul", "Tea Kettle", "Pudslide"]
        let soulplateTricks = ["Makio", "Soul", "Mizou", "Porn Star", "Acid", "X-Grind", "Torque Soul", "Mistrail", "Christ Makio", "Stub Soul", "Tea Kettle"]
        let grooveTricks = ["Grind", "Fahrvergnugen ", "Royale", "Unity", "Savannah", "Torque", "Backslide", "Cab Driver", "UFO", "Fastslide", "Pudslide"]
        let topsideNegativeTricks = ["Makio", "Soul", "Mizou", "Porn Star", "Acid", "Torque Soul", "Mistrail", "Christ Makio"]
        
        // CONSTANTS: Spins -- Order: easy to hard
        let soulplateForwardInSpins = ["", "Alley-Oop", "True Spin", "360", "Hurricane"]
        let soulplateFakieInSpins = ["In-Spin", "Out-Spin", "Zero Spin", "Cab Alley-Oop", "Cab True Spin"]
        let soulplateForwardOutSpins = ["", "to Fakie", "360 Out"]
        let soulplateFakieOutSpins = ["", "to Forward", "Cab Out"]
        let grooveForwardInSpins = ["FS", "BS", "270 BS", "270 FS"]
        let grooveFakieInSpins = ["FS", "BS", "270 BS", "270 FS"]
        let grooveSidewaysOutSpins = ["to Fakie", "to Forward", "270 Out", "270 Out to Fakie", "270 Out to Forward", "450 Out"]
        
        // Game Difficulty Options
        var difficulty: Double = 0.8

        // TRICK NAME DISPLAYED VARIABLES
        var trickName: String = ""
        var spinIn: String = ""
        var fakieStamp: String = ""
        var topsideStamp: String = ""
        var negativeStamp: String = ""
        var rewindStamp: String = ""
        var spinOut: String = ""
        var difficultyStamp: String = "Noob"

        // Difficulty Option System
//        var fakieChance: Double = 0.5
//        var topsideChance: Double = 0.7
//        var negativeChance: Double = 0.2
//        var rewindChance: Double = 0.25
//
//        var tricksCAP: Int = 22
//        var soulplateForwardInSpinsCAP: Int = 5
//        var soulplateFakieInSpinsCAP: Int = 5
//        var soulplateForwardOutSpinsCAP: Int = 3
//        var soulplateFakieOutSpinsCAP: Int = 3
//        var grooveForwardInSpinsCAP: Int = 4
//        var grooveFakieInSpinsCAP: Int = 4
//        var grooveSidewaysOutSpinsCAP: Int = 6
        let settings = currentDifficulty.settings
        let fakieChance = settings.fakieChance
        let topsideChance = settings.topsideChance
        var negativeChance = settings.negativeChance
        let rewindChance = settings.rewindChance
        let tricksCAP = settings.tricksCAP
        let soulplateForwardInSpinsCAP = settings.soulplateForwardInSpinsCAP
        let soulplateFakieInSpinsCAP = settings.soulplateFakieInSpinsCAP
        let soulplateForwardOutSpinsCAP = settings.soulplateForwardOutSpinsCAP
        let soulplateFakieOutSpinsCAP = settings.soulplateFakieOutSpinsCAP
        let grooveForwardInSpinsCAP = settings.grooveForwardInSpinsCAP
        let grooveFakieInSpinsCAP = settings.grooveFakieInSpinsCAP
        let grooveSidewaysOutSpinsCAP = settings.grooveSidewaysOutSpinsCAP

        
        // TRICK VARIATIONS (move to inside function)
        var isFakie: Bool = false
        var isTopside: Bool = false
        var isNegative: Bool = false
        var isRewind: Bool = false

        // Skater's current stance during a trick
        var currentStance: String = "Forward"

        
//            print("\n\n- Fakie chance: \(fakieChance * 100)%")
//            print("- Topside chance: \(topsideChance * 100)%")
//            print("- Negative chance: \(negativeChance * 100)%")
//            print("- Rewind chance: \t\(rewindChance * 100)%")
//            print("TRICKS CAP IS::: \(tricksCAP)")
        // Choose a soulplate or groove trick (this wil determine the spin, topside and negative options) - Difficulty applied
        var trick = allTricks[Int.random(in: 0..<tricksCAP)]

        // Find out if the chosen trick is done with soul plate
        if soulplateTricks.contains(trick) {
            // SOULPLATE TRICK CHOSEN !!!
            print("SOULPLATE TRICK CHOSEN!!!")
            
            // 1.1 Choose Fakie
            // Set the Fakie chance according to difficulty
            isFakie = (Double.random(in: 0...1) < fakieChance)
            if isFakie {
                currentStance = "Fakie"
                fakieStamp = "Fakie"
            } else {
                currentStance = "Forward"
                fakieStamp = ""
            }
            
            // 1.2 Choose Spin in
            if currentStance == "Fakie" {
                // Choose a spin from the list according to the difficulty
                spinIn = soulplateFakieInSpins[Int.random(in: 0..<soulplateFakieInSpinsCAP)]
                // Update the skater's current stance
                if spinIn == "In-Spin" || spinIn == "Out-Spin" {
                    currentStance = "Forward"
                }
            } else if currentStance == "Forward" {
                // Choose a spin from the list according to the difficulty
                spinIn = soulplateForwardInSpins[Int.random(in: 0..<soulplateForwardInSpinsCAP)]
                // Update the skater's current stance
                if spinIn == "Alley-Oop" || spinIn == "True Spin" {
                    currentStance = "Fakie"
                }
            }
            
            // 1.3 Choose topside
            if topsideNegativeTricks.contains(trick) {
                // Set the topside according to topside chance
                isTopside = (Double.random(in: 0...1) < topsideChance)
                // Update the topside stamp
                if isTopside {
                    topsideStamp = " Top"
                } else {
                    topsideStamp = ""
                }
            }
            
            // 1.4 Choose Negative
            if topsideNegativeTricks.contains(trick) {
                //Reduce chance of negative if trick is topside
                if isTopside && negativeChance != 0 {
                    negativeChance = 0.05
                }
                // Set the topside chance according to difficulty
                isNegative = (Double.random(in: 0...1) < negativeChance)
                // Update the negative stamp
                if isNegative {
                    negativeStamp = " Negative"
                } else {
                    negativeStamp = ""
                }
                // Cancel negative + topsides unless in God difficulty
                if difficulty <= 79 && isTopside && isNegative {
                    negativeStamp = ""
                }
            }
            
            // 1.5 Choose Spin Out
            if currentStance == "Fakie" {
                spinOut = soulplateFakieOutSpins[Int.random(in: 0..<soulplateFakieOutSpinsCAP)]
                // Update the skater's current stance
                if spinOut == "to Forward" {
                    currentStance = "Forward"
                }
            } else {
                spinOut = soulplateForwardOutSpins[Int.random(in: 0..<soulplateForwardOutSpinsCAP)]
                // Update the skater's current stance
                if spinOut == "to Fakie" {
                    currentStance = "Fakie"
                }
            }
            
            // 1.6 Choose if Spin Out is Rewind
            // Set the topside chance according to difficulty
            isRewind = (Double.random(in: 0...1) < rewindChance)
            // check if there's at least a 180 spin in and out
            if (spinIn == "" || spinIn == "Zero Spin" || spinOut == "") {
                rewindStamp = ""
            } else {
                if (isRewind) {
                    rewindStamp = " Rewind"
                }
            }
            
            // 1.7 Find the edge cases: Special named tricks
            // Edge Case: Top Makio = Fishbrain
            if (trick == "Makio" && isTopside == true) {
                trick = "Fishbrain"
                topsideStamp = ""
            }
            // Edge Case: Top Christ Makio = Christ Fishbrain
            if (trick == "Christ Makio" && isTopside == true) {
                trick = "Christ Fishbrain"
                topsideStamp = ""
            }
            // Edge Case: Top Mizou = Sweatstance
            if (trick == "Mizou" && isTopside == true) {
                trick = "Sweatstance"
                topsideStamp = ""
            }
            // Edge Case: Alley-Oop Sweatstance = Kind
            if (trick == "Sweatstance" && spinIn == "Alley-Oop") {
                trick = "Kind Grind"
                spinIn = ""
            }
            // Edge Case: Cab Alley-Oop Sweatstance = Cab Kind
            if (trick == "Sweatstance" && spinIn == "Cab Alley-Oop") {
                trick = "Kind Grind"
                spinIn = "Cab"
            }
            // Edge Case: True Spin Sweatstance = True Spin Kind
            if (trick == "Sweatstance" && (spinIn == "True Spin" || spinIn == "Cab True Spin" || spinIn == "Zero Spin")) {
                trick = "Kind Grind"
            }
            // Edge Case: Alley-Oop Top Mistrail = Misfit
            if (trick == "Mistrail" && isTopside == true && spinIn == "Alley-Oop") {
                trick = "Misfit"
                spinIn = ""
                topsideStamp = ""
            }
            // Edge Case: Cab Alley-Oop top mistrail = Misfit
            if (trick == "Mistrail" && isTopside == true && spinIn == "Cab Alley-Oop") {
                trick = "Misfit"
                spinIn = "Cab"
                topsideStamp = ""
            }
            // Edge Case: True Spin Top Mistrail = True Spin Misfit
            // MAYBE USE CURRENT STANCE FAKIE INSTEAD OF SPIN IN???
            if (trick == "Mistrail" && isTopside == true && (spinIn == "True Spin" || spinIn == "Cab True Spin")) {
                trick = "Misfit"
                topsideStamp = ""
            }
            // Edge Case: fakie stance + torque soul = soulyale
            if (trick == "Torque Soul" && currentStance == "Fakie") {
                trick = "Soyale"
            }
            
            // Edge Case: fakie stance + torque soul = soulyale
            // Edge Case: In spin top soulyale??? makes no sense
            
            // FINAL STEP: Set trick name
            trickName = ("\(spinIn)\(negativeStamp)\(topsideStamp) \(trick)\(rewindStamp) \(spinOut)")
            
        } else {
            // GROOVE TRICK CHOSEN !!!
            print("\nGROOVE TRICK CHOSEN!!!")

//            var initialStance = ""

            // 1.1 Choose Fakie
            // Set the Fakie chance according to difficulty
            isFakie = (Double.random(in: 0...1) < fakieChance)
            if (isFakie) {
                currentStance = "Fakie"
                fakieStamp = "Fakie"
                // initialStance = 'Fakie'
            } else {
                currentStance = "Forward"
                fakieStamp = ""
                // initialStance = 'Forward'
            }

            // 2.2 Choose Spin in
            if (currentStance == "Fakie") {
                spinIn = grooveFakieInSpins[Int.random(in: 0..<grooveFakieInSpinsCAP)]
                // Update the skater's current stance
                //currentStance = 'Sideways' // this messes up the edge case for true spins
            } else if (currentStance == "Forward") {
                spinIn = grooveForwardInSpins[Int.random(in: 0..<grooveForwardInSpinsCAP)]
                // Update the skater's current stance
                //currentStance = 'Sideways' // this messes up the edge case for true spins
            }

            // Edge Case: forward stance 270 frontside = True Spin
            if (currentStance == "Forward" && spinIn == "270 FS") {
                spinIn = "270 FS"
                // spinIn = "270 FS (True Spin)"
            }
            
            // 2.3 Choose Spin Out
            if (currentStance == "Fakie") {
              spinOut = grooveSidewaysOutSpins[Int.random(in: 0..<grooveSidewaysOutSpinsCAP)]
              // Update the skater's current stance
              if (spinOut == "to Forward") {
                currentStance = "Forward"
              }
            } else {
              spinOut = grooveSidewaysOutSpins[Int.random(in: 0..<grooveSidewaysOutSpinsCAP)];
              // Update the skater's current stance
              if (spinOut == "to Fakie") {
                currentStance = "Fakie"
              }
            }

            // 2.4 Choose if Spin Out is Rewind
            // ?? should i even do this? everyone's frontside and backside grinds are different & different shoulder fakie
            // Forward + BS || Fakie + 270 BS
            // Fakie
            rewindStamp = "";


            // 2.5 Find the edge cases and address them
            // Edge Case: FS grind = Frontside // maybe just leave the way it is
            if (spinIn == "FS" && spinIn == "270 FS") {
              spinIn = "270 FS (True Spin)"
            }
            // Edge Case: BS Grind = Backside Grind && 270 BS Grind = 270 Backside Grind
            if (trick == "Grind" && spinIn.contains("BS")) {
              trick = "Backside Grind"
              if (spinIn == "BS") {
                spinIn = ""
              } else
              if (spinIn == "270 BS") {
                spinIn = "270"
              }
            }
            // Edge Case: FS Grind = Frontside Grind && 270 FS Grind = 270 Frontside Grind
            if (trick == "Grind" && spinIn.contains("FS")) {
              trick = "Frontside Grind"
              if (spinIn == "FS") {
                spinIn = ""
              } else
              if (spinIn == "270 FS") {
                spinIn = "270"
              }
            }

            // FINAL STEP: Set trick name
            trickName = (fakieStamp + " " + spinIn + " " + trick + rewindStamp + " " + spinOut);

        }

        // Update trick name label

        // Add additional logic here if necessary, e.g., combining tricks, spins, etc.
        return trickName
        // displayTrickName = "Trick: \(trickName) Generated with \(currentDifficulty.level)"
        
    }
    
    
    func setDifficulty(_ difficulty: Difficulty) {
            currentDifficulty = difficulty
            UserDefaults.standard.set(difficulty.level, forKey: "selectedDifficultyLevel")
            if difficulty.isCustom {
                customSettings = loadCustomSettings() ?? difficulty.settings // Reload the latest custom settings
                applyCustomSettings()
            }
        }
    
    
    func updateCustomSettings(fakieChance: Double) {
        if currentDifficulty.isCustom {
            var updatedSettings = currentDifficulty.settings
            updatedSettings.fakieChance = fakieChance
            currentDifficulty.settings = updatedSettings // Update current settings
            saveSettings() // Persist the updated settings
        }
    }
    
    func saveSettings() {
        let settingsData = try? JSONEncoder().encode(currentDifficulty.settings)
        UserDefaults.standard.set(settingsData, forKey: "customSettings")
    }

    func loadSettings() {
        if let settingsData = UserDefaults.standard.data(forKey: "customSettings"),
           let settings = try? JSONDecoder().decode(Difficulty.DifficultySettings.self, from: settingsData) {
            currentDifficulty.settings = settings
        }
    }
}

