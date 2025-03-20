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
    let topsideNegativeTricks = ["Makio", "Soul", "Mizou", "Porn Star", "Acid", "X-Grind", "Torque Soul", "Mistrial", "Christ Makio", "Tea Kettle"]
    
    // CONSTANTS: Spins -- Order: easy to hard
    // IMPORTANT: Ledge is always on the right side (for Left and Right Spins)
    // Forward to Soulplate
    let forwardToSoulplateSpins = ["", "Alley-Oop", "Truespin", "360", "Hurricane", "540 Alley-Oop", "540 Truespin"]
    let forwardToSoulplateSpinsLeft = ["Truespin", "Hurricane", "540 Truespin"]
    let forwardToSoulplateSpinsRight = ["Alley-Oop", "360", "540 Alley-Oop"]
    // Forward to Groove
    let forwardToGrooveSpins = ["FS", "BS", "270 BS", "270 FS", "450 FS", "450 BS"]
    let forwardToGrooveSpinsLeft = ["BS", "270 FS", "450 BS"]
    let forwardToGrooveSpinsRight = ["FS", "270 BS", "450 FS"]
    // Fakie to Soulplate
    let fakieToSoulplateSpins = ["In-Spin", "Out-Spin", "Zero Spin", "Cab Alley-Oop", "Cab Truespin", "540 In-Spin", "540 Out-Spin"]
    let fakieToSoulplateSpinsLeft = ["In-Spin", "Cab Truespin", "540 In-Spin"]
    let fakieToSoulplateSpinsRight = ["Out-Spin", "Cab Alley-Oop", "540 Out-Spin"]
    // Fakie to Groove
    let fakieToGrooveSpins = ["FS", "BS", "270 BS", "270 FS", "450 FS", "450 BS"]
    let fakieToGrooveSpinsLeft = ["FS", "270 BS", "450 FS"]
    let fakieToGrooveSpinsRight = ["BS", "270 FS", "450 BS"]
    // FS to Soulplate
    let fsToSoulplateSpins = ["", "Alley-Oop", "270", "270 Truespin", "450 Alley-Oop", "450 (Hurricane)"]
    let fsToSoulplateSpinsLeft = ["", "270 Truespin", "450 (Hurricane)"]
    let fsToSoulplateSpinsRight = ["Alley-Oop", "270", "450 Alley-Oop"]
    // FS to Groove
    let fsToGrooveSpins = ["FS", "BS", "360 FS"]
    // BS to Soulplate
    let bsToSoulplateSpins = ["", "Truespin", "270", "270 Alley-Oop", "450 Truespin", "450"]
    let bsToSoulplateSpinsLeft = ["Truespin", "270", "450 Truespin"]
    let bsToSoulplateSpinsRight = ["", "270 Alley-Oop", "450"]
    // BS to Groove
    let bsToGrooveSpins = ["BS", "FS", "360 BS"] // FS, 360 BS can be regular or rewind
    
    // Out-Spins
    let forwardOutSpins = ["to Forward", "to Fakie", "360 Out to Forward", "540 to Fakie"] // had "" instead of "to Forward
    let fakieOutSpins = ["to Fakie", "to Forward", "360 Out to Fakie", "540 to Forward"] // had "" instead of "to Fakie
    // FS Out Spins
    let fsOutSpins = ["to Fakie", "to Forward", "270 Out to Fakie", "270 Out to Forward", "450 Out to Fakie", "450 Out to Forward"]
    let fsOutSpinsLeft = ["to Forward", "270 Out to Fakie", "450 Out to Forward"]
    let fsOutSpinsRight = ["to Fakie", "270 Out to Forward", "450 Out to Fakie"]
    //BS Out Spins
    let bsOutSpins = ["to Forward", "to Fakie", "270 Out to Fakie", "270 Out to Forward", "450 Out to Fakie", "450 Out to Forward"]
    let bsOutSpinsLeft = ["to Fakie", "270 Out to Forward", "450 Out to Fakie"]
    let bsOutSpinsRight = ["to Forward", "270 Out to Fakie", "450 Out to Forward"]
    
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
    
    func isDuplicateSwitchUp(trick1: Trick, trick2: Trick) -> Bool {
        // Check if the names are the same
        if trick1.trickName == trick2.trickName {
            if trick1.type == .groove && trick2.type == .groove {
                // Check for groove tricks with exact "FS" or "BS"
                let sides = ["FS", "BS"]
                for side in sides {
                    if trick1.spinIn.contains(side) && trick2.spinIn == side {
                        print("*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n*\n")
                        return true
                    }
                }
            } else if trick1.type == .soulplate && trick2.type == .soulplate {
                if trick1.grindStance == trick2.grindStance {
                    // Check for soulplate tricks with no spin or "Zero Spin"
                    if trick2.spinIn == "" || trick2.spinIn == "Zero Spin" {
                        return true
                    }
                }
            }
        }
        return false
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
                var trick2 = trickGenerator(previousTrick: trick1, trickMode: "exit")
                
                // Check for duplicate conditions
                while isDuplicateSwitchUp(trick1: trick1, trick2: trick2) {
                    print("* Repeated trick prevented: \(trick1.spinIn) \(trick1.trickName) to \(trick2.spinIn) \(trick2.trickName)")
                    trick2 = trickGenerator(previousTrick: trick1, trickMode: "exit")
                }
                
                newTrickName = "\(trick1.trickFullName) \n to \n\(trick2.trickFullName)"
            case 2:  // Triple switch-up
                print("\n---< TRIPLE TRICK >---")
                print("> 1st Trick:")
                let trick1 = trickGenerator(trickMode: "entry")
                
                print("> 2nd Trick:")
                var trick2 = trickGenerator(previousTrick: trick1, trickMode: "mid")
                // Check for duplicate conditions between 1st and 2nd tricks
                while isDuplicateSwitchUp(trick1: trick1, trick2: trick2) {
                    print("* Repeated trick prevented: \(trick1.spinIn) \(trick1.trickName) to \(trick2.spinIn) \(trick2.trickName)");
                    trick2 = trickGenerator(previousTrick: trick1, trickMode: "mid")
                }
                
                print("> 3rd Trick:")
                var trick3 = trickGenerator(previousTrick: trick2, trickMode: "exit")
                // Check for duplicate conditions between 2nd and 3rd tricks
                while isDuplicateSwitchUp(trick1: trick2, trick2: trick3) {
                    print("* Repeated trick prevented: \(trick2.spinIn) \(trick2.trickName) to \(trick3.spinIn) \(trick3.trickName)")
                    trick3 = trickGenerator(previousTrick: trick2, trickMode: "exit")
                }
                newTrickName = "\(trick1.trickFullName) to \n\(trick2.trickFullName) to \n\(trick3.trickFullName)"
            default:  // Single trick
                print("\n---< SINGLE TRICK >---")
                let trick1 = trickGenerator(trickMode: "single")
                newTrickName = trick1.trickFullName
            }
            // remove any double spaces
            newTrickName = newTrickName.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression, range: nil)

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
        var trickNameStamp: String = ""
        var spinInStamp: String = ""
        var spinOutStamp: String = ""
        
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
        trickObject.trickName = allTricks[Int.random(in: 0..<settings.tricksCAP)]
