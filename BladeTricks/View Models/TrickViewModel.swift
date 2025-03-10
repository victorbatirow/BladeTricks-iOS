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
    let topsideNegativeTricks = ["Makio", "Soul", "Mizou", "Porn Star", "Acid", "Torque Soul", "Mistrial", "Christ Makio", "Tea Kettle"]
    
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
                print("\n---< DOUBLE TRICK >---")
                print("> 1st Trick:")
                let trick1 = trickGenerator(trickMode: "entry")
                print("> 2nd Trick:")
                let trick2 = trickGenerator(previousTrick: trick1, trickMode: "exit")
                newTrickName = "\(trick1.trickFullName) \n to \n\(trick2.trickFullName)"
            case 2:  // Triple switch-up
                print("\n---< TRIPLE TRICK >---")
                print("> 1st Trick:")
                let trick1 = trickGenerator(trickMode: "entry")
                print("> 2nd Trick:")
                let trick2 = trickGenerator(previousTrick: trick1, trickMode: "mid")
                print("> 3rd Trick:")
                let trick3 = trickGenerator(previousTrick: trick2, trickMode: "exit")
                newTrickName = "\(trick1.trickFullName) to \n\(trick2.trickFullName) to \n\(trick3.trickFullName)"
            default:  // Single trick
                print("\n---< SINGLE TRICK >---")
                let trick1 = trickGenerator(trickMode: "single")
                newTrickName = trick1.trickFullName
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
    
    private func trickGenerator(previousTrick: Trick? = nil, trickMode: String)-> Trick {
        
        // TRICK NAME DISPLAYED VARIABLES
        var fakieStamp: String = ""
        var topsideStamp: String = ""
        var negativeStamp: String = ""
        var rewindStamp: String = ""
        
        var trickObject = Trick()
        let settings = currentDifficulty.settings
        
        
        // Additional trick generation logic based on `trickMode`
//            switch trickMode {
//            case "entry":
//                newTrick.trickName = "Entry Trick Name" // Placeholder for actual generation logic
//            case "exit":
//                newTrick.trickName = "Exit Trick Name"  // Placeholder for actual generation logic
//            default:
//                newTrick.trickName = "Default Trick Name" // Placeholder for actual generation logic
//            }
        
        // 1.1 Choose Fakie
        // Set the Fakie chance according to difficulty
        if trickMode == "single" || trickMode == "entry" {
            var isFakie = (Double.random(in: 0...1) < settings.fakieChance)
            if isFakie {
                trickObject.initialStance = .fakie
            } else {
                trickObject.initialStance = .forward
            }
            print("Entry stance: \(trickObject.initialStance)")
        } else if trickMode == "mid" || trickMode == "exit" {
            // Set trick initial stance to last trick's grind stance
            trickObject.initialStance = previousTrick!.grindStance
            print("Transition stance: \(previousTrick!.grindStance.rawValue)")
        }
        
        
        // Choose a soulplate or groove trick (this wil determine the spin, topside and negative options) - Difficulty applied
//        var trick = allTricks[Int.random(in: 0..<tricksCAP)]
        trickObject.trickName = allTricks[Int.random(in: 0..<settings.tricksCAP)]

        // Find out if the chosen trick is done with soul plate
        if soulplateTricks.contains(trickObject.trickName) {
            // SOULPLATE TRICK CHOSEN !!!
            trickObject.type = .soulplate
            
            // 1.2 Choose Spin in according to stance
            if trickObject.initialStance == .fakie {
                // Choose a spin from the list according to the difficulty
                trickObject.spinIn = soulplateFakieInSpins[Int.random(in: 0..<settings.soulplateFakieInSpinsCAP)]
                // Update the skater's current stance
                if trickObject.spinIn == "In-Spin" || trickObject.spinIn == "Out-Spin" {
                    trickObject.grindStance = .forward
                }
            } else if trickObject.initialStance == .forward {
                // Choose a spin from the list according to the difficulty
                trickObject.spinIn = soulplateForwardInSpins[Int.random(in: 0..<settings.soulplateForwardInSpinsCAP)]
                // Update the skater's current stance
                if trickObject.spinIn == "Alley-Oop" || trickObject.spinIn == "True Spin" {
                    trickObject.grindStance = .fakie
                }
            } else if trickObject.initialStance == .bs {
                // Choose a spin from the list according to the difficulty
                trickObject.spinIn = grooveBSToSoulplateSpins[Int.random(in: 0..<settings.grooveBSToSoulplateSpinsCAP)]
                // Update the skater's current stance
                if trickObject.spinIn == "True Spin" || trickObject.spinIn == "270 Alley-Oop" || trickObject.spinIn == "450 True Spin" {
                    trickObject.grindStance = .fakie
                } else {
                    trickObject.grindStance = .forward
                }
            } else if trickObject.initialStance == .fs {
                // Choose a spin from the list according to the difficulty
                trickObject.spinIn = grooveFSToSoulplateSpins[Int.random(in: 0..<settings.grooveFSToSoulplateSpinsCAP)]
                // Update the skater's current stance
                if trickObject.spinIn == "Alley-Oop" || trickObject.spinIn == "270 True Spin" || trickObject.spinIn == "450 Alley-Oop" {
                    trickObject.grindStance = .fakie
                } else {
                    trickObject.grindStance = .forward
                }
            }
            
            // 1.3 Choose topside
            if topsideNegativeTricks.contains(trickObject.trickName) {
                // Set the topside according to topside chance
                trickObject.isTopside = (Double.random(in: 0...1) < settings.topsideChance)
            }
            
            // 1.4 Choose Negative
            if topsideNegativeTricks.contains(trickObject.trickName) {
                var negativeChance = settings.negativeChance
                //Reduce chance of negative if trick is topside
                if trickObject.isTopside && negativeChance != 0 {
                    negativeChance = 0.05
                }
                // Set the topside chance according to difficulty
                trickObject.isNegative = (Double.random(in: 0...1) < negativeChance)
            }
            
            // 1.5 Choose Spin Out
            if trickMode == "single" || trickMode == "exit" {
                if trickObject.grindStance == .fakie {
                    trickObject.spinOut = soulplateFakieOutSpins[Int.random(in: 0..<settings.soulplateFakieOutSpinsCAP)]
                    // Update the skater's current stance
                    if trickObject.spinOut == "to Forward" {
                        trickObject.outStance = .forward
                    }
                } else if trickObject.grindStance == .forward{
                    trickObject.spinOut = soulplateForwardOutSpins[Int.random(in: 0..<settings.soulplateForwardOutSpinsCAP)]
                    // Update the skater's current stance
                    if trickObject.spinOut == "to Fakie" {
                        trickObject.outStance = .fakie
                    }
                }
            }
            
            // 1.6 Choose if Spin Out is Rewind
            trickObject.isSpinOutRewind = (Double.random(in: 0...1) < settings.rewindChance)
            
            // 1.7 Find the edge cases: Special named tricks
            // Edge Case: Top Makio = Fishbrain
            if (trickObject.trickName == "Makio" && trickObject.isTopside == true) {
                trickObject.trickName = "Fishbrain"
                topsideStamp = ""
            }
            // Edge Case: Top Christ Makio = Christ Fishbrain
            if (trickObject.trickName == "Christ Makio" && trickObject.isTopside == true) {
                trickObject.trickName = "Christ Fishbrain"
                topsideStamp = ""
            }
            // Edge Case: Top Mizou = Sweatstance
            if (trickObject.trickName == "Mizou" && trickObject.isTopside == true) {
                trickObject.trickName = "Sweatstance"
                topsideStamp = ""
            }
            // Edge Case: Alley-Oop Sweatstance = Kind
            if (trickObject.trickName == "Sweatstance" && trickObject.spinIn == "Alley-Oop") {
                trickObject.trickName = "Kind Grind"
                trickObject.spinIn = ""
            }
            // Edge Case: Cab Alley-Oop Sweatstance = Cab Kind
            if (trickObject.trickName == "Sweatstance" && trickObject.spinIn == "Cab Alley-Oop") {
                trickObject.trickName = "Kind Grind"
                trickObject.spinIn = "Cab"
            }
            // Edge Case: True Spin Sweatstance = True Spin Kind
            if (trickObject.trickName == "Sweatstance" && (trickObject.spinIn == "True Spin" || trickObject.spinIn == "Cab True Spin" || trickObject.spinIn == "Zero Spin")) {
                trickObject.trickName = "Kind Grind"
            }
            // Edge Case: Alley-Oop Top Mistrial = Misfit
            if (trickObject.trickName == "Mistrial" && trickObject.isTopside == true && trickObject.spinIn == "Alley-Oop") {
                trickObject.trickName = "Misfit"
                trickObject.spinIn = ""
                topsideStamp = ""
            }
            // Edge Case: Cab Alley-Oop top Mistrial = Misfit
            if (trickObject.trickName == "Mistrial" && trickObject.isTopside == true && trickObject.spinIn == "Cab Alley-Oop") {
                trickObject.trickName = "Misfit"
                trickObject.spinIn = "Cab"
                topsideStamp = ""
            }
            // Edge Case: True Spin Top Mistrial = True Spin Misfit
            // MAYBE USE CURRENT STANCE FAKIE INSTEAD OF SPIN IN???
            if (trickObject.trickName == "Mistrial" && trickObject.isTopside == true && (trickObject.spinIn == "True Spin" || trickObject.spinIn == "Cab True Spin")) {
                trickObject.trickName = "Misfit"
                topsideStamp = ""
            }
            // Edge Case: fakie stance + torque soul = soulyale
            if (trickObject.trickName == "Torque Soul" && trickObject.grindStance == .fakie) {
                trickObject.trickName = "Soyale"
            }
            
            // Edge Case: fakie stance + torque soul = soulyale
            // Edge Case: In spin top soulyale??? makes no sense
            
            // FINAL STEP: Set trick name
//            trickObject.trickFullName = ("\(spinIn)\(negativeStamp)\(topsideStamp) \(trickObject.trickName)\(rewindStamp) \(spinOut)")
            
        } else {
            // GROOVE TRICK CHOSEN !!!
            trickObject.type = .groove

            // 2.2 Choose Spin in according to stance
            if (trickObject.initialStance == .fakie) {
                trickObject.spinIn = grooveFakieInSpins[Int.random(in: 0..<settings.grooveFakieInSpinsCAP)]
                // Update the skater's current stance
                if trickObject.spinIn.contains("FS") {
                    trickObject.grindStance = .fs
                } else if trickObject.spinIn.contains("BS") {
                    trickObject.grindStance = .bs
                }
            } else if (trickObject.initialStance == .forward) {
                trickObject.spinIn = grooveForwardInSpins[Int.random(in: 0..<settings.grooveForwardInSpinsCAP)]
                // Update the skater's current stance
                if trickObject.spinIn.contains("FS") {
                    trickObject.grindStance = .fs
                } else if trickObject.spinIn.contains("BS") {
                    trickObject.grindStance = .bs
                }
            } else if trickObject.initialStance == .bs {
                trickObject.spinIn = grooveBSToGrooveSpins[Int.random(in: 0..<settings.grooveBSToGrooveSpinsCAP)]
                // Update the skater's current stance
                if trickObject.spinIn.contains("FS") {
                    trickObject.grindStance = .fs
                }
            } else if trickObject.initialStance == .fs {
                trickObject.spinIn = grooveFSToGrooveSpins[Int.random(in: 0..<settings.grooveFSToGrooveSpinsCAP)]
                // Update the skater's current stance
                if trickObject.spinIn.contains("BS") {
                    trickObject.grindStance = .bs
                }
            }
            
            // 2.3 Choose Spin Out
            if trickMode == "single" || trickMode == "exit" {
                trickObject.spinOut = grooveSidewaysOutSpins[Int.random(in: 0..<settings.grooveSidewaysOutSpinsCAP)]
                // Update the skater's current stance
                if (trickObject.spinOut == "to Forward") {
                    trickObject.outStance = .forward
                } else if (trickObject.spinOut == "to Fakie") {
                    trickObject.outStance = .fakie
                }
            }
            
            // 2.4 Choose if Spin Out is Rewind
            // ?? should i even do this? everyone's frontside and backside grinds are different & different shoulder fakie
            // Forward + BS || Fakie + 270 BS
            // Fakie
            rewindStamp = "";


            // 2.5 Find the edge cases and address them
            // Edge Case: FS grind = Frontside // maybe just leave the way it is
//            if (spinIn == "FS" && spinIn == "270 FS") {
//              spinIn = "270 FS (True Spin)"
//            }
            // Edge Case: BS Grind = Backside Grind && 270 BS Grind = 270 Backside Grind
            if (trickObject.trickName == "Grind" && trickObject.spinIn.contains("BS")) {
              trickObject.trickName = "Backside Grind"
              if (trickObject.spinIn == "BS") {
                  trickObject.spinIn = ""
              } else
              if (trickObject.spinIn == "270 BS") {
                  trickObject.spinIn = "270"
              }
            }
            // Edge Case: FS Grind = Frontside Grind && 270 FS Grind = 270 Frontside Grind
            if (trickObject.trickName == "Grind" && trickObject.spinIn.contains("FS")) {
              trickObject.trickName = "Frontside Grind"
              if (trickObject.spinIn == "FS") {
                  trickObject.spinIn = ""
              } else
              if (trickObject.spinIn == "270 FS") {
                  trickObject.spinIn = "270"
              }
            }

            // FINAL STEP: Set trick name
//            trickObject.trickFullName = (fakieStamp + " " + spinIn + " " + trickObject.trickName + rewindStamp + " " + spinOut);
            
        }

        print("Spin In      \(trickObject.spinIn)")
        print("Trick        \(trickObject.trickName)")
        if trickMode == "single" || trickMode == "exit" {
            print("Spin Out     \(trickObject.spinOut)")
        }
        
        
        if trickObject.initialStance == .fakie {
            fakieStamp = "Fakie"
        }
        if trickObject.isTopside {
            topsideStamp = " Top"
        }
        if trickObject.isNegative {
            negativeStamp = " Negative"
        }
        // check if there's at least a 180 spin in and out
        if trickObject.isSpinOutRewind {
            if !(trickObject.spinIn == "" || trickObject.spinIn == "Zero Spin" || trickObject.spinIn == "") {
                rewindStamp = " Rewind"
            }
        }
        
        // Update trick name label
        if trickObject.type == .soulplate {
            trickObject.trickFullName = ("\(trickObject.spinIn)\(negativeStamp)\(topsideStamp) \(trickObject.trickName)\(rewindStamp) \(trickObject.spinOut)")
        } else {
            trickObject.trickFullName = (fakieStamp + " " + trickObject.spinIn + " " + trickObject.trickName + rewindStamp + " " + trickObject.spinOut);
        }
        // Add additional logic here if necessary, e.g., combining tricks, spins, etc.
//        return trickName
        return trickObject
        // displayTrickName = "Trick: \(trickName) Generated with \(currentDifficulty.level)"
        
    }
    
    
    func setDifficulty(_ difficulty: Difficulty) {
            currentDifficulty = difficulty
            UserDefaults.standard.set(difficulty.level, forKey: "selectedDifficultyLevel")
            if difficulty.isCustom {
                customSettings = loadCustomSettings() ?? difficulty.settings // Reload the latest custom settings
                applyCustomSettings()
            }
            print("""
                \n
                - Level name:       \(currentDifficulty.level): \(currentDifficulty.difficultyLevel.rawValue)
                - Fakie chance:     \(currentDifficulty.settings.fakieChance * 100)%
                - Topside chance:   \(currentDifficulty.settings.topsideChance * 100)%
                - Negative chance:  \(currentDifficulty.settings.negativeChance * 100)%
                - Rewind chance:    \(currentDifficulty.settings.rewindChance * 100)%
                - Trick CAP:        \(currentDifficulty.settings.tricksCAP)
                """)
        }
}

