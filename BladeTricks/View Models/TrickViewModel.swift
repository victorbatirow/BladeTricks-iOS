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
    let forwardToSoulplateSpins: [SpinOption] = [
        SpinOption(name: "", direction: "N0", difficulty: 0),  // No spin
        SpinOption(name: "Alley-Oop", direction: "R180", difficulty: 1),
        SpinOption(name: "Truespin", direction: "L180", difficulty: 2),
        SpinOption(name: "360", direction: "R360", difficulty: 3),
        SpinOption(name: "Hurricane", direction: "L360", difficulty: 4),
        SpinOption(name: "540 Alley-Oop", direction: "R540", difficulty: 5),
        SpinOption(name: "540 Truespin", direction: "L540", difficulty: 6)
    ]

    // Forward to Groove
    let forwardToGrooveSpins: [SpinOption] = [
        SpinOption(name: "FS", direction: "R90", difficulty: 0),
        SpinOption(name: "BS", direction: "L90", difficulty: 1),
        SpinOption(name: "270 BS", direction: "R270", difficulty: 2),
        SpinOption(name: "270 FS", direction: "L270", difficulty: 3),
        SpinOption(name: "450 FS", direction: "R450", difficulty: 4),
        SpinOption(name: "450 BS", direction: "L450", difficulty: 5)
    ]

    // Fakie to Soulplate
    let fakieToSoulplateSpins: [SpinOption] = [
        SpinOption(name: "In-Spin", direction: "L180", difficulty: 0),
        SpinOption(name: "Out-Spin", direction: "R180", difficulty: 1),
        SpinOption(name: "Zero Spin", direction: "N0", difficulty: 2),
        SpinOption(name: "Cab Alley-Oop", direction: "R360", difficulty: 3),
        SpinOption(name: "Cab Truespin", direction: "L360", difficulty: 4),
        SpinOption(name: "540 In-Spin", direction: "L540", difficulty: 5),
        SpinOption(name: "540 Out-Spin", direction: "R540", difficulty: 6)
    ]

    // Fakie to Groove
    let fakieToGrooveSpins: [SpinOption] = [
        SpinOption(name: "FS", direction: "L90", difficulty: 0),
        SpinOption(name: "BS", direction: "R90", difficulty: 1),
        SpinOption(name: "270 BS", direction: "L270", difficulty: 2),
        SpinOption(name: "270 FS", direction: "R270", difficulty: 3),
        SpinOption(name: "450 FS", direction: "L450", difficulty: 4),
        SpinOption(name: "450 BS", direction: "R450", difficulty: 5)
    ]

    // FS to Soulplate
    let fsToSoulplateSpins: [SpinOption] = [
        SpinOption(name: "", direction: "L90", difficulty: 0),
        SpinOption(name: "Alley-Oop", direction: "R90", difficulty: 1),
        SpinOption(name: "270", direction: "R270", difficulty: 2),
        SpinOption(name: "270 Truespin", direction: "L270", difficulty: 3),
        SpinOption(name: "450 Alley-Oop", direction: "R450", difficulty: 4),
        SpinOption(name: "450 (Hurricane)", direction: "L450", difficulty: 5)
    ]

    // FS to Groove
    let fsToGrooveSpins: [SpinOption] = [
        SpinOption(name: "FS", direction: "N0", difficulty: 0), // No additional rotation
        SpinOption(name: "BS", direction: "C180", difficulty: 1),
        SpinOption(name: "Rewind BS", direction: "R180", difficulty: 2), // Changed from B180 to clear C/R distinction
        SpinOption(name: "360 FS", direction: "C360", difficulty: 3),
        SpinOption(name: "Rewind 360 FS", direction: "R360", difficulty: 4) // Changed from B360 to clear C/R distinction
    ]

    // BS to Soulplate
    let bsToSoulplateSpins: [SpinOption] = [
        SpinOption(name: "", direction: "R90", difficulty: 0),
        SpinOption(name: "Truespin", direction: "L90", difficulty: 1),
        SpinOption(name: "270", direction: "L270", difficulty: 2), // WHY?
        SpinOption(name: "270 Alley-Oop", direction: "R270", difficulty: 3),
        SpinOption(name: "450 Truespin", direction: "L450", difficulty: 4),
        SpinOption(name: "450", direction: "R450", difficulty: 5)
    ]

    // BS to Groove
    let bsToGrooveSpins: [SpinOption] = [
        SpinOption(name: "BS", direction: "N0", difficulty: 0), // No additional rotation
        SpinOption(name: "FS", direction: "C180", difficulty: 1),
        SpinOption(name: "Rewind FS", direction: "R180", difficulty: 2), //add these for rewind logic - B for both directions
        SpinOption(name: "360 BS", direction: "C360", difficulty: 3),
        SpinOption(name: "Rewind 360 BS", direction: "R360", difficulty: 4) //add these for rewind logic - B for both directions
    ]

    // Out-Spins
    let forwardOutSpins: [SpinOption] = [
        SpinOption(name: "to Forward", direction: "N0", difficulty: 0),
        SpinOption(name: "to Fakie", direction: "N180", difficulty: 1), 
//        SpinOption(name: "to Fakie", direction: "C180", difficulty: 1), // figure this out
        SpinOption(name: "360 Out to Forward", direction: "R360", difficulty: 2),
//        SpinOption(name: "360 Out to Forward", direction: "L360", difficulty: 2), // figure this out
        SpinOption(name: "540 to Fakie", direction: "R540", difficulty: 3)
//        SpinOption(name: "540 to Fakie", direction: "L540", difficulty: 3) // figure this out
        // FIGURE THIS OUT FIRST: But which way is the hard way out???
    ]

    let fakieOutSpins: [SpinOption] = [
        SpinOption(name: "to Fakie", direction: "N0", difficulty: 0),
        SpinOption(name: "to Forward", direction: "N180", difficulty: 1),
//        SpinOption(name: "to Forward", direction: "R180", difficulty: 1), // figure this out
        SpinOption(name: "360 Out to Fakie", direction: "R360", difficulty: 2),
//        SpinOption(name: "360 Out to Fakie", direction: "L360", difficulty: 2), // figure this out
        SpinOption(name: "540 to Forward", direction: "R540", difficulty: 3)
//        SpinOption(name: "540 to Forward", direction: "L540", difficulty: 3) // figure this out
        // FIGURE THIS OUT FIRST: But which way is the hard way out???
    ]

    // FS Out Spins
    let fsOutSpins: [SpinOption] = [
        SpinOption(name: "to Fakie", direction: "R90", difficulty: 0),
        SpinOption(name: "to Forward", direction: "L90", difficulty: 1),
        SpinOption(name: "270 Out to Fakie", direction: "L270", difficulty: 2),
        SpinOption(name: "270 Out to Forward", direction: "R270", difficulty: 3),
        SpinOption(name: "450 Out to Fakie", direction: "R450", difficulty: 4),
        SpinOption(name: "450 Out to Forward", direction: "L450", difficulty: 5)
    ]

    // BS Out Spins
    let bsOutSpins: [SpinOption] = [
        SpinOption(name: "to Forward", direction: "R90", difficulty: 0),
        SpinOption(name: "to Fakie", direction: "L90", difficulty: 1),
        SpinOption(name: "270 Out to Fakie", direction: "R270", difficulty: 2),
        SpinOption(name: "270 Out to Forward", direction: "L270", difficulty: 3),
        SpinOption(name: "450 Out to Fakie", direction: "L450", difficulty: 4),
        SpinOption(name: "450 Out to Forward", direction: "R450", difficulty: 5)
    ]
    
    struct SpinOption {
        let name: String
        let direction: String
        let difficulty: Int  // Lower number = easier
    }
    
    // Add these properties to your class
    // For Forward to Soul Plate spins
    var forwardToSoulplateSpinsLeft: [SpinOption] {
        return forwardToSoulplateSpins.filter { $0.direction.hasPrefix("L") }
    }

    var forwardToSoulplateSpinsRight: [SpinOption] {
        return forwardToSoulplateSpins.filter { $0.direction.hasPrefix("R") }
    }

    // For Forward to Groove spins
    var forwardToGrooveSpinsLeft: [SpinOption] {
        return forwardToGrooveSpins.filter { $0.direction.hasPrefix("L") }
    }

    var forwardToGrooveSpinsRight: [SpinOption] {
        return forwardToGrooveSpins.filter { $0.direction.hasPrefix("R") }
    }

    // For Fakie to Soul Plate spins
    var fakieToSoulplateSpinsLeft: [SpinOption] {
        return fakieToSoulplateSpins.filter { $0.direction.hasPrefix("L") }
    }

    var fakieToSoulplateSpinsRight: [SpinOption] {
        return fakieToSoulplateSpins.filter { $0.direction.hasPrefix("R") }
    }

    // For Fakie to Groove spins
    var fakieToGrooveSpinsLeft: [SpinOption] {
        return fakieToGrooveSpins.filter { $0.direction.hasPrefix("L") }
    }

    var fakieToGrooveSpinsRight: [SpinOption] {
        return fakieToGrooveSpins.filter { $0.direction.hasPrefix("R") }
    }

    // For FS to Soul Plate spins
    var fsToSoulplateSpinsLeft: [SpinOption] {
        return fsToSoulplateSpins.filter { $0.direction.hasPrefix("L") }
    }

    var fsToSoulplateSpinsRight: [SpinOption] {
        return fsToSoulplateSpins.filter { $0.direction.hasPrefix("R") }
    }
    
    // For FS to Groove spins
    var fsToGrooveContinuousSpins: [SpinOption] {
        return fsToGrooveSpins.filter { $0.direction.hasPrefix("C") }
    }

    var fsToGrooveRewindSpins: [SpinOption] {
        return fsToGrooveSpins.filter { $0.direction.hasPrefix("R") }
    }

    var fsToGrooveNoSpins: [SpinOption] {
        return fsToGrooveSpins.filter { $0.direction.hasPrefix("N") }
    }

    // For BS to Soul Plate spins
    var bsToSoulplateSpinsLeft: [SpinOption] {
        return bsToSoulplateSpins.filter { $0.direction.hasPrefix("L") }
    }

    var bsToSoulplateSpinsRight: [SpinOption] {
        return bsToSoulplateSpins.filter { $0.direction.hasPrefix("R") }
    }
    
    // For BS to Groove spins
    var bsToGrooveContinuousSpins: [SpinOption] {
        return bsToGrooveSpins.filter { $0.direction.hasPrefix("C") }
    }

    var bsToGrooveRewindSpins: [SpinOption] {
        return bsToGrooveSpins.filter { $0.direction.hasPrefix("R") }
    }

    var bsToGrooveNoSpins: [SpinOption] {
        return bsToGrooveSpins.filter { $0.direction.hasPrefix("N") }
    }
    // For FS Out spins
    var fsOutSpinsLeft: [SpinOption] {
        return fsOutSpins.filter { $0.direction.hasPrefix("L") }
    }

    var fsOutSpinsRight: [SpinOption] {
        return fsOutSpins.filter { $0.direction.hasPrefix("R") }
    }

    // For BS Out spins
    var bsOutSpinsLeft: [SpinOption] {
        return bsOutSpins.filter { $0.direction.hasPrefix("L") }
    }

    var bsOutSpinsRight: [SpinOption] {
        return bsOutSpins.filter { $0.direction.hasPrefix("R") }
    }
        
    
