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
//      -- zero spin top Mistrial makes no sense
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
    let allTricks = ["Makio", "Grind", "Soul", "Mizou", "Porn Star", "Acid", "Fahrv", "Royale", "Unity", "X-Grind", "Torque Soul", "Mistrial", "Savannah", "UFO", "Torque", "Backslide", "Cab Driver", "Christ Makio", "Fastslide", "Stub Soul", "Tea Kettle", "Pudslide"]
    let soulplateTricks = ["Makio", "Soul", "Mizou", "Porn Star", "Acid", "X-Grind", "Torque Soul", "Mistrial", "Christ Makio", "Stub Soul", "Tea Kettle"]
    let grooveTricks = ["Grind", "Fahrvergnugen ", "Royale", "Unity", "Savannah", "Torque", "Backslide", "Cab Driver", "UFO", "Fastslide", "Pudslide"]
    let topsideNegativeTricks = ["Makio", "Soul", "Mizou", "Porn Star", "Acid", "Torque Soul", "Mistrial", "Christ Makio"]
    
    // CONSTANTS: Spins -- Order: easy to hard
    // In-Spins
    let soulplateForwardInSpins = ["", "Alley-Oop", "True Spin", "360", "Hurricane"] // left(true, hurricane) - right(AO, 360) - neutral("")
    let soulplateFakieInSpins = ["In-Spin", "Out-Spin", "Zero Spin", "Cab Alley-Oop", "Cab True Spin"] // left(inspin, cab true) - right(outspin, cab AO) - neutral(zero)
    let grooveForwardInSpins = ["FS", "BS", "270 BS", "270 FS"] // left(BS, 270FS) right(FS, 270 BS) neutral
    let grooveFakieInSpins = ["FS", "BS", "270 BS", "270 FS"] // left(FS, 270 BS) right(BS, 270 FS)
    // Out-Spins
    let soulplateForwardOutSpins = ["", "to Fakie", "360 Out"]
    let soulplateFakieOutSpins = ["", "to Forward", "Cab Out"]
