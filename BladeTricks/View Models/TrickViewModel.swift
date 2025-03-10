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
    // IMPORTANT: Ledge is always on the right side (for Left and Right Spins)
    // Forward to Soulplate
    let forwardToSoulplateSpins = ["", "Alley-Oop", "True Spin", "360", "Hurricane", "540 Alley-Oop", "540 True Spin"]
    let forwardToSoulplateSpinsLeft = ["True Spin", "Hurricane", "540 True Spin"]
    let forwardToSoulplateSpinsRight = ["Alley-Oop", "360", "540 Alley-Oop"]
    // Forward to Groove
    let forwardToGrooveSpins = ["FS", "BS", "270 BS", "270 FS", "450 FS", "450 BS"]
    let forwardToGrooveSpinsLeft = ["BS", "270 FS", "450 BS"]
    let forwardToGrooveSpinsRight = ["FS", "270 BS", "450FS"]
    // Fakie to Soulplate
    let fakieToSoulplateSpins = ["In-Spin", "Out-Spin", "Zero Spin", "Cab Alley-Oop", "Cab True Spin", "540 In-Spin", "540 Out-Spin"]
    let fakieToSoulplateSpinsLeft = ["In-Spin", "Cab True Spin", "540 In-Spin"]
    let fakieToSoulplateSpinsRight = ["Out-Spin", "Cab Alley-Oop", "540 Out-Spin"]
    // Fakie to Groove
    let fakieToGrooveSpins = ["FS", "BS", "270 BS", "270 FS", "450 FS", "450 BS"]
    let fakieToGrooveSpinsLeft = ["FS", "270 BS", "450 FS"]
    let fakieToGrooveSpinsRight = ["BS", "270 FS", "450 BS"]
    // FS to Soulplate
    let fsToSoulplateSpins = ["", "Alley-Oop", "270", "270 True Spin", "450 Alley-Oop", "450 (Hurricane)"]
    let fsToSoulplateSpinsLeft = ["270 True Spin", "450 (Hurricane)"]
    let fsToSoulplateSpinsRight = ["Alley-Oop", "270", "450 Alley-Oop"]
    // FS to Groove
    let fsToGrooveSpins = ["FS", "BS", "360 FS"]
    // BS to Soulplate
    let bsToSoulplateSpins = ["", "True Spin", "270", "270 Alley-Oop", "450 True Spin", "450"]
    let bsToSoulplateSpinsLeft = ["True Spin", "270", "450 True Spin"]
    let bsToSoulplateSpinsRight = ["270 Alley-Oop", "450"]
    // BS to Groove
    let bsToGrooveSpins = ["BS", "FS", "360 BS"] // FS, 360 BS can be regular or rewind
    
    //will delete in future
    let grooveSidewaysOutSpins = ["to Fakie", "to Forward", "270", "270 Out to Fakie", "270 Out to Forward", "450 Out"]
    
    // Out-Spins
    let forwardOutSpins = ["", "to Fakie", "360 Out"]
    let fakieOutSpins = ["", "to Forward", "Cab Out"]
    // FS Out Spins
    let fsOutSpins = ["to Fakie", "to Forward", "270 to Fakie", "270 to Forward", "450 to Fakie", "450 to Forward"]
    let fsOutSpinsLeft = ["270 Out to Fakie", "450 Out to Forward"]
    let fsOutSpinsRight = ["270 Out to Forward", "450 Out to Fakie"]
    //BS Out Spins
    let bsOutSpins = ["to Forward", "to Fakie", "270 to Forward", "270 to Fakie", "450 to Fakie", "450 to Forward"]
    let bsOutSpinsLeft = ["270 Out to Forward", "450 Out to Fakie"]
    let bsOutSpinsRight = ["270 Out to Fakie", "450 Out to Forward"]
    
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

        // Now that all properties are initialized, can safely use instance methods
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
            let isFakie = (Double.random(in: 0...1) < settings.fakieChance)
            if isFakie {
                trickObject.initialStance = .fakie
                fakieStamp = "Fakie"
            } else {
                trickObject.initialStance = .forward
                fakieStamp = ""
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
            // Remove rewind spins for switch ups
            var fakieToSoulplateSpinsAllowed = fakieToSoulplateSpins
            var forwardToSoulplateSpinsAllowed = forwardToSoulplateSpins
            var bsToSoulplateSpinsAllowed = bsToSoulplateSpins
            var fsToSoulplateSpinsAllowed = fsToSoulplateSpins
            var isSwitchUpRewindBlocked = false
            
            if (trickMode == "mid" || trickMode == "exit") {
                if !customSettings.switchUpRewindAllowed {
                    if previousTrick?.spinInDirection == "L" {
                        fakieToSoulplateSpinsAllowed = fakieToSoulplateSpins.filter { !fakieToSoulplateSpinsRight.contains($0) }
                        forwardToSoulplateSpinsAllowed = forwardToSoulplateSpins.filter { !forwardToSoulplateSpinsRight.contains($0) }
                        bsToSoulplateSpinsAllowed = bsToSoulplateSpins.filter { !bsToSoulplateSpinsRight.contains($0) }
                        fsToSoulplateSpinsAllowed = fsToSoulplateSpins.filter { !fsToSoulplateSpinsRight.contains($0) }
                        print("Switch up Rewind Spins Blocked")
                        isSwitchUpRewindBlocked = true
                    } else if previousTrick?.spinInDirection == "R" {
                        fakieToSoulplateSpinsAllowed = fakieToSoulplateSpins.filter { !fakieToSoulplateSpinsLeft.contains($0) }
                        forwardToSoulplateSpinsAllowed = forwardToSoulplateSpins.filter { !forwardToSoulplateSpinsLeft.contains($0) }
                        bsToSoulplateSpinsAllowed = bsToSoulplateSpins.filter { !bsToSoulplateSpinsLeft.contains($0) }
                        fsToSoulplateSpinsAllowed = fsToSoulplateSpins.filter { !fsToSoulplateSpinsLeft.contains($0) }
                        print("Switch up Rewind Spins Blocked")
                        isSwitchUpRewindBlocked = true
                    } else if previousTrick?.spinInDirection == "N" {
                        fakieToSoulplateSpinsAllowed = fakieToSoulplateSpins
                        forwardToSoulplateSpinsAllowed = forwardToSoulplateSpins
                        bsToSoulplateSpinsAllowed = bsToSoulplateSpins
                        fsToSoulplateSpinsAllowed = fsToSoulplateSpins
                        print("(Neutral) Switch up Rewind Spins NOT Blocked")
                        isSwitchUpRewindBlocked = false
                    }
                } else {
                    print("Switch up rewind spins allowed")
                }
            }
            if trickObject.initialStance == .fakie {
                // Choose a spin from the list according to the difficulty
                if !isSwitchUpRewindBlocked {
                    trickObject.spinIn = fakieToSoulplateSpinsAllowed[Int.random(in: 0..<settings.soulplateFakieInSpinsCAP)]
                } else {
                    let upperBound = max(1, Int(settings.soulplateFakieInSpinsCAP) - fakieToSoulplateSpinsLeft.count)
                    if upperBound > 0 {
                        let randomIndex = Int.random(in: 0..<upperBound)
                        trickObject.spinIn = fakieToSoulplateSpinsAllowed[randomIndex]
                    } else {
                        // Handle error or provide a fallback value
                        print("No valid spins available")
                        trickObject.spinIn = "Default Spin"
                    }
                }
                // Update the skater's current stance
                if trickObject.spinIn.contains("In-Spin") || trickObject.spinIn.contains("Out-Spin") {
                    trickObject.grindStance = .forward
                } else {
                    trickObject.grindStance = .fakie
                }
                // Update skater's spin direction
                if (fakieToSoulplateSpinsLeft.contains(trickObject.spinIn)) {
                    print("Spinning Direction: Left")
                    trickObject.spinInDirection = "L"
                } else if (fakieToSoulplateSpinsRight.contains(trickObject.spinIn)) {
                    print("Spinning Direction: Right")
                    trickObject.spinInDirection = "R"
                } else {
                    print("Spinning Direction: Neutral")
                    trickObject.spinInDirection = "N"
                }
            } else if trickObject.initialStance == .forward {
                // Choose a spin from the list according to the difficulty
                if !isSwitchUpRewindBlocked {
                    trickObject.spinIn = forwardToSoulplateSpinsAllowed[Int.random(in: 0..<settings.soulplateForwardInSpinsCAP)]
                } else {
                    let upperBound = max(1, Int(settings.soulplateForwardInSpinsCAP) - forwardToSoulplateSpinsLeft.count)
                    if upperBound > 0 {
                        let randomIndex = Int.random(in: 0..<upperBound)
                        trickObject.spinIn = forwardToSoulplateSpinsAllowed[randomIndex]
                    } else {
                        // Handle error or provide a fallback value
                        print("No valid spins available")
                        trickObject.spinIn = "Default Spin"
                    }
                }
                // Update the skater's current stance
                if trickObject.spinIn.contains("Alley-Oop") || trickObject.spinIn.contains("True Spin") {
                    trickObject.grindStance = .fakie
                } else {
                    trickObject.grindStance = .forward
                }
                // Update skater's spin direction
                if (forwardToSoulplateSpinsLeft.contains(trickObject.spinIn)) {
                    print("Spinning Direction: Left")
                    trickObject.spinInDirection = "L"
                } else if (forwardToSoulplateSpinsRight.contains(trickObject.spinIn)) {
                    print("Spinning Direction: Right")
                    trickObject.spinInDirection = "R"
                } else {
                    print("Spinning Direction: Neutral")
                    trickObject.spinInDirection = "N"
                }
            } else if trickObject.initialStance == .bs {
                // Choose a spin from the list according to the difficulty
                if !isSwitchUpRewindBlocked {
                    trickObject.spinIn = bsToSoulplateSpinsAllowed[Int.random(in: 0..<settings.grooveBSToSoulplateSpinsCAP)]
                } else {
                    let upperBound = max(1, Int(settings.grooveBSToSoulplateSpinsCAP) - bsToSoulplateSpinsLeft.count)
                    if upperBound > 0 {
                        let randomIndex = Int.random(in: 0..<upperBound)
                        trickObject.spinIn = bsToSoulplateSpinsAllowed[randomIndex]
                    } else {
                        // Handle error or provide a fallback value
                        print("No valid spins available")
                        trickObject.spinIn = "Default Spin"
                    }
                }
                // Update the skater's current stance
                if trickObject.spinIn == "True Spin" || trickObject.spinIn == "270 Alley-Oop" || trickObject.spinIn == "450 True Spin" {
                    trickObject.grindStance = .fakie
                } else {
                    trickObject.grindStance = .forward
                }
                // Update skater's spin direction
                if (bsToSoulplateSpinsLeft.contains(trickObject.spinIn)) {
                    print("Spinning Direction: Left")
                    trickObject.spinInDirection = "L"
                } else if (bsToSoulplateSpinsRight.contains(trickObject.spinIn)) {
                    print("Spinning Direction: Right")
                    trickObject.spinInDirection = "R"
                } else {
                    print("Spinning Direction: Neutral")
                    trickObject.spinInDirection = "N"
                }
            } else if trickObject.initialStance == .fs {
                // Choose a spin from the list according to the difficulty
                if !isSwitchUpRewindBlocked {
                    trickObject.spinIn = fsToSoulplateSpinsAllowed[Int.random(in: 0..<settings.grooveFSToSoulplateSpinsCAP)]
                } else {
                    let upperBound = max(1, Int(settings.grooveFSToSoulplateSpinsCAP) - bsToSoulplateSpinsLeft.count)
                    if upperBound > 0 {
                        let randomIndex = Int.random(in: 0..<upperBound)
                        trickObject.spinIn = fsToSoulplateSpinsAllowed[randomIndex]
                    } else {
                        // Handle error or provide a fallback value
                        print("No valid spins available")
                        trickObject.spinIn = "Default Spin"
                    }
                }
                // Update the skater's current stance
                if trickObject.spinIn == "Alley-Oop" || trickObject.spinIn == "270 True Spin" || trickObject.spinIn == "450 Alley-Oop" {
                    trickObject.grindStance = .fakie
                } else {
                    trickObject.grindStance = .forward
                }
                // Update skater's spin direction
                if (fsToSoulplateSpinsLeft.contains(trickObject.spinIn)) {
                    print("Spinning Direction: Left")
                    trickObject.spinInDirection = "L"
                } else if (fsToSoulplateSpinsRight.contains(trickObject.spinIn)) {
                    print("Spinning Direction: Right")
                    trickObject.spinInDirection = "R"
                } else {
                    print("Spinning Direction: Neutral")
                    trickObject.spinInDirection = "N"
                }
            }
            
            // 1.3 Choose topside
            if topsideNegativeTricks.contains(trickObject.trickName) {
                // Set the topside according to topside chance
                trickObject.isTopside = (Double.random(in: 0...1) < settings.topsideChance)
               // Update the topside stamp
                if trickObject.isTopside {
                   topsideStamp = " Top"
               } else {
                   topsideStamp = ""
               }
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
                if trickObject.isNegative {
                   negativeStamp = " Negative"
               } else {
                   negativeStamp = ""
               }
            }
            
            // 1.5 Choose Spin Out
            if trickMode == "single" || trickMode == "exit" {
                if trickObject.grindStance == .fakie {
                    trickObject.spinOut = fakieOutSpins[Int.random(in: 0..<settings.soulplateFakieOutSpinsCAP)]
                    // Update the skater's current stance
                    if trickObject.spinOut == "to Forward" {
                        trickObject.outStance = .forward
                    }
                } else if trickObject.grindStance == .forward{
                    trickObject.spinOut = forwardOutSpins[Int.random(in: 0..<settings.soulplateForwardOutSpinsCAP)]
                    // Update the skater's current stance
                    if trickObject.spinOut == "to Fakie" {
                        trickObject.outStance = .fakie
                    }
                }
            }
            
            // 1.6 Choose if Spin Out is Rewind
            if trickMode == "single" || trickMode == "exit" {
                trickObject.isSpinOutRewind = (Double.random(in: 0...1) < settings.rewindOutChance)
                if (trickObject.spinIn == "" || trickObject.spinIn == "Zero Spin" || trickObject.spinOut == "") {
                    rewindStamp = ""
                } else {
                    if (trickObject.isSpinOutRewind) {
                        rewindStamp = " Rewind"
                    }
                }
            }
            
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
            
            // 1.2 Choose Spin in according to stance
            // Remove rewind spins for switch ups
            var fakieToGrooveSpinsAllowed = fakieToGrooveSpins
            var forwardToGrooveSpinsAllowed = forwardToGrooveSpins
            var bsToGrooveSpinsAllowed = bsToGrooveSpins
            var fsToGrooveSpinsAllowed = fsToGrooveSpins
            var isSwitchUpRewindBlocked = false
            
            if (trickMode == "mid" || trickMode == "exit") {
                if !customSettings.switchUpRewindAllowed {
                    if previousTrick?.spinInDirection == "L" {
                        fakieToGrooveSpinsAllowed = fakieToGrooveSpins.filter { !fakieToGrooveSpinsRight.contains($0) }
                        forwardToGrooveSpinsAllowed = forwardToGrooveSpins.filter { !forwardToGrooveSpinsRight.contains($0) }
                        print("Switch up Rewind Spins Blocked")
                        isSwitchUpRewindBlocked = true
                    } else if previousTrick?.spinInDirection == "R" {
                        fakieToGrooveSpinsAllowed = fakieToGrooveSpins.filter { !fakieToGrooveSpinsLeft.contains($0) }
                        forwardToGrooveSpinsAllowed = forwardToGrooveSpins.filter { !forwardToGrooveSpinsLeft.contains($0) }
                        print("Switch up Rewind Spins Blocked")
                        isSwitchUpRewindBlocked = true
                    } else if previousTrick?.spinInDirection == "N" {
                        fakieToGrooveSpinsAllowed = fakieToGrooveSpins
                        forwardToGrooveSpinsAllowed = forwardToGrooveSpins
                        bsToGrooveSpinsAllowed = bsToGrooveSpins
                        fsToGrooveSpinsAllowed = fsToGrooveSpins
                        print("(Neutral) Switch up Rewind Spins NOT Blocked")
                        isSwitchUpRewindBlocked = false
                    }
                } else {
                    print("Switch up rewind spins allowed")
                }
            }

            // 2.2 Choose Spin in according to stance
            if (trickObject.initialStance == .fakie) {
                // Choose a spin from the list according to the difficulty
                if !isSwitchUpRewindBlocked {
                    trickObject.spinIn = fakieToGrooveSpinsAllowed[Int.random(in: 0..<settings.grooveFakieInSpinsCAP)]
                } else {
                    let upperBound = max(1, Int(settings.grooveFakieInSpinsCAP) - fakieToGrooveSpinsLeft.count)
                    if upperBound > 0 {
                        let randomIndex = Int.random(in: 0..<upperBound)
                        trickObject.spinIn = fakieToGrooveSpinsAllowed[randomIndex]
                    } else {
                        // Handle error or provide a fallback value
                        print("No valid spins available")
                        trickObject.spinIn = "Default Spin"
                    }
                }
                // Update the skater's current stance
                if trickObject.spinIn.contains("FS") {
                    trickObject.grindStance = .fs
                } else if trickObject.spinIn.contains("BS") {
                    trickObject.grindStance = .bs
                }
                // Update skater's spin direction
                if (fakieToGrooveSpinsLeft.contains(trickObject.spinIn)) {
                    print("Spinning Direction: Left")
                    trickObject.spinInDirection = "L"
                } else if (fakieToGrooveSpinsRight.contains(trickObject.spinIn)) {
                    print("Spinning Direction: Right")
                    trickObject.spinInDirection = "R"
                } else {
                    print("Spinning Direction: Neutral")
                    trickObject.spinInDirection = "N"
                }
            } else if (trickObject.initialStance == .forward) {
                // Choose a spin from the list according to the difficulty
                if !isSwitchUpRewindBlocked {
                    trickObject.spinIn = forwardToGrooveSpinsAllowed[Int.random(in: 0..<settings.grooveForwardInSpinsCAP)]
                } else {
                    let upperBound = max(1, Int(settings.grooveForwardInSpinsCAP) - forwardToGrooveSpinsLeft.count)
                    if upperBound > 0 {
                        let randomIndex = Int.random(in: 0..<upperBound)
                        trickObject.spinIn = forwardToGrooveSpinsAllowed[randomIndex]
                    } else {
                        // Handle error or provide a fallback value
                        print("No valid spins available")
                        trickObject.spinIn = "Default Spin"
                    }
                }
                trickObject.spinIn = forwardToGrooveSpins[Int.random(in: 0..<settings.grooveForwardInSpinsCAP)]
                // Update the skater's current stance
                if trickObject.spinIn.contains("FS") {
                    trickObject.grindStance = .fs
                } else if trickObject.spinIn.contains("BS") {
                    trickObject.grindStance = .bs
                }
                // Update skater's spin direction
                if (forwardToGrooveSpinsLeft.contains(trickObject.spinIn)) {
                    print("Spinning Direction: Left")
                    trickObject.spinInDirection = "L"
                } else if (forwardToGrooveSpinsRight.contains(trickObject.spinIn)) {
                    print("Spinning Direction: Right")
                    trickObject.spinInDirection = "R"
                } else {
                    print("Spinning Direction: Neutral")
                    trickObject.spinInDirection = "N"
                }
            } else if trickObject.initialStance == .bs {
                trickObject.spinIn = bsToGrooveSpins[Int.random(in: 0..<settings.grooveBSToGrooveSpinsCAP)]
                // Update the skater's current stance
                if trickObject.spinIn.contains("FS") {
                    trickObject.grindStance = .fs
                } else if trickObject.spinIn.contains("BS") {
                    trickObject.grindStance = .bs
                }
            } else if trickObject.initialStance == .fs {
                trickObject.spinIn = fsToGrooveSpins[Int.random(in: 0..<settings.grooveFSToGrooveSpinsCAP)]
                // Update the skater's current stance
                if trickObject.spinIn.contains("BS") {
                    trickObject.grindStance = .bs
                } else if trickObject.spinIn.contains("FS") {
                    trickObject.grindStance = .fs
                }
            }
            
            // 2.3 Choose Spin Out
            if trickMode == "single" || trickMode == "exit" {
                if trickObject.grindStance == .fs {
                    trickObject.spinOut = fsOutSpins[Int.random(in: 0..<settings.grooveSidewaysOutSpinsCAP)]
                    // Update the skater's current stance
                    if (trickObject.spinOut == "to Forward") {
                        trickObject.outStance = .forward
                    } else if (trickObject.spinOut == "to Fakie") {
                        trickObject.outStance = .fakie
                    }
                } else if trickObject.grindStance == .bs {
                    trickObject.spinOut = bsOutSpins[Int.random(in: 0..<settings.grooveSidewaysOutSpinsCAP)]
                    // Update the skater's current stance
                    if (trickObject.spinOut == "to Forward") {
                        trickObject.outStance = .forward
                    } else if (trickObject.spinOut == "to Fakie") {
                        trickObject.outStance = .fakie
                    }
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
              } else if (trickObject.spinIn == "270 BS") {
                  trickObject.spinIn = "270"
              } else if (trickObject.spinIn == "360 BS") {
                  trickObject.spinIn = "360"
              } else if (trickObject.spinIn == "450 BS") {
                  trickObject.spinIn = "450"
              }
            }
            // Edge Case: FS Grind = Frontside Grind && 270 FS Grind = 270 Frontside Grind
            if (trickObject.trickName == "Grind" && trickObject.spinIn.contains("FS")) {
              trickObject.trickName = "Frontside Grind"
              if (trickObject.spinIn == "FS") {
                  trickObject.spinIn = ""
              } else if (trickObject.spinIn == "270 FS") {
                  trickObject.spinIn = "270"
              } else if (trickObject.spinIn == "360 FS") {
                  trickObject.spinIn = "360"
              } else if (trickObject.spinIn == "450 FS") {
                  trickObject.spinIn = "450"
              }
            }
            // Edge Case: If previous trick grind stance raw value == trickobject.spinIn { trickobject.spinin = "" }
            if (previousTrick?.grindStance.rawValue == trickObject.spinIn) {
                trickObject.spinIn = ""
            }

            // FINAL STEP: Set trick name
//            trickObject.trickFullName = (fakieStamp + " " + spinIn + " " + trickObject.trickName + rewindStamp + " " + spinOut);
            
        }

        print("Spin In      \(trickObject.spinIn)")
        print("Trick        \(trickObject.trickName)")
        if trickMode == "single" || trickMode == "exit" {
            print("Spin Out     \(trickObject.spinOut)")
        }
        
        // Update trick name label
        if trickObject.type == .soulplate {
            if !trickObject.spinOut.isEmpty {
                trickObject.spinOut = " \(trickObject.spinOut)"
            }
            trickObject.trickFullName = ("\(trickObject.spinIn)\(negativeStamp)\(topsideStamp) \(trickObject.trickName)\(rewindStamp)\(trickObject.spinOut)")
        } else if trickObject.type == .groove{
            if !trickObject.spinOut.isEmpty {
                trickObject.spinOut = " \(trickObject.spinOut)"
            }
            if !trickObject.spinIn.isEmpty {
                trickObject.spinIn = "\(trickObject.spinIn) "
            }
            trickObject.trickFullName = (fakieStamp + " " + trickObject.spinIn + trickObject.trickName + rewindStamp + trickObject.spinOut);
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
                - Rewind chance:    \(currentDifficulty.settings.rewindOutChance * 100)%
                - Trick CAP:        \(currentDifficulty.settings.tricksCAP)
                """)
        }
}