//        trickObject.trickName = grooveTricks[Int.random(in: 0..<2)]
        trickNameStamp = trickObject.trickName

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
            
            if (trickMode == "mid" || trickMode == "exit") {
                if !customSettings.switchUpRewindAllowed {
                    if previousTrick?.spinInDirection == "L" {
                        fakieToSoulplateSpinsAllowed = fakieToSoulplateSpins.filter { !fakieToSoulplateSpinsRight.contains($0) }
                        forwardToSoulplateSpinsAllowed = forwardToSoulplateSpins.filter { !forwardToSoulplateSpinsRight.contains($0) }
                        bsToSoulplateSpinsAllowed = bsToSoulplateSpins.filter { !bsToSoulplateSpinsRight.contains($0) }
                        fsToSoulplateSpinsAllowed = fsToSoulplateSpins.filter { !fsToSoulplateSpinsRight.contains($0) }
                        print("Switch up Rewind Spins Blocked")
                    } else if previousTrick?.spinInDirection == "R" {
                        fakieToSoulplateSpinsAllowed = fakieToSoulplateSpins.filter { !fakieToSoulplateSpinsLeft.contains($0) }
                        forwardToSoulplateSpinsAllowed = forwardToSoulplateSpins.filter { !forwardToSoulplateSpinsLeft.contains($0) }
                        bsToSoulplateSpinsAllowed = bsToSoulplateSpins.filter { !bsToSoulplateSpinsLeft.contains($0) }
                        fsToSoulplateSpinsAllowed = fsToSoulplateSpins.filter { !fsToSoulplateSpinsLeft.contains($0) }
                        print("Switch up Rewind Spins Blocked")
                    } else if previousTrick?.spinInDirection == "N" {
                        fakieToSoulplateSpinsAllowed = fakieToSoulplateSpins
                        forwardToSoulplateSpinsAllowed = forwardToSoulplateSpins
                        bsToSoulplateSpinsAllowed = bsToSoulplateSpins
                        fsToSoulplateSpinsAllowed = fsToSoulplateSpins
                        print("(Neutral) Switch up Rewind Spins NOT Blocked")
                    }
                } else {
                    print("Switch up rewind spins allowed")
                }
            }
            if trickObject.initialStance == .fakie {
                // Choose a spin from the list according to the difficulty
                let matchingCount = fakieToSoulplateSpins[0..<settings.soulplateFakieInSpinsCAP].filter { item in
                    fakieToSoulplateSpinsAllowed.contains(where: { $0.caseInsensitiveCompare(item) == .orderedSame })
                }.count
                // check if no spins are allowed
                if !(matchingCount == 0) {
                    trickObject.spinIn = fakieToSoulplateSpinsAllowed[Int.random(in: 0..<(matchingCount))]
                } else {
                    // if no spins allowed, choose zero spin (this is only for switch ups)
                    trickObject.spinIn = fakieToSoulplateSpins[2]
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
//                    print("Spinning Direction: Neutral")
//                    trickObject.spinInDirection = "N"
                    trickObject.spinInDirection = previousTrick?.spinInDirection ?? "N"
                }
            } else if trickObject.initialStance == .forward {
                // Choose a spin from the list according to the difficulty
                let matchingCount = forwardToSoulplateSpins[0..<settings.soulplateForwardInSpinsCAP].filter { item in
                    forwardToSoulplateSpinsAllowed.contains(where: { $0.caseInsensitiveCompare(item) == .orderedSame })
                }.count
                if !(matchingCount == 0) {
                    trickObject.spinIn = forwardToSoulplateSpinsAllowed[Int.random(in: 0..<(matchingCount))]
                } else {
                    // if no spins allowed, choose no spin
                    trickObject.spinIn = forwardToSoulplateSpins[0]
                }
                
                // Update the skater's current stance
                if trickObject.spinIn.contains("Alley-Oop") || trickObject.spinIn.contains("Truespin") {
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
//                    print("Spinning Direction: Neutral")
//                    trickObject.spinInDirection = "N"
                    trickObject.spinInDirection = previousTrick?.spinInDirection ?? "N"
                }
            } else if trickObject.initialStance == .bs {
                // Choose a spin from the list according to the difficulty
                let matchingCount = bsToSoulplateSpins[0..<settings.grooveBSToSoulplateSpinsCAP].filter { item in
                    bsToSoulplateSpinsAllowed.contains(where: { $0.caseInsensitiveCompare(item) == .orderedSame })
                }.count
                trickObject.spinIn = bsToSoulplateSpinsAllowed[Int.random(in: 0..<(matchingCount))]
                
                // Update the skater's current stance
                if trickObject.spinIn == "Truespin" || trickObject.spinIn == "270 Alley-Oop" || trickObject.spinIn == "450 Truespin" {
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
//                    print("Spinning Direction: Neutral")
//                    trickObject.spinInDirection = "N"
                    trickObject.spinInDirection = previousTrick?.spinInDirection ?? "N"
                }
            } else if trickObject.initialStance == .fs {
                // Choose a spin from the list according to the difficulty
                let matchingCount = fsToSoulplateSpins[0..<settings.grooveFSToSoulplateSpinsCAP].filter { item in
                    fsToSoulplateSpinsAllowed.contains(where: { $0.caseInsensitiveCompare(item) == .orderedSame })
                }.count
                
                if matchingCount > 0 {
                    trickObject.spinIn = fsToSoulplateSpinsAllowed[Int.random(in: 0..<matchingCount)]
                } else {
                    // Fallback if no spins are allowed
                    print("No allowed spins available, using default spin.")
                    trickObject.spinIn = fsToSoulplateSpins.first ?? ""  // Ensure there's always a default to avoid nil.
                }
                
                // Update the skater's current stance
                if trickObject.spinIn == "Alley-Oop" || trickObject.spinIn == "270 Truespin" || trickObject.spinIn == "450 Alley-Oop" {
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
//                    print("Spinning Direction: Neutral")
//                    trickObject.spinInDirection = "N"
                    trickObject.spinInDirection = previousTrick?.spinInDirection ?? "N"
                }
            }
            spinInStamp = trickObject.spinIn
            
            // 1.3 Choose topside
            if topsideNegativeTricks.contains(trickObject.trickName) {
                // Set the topside according to topside chance
                trickObject.isTopside = (Double.random(in: 0...1) < settings.topsideChance)
               // Update the topside stamp
                if trickObject.isTopside {
                   topsideStamp = "Top"
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
                   negativeStamp = "Negative"
               } else {
                   negativeStamp = ""
               }
            }
            
            // 1.5 Choose Spin Out
            var noSpinOut = false
            if trickMode == "single" || trickMode == "exit" {
                if trickObject.grindStance == .fakie {
                    trickObject.spinOut = fakieOutSpins[Int.random(in: 0..<settings.soulplateFakieOutSpinsCAP)]
                    // Update the skater's current stance
                    if trickObject.spinOut.contains("to Forward") {
                        trickObject.outStance = .forward
                    } else {
                        trickObject.outStance = .fakie
                    }
                    // fakie grind + to fakie = no spin
                    if trickObject.spinOut == "to Fakie" {
                        noSpinOut = true
                    }
                } else if trickObject.grindStance == .forward{
                    trickObject.spinOut = forwardOutSpins[Int.random(in: 0..<settings.soulplateForwardOutSpinsCAP)]
                    // Update the skater's current stance
                    if trickObject.spinOut.contains("to Fakie") {
                        trickObject.outStance = .fakie
                    } else {
                        trickObject.outStance = .forward
                    }
                    // fakie grind + to fakie = no spin
                    if trickObject.spinOut == "to Forward" {
                        noSpinOut = true
                    }
                }
            }
            
            // 1.6 Choose if Spin Out is Rewind
            if trickMode == "single" || trickMode == "exit" {
                trickObject.isSpinOutRewind = (Double.random(in: 0...1) < settings.rewindOutChance)
                if !noSpinOut {
                    if (trickObject.spinInDirection == "N") {
                        if (trickObject.isSpinOutRewind) {
                            rewindStamp = "hard-way"
                        }
                    } else if (trickObject.spinInDirection == "R" || trickObject.spinInDirection == "L") {
                        if (trickObject.isSpinOutRewind) {
                            rewindStamp = "rewind"
                        }
                    }
                } else {
                    rewindStamp = ""
//                    if !(trickObject.spinOut == "to Forward" || trickObject.spinOut == "to Fakie") {
//                        rewindStamp = " revert"
//                    }
                }
            }
            
            // 1.7 Find the edge cases: Special named tricks
            // Edge Case: Top Makio = Fishbrain
            if (trickNameStamp == "Makio" && trickObject.isTopside == true) {
                trickNameStamp = "Fishbrain"
                topsideStamp = ""
            }
            // Edge Case: Top Christ Makio = Christ Fishbrain
            if (trickNameStamp == "Christ Makio" && trickObject.isTopside == true) {
                trickNameStamp = "Christ Fishbrain"
                topsideStamp = ""
            }
            // Edge Case: Top Mizou = Sweatstance
            if (trickNameStamp == "Mizou" && trickObject.isTopside == true) {
                trickNameStamp = "Sweatstance"
                topsideStamp = ""
            }
            // Edge Case: Alley-Oop Sweatstance = Kind
            if (trickNameStamp == "Sweatstance" && trickObject.spinIn == "Alley-Oop") {
                trickNameStamp = "Kind Grind"
                spinInStamp = ""
            }
            // Edge Case: Cab Alley-Oop Sweatstance = Cab Kind
            if (trickNameStamp == "Sweatstance" && trickObject.spinIn == "Cab Alley-Oop") {
                trickNameStamp = "Kind Grind"
                spinInStamp = "Cab"
            }
            // Edge Case: Truespin Sweatstance = Truespin Kind
            if (trickNameStamp == "Sweatstance" && (trickObject.spinIn == "Truespin" || trickObject.spinIn == "Cab Truespin" || trickObject.spinIn == "Zero Spin")) {
                trickNameStamp = "Kind Grind"
            }
            // Edge Case: Alley-Oop Top Mistrial = Misfit
            if (trickNameStamp == "Mistrial" && trickObject.isTopside == true && trickObject.spinIn == "Alley-Oop") {
                trickNameStamp = "Misfit"
                spinInStamp = ""
                topsideStamp = ""
            }
            // Edge Case: Cab Alley-Oop top Mistrial = Misfit
            if (trickNameStamp == "Mistrial" && trickObject.isTopside == true && trickObject.spinIn == "Cab Alley-Oop") {
                trickNameStamp = "Misfit"
                spinInStamp = "Cab"
                topsideStamp = ""
            }
            // Edge Case: Truespin Top Mistrial = Truespin Misfit
            // MAYBE USE CURRENT STANCE FAKIE INSTEAD OF SPIN IN???
            if (trickNameStamp == "Mistrial" && trickObject.isTopside == true && (trickObject.spinIn == "Truespin" || trickObject.spinIn == "Cab Truespin")) {
                trickNameStamp = "Misfit"
                topsideStamp = ""
            }
            // Edge Case: fakie stance + torque soul = soulyale
            if (trickNameStamp == "Torque Soul" && trickObject.grindStance == .fakie) {
                trickNameStamp = "Soyale"
            }
            
            // Edge Case: fakie stance + torque soul = soulyale
            // Edge Case: In spin top soulyale??? makes no sense
            
            // FINAL STEP: Set trick name