//    // CONSTANTS: Spins -- Order: easy to hard
//    // IMPORTANT: Ledge is always on the right side (for Left and Right Spins)
//    // Forward to Soulplate
//    let forwardToSoulplateSpins = ["", "Alley-Oop", "Truespin", "360", "Hurricane", "540 Alley-Oop", "540 Truespin"]
//    let forwardToSoulplateSpinsLeft = ["Truespin", "Hurricane", "540 Truespin"]
//    let forwardToSoulplateSpinsRight = ["Alley-Oop", "360", "540 Alley-Oop"]
//    // Forward to Groove
//    let forwardToGrooveSpins = ["FS", "BS", "270 BS", "270 FS", "450 FS", "450 BS"]
//    let forwardToGrooveSpinsLeft = ["BS", "270 FS", "450 BS"]
//    let forwardToGrooveSpinsRight = ["FS", "270 BS", "450 FS"]
//    // Fakie to Soulplate
//    let fakieToSoulplateSpins = ["In-Spin", "Out-Spin", "Zero Spin", "Cab Alley-Oop", "Cab Truespin", "540 In-Spin", "540 Out-Spin"]
//    let fakieToSoulplateSpinsLeft = ["In-Spin", "Cab Truespin", "540 In-Spin"]
//    let fakieToSoulplateSpinsRight = ["Out-Spin", "Cab Alley-Oop", "540 Out-Spin"]
//    // Fakie to Groove
//    let fakieToGrooveSpins = ["FS", "BS", "270 BS", "270 FS", "450 FS", "450 BS"]
//    let fakieToGrooveSpinsLeft = ["FS", "270 BS", "450 FS"]
//    let fakieToGrooveSpinsRight = ["BS", "270 FS", "450 BS"]
//    // FS to Soulplate
//    let fsToSoulplateSpins = ["", "Alley-Oop", "270", "270 Truespin", "450 Alley-Oop", "450 (Hurricane)"]
//    let fsToSoulplateSpinsLeft = ["", "270 Truespin", "450 (Hurricane)"]
//    let fsToSoulplateSpinsRight = ["Alley-Oop", "270", "450 Alley-Oop"]
//    // FS to Groove
//    let fsToGrooveSpins = ["FS", "BS", "360 FS"]
//    // BS to Soulplate
//    let bsToSoulplateSpins = ["", "Truespin", "270", "270 Alley-Oop", "450 Truespin", "450"]
//    let bsToSoulplateSpinsLeft = ["Truespin", "270", "450 Truespin"]
//    let bsToSoulplateSpinsRight = ["", "270 Alley-Oop", "450"]
//    // BS to Groove
//    let bsToGrooveSpins = ["BS", "FS", "360 BS"] // FS, 360 BS can be regular or rewind
//    
//    // Out-Spins
//    let forwardOutSpins = ["to Forward", "to Fakie", "360 Out to Forward", "540 to Fakie"] // had "" instead of "to Forward
//    let fakieOutSpins = ["to Fakie", "to Forward", "360 Out to Fakie", "540 to Forward"] // had "" instead of "to Fakie
//    // FS Out Spins
//    let fsOutSpins = ["to Fakie", "to Forward", "270 Out to Fakie", "270 Out to Forward", "450 Out to Fakie", "450 Out to Forward"]
//    let fsOutSpinsLeft = ["to Forward", "270 Out to Fakie", "450 Out to Forward"]
//    let fsOutSpinsRight = ["to Fakie", "270 Out to Forward", "450 Out to Fakie"]
//    //BS Out Spins
//    let bsOutSpins = ["to Forward", "to Fakie", "270 Out to Fakie", "270 Out to Forward", "450 Out to Fakie", "450 Out to Forward"]
//    let bsOutSpinsLeft = ["to Fakie", "270 Out to Forward", "450 Out to Fakie"]
//    let bsOutSpinsRight = ["to Forward", "270 Out to Fakie", "450 Out to Forward"]
    
    // SkaterSpinDirection = ["N", "L90", "R90", "L, "]
    
    @Published var displayTrickName: String = "Press button to generate trick."
    @Published var currentDifficulty: Difficulty = Difficulty.levels[0]  // Default to first difficulty
    @Published var customSettings: Difficulty.DifficultySettings
    @Published var SwitchUpMode: Int = 0  // 0 for single, 1 for double, 2 for triple
    // Spin Settings Managers
    @Published var inSpinManager: SpinSettingsManager!
    @Published var outSpinManager: SpinSettingsManager!
    @Published var switchUpSpinManager: SpinSettingsManager!
    
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
        
        // Initialize spin settings managers
        self.inSpinManager = SpinSettingsManager(spinType: .inSpin, viewModel: self)
        self.outSpinManager = SpinSettingsManager(spinType: .outSpin, viewModel: self)
        self.switchUpSpinManager = SpinSettingsManager(spinType: .switchUpSpin, viewModel: self)
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
        // Only apply custom settings when custom difficulty is selected
        if currentDifficulty.isCustom {
            // Update the current difficulty settings if we're in custom mode
            currentDifficulty.settings = customSettings
            saveCustomSettings()
            
            print("Applied custom settings: fakie=\(customSettings.fakieChance)")
        } else {
            print("Not applying custom settings because current difficulty is: \(currentDifficulty.difficultyLevel.rawValue)")
        }
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
        // Debug print to verify which settings are being used
        print("Generating trick with difficulty: \(currentDifficulty.difficultyLevel.rawValue)")
        print("  - Fakie chance: \(currentDifficulty.settings.fakieChance)")
        print("  - Topside chance: \(currentDifficulty.settings.topsideChance)")
        
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
        
        // Print to confirm which settings we're using
        print("trickGenerator using difficulty: \(currentDifficulty.difficultyLevel.rawValue)")
        print("  - With settings: fakie=\(currentDifficulty.settings.fakieChance), topside=\(currentDifficulty.settings.topsideChance)")

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
        
        
        // Choose a soulplate or groove trick (this will determine the spin, topside and negative options) - Difficulty applied
        trickObject.trickName = allTricks[Int.random(in: 0..<settings.tricksCAP)]