// remove "to fakie/forward", add it back after generating the spin out. find out if its forward of fakie using currstance + spinOut (before updating currentStance to count for spin out)
//    let grooveSidewaysOutSpins = ["to Fakie", "to Forward", "270 Out", "270 Out to Fakie", "270 Out to Forward", "450 Out"]
    let grooveSidewaysOutSpins = ["to Fakie", "to Forward", "270 Out", "270 Out to Fakie", "270 Out to Forward", "450 Out"]
    // let grooveFsLeftOutSpins = ["to Forward", "270 Out to Fakie", "450 Out to Forward"]
    // let grooveFsRightOutSpins = ["to Fakie", "270 Out to Forward", "450 Out to Fakie"]
    // let grooveBsLeftOutSpins = ["to Fakie", "270 Out to Forward", "450 Out to Fakie"]
    // let grooveBsRightOutSpins = ["to Forward", "270 Out to Fakie", "450 Out to Forward"]
    
    // Switch up Spins
    let grooveFSToSoulplateSpins = ["", "Alley-Oop", "270", "270 True Spin", "450 Alley-Oop", "450"] // "", "270 true spin", "450" - are reqwind  --- left()
    let grooveBSToSoulplateSpins = ["", "True Spin", "270", "270 Alley-Oop", "450 True Spin", "450"] // "", "270 Alley-Oop spin", "450" - are reqwind
    let grooveFSToGrooveSpins = ["FS", "BS", "360 FS"] // double FS is easier than FS to BS | BS, 360 FS can be regular or rewind
    let grooveBSToGrooveSpins = ["BS", "FS", "360 BS"] // double BS is easier than BS to FS | FS, 360 BS can be regular or rewind
    
    // SkaterSpinDirection = ["N", "L90", "R90", "L, "]
    
    @Published var displayTrickName: String = "Press button to generate trick."
    @Published var currentDifficulty: Difficulty = Difficulty.levels[0]  // Default to first difficulty
    @Published var customSettings: Difficulty.DifficultySettings
    @Published var SwitchUpMode: Int = 0  // 0 for single, 1 for double, 2 for triple
    private var lastTricks: [String] = []  // This array will store the history of generated tricks
    // Skater's current stance during a trick
    var currentStance: String = "Forward"


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
        
        // Ensure that trick generated is not the same as previous 3
        while !uniqueTrickFound {
            // Generate a trick
            switch SwitchUpMode {
            case 1:  // Double switch-up
                print("---< DOUBLE TRICK >---")
                print("1st Trick:")
                let trick1 = generateTrickName(trickMode: "entry")
                print("2nd Trick:")
                let trick2 = generateTrickName(trickMode: "exit")
                newTrickName = "\(trick1) \n to \n\(trick2)"
            case 2:  // Triple switch-up
                print("---< TRIPLE TRICK >---")
                print("1st Trick:")
                let trick1 = generateTrickName(trickMode: "entry")
                print("2nd Trick:")
                let trick2 = generateTrickName(trickMode: "mid")
                print("3rd Trick:")
                let trick3 = generateTrickName(trickMode: "exit")
                newTrickName = "\(trick1) to \n\(trick2) to \n\(trick3)"
            default:  // Single trick
                print("---< SINGLE TRICK >---")
                newTrickName = generateTrickName(trickMode: "single")
            }

            // Check if the trick has been generated in the last three attempts
            if !lastTricks.contains(newTrickName) {
                uniqueTrickFound = true
                lastTricks.append(newTrickName)
                
                // Keep only the last three entries in the history
                if lastTricks.count > 3 {
                    lastTricks.removeFirst()
                }
            } else {
                print("* repeated trick found, re-generating....")
            }
        }
        
        displayTrickName = newTrickName
    }
    
    private func generateTrickName(trickMode: String)-> String {

        // TRICK NAME DISPLAYED VARIABLES
        var trickName: String = ""
        var spinIn: String = ""
        var fakieStamp: String = ""
        var topsideStamp: String = ""
        var negativeStamp: String = ""
        var rewindStamp: String = ""
        var spinOut: String = ""
        
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
        let grooveFSToSoulplateSpinsCAP = settings.grooveFSToSoulplateSpinsCAP
        let grooveBSToSoulplateSpinsCAP = settings.grooveBSToSoulplateSpinsCAP
        let grooveFSToGrooveSpinsCAP = settings.grooveFSToGrooveSpinsCAP
        let grooveBSToGrooveSpinsCAP = settings.grooveBSToGrooveSpinsCAP

        
        // TRICK VARIATIONS (move to inside function)
        var isFakie: Bool = false
        var isTopside: Bool = false
        var isNegative: Bool = false
        var isRewind: Bool = false

        
//        print("""
//        - Fakie chance:     \(fakieChance * 100)%
//        - Topside chance:   \(topsideChance * 100)%
//        - Negative chance:  \(negativeChance * 100)%
//        - Rewind chance:    \(rewindChance * 100)%
//        - Trick CAP:        \(tricksCAP)
//        """)
        
        // 1.1 Choose Fakie
        // Set the Fakie chance according to difficulty
        if trickMode == "single" || trickMode == "entry" {
            isFakie = (Double.random(in: 0...1) < fakieChance)
            if isFakie {
                currentStance = "Fakie"
                fakieStamp = "Fakie"
            } else {
                currentStance = "Forward"
                fakieStamp = ""
            }
            print("Entry stance: \(currentStance)")
        } else {
            print("Transition stance: \(currentStance)")
        }
        
        
        
        // Choose a soulplate or groove trick (this wil determine the spin, topside and negative options) - Difficulty applied
        var trick = allTricks[Int.random(in: 0..<tricksCAP)]

        // Find out if the chosen trick is done with soul plate
        if soulplateTricks.contains(trick) {
            // SOULPLATE TRICK CHOSEN !!!
            
            // 1.2 Choose Spin in according to stance
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
            } else if currentStance == "BS" {
                // Choose a spin from the list according to the difficulty
                spinIn = grooveBSToSoulplateSpins[Int.random(in: 0..<grooveBSToSoulplateSpinsCAP)]
                // Update the skater's current stance
                if spinIn == "True Spin" || spinIn == "270 Alley-Oop" || spinIn == "450 True Spin" {
                    currentStance = "Fakie"
                } else {
                    currentStance = "Forward"
                }
            } else if currentStance == "FS" {
                // Choose a spin from the list according to the difficulty
                spinIn = grooveFSToSoulplateSpins[Int.random(in: 0..<grooveFSToSoulplateSpinsCAP)]
                // Update the skater's current stance
                if spinIn == "Alley-Oop" || spinIn == "270 True Spin" || spinIn == "450 Alley-Oop" {
                    currentStance = "Fakie"
                } else {
                    currentStance = "Forward"
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
            }
            
            // 1.5 Choose Spin Out
            if trickMode == "single" || trickMode == "exit" {
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
            // Edge Case: Alley-Oop Top Mistrial = Misfit
            if (trick == "Mistrial" && isTopside == true && spinIn == "Alley-Oop") {
                trick = "Misfit"
                spinIn = ""
                topsideStamp = ""
            }
            // Edge Case: Cab Alley-Oop top Mistrial = Misfit
            if (trick == "Mistrial" && isTopside == true && spinIn == "Cab Alley-Oop") {
                trick = "Misfit"
                spinIn = "Cab"
                topsideStamp = ""
            }
            // Edge Case: True Spin Top Mistrial = True Spin Misfit
            // MAYBE USE CURRENT STANCE FAKIE INSTEAD OF SPIN IN???
            if (trick == "Mistrial" && isTopside == true && (spinIn == "True Spin" || spinIn == "Cab True Spin")) {
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

            // 2.2 Choose Spin in according to stance
            if (currentStance == "Fakie") {
                spinIn = grooveFakieInSpins[Int.random(in: 0..<grooveFakieInSpinsCAP)]
                // Update the skater's current stance
                if spinIn.contains("FS") {
                    currentStance = "FS"
                } else if spinIn.contains("BS") {
                    currentStance = "BS"
                }
            } else if (currentStance == "Forward") {
                spinIn = grooveForwardInSpins[Int.random(in: 0..<grooveForwardInSpinsCAP)]
                // Update the skater's current stance
                if spinIn.contains("FS") {
                    currentStance = "FS"
                } else if spinIn.contains("BS") {
                    currentStance = "BS"
                }
            } else if currentStance == "BS" {
                spinIn = grooveBSToGrooveSpins[Int.random(in: 0..<grooveBSToGrooveSpinsCAP)]
                // Update the skater's current stance
                if spinIn.contains("FS") {
                    currentStance = "FS"
                }
            } else if currentStance == "FS" {
                spinIn = grooveFSToGrooveSpins[Int.random(in: 0..<grooveFSToGrooveSpinsCAP)]
                // Update the skater's current stance
                if spinIn.contains("BS") {
                    currentStance = "BS"
                }
            }

            // Edge Case: forward stance 270 frontside = True Spin
//            if (currentStance == "Forward" && spinIn == "270 FS") {
//                spinIn = "270 FS"
//                // spinIn = "270 FS (True Spin)"
//            }
            
            // 2.3 Choose Spin Out
            if trickMode == "single" || trickMode == "exit" {
                spinOut = grooveSidewaysOutSpins[Int.random(in: 0..<grooveSidewaysOutSpinsCAP)]
                // Update the skater's current stance
                if (spinOut == "to Forward") {
                    currentStance = "Forward"
                } else if (spinOut == "to Fakie") {
                    currentStance = "Fakie"
                }
            }
            // 2.3 Choose Spin Out
//            if trickMode == "single" || trickMode == "exit" {
//                if (currentStance == "Fakie") {
//                    spinOut = grooveSidewaysOutSpins[Int.random(in: 0..<grooveSidewaysOutSpinsCAP)]
//                    // Update the skater's current stance
//                    if (spinOut == "to Forward") {
//                        currentStance = "Forward"
//                    }
//                } else {
//                    spinOut = grooveSidewaysOutSpins[Int.random(in: 0..<grooveSidewaysOutSpinsCAP)];
//                    // Update the skater's current stance
//                    if (spinOut == "to Fakie") {
//                        currentStance = "Fakie"
//                    }
//                }
//            }
            
            
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

        print("Spin In      \(spinIn)")
        print("Trick        \(trick)")
        if trickMode == "single" || trickMode == "exit" {
            print("Spin Out     \(spinOut)")
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