//            trickObject.trickFullName = ("\(spinIn)\(negativeStamp)\(topsideStamp) \(trickObject.trickName)\(rewindStamp) \(spinOut)")
            
        } else {
            // GROOVE TRICK CHOSEN !!!
            trickObject.type = .groove
            
            // 2.2 Choose Spin in according to stance
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
                let matchingCount = fakieToGrooveSpins[0..<settings.grooveFakieInSpinsCAP].filter { item in
                    fakieToGrooveSpinsAllowed.contains(where: { $0.caseInsensitiveCompare(item) == .orderedSame })
                }.count
                if !(matchingCount == 0) {
                    trickObject.spinIn = fakieToGrooveSpinsAllowed[Int.random(in: 0..<(matchingCount))]
                } else {
                    if previousTrick?.spinInDirection == "R" {
                        trickObject.spinIn = fakieToGrooveSpinsRight[0]
                    } else if previousTrick?.spinInDirection == "L" {
                        trickObject.spinIn = fakieToGrooveSpinsLeft[0]
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
                    print("Spinning Direction: Neutral *** CHECK THIS, IT SHOULD NEVER BE NEUTRAL AFTER A GROOVE TRICK (always must spin 90 degrees)")
//                    trickObject.spinInDirection = "N"
//                    trickObject.spinInDirection = previousTrick?.spinInDirection ?? "N"
                }
            } else if (trickObject.initialStance == .forward) {
                // Choose a spin from the list according to the difficulty
                let matchingCount = forwardToGrooveSpins[0..<settings.grooveForwardInSpinsCAP].filter { item in
                    forwardToGrooveSpinsAllowed.contains(where: { $0.caseInsensitiveCompare(item) == .orderedSame })
                }.count
                if !(matchingCount == 0) {
                    trickObject.spinIn = forwardToGrooveSpinsAllowed[Int.random(in: 0..<(matchingCount))]
                } else {
                    if previousTrick?.spinInDirection == "R" {
                        trickObject.spinIn = forwardToGrooveSpinsRight[0]
                    } else if previousTrick?.spinInDirection == "L" {
                        trickObject.spinIn = forwardToGrooveSpinsLeft[0]
                    }
                }
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
//                if (trickMode == "single" || trickMode == "entry") {
//                } else if (trickMode == "mid" || trickMode == "exit") {
//                }
                // REMINDER: in case of "FS Fahrv to FS Svannah -> SpinInDirection = previousTrick.spinInDirection
                trickObject.spinIn = bsToGrooveSpins[Int.random(in: 0..<settings.grooveBSToGrooveSpinsCAP)]
                // Update the skater's current stance
                if trickObject.spinIn.contains("FS") {
                    trickObject.grindStance = .fs
                } else if trickObject.spinIn.contains("BS") {
                    trickObject.grindStance = .bs
                }
            } else if trickObject.initialStance == .fs {
//                (trickMode == "single" || trickMode == "entry") {
//                } else if (trickMode == "mid" || trickMode == "exit") {
//                }
                // REMINDER: in case of "FS Fahrv to FS Svannah -> SpinInDirection = previousTrick.spinInDirection
                trickObject.spinIn = fsToGrooveSpins[Int.random(in: 0..<settings.grooveFSToGrooveSpinsCAP)]
                // Update the skater's current stance
                if trickObject.spinIn.contains("BS") {
                    trickObject.grindStance = .bs
                } else if trickObject.spinIn.contains("FS") {
                    trickObject.grindStance = .fs
                }
            }
            
            spinInStamp = trickObject.spinIn
            
            // !!!!!! FIGURE THIS STUFF ABOVE OUT !!!!!!! (bs and fs)
            
            // 2.6 Choose if Spin Out is Rewind
            var fsOutSpinsAllowed = fsOutSpins
            var bsOutSpinsAllowed = bsOutSpins
            var rewindChosen = false
            
            if trickMode == "single" || trickMode == "exit" {
                rewindChosen = (Double.random(in: 0...1) < settings.rewindOutChance)
                print("Rewind chosen")
                if rewindChosen {
                    // Remove same direction out spins
                    if trickObject.spinInDirection == "L" {
                        fsOutSpinsAllowed = fsOutSpins.filter { !fsOutSpinsLeft.contains($0) }
                        bsOutSpinsAllowed = bsOutSpins.filter { !bsOutSpinsLeft.contains($0) }
                        print("YES rewind chosen! removing all rewind spins 1")
//                        trickObject.spinOutDirection = "R"
                    } else if trickObject.spinInDirection == "R" {
                        fsOutSpinsAllowed = fsOutSpins.filter { !fsOutSpinsRight.contains($0) }
                        bsOutSpinsAllowed = bsOutSpins.filter { !bsOutSpinsRight.contains($0) }
                        print("YES rewind chosen! removing all rewind spins 2")
//                        trickObject.spinOutDirection = "L"
                    } else {
                        print("YES rewind chosen! (somehow reached else statement)")
                    }
                } else {
                    // Remove rewind out spins
                    if trickObject.spinInDirection == "L" {
                        fsOutSpinsAllowed = fsOutSpins.filter { !fsOutSpinsRight.contains($0) }
                        bsOutSpinsAllowed = bsOutSpins.filter { !bsOutSpinsRight.contains($0) }
                        print("NOT rewind chosen! removing all rewind spins 1")
//                        trickObject.spinOutDirection = "L"
                    } else if trickObject.spinInDirection == "R" {
                        fsOutSpinsAllowed = fsOutSpins.filter { !fsOutSpinsLeft.contains($0) }
                        bsOutSpinsAllowed = bsOutSpins.filter { !bsOutSpinsLeft.contains($0) }
                        print("NOT rewind chosen! removing all rewind spins 2")
//                        trickObject.spinOutDirection = "R"
                    } else {
                        print("NOT rewind chosen! (somehow reached else statement)")
                    }
                }
            }
            
            // 2.3 Choose Spin Out
            if trickMode == "single" || trickMode == "exit" {
                if trickObject.grindStance == .fs {
                    let matchingCount = fsOutSpins[0..<settings.fsOutSpinsCAP].filter { item in
                        fsOutSpinsAllowed.contains(where: { $0.caseInsensitiveCompare(item) == .orderedSame })
                    }.count
                    trickObject.spinOut = fsOutSpinsAllowed[Int.random(in: 0..<(matchingCount))]
                    spinOutStamp = trickObject.spinOut
                    if trickObject.spinInDirection == "L" {
                        if fsOutSpinsRight.contains(trickObject.spinOut) {
                            trickObject.isSpinOutRewind = true
                        }
                    } else if trickObject.spinInDirection == "R" {
                        if fsOutSpinsLeft.contains(trickObject.spinOut) {
                            trickObject.isSpinOutRewind = true
                        }
                    }
                } else if trickObject.grindStance == .bs {
                    let matchingCount = bsOutSpins[0..<settings.bsOutSpinsCAP].filter { item in
                        bsOutSpinsAllowed.contains(where: { $0.caseInsensitiveCompare(item) == .orderedSame })
                    }.count
                    trickObject.spinOut = bsOutSpinsAllowed[Int.random(in: 0..<(matchingCount))]
                    spinOutStamp = trickObject.spinOut
                    if trickObject.spinInDirection == "L" {
                        if bsOutSpinsRight.contains(trickObject.spinOut) {
                            trickObject.isSpinOutRewind = true
                        }
                    } else if trickObject.spinInDirection == "R" {
                        if bsOutSpinsLeft.contains(trickObject.spinOut) {
                            trickObject.isSpinOutRewind = true
                        }
                    }
                }
                // Update rewindStamp
                if trickObject.isSpinOutRewind {
                    rewindStamp = "rewind"
                } else {
                    rewindStamp = ""
//                    rewindStamp = " revert"
                }
                if trickObject.spinOut == "to Forward" || trickObject.spinOut == "to Fakie" {
                    rewindStamp = ""
                }
                
                
                    
//                if !(trickObject.spinOut == "to Forward" || trickObject.spinOut  == "to Fakie") {
//                    print("HAHAHAHAHHAHAHAHAHAHAHHAHAa")
//                    if trickObject.isSpinOutRewind {
//                        rewindStamp = " Rewind"
//                    } else {
//                        rewindStamp = ""
//                    }
//                }
            }

            
            // Update spin out rewindStamp
//            if (trickObject.spinInDirection == "L" &&
            
            // 2.4 Choose if Spin Out is Rewind
            // ?? should i even do this? everyone's frontside and backside grinds are different & different shoulder fakie
            // Forward + BS || Fakie + 270 BS
            // Fakie
//            rewindStamp = "";


            // 2.5 Find the edge cases and address them
            // Edge Case: FS grind = Frontside // maybe just leave the way it is
//            if (spinIn == "FS" && spinIn == "270 FS") {
//              spinIn = "270 FS (Truespin)"
//            }
            // Edge Case: BS Grind = Backside Grind && 270 BS Grind = 270 Backside Grind
            if (trickObject.trickName == "Grind" && trickObject.spinIn.contains("BS")) {
                trickNameStamp = "Backside Grind"
              if (trickObject.spinIn == "BS") {
                  spinInStamp = ""
              } else if (trickObject.spinIn == "270 BS") {
                  spinInStamp = "270"
              } else if (trickObject.spinIn == "360 BS") {
                  spinInStamp = "360"
              } else if (trickObject.spinIn == "450 BS") {
                  spinInStamp = "450"
              }
            }
            // Edge Case: FS Grind = Frontside Grind && 270 FS Grind = 270 Frontside Grind
            if (trickObject.trickName == "Grind" && trickObject.spinIn.contains("FS")) {
                trickNameStamp = "Frontside Grind"
              if (trickObject.spinIn == "FS") {
                  spinInStamp = ""
              } else if (trickObject.spinIn == "270 FS") {
                  spinInStamp = "270"
              } else if (trickObject.spinIn == "360 FS") {
                  spinInStamp = "360"
              } else if (trickObject.spinIn == "450 FS") {
                  spinInStamp = "450"
              }
            }
            // Edge Case: If previous trick grind stance raw value == trickobject.spinIn { trickobject.spinin = "" }
//            if (previousTrick?.grindStance.rawValue == trickObject.spinIn) {
//                trickObject.spinIn = ""
//            }

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
                spinOutStamp = "\(trickObject.spinOut)"
            }
            trickObject.trickFullName = ("\(spinInStamp) \(negativeStamp) \(topsideStamp) \(trickNameStamp) \(rewindStamp) \(spinOutStamp)")
        } else if trickObject.type == .groove{
            if !trickObject.spinOut.isEmpty {
                spinOutStamp = "\(spinOutStamp)"
            }
            if !trickObject.spinIn.isEmpty {
                spinInStamp = "\(spinInStamp)"
            }
            trickObject.trickFullName = ("\(fakieStamp) \(spinInStamp) \(trickNameStamp) \(rewindStamp) \(spinOutStamp)");
        }
        
        trickObject.trickFullName = trickObject.trickFullName.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression, range: nil)

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