//        trickObject.trickName = grooveTricks[Int.random(in: 0..<2)]
        trickNameStamp = trickObject.trickName

        // Find out if the chosen trick is done with soul plate
        if soulplateTricks.contains(trickObject.trickName) {
            // SOULPLATE TRICK CHOSEN !!!
            trickObject.type = .soulplate
            
            // 1.2 Choose Spin in according to stance
            var fakieToSoulplateSpinsAllowed = fakieToSoulplateSpins
            var forwardToSoulplateSpinsAllowed = forwardToSoulplateSpins
            var bsToSoulplateSpinsAllowed = bsToSoulplateSpins
            var fsToSoulplateSpinsAllowed = fsToSoulplateSpins
            
            // Remove rewind spins for switch ups
            if (trickMode == "mid" || trickMode == "exit") {
                if !customSettings.switchUpRewindAllowed {
                    // For the soulplate section around line 366
                    if previousTrick?.spinInDirection == "L" {
                        fakieToSoulplateSpinsAllowed = fakieToSoulplateSpins.filter { spin in
                            !fakieToSoulplateSpinsRight.contains { rightSpin in rightSpin.name == spin.name }
                        }
                        forwardToSoulplateSpinsAllowed = forwardToSoulplateSpins.filter { spin in
                            !forwardToSoulplateSpinsRight.contains { rightSpin in rightSpin.name == spin.name }
                        }
                        bsToSoulplateSpinsAllowed = bsToSoulplateSpins.filter { spin in
                            !bsToSoulplateSpinsRight.contains { rightSpin in rightSpin.name == spin.name }
                        }
                        fsToSoulplateSpinsAllowed = fsToSoulplateSpins.filter { spin in
                            !fsToSoulplateSpinsRight.contains { rightSpin in rightSpin.name == spin.name }
                        }
                        print("Switch up Rewind Spins Blocked")
                    } else if previousTrick?.spinInDirection == "R" {
                        fakieToSoulplateSpinsAllowed = fakieToSoulplateSpins.filter { spin in
                            !fakieToSoulplateSpinsLeft.contains { leftSpin in leftSpin.name == spin.name }
                        }
                        forwardToSoulplateSpinsAllowed = forwardToSoulplateSpins.filter { spin in
                            !forwardToSoulplateSpinsLeft.contains { leftSpin in leftSpin.name == spin.name }
                        }
                        bsToSoulplateSpinsAllowed = bsToSoulplateSpins.filter { spin in
                            !bsToSoulplateSpinsLeft.contains { leftSpin in leftSpin.name == spin.name }
                        }
                        fsToSoulplateSpinsAllowed = fsToSoulplateSpins.filter { spin in
                            !fsToSoulplateSpinsLeft.contains { leftSpin in leftSpin.name == spin.name }
                        }
                        print("Switch up Rewind Spins Blocked")
                    }
                } else {
                    print("Switch up rewind spins allowed")
                }
            }
            if trickObject.initialStance == .fakie {
                // Filter by difficulty first
                let spinsWithinDifficulty = fakieToSoulplateSpins.filter { $0.difficulty < settings.soulplateFakieInSpinsCAP }
                
                // Then filter by allowed spins (for rewind blocking)
                let allowedSpins = spinsWithinDifficulty.filter { difficultySpin in
                    fakieToSoulplateSpinsAllowed.contains { allowedSpin in
                        allowedSpin.name == difficultySpin.name
                    }
                }
                
                if !allowedSpins.isEmpty {
                    // Pick a random spin from allowed ones
                    let randomSpin = allowedSpins.randomElement()!
                    trickObject.spinIn = randomSpin.name
                } else {
                    // Fallback to Zero Spin
                    let zeroSpin = fakieToSoulplateSpins.first { $0.name == "Zero Spin" }
                    trickObject.spinIn = zeroSpin?.name ?? ""
                }
                // Update the skater's current stance
                if trickObject.spinIn.contains("In-Spin") || trickObject.spinIn.contains("Out-Spin") {
                    trickObject.grindStance = .forward
                } else {
                    trickObject.grindStance = .fakie
                }
                // Update skater's spin direction
                if (fakieToSoulplateSpinsLeft.contains(where: { $0.name == trickObject.spinIn })) {
                    print("Spinning Direction: Left")
                    trickObject.spinInDirection = "L"
                } else if (fakieToSoulplateSpinsRight.contains(where: { $0.name == trickObject.spinIn })) {
                    print("Spinning Direction: Right")
                    trickObject.spinInDirection = "R"
                } else {
                    trickObject.spinInDirection = previousTrick?.spinInDirection ?? "N"
                }
            } else if trickObject.initialStance == .forward {
                // Filter by difficulty first
                let spinsWithinDifficulty = forwardToSoulplateSpins.filter { $0.difficulty < settings.soulplateForwardInSpinsCAP }

                // Then filter by allowed spins (for rewind blocking)
                let allowedSpins = spinsWithinDifficulty.filter { difficultySpin in
                    forwardToSoulplateSpinsAllowed.contains { allowedSpin in
                        allowedSpin.name == difficultySpin.name
                    }
                }

                if !allowedSpins.isEmpty {
                    // Pick a random spin from allowed ones
                    let randomSpin = allowedSpins.randomElement()!
                    trickObject.spinIn = randomSpin.name
                } else {
                    // Fallback to no spin
                    let noSpin = forwardToSoulplateSpins.first { $0.name == "" }
                    trickObject.spinIn = noSpin?.name ?? ""
                }
                
                // Update the skater's current stance
                if trickObject.spinIn.contains("Alley-Oop") || trickObject.spinIn.contains("Truespin") {
                    trickObject.grindStance = .fakie
                } else {
                    trickObject.grindStance = .forward
                }
                // Update skater's spin direction
                if (forwardToSoulplateSpinsLeft.contains(where: { $0.name == trickObject.spinIn })) {
                    print("Spinning Direction: Left")
                    trickObject.spinInDirection = "L"
                } else if (forwardToSoulplateSpinsRight.contains(where: { $0.name == trickObject.spinIn })) {
                    print("Spinning Direction: Right")
                    trickObject.spinInDirection = "R"
                } else {
                    trickObject.spinInDirection = previousTrick?.spinInDirection ?? "N"
                }
            } else if trickObject.initialStance == .bs {
                // Filter by difficulty first
                let spinsWithinDifficulty = bsToSoulplateSpins.filter { $0.difficulty < settings.grooveBSToSoulplateSpinsCAP }

                // Then filter by allowed spins (for rewind blocking)
                let allowedSpins = spinsWithinDifficulty.filter { difficultySpin in
                    bsToSoulplateSpinsAllowed.contains { allowedSpin in
                        allowedSpin.name == difficultySpin.name
                    }
                }

                if !allowedSpins.isEmpty {
                    // Pick a random spin from allowed ones
                    let randomSpin = allowedSpins.randomElement()!
                    trickObject.spinIn = randomSpin.name
                } else {
                    // Fallback to no spin
                    let noSpin = bsToSoulplateSpins.first { $0.name == "" }
                    trickObject.spinIn = noSpin?.name ?? ""
                }
                
                // Update the skater's current stance
                if trickObject.spinIn == "Truespin" || trickObject.spinIn == "270 Alley-Oop" || trickObject.spinIn == "450 Truespin" {
                    trickObject.grindStance = .fakie
                } else {
                    trickObject.grindStance = .forward
                }
                // Update skater's spin direction
                if (bsToSoulplateSpinsLeft.contains(where: { $0.name == trickObject.spinIn })) {
                    print("Spinning Direction: Left")
                    trickObject.spinInDirection = "L"
                } else if (bsToSoulplateSpinsRight.contains(where: { $0.name == trickObject.spinIn })) {
                    print("Spinning Direction: Right")
                    trickObject.spinInDirection = "R"
                } else {
                    trickObject.spinInDirection = previousTrick?.spinInDirection ?? "N"
                }
            } else if trickObject.initialStance == .fs {
                // Filter by difficulty first
                let spinsWithinDifficulty = fsToSoulplateSpins.filter { $0.difficulty < settings.grooveFSToSoulplateSpinsCAP }

                // Then filter by allowed spins (for rewind blocking)
                let allowedSpins = spinsWithinDifficulty.filter { difficultySpin in
                    fsToSoulplateSpinsAllowed.contains { allowedSpin in
                        allowedSpin.name == difficultySpin.name
                    }
                }

                if !allowedSpins.isEmpty {
                    // Pick a random spin from allowed ones
                    let randomSpin = allowedSpins.randomElement()!
                    trickObject.spinIn = randomSpin.name
                } else {
                    // Fallback to no spin
                    let noSpin = fsToSoulplateSpins.first { $0.name == "" }
                    trickObject.spinIn = noSpin?.name ?? ""
                }
                
                // Update the skater's current stance
                if trickObject.spinIn == "Alley-Oop" || trickObject.spinIn == "270 Truespin" || trickObject.spinIn == "450 Alley-Oop" {
                    trickObject.grindStance = .fakie
                } else {
                    trickObject.grindStance = .forward
                }
                // Update skater's spin direction
                if (fsToSoulplateSpinsLeft.contains(where: { $0.name == trickObject.spinIn })) {
                    print("Spinning Direction: Left")
                    trickObject.spinInDirection = "L"
                } else if (fsToSoulplateSpinsRight.contains(where: { $0.name == trickObject.spinIn })) {
                    print("Spinning Direction: Right")
                    trickObject.spinInDirection = "R"
                } else {
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
                    let spinsWithinDifficulty = fakieOutSpins.filter { $0.difficulty < settings.soulplateFakieOutSpinsCAP }
                    if !spinsWithinDifficulty.isEmpty {
                        let randomSpin = spinsWithinDifficulty.randomElement()!
                        trickObject.spinOut = randomSpin.name
                    } else {
                        trickObject.spinOut = fakieOutSpins[0].name
                    }
                    
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
                } else if trickObject.grindStance == .forward {
                    let spinsWithinDifficulty = forwardOutSpins.filter { $0.difficulty < settings.soulplateForwardOutSpinsCAP }
                    if !spinsWithinDifficulty.isEmpty {
                        let randomSpin = spinsWithinDifficulty.randomElement()!
                        trickObject.spinOut = randomSpin.name
                    } else {
                        trickObject.spinOut = forwardOutSpins[0].name
                    }
                    
                    // Update the skater's current stance
                    if trickObject.spinOut.contains("to Fakie") {
                        trickObject.outStance = .fakie
                    } else {
                        trickObject.outStance = .forward
                    }
                    // forward grind + to forward = no spin
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
            if (trickObject.trickName == "Makio" && trickObject.isTopside == true) {
                trickNameStamp = "Fishbrain"
                topsideStamp = ""
            }
            // Edge Case: Top Christ Makio = Christ Fishbrain
            if (trickObject.trickName == "Christ Makio" && trickObject.isTopside == true) {
                trickNameStamp = "Christ Fishbrain"
                topsideStamp = ""
            }
            // Edge Case: Top Mizou = Sweatstance
            // Edge Case: In-Spin Top Mizou = In-Spin Sweatstance
            // Edge Case: Out-Spin Top Mizou = Out-Spin Sweatstance
            // Edge Case: 360 Top Mizou = 360 Sweatstance
            // Edge Case: Hurricane Top Mizou = Hurricane Sweatstance
            // Edge Case: In-Spin 540 Top Mizou = In-Spin 540 Sweatstance
            // Edge Case: Out-Spin 540 Top Mizou = Out-Spin 540 Sweatstance
            if (trickObject.trickName == "Mizou" && trickObject.isTopside == true && trickObject.grindStance == .forward) {
                trickNameStamp = "Sweatstance"
                topsideStamp = ""
            }
            
            // Edge Case: Top Mizou Fakie = Kind
            if (trickObject.trickName == "Mizou" && trickObject.isTopside == true && trickObject.grindStance == .fakie) {
                trickNameStamp = "Kind Grind"
                topsideStamp = ""
            }
            if trickObject.trickName == "Mizou" && trickObject.isTopside == true && trickObject.spinIn.contains("Alley-Oop") {
                // Extract the spin part by removing "Alley-Oop" and any preceding space
                spinInStamp = trickObject.spinIn.replacingOccurrences(of: "\\s*Alley-Oop", with: "", options: .regularExpression)
            }
            // Edge Case: Zero Spin Top Mistrial = Zero Spin Misfit
            // Edge Case: Alley-Oop Top Mistrial = Misfit
            // Edge Case: Truespin Top Mistrial = Truespin Misfit
            // Edge Case: Cab Alley-Oop Top Mistrial = Cab Misfit
            // Edge Case: Cab Truespin Top Mistrial = Cab Truespin Misfit
            // Edge Case: 540 Alley-Oop Top Mistrial = 540 Misfit
            // Edge Case: 540 Truespin Top Mistrial = 540 Truespin Misfit
            if (trickObject.trickName == "Mistrial" && trickObject.isTopside == true && trickObject.grindStance == .fakie) {
                trickNameStamp = "Misfit"
                topsideStamp = ""
            }
            // Edge Case: Alley-Oop Top Mistrial = Misfit
            // Edge Case: Cab Alley-Oop top Mistrial = Cab Misfit
            // Edge Case: 540 Alley-Oop top Mistrial = 540 Misfit
            if trickObject.trickName == "Mistrial" && trickObject.isTopside == true && trickObject.spinIn.contains("Alley-Oop") {
                // Extract the spin part by removing "Alley-Oop" and any preceding space
                spinInStamp = trickObject.spinIn.replacingOccurrences(of: "\\s*Alley-Oop", with: "", options: .regularExpression)
            }
            
            // Edge Case: fakie stance + torque soul = soulyale
            if (trickObject.trickName == "Torque Soul" && trickObject.grindStance == .fakie) {
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
            
            // Remove rewind spins for switch ups
            if (trickMode == "mid" || trickMode == "exit") {
                if !customSettings.switchUpRewindAllowed {
                    if previousTrick?.spinInDirection == "L" {
                        // Remove rewind spins for Fakie to Groove
                        fakieToGrooveSpinsAllowed = fakieToGrooveSpins.filter { spin in
                            !fakieToGrooveSpinsRight.contains { rightSpin in rightSpin.name == spin.name }
                        }
                        // Remove rewind spins for Forward to Groove
                        forwardToGrooveSpinsAllowed = forwardToGrooveSpins.filter { spin in
                            !forwardToGrooveSpinsRight.contains { rightSpin in rightSpin.name == spin.name }
                        }
                        // Remove rewind spins for FS to Groove
                        fsToGrooveSpinsAllowed = fsToGrooveSpins.filter { spin in
                            spin.direction.hasPrefix("N") || spin.direction.hasPrefix("C")
                        }
                        // Remove rewind spins for BS to Groove
                        bsToGrooveSpinsAllowed = bsToGrooveSpins.filter { spin in
                            spin.direction.hasPrefix("N") || spin.direction.hasPrefix("C")
                        }
                        print("Switch up Rewind Spins Blocked")
                        isSwitchUpRewindBlocked = true
                    } else if previousTrick?.spinInDirection == "R" {
                        // Remove rewind spins for Fakie to Groove
                        fakieToGrooveSpinsAllowed = fakieToGrooveSpins.filter { spin in
                            !fakieToGrooveSpinsLeft.contains { leftSpin in leftSpin.name == spin.name }
                        }
                        // Remove rewind spins for Forward to Groove
                        forwardToGrooveSpinsAllowed = forwardToGrooveSpins.filter { spin in
                            !forwardToGrooveSpinsLeft.contains { leftSpin in leftSpin.name == spin.name }
                        }
                        // Remove rewind spins for FS to Groove
                        fsToGrooveSpinsAllowed = fsToGrooveSpins.filter { spin in
                            spin.direction.hasPrefix("N") || spin.direction.hasPrefix("C")
                        }
                        // Remove rewind spins for BS to Groove
                        bsToGrooveSpinsAllowed = bsToGrooveSpins.filter { spin in
                            spin.direction.hasPrefix("N") || spin.direction.hasPrefix("C")
                        }
                        print("Switch up Rewind Spins Blocked")
                        isSwitchUpRewindBlocked = true
                    }
                } else {
                    print("Switch up rewind spins allowed")
                }
            }

            // 2.2 Choose Spin in according to stance
            if (trickObject.initialStance == .fakie) {
                
                // Filter by difficulty first
                let spinsWithinDifficulty = fakieToGrooveSpins.filter { $0.difficulty < settings.grooveFakieInSpinsCAP }

                // Then filter by allowed spins (for rewind blocking)
                let allowedSpins = spinsWithinDifficulty.filter { difficultySpin in
                    fakieToGrooveSpinsAllowed.contains { allowedSpin in
                        allowedSpin.name == difficultySpin.name
                    }
                }

                if !allowedSpins.isEmpty {
                    // Pick a random spin from allowed ones
                    let randomSpin = allowedSpins.randomElement()!
                    trickObject.spinIn = randomSpin.name
                } else {
                    // Fallback
                    if previousTrick?.spinInDirection == "R" {
                        trickObject.spinIn = fakieToGrooveSpinsRight[0].name
                    } else if previousTrick?.spinInDirection == "L" {
                        trickObject.spinIn = fakieToGrooveSpinsLeft[0].name
                    } else {
                        // Default case
                        trickObject.spinIn = fakieToGrooveSpins[0].name
                    }
                }
                
                // Update the skater's current stance
                if trickObject.spinIn.contains("FS") {
                    trickObject.grindStance = .fs
                } else if trickObject.spinIn.contains("BS") {
                    trickObject.grindStance = .bs
                }
                // Update skater's spin direction
                if (fakieToGrooveSpinsLeft.contains(where: { $0.name == trickObject.spinIn })) {
                    print("Spinning Direction: Left")
                    trickObject.spinInDirection = "L"
                } else if (fakieToGrooveSpinsRight.contains(where: { $0.name == trickObject.spinIn })) {
                    print("Spinning Direction: Right")
                    trickObject.spinInDirection = "R"
                } else {
                    print("Spinning Direction: Neutral *** CHECK THIS...")
                }
            } else if (trickObject.initialStance == .forward) {
                // Filter by difficulty first
                let spinsWithinDifficulty = forwardToGrooveSpins.filter { $0.difficulty < settings.grooveForwardInSpinsCAP }

                // Then filter by allowed spins (for rewind blocking)
                let allowedSpins = spinsWithinDifficulty.filter { difficultySpin in
                    forwardToGrooveSpinsAllowed.contains { allowedSpin in
                        allowedSpin.name == difficultySpin.name
                    }
                }

                if !allowedSpins.isEmpty {
                    // Pick a random spin from allowed ones
                    let randomSpin = allowedSpins.randomElement()!
                    trickObject.spinIn = randomSpin.name
                } else {
                    // Fallback
                    if previousTrick?.spinInDirection == "R" {
                        trickObject.spinIn = forwardToGrooveSpinsRight[0].name
                    } else if previousTrick?.spinInDirection == "L" {
                        trickObject.spinIn = forwardToGrooveSpinsLeft[0].name
                    } else {
                        // Default case
                        trickObject.spinIn = forwardToGrooveSpins[0].name
                    }
                }
                // Update the skater's current stance
                if trickObject.spinIn.contains("FS") {
                    trickObject.grindStance = .fs
                } else if trickObject.spinIn.contains("BS") {
                    trickObject.grindStance = .bs
                }
                // Update skater's spin direction
                if (forwardToGrooveSpinsLeft.contains(where: { $0.name == trickObject.spinIn })) {
                    print("Spinning Direction: Left")
                    trickObject.spinInDirection = "L"
                } else if (forwardToGrooveSpinsRight.contains(where: { $0.name == trickObject.spinIn })) {
                    print("Spinning Direction: Right")
                    trickObject.spinInDirection = "R"
                } else {
                    print("Spinning Direction: Neutral")
                    trickObject.spinInDirection = "N"
                }
            } else if trickObject.initialStance == .bs {
                // Filter by difficulty first
                let spinsWithinDifficulty = bsToGrooveSpinsAllowed.filter { $0.difficulty < settings.grooveBSToGrooveSpinsCAP }
                
                if !spinsWithinDifficulty.isEmpty {
                    let randomSpin = spinsWithinDifficulty.randomElement()!
                    trickObject.spinIn = randomSpin.name
                    
                    // Set the actual spin direction based on the spin type
                    if randomSpin.direction.hasPrefix("C") {
                        // For continuous spins, continue in the same direction as previous trick
                        if previousTrick?.spinInDirection == "L" {
                            trickObject.spinInDirection = "L"
                        } else if previousTrick?.spinInDirection == "R" {
                            trickObject.spinInDirection = "R"
                        } else {
                            // Default direction if no previous direction
                            trickObject.spinInDirection = "L"
                        }
                    } else if randomSpin.direction.hasPrefix("R") {
                        // For rewind spins, go opposite to the previous direction
                        if previousTrick?.spinInDirection == "L" {
                            trickObject.spinInDirection = "R"
                        } else if previousTrick?.spinInDirection == "R" {
                            trickObject.spinInDirection = "L"
                        } else {
                            // Default direction if no previous direction
                            trickObject.spinInDirection = "R"
                        }
                    } else if randomSpin.direction.hasPrefix("N") {
                        // For neutral spins, keep the previous direction
                        trickObject.spinInDirection = previousTrick?.spinInDirection ?? "N"
                    }
                } else {
                    // Fallback if no spins are allowed
                    trickObject.spinIn = bsToGrooveSpins[0].name
                    trickObject.spinInDirection = previousTrick?.spinInDirection ?? "N"  // Keep previous direction here too
                }
                
                // Update grind stance based on spin
                if trickObject.spinIn.contains("FS") {
                    trickObject.grindStance = .fs
                } else if trickObject.spinIn.contains("BS") {
                    trickObject.grindStance = .bs
                }
            } else if trickObject.initialStance == .fs {
                // Filter by difficulty first
                let spinsWithinDifficulty = fsToGrooveSpinsAllowed.filter { $0.difficulty < settings.grooveFSToGrooveSpinsCAP }
                
                if !spinsWithinDifficulty.isEmpty {
                    let randomSpin = spinsWithinDifficulty.randomElement()!
                    trickObject.spinIn = randomSpin.name
                    
                    // Set the actual spin direction based on the spin type
                    if randomSpin.direction.hasPrefix("C") {
                        // For continuous spins, continue in the same direction as previous trick
                        if previousTrick?.spinInDirection == "L" {
                            trickObject.spinInDirection = "L"
                        } else if previousTrick?.spinInDirection == "R" {
                            trickObject.spinInDirection = "R"
                        } else {
                            // Default direction if no previous direction
                            trickObject.spinInDirection = "L"
                        }
                    } else if randomSpin.direction.hasPrefix("R") {
                        // For rewind spins, go opposite to the previous direction
                        if previousTrick?.spinInDirection == "L" {
                            trickObject.spinInDirection = "R"
                        } else if previousTrick?.spinInDirection == "R" {
                            trickObject.spinInDirection = "L"
                        } else {
                            // Default direction if no previous direction
                            trickObject.spinInDirection = "R"
                        }
                    } else if randomSpin.direction.hasPrefix("N") {
                        // For neutral spins, keep the previous direction
                        trickObject.spinInDirection = previousTrick?.spinInDirection ?? "N"
                    }
                } else {
                    // Fallback if no spins are allowed
                    trickObject.spinIn = fsToGrooveSpins[0].name
                    trickObject.spinInDirection = previousTrick?.spinInDirection ?? "N"  // Keep previous direction here too
                }
                
                // Update grind stance based on spin
                if trickObject.spinIn.contains("FS") {
                    trickObject.grindStance = .fs
                } else if trickObject.spinIn.contains("BS") {
                    trickObject.grindStance = .bs
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
                        fsOutSpinsAllowed = fsOutSpins.filter { spin in
                            !fsOutSpinsLeft.contains { leftSpin in leftSpin.name == spin.name }
                        }
                        bsOutSpinsAllowed = bsOutSpins.filter { spin in
                            !bsOutSpinsLeft.contains { leftSpin in leftSpin.name == spin.name }
                        }
                        print("YES rewind chosen! removing all rewind spins 1")
                    } else if trickObject.spinInDirection == "R" {
                        fsOutSpinsAllowed = fsOutSpins.filter { spin in
                            !fsOutSpinsRight.contains { rightSpin in rightSpin.name == spin.name }
                        }
                        bsOutSpinsAllowed = bsOutSpins.filter { spin in
                            !bsOutSpinsRight.contains { rightSpin in rightSpin.name == spin.name }
                        }
                        print("YES rewind chosen! removing all rewind spins 2")
                    }
                } else {
                    // Remove rewind out spins
                    if trickObject.spinInDirection == "L" {
                        fsOutSpinsAllowed = fsOutSpins.filter { spin in
                            !fsOutSpinsRight.contains { rightSpin in rightSpin.name == spin.name }
                        }
                        bsOutSpinsAllowed = bsOutSpins.filter { spin in
                            !bsOutSpinsRight.contains { rightSpin in rightSpin.name == spin.name }
                        }
                        print("NOT rewind chosen! removing all rewind spins 1")
                    } else if trickObject.spinInDirection == "R" {
                        fsOutSpinsAllowed = fsOutSpins.filter { spin in
                            !fsOutSpinsLeft.contains { leftSpin in leftSpin.name == spin.name }
                        }
                        bsOutSpinsAllowed = bsOutSpins.filter { spin in
                            !bsOutSpinsLeft.contains { leftSpin in leftSpin.name == spin.name }
                        }
                        print("NOT rewind chosen! removing all rewind spins 2")
                    }
                }
            }
            
            // 2.3 Choose Spin Out
            if trickMode == "single" || trickMode == "exit" {
                if trickObject.grindStance == .fs {
                    // Filter by difficulty first
                    let spinsWithinDifficulty = fsOutSpins.filter { $0.difficulty < settings.fsOutSpinsCAP }
                    
                    // Then filter by allowed spins
                    let allowedSpins = spinsWithinDifficulty.filter { difficultySpin in
                        fsOutSpinsAllowed.contains { allowedSpin in
                            allowedSpin.name == difficultySpin.name
                        }
                    }
                    
                    if !allowedSpins.isEmpty {
                        // Pick a random spin
                        let randomSpin = allowedSpins.randomElement()!
                        trickObject.spinOut = randomSpin.name
                    } else {
                        // Fallback option when no spins are allowed
                        trickObject.spinOut = fsOutSpinsAllowed.first?.name ?? ""
                        print("Warning: No valid FS out spins available after filtering. Using fallback.")
                    }
                    
                    spinOutStamp = trickObject.spinOut
                    if trickObject.spinInDirection == "L" {
                        if fsOutSpinsRight.contains(where: { $0.name == trickObject.spinOut }) {
                            trickObject.isSpinOutRewind = true
                        }
                    } else if trickObject.spinInDirection == "R" {
                        if fsOutSpinsLeft.contains(where: { $0.name == trickObject.spinOut }) {
                            trickObject.isSpinOutRewind = true
                        }
                    }
                } else if trickObject.grindStance == .bs {
                    // Filter by difficulty first
                    let spinsWithinDifficulty = bsOutSpins.filter { $0.difficulty < settings.bsOutSpinsCAP }
                    
                    // Then filter by allowed spins
                    let allowedSpins = spinsWithinDifficulty.filter { difficultySpin in
                        bsOutSpinsAllowed.contains { allowedSpin in
                            allowedSpin.name == difficultySpin.name
                        }
                    }
                    
                    if !allowedSpins.isEmpty {
                        // Pick a random spin
                        let randomSpin = allowedSpins.randomElement()!
                        trickObject.spinOut = randomSpin.name
                    } else {
                        // Fallback option when no spins are allowed
                        trickObject.spinOut = bsOutSpinsAllowed.first?.name ?? ""
                        print("Warning: No valid BS out spins available after filtering. Using fallback.")
                    }
                    
                    spinOutStamp = trickObject.spinOut
                    if trickObject.spinInDirection == "L" {
                        if bsOutSpinsRight.contains(where: { $0.name == trickObject.spinOut }) {
                            trickObject.isSpinOutRewind = true
                        }
                    } else if trickObject.spinInDirection == "R" {
                        if bsOutSpinsLeft.contains(where: { $0.name == trickObject.spinOut }) {
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
        print("Setting difficulty to: \(difficulty.difficultyLevel.rawValue)")
        
        // Get a fresh copy of the difficulty settings to ensure we're not using modified settings
        let freshSettings: Difficulty.DifficultySettings
        
        if difficulty.isCustom {
            // For custom difficulty, use the stored custom settings
            freshSettings = loadCustomSettings() ?? difficulty.settings
            customSettings = freshSettings // Update the custom settings
        } else {
            // For preset difficulties, get the original settings from the levels array
            if let original = Difficulty.levels.first(where: { $0.difficultyLevel == difficulty.difficultyLevel }) {
                freshSettings = original.settings
            } else {
                freshSettings = difficulty.settings
            }
        }
        
        // Create a new difficulty instance with the correct settings
        currentDifficulty = Difficulty(
            id: difficulty.id,
            level: difficulty.level,
            difficultyLevel: difficulty.difficultyLevel,
            settings: freshSettings, // Use the fresh settings
            isCustom: difficulty.isCustom
        )
        
        // Save the selected difficulty level
        UserDefaults.standard.set(difficulty.level, forKey: "selectedDifficultyLevel")
        
        // Apply custom settings only if we're in custom mode
        if difficulty.isCustom {
            applyCustomSettings()
        }
        
        // Sync spin settings with current difficulty
        if let inManager = self.inSpinManager, let outManager = self.outSpinManager, let switchUpManager = self.switchUpSpinManager {
            inManager.setSimpleDegree(inManager.findHighestDegreeFromSettings())
            outManager.setSimpleDegree(outManager.findHighestDegreeFromSettings())
            switchUpManager.setSimpleDegree(switchUpManager.findHighestDegreeFromSettings())
        }
        
        print("""
            Difficulty set:
            - Level name:       \(currentDifficulty.level): \(currentDifficulty.difficultyLevel.rawValue)
            - Is Custom:        \(currentDifficulty.isCustom)
            - Fakie chance:     \(currentDifficulty.settings.fakieChance * 100)%
            - Topside chance:   \(currentDifficulty.settings.topsideChance * 100)%
            - Negative chance:  \(currentDifficulty.settings.negativeChance * 100)%
            - Rewind chance:    \(currentDifficulty.settings.rewindOutChance * 100)%
            - Trick CAP:        \(currentDifficulty.settings.tricksCAP)
            """)
    }
}

