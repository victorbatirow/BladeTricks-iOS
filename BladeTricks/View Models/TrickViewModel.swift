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

// Place this in a helper file later
extension Optional where Wrapped == Bool {
    var isTrue: Bool {
        switch self {
        case .some(true): return true
        default: return false
        }
    }
}

class TrickViewModel: ObservableObject {
    
    // Repository reference
    private let trickRepository = TrickRepository.shared
    
    @Published var displayTrickName: String = "Press button to generate trick."
    @Published var currentDifficulty: Difficulty = Difficulty.levels[0]  // Default to first difficulty
    @Published var customSettings: Difficulty.DifficultySettings
    @Published var SwitchUpMode: Int = 0  // 0 for single, 1 for double, 2 for triple
    
    // Spin Settings Managers
    @Published var inSpinManager: SpinSettingsManager!
    @Published var outSpinManager: SpinSettingsManager!
    @Published var switchUpSpinManager: SpinSettingsManager!
    
    // Publisher for settings service changes, to be exposed to SpinSettingsManager
    private var settingsChangedSubject = PassthroughSubject<Void, Never>()
    var settingsServiceChanged: AnyPublisher<Void, Never> {
        settingsChangedSubject.eraseToAnyPublisher()
    }
    
    // For storing Combine subscriptions
    private var cancellables = Set<AnyCancellable>()
    
    // This array will store the history of generated tricks
    private var lastTricks: [String] = []
    
    // Update the init() method to properly initialize the spin settings managers after customSettings is loaded
    init() {
        let defaultDifficulty = Difficulty.levels[0] // Default to first difficulty
        self.currentDifficulty = defaultDifficulty
        self.customSettings = defaultDifficulty.settings // Temporarily initialize with default settings

        // Load custom settings using the service
        if let loadedSettings = SettingsService.shared.loadCustomSettings() {
            self.customSettings = loadedSettings.settings
        }

        // Load saved difficulty level using the service
        let savedDifficultyLevel = SettingsService.shared.loadSelectedDifficultyLevel() ?? defaultDifficulty.level
        if let savedDifficulty = Difficulty.levels.first(where: {$0.level == savedDifficultyLevel}) {
            currentDifficulty = savedDifficulty
        }
        
        // Initialize spin settings managers with self as viewModel
        self.inSpinManager = SpinSettingsManager(spinType: .spinIn, viewModel: self)
        self.outSpinManager = SpinSettingsManager(spinType: .spinOut, viewModel: self)
        self.switchUpSpinManager = SpinSettingsManager(spinType: .switchUpSpin, viewModel: self)
        
        // Subscribe to settings changes
        SettingsService.shared.settingsChanged
            .receive(on: RunLoop.main)
            .sink { [weak self] in
                self?.objectWillChange.send()
                self?.settingsChangedSubject.send() // Forward the settings change event
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Settings Management
    
    func loadCustomSettings() -> Difficulty.DifficultySettings? {
        if let customDifficulty = SettingsService.shared.loadCustomSettings() {
            return customDifficulty.settings
        }
        return nil
    }
    
    func saveCustomSettings() {
        if currentDifficulty.isCustom {
            // Update the current difficulty with custom settings
            var updatedDifficulty = currentDifficulty
            updatedDifficulty.settings = customSettings
            SettingsService.shared.saveCustomSettings(updatedDifficulty)
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
    
    // Update the setDifficulty method to properly handle transitions between difficulty levels
    func setDifficulty(_ difficulty: Difficulty) {
        // Save the current custom settings before switching
        if currentDifficulty.isCustom {
            saveCustomSettings()
        }
        
        // Get a fresh copy of the difficulty settings
        let freshSettings: Difficulty.DifficultySettings
        
        if difficulty.isCustom {
            // For custom difficulty, always use the stored custom settings
            if let storedCustomSettings = SettingsService.shared.loadCustomSettings() {
                freshSettings = storedCustomSettings.settings
            } else {
                // Fall back to the default custom template if nothing is saved
                freshSettings = Difficulty.customTemplate.settings
            }
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
        
        // Save the selected difficulty level using the service
        SettingsService.shared.saveSelectedDifficultyLevel(level: difficulty.level)
        
        // Notify all observers about the settings change
        settingsChangedSubject.send()
        
        // Debug output
        print("""
            Difficulty set:
            - Level name:       \(currentDifficulty.level): \(currentDifficulty.difficultyLevel.rawValue)
            - Is Custom:        \(currentDifficulty.isCustom)
            - Fakie chance:     \(currentDifficulty.settings.fakieChance * 100)%
            - Topside chance:   \(currentDifficulty.settings.topsideChance * 100)%
            - Negative chance:  \(currentDifficulty.settings.negativeChance * 100)%
            - Rewind chance:    \(currentDifficulty.settings.rewindOutChance * 100)%
            - Trick CAP:        \(currentDifficulty.settings.tricksCAP)
            - In Spin Max:      \(currentDifficulty.settings.inSpinMaxDegree)°
            - Out Spin Max:     \(currentDifficulty.settings.outSpinMaxDegree)°
            - SwitchUp Max:     \(currentDifficulty.settings.switchUpSpinMaxDegree)°
            """)
    }

    
    // MARK: - Trick Generation
    
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
                    print("* Repeated trick prevented: \(trick1.spinIn?.name ?? "None") \(trick1.trickName) to \(trick2.spinIn?.name ?? "None") \(trick2.trickName)")
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
                    print("* Repeated trick prevented: \(trick1.spinIn?.name ?? "None") \(trick1.trickName) to \(trick2.spinIn?.name ?? "None") \(trick2.trickName)")
                    trick2 = trickGenerator(previousTrick: trick1, trickMode: "mid")
                }
                
                print("> 3rd Trick:")
                var trick3 = trickGenerator(previousTrick: trick2, trickMode: "exit")
                // Check for duplicate conditions between 2nd and 3rd tricks
                while isDuplicateSwitchUp(trick1: trick2, trick2: trick3) {
                    print("* Repeated trick prevented: \(trick2.spinIn?.name ?? "None") \(trick2.trickName) to \(trick3.spinIn?.name ?? "None") \(trick3.trickName)")
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
    
    func isDuplicateSwitchUp(trick1: Trick, trick2: Trick) -> Bool {
        // Check if the names are the same
        if trick1.trickName == trick2.trickName {
            if trick1.type == .groove && trick2.type == .groove {
                // For groove tricks, check if we're repeating the same direction
                let sides = ["FS", "BS"]
                for side in sides {
                    if trick1.spinInName.contains(side) && trick2.spinInName == side {
                        print("Duplicate groove trick detected")
                        return true
                    }
                }
            } else if trick1.type == .soulplate && trick2.type == .soulplate {
                // For soulplate tricks, check if we're doing the same trick in the same stance
                if trick1.grindStance == trick2.grindStance {
                    // Consider it a duplicate if the second trick has no spin or a "Zero Spin"
                    if trick2.spinInName.isEmpty || trick2.spinInName == "Zero Spin" {
                        print("Duplicate soulplate trick detected")
                        return true
                    }
                }
            }
        }
        return false
    }
    
    // MARK: - Repository Data Access Methods
    
    // IN SPINS:
    var forwardToSoulplateSpinsIn: [Spin] {
        if currentDifficulty.isCustom {
            // For custom settings, filter by max degree
            let maxDegree = customSettings.inSpinMaxDegree
            return trickRepository.forwardToSoulplateSpinsIn.filter { $0.rotation <= maxDegree }
        } else {
            // For preset difficulties, filter by difficulty level
            let difficultyLevel = currentDifficulty.numericLevel
            return trickRepository.forwardToSoulplateSpinsIn.filter { $0.difficulty <= difficultyLevel }
        }
    }

    var fakieToSoulplateSpinsIn: [Spin] {
        if currentDifficulty.isCustom {
            let maxDegree = customSettings.inSpinMaxDegree
            return trickRepository.fakieToSoulplateSpinsIn.filter { $0.rotation <= maxDegree }
        } else {
            let difficultyLevel = currentDifficulty.numericLevel
            return trickRepository.fakieToSoulplateSpinsIn.filter { $0.difficulty <= difficultyLevel }
        }
    }

    var forwardToGrooveSpinsIn: [Spin] {
        if currentDifficulty.isCustom {
            let maxDegree = customSettings.inSpinMaxDegree
            return trickRepository.forwardToGrooveSpinsIn.filter { $0.rotation <= maxDegree }
        } else {
            let difficultyLevel = currentDifficulty.numericLevel
            return trickRepository.forwardToGrooveSpinsIn.filter { $0.difficulty <= difficultyLevel }
        }
    }

    var fakieToGrooveSpinsIn: [Spin] {
        if currentDifficulty.isCustom {
            let maxDegree = customSettings.inSpinMaxDegree
            return trickRepository.fakieToGrooveSpinsIn.filter { $0.rotation <= maxDegree }
        } else {
            let difficultyLevel = currentDifficulty.numericLevel
            return trickRepository.fakieToGrooveSpinsIn.filter { $0.difficulty <= difficultyLevel }
        }
    }

    // OUT SPINS
    var forwardOutSpins: [Spin] {
        if currentDifficulty.isCustom {
            let maxDegree = customSettings.outSpinMaxDegree
            return trickRepository.forwardOutSpins.filter { $0.rotation <= maxDegree }
        } else {
            let difficultyLevel = currentDifficulty.numericLevel
            return trickRepository.forwardOutSpins.filter { $0.difficulty <= difficultyLevel }
        }
    }

    var fakieOutSpins: [Spin] {
        if currentDifficulty.isCustom {
            let maxDegree = customSettings.outSpinMaxDegree
            return trickRepository.fakieOutSpins.filter { $0.rotation <= maxDegree }
        } else {
            let difficultyLevel = currentDifficulty.numericLevel
            return trickRepository.fakieOutSpins.filter { $0.difficulty <= difficultyLevel }
        }
    }

    var fsOutSpins: [Spin] {
        if currentDifficulty.isCustom {
            let maxDegree = customSettings.outSpinMaxDegree
            return trickRepository.fsOutSpins.filter { $0.rotation <= maxDegree }
        } else {
            let difficultyLevel = currentDifficulty.numericLevel
            return trickRepository.fsOutSpins.filter { $0.difficulty <= difficultyLevel }
        }
    }

    var bsOutSpins: [Spin] {
        if currentDifficulty.isCustom {
            let maxDegree = customSettings.outSpinMaxDegree
            return trickRepository.bsOutSpins.filter { $0.rotation <= maxDegree }
        } else {
            let difficultyLevel = currentDifficulty.numericLevel
            return trickRepository.bsOutSpins.filter { $0.difficulty <= difficultyLevel }
        }
    }

    // SWITCH UP SPINS:
    // SWITCH UP SPINS:
    var fsToSoulplateSpins: [Spin] {
        if currentDifficulty.isCustom {
            let maxDegree = customSettings.switchUpSpinMaxDegree
            return trickRepository.fsToSoulplateSpins.filter { $0.rotation <= maxDegree }
        } else {
            let difficultyLevel = currentDifficulty.numericLevel
            return trickRepository.fsToSoulplateSpins.filter { $0.difficulty <= difficultyLevel }
        }
    }

    var fsToGrooveSpins: [Spin] {
        if currentDifficulty.isCustom {
            let maxDegree = customSettings.switchUpSpinMaxDegree
            return trickRepository.fsToGrooveSpins.filter { $0.rotation <= maxDegree }
        } else {
            let difficultyLevel = currentDifficulty.numericLevel
            return trickRepository.fsToGrooveSpins.filter { $0.difficulty <= difficultyLevel }
        }
    }

    var bsToSoulplateSpins: [Spin] {
        if currentDifficulty.isCustom {
            let maxDegree = customSettings.switchUpSpinMaxDegree
            return trickRepository.bsToSoulplateSpins.filter { $0.rotation <= maxDegree }
        } else {
            let difficultyLevel = currentDifficulty.numericLevel
            return trickRepository.bsToSoulplateSpins.filter { $0.difficulty <= difficultyLevel }
        }
    }

    var bsToGrooveSpins: [Spin] {
        if currentDifficulty.isCustom {
            let maxDegree = customSettings.switchUpSpinMaxDegree
            return trickRepository.bsToGrooveSpins.filter { $0.rotation <= maxDegree }
        } else {
            let difficultyLevel = currentDifficulty.numericLevel
            return trickRepository.bsToGrooveSpins.filter { $0.difficulty <= difficultyLevel }
        }
    }

    var forwardToSoulplateSwitchUpSpins: [Spin] {
        if currentDifficulty.isCustom {
            let maxDegree = customSettings.switchUpSpinMaxDegree
            return trickRepository.forwardToSoulplateSwitchUpSpins.filter { $0.rotation <= maxDegree }
        } else {
            let difficultyLevel = currentDifficulty.numericLevel
            return trickRepository.forwardToSoulplateSwitchUpSpins.filter { $0.difficulty <= difficultyLevel }
        }
    }

    var forwardToGrooveSwitchUpSpins: [Spin] {
        if currentDifficulty.isCustom {
            let maxDegree = customSettings.switchUpSpinMaxDegree
            return trickRepository.forwardToGrooveSwitchUpSpins.filter { $0.rotation <= maxDegree }
        } else {
            let difficultyLevel = currentDifficulty.numericLevel
            return trickRepository.forwardToGrooveSwitchUpSpins.filter { $0.difficulty <= difficultyLevel }
        }
    }

    var fakieToSoulplateSwitchUpSpins: [Spin] {
        if currentDifficulty.isCustom {
            let maxDegree = customSettings.switchUpSpinMaxDegree
            return trickRepository.fakieToSoulplateSwitchUpSpins.filter { $0.rotation <= maxDegree }
        } else {
            let difficultyLevel = currentDifficulty.numericLevel
            return trickRepository.fakieToSoulplateSwitchUpSpins.filter { $0.difficulty <= difficultyLevel }
        }
    }

    var fakieToGrooveSwitchUpSpins: [Spin] {
        if currentDifficulty.isCustom {
            let maxDegree = customSettings.switchUpSpinMaxDegree
            return trickRepository.fakieToGrooveSwitchUpSpins.filter { $0.rotation <= maxDegree }
        } else {
            let difficultyLevel = currentDifficulty.numericLevel
            return trickRepository.fakieToGrooveSwitchUpSpins.filter { $0.difficulty <= difficultyLevel }
        }
    }

    // Trick Lists
    var allTricks: [String] {
        return trickRepository.allTricks
    }

    var soulplateTricks: [String] {
        return trickRepository.soulplateTricks
    }

    var grooveTricks: [String] {
        return trickRepository.grooveTricks
    }

    var topsideNegativeTricks: [String] {
        return trickRepository.topsideNegativeTricks
    }
    
    // Helper methods for the repository
    func isSoulplateTrick(_ trickName: String) -> Bool {
        return trickRepository.isSoulplateTrick(trickName)
    }
    
    func isGrooveTrick(_ trickName: String) -> Bool {
        return trickRepository.isGrooveTrick(trickName)
    }
    
    func canHaveTopsideNegative(_ trickName: String) -> Bool {
        return trickRepository.canHaveTopsideNegative(trickName)
    }
    
    func getRandomTrick(withCap cap: Int) -> String {
        return trickRepository.getRandomTrick(withCap: cap)
    }
    
    private func trickGenerator(previousTrick: Trick? = nil, trickMode: String) -> Trick {
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
        
        // 1.1 Choose Fakie
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
        
        // Choose a soulplate or groove trick
        trickObject.trickName = trickRepository.getRandomTrick(withCap: settings.tricksCAP)
        trickNameStamp = trickObject.trickName

        // Find out if the chosen trick is done with soul plate
        if trickRepository.isSoulplateTrick(trickObject.trickName) {
            // SOULPLATE TRICK CHOSEN
            trickObject.type = .soulplate
            
            // 1.2 Choose Spin in according to stance - NEW APPROACH
            let prevDirection = (trickMode == "mid" || trickMode == "exit") ? previousTrick?.spinIn?.direction : nil
            
            if trickObject.initialStance == .forward {
                // Use our helper method to select a spin
                let selectedSpin = selectRandomSpin(
                    from: trickRepository.forwardToSoulplateSpinsIn,
                    forType: .spinIn,
                    initialStance: .forward,
                    previousDirection: prevDirection
                )
                
                trickObject.spinIn = selectedSpin
                
                // Update the skater's current stance based on the spin
                if let spinName = selectedSpin?.name {
                    if spinName.contains("Alley-Oop") || spinName.contains("Truespin") {
                        trickObject.grindStance = .fakie
                    } else {
                        trickObject.grindStance = .forward
                    }
                } else {
                    // Default if no spin
                    trickObject.grindStance = trickObject.initialStance
                }
                
                // Update spin direction info for debugging
                if let spinDirection = trickObject.spinIn?.direction {
                    switch spinDirection {
                    case .left:
                        print("Spinning Direction: Left")
                    case .right:
                        print("Spinning Direction: Right")
                    case .neutral:
                        print("Spinning Direction: Neutral")
                    }
                }
            } else if trickObject.initialStance == .fakie {
                // Similar approach for fakie stance
                let selectedSpin = selectRandomSpin(
                    from: trickRepository.fakieToSoulplateSpinsIn,
                    forType: .spinIn,
                    initialStance: .fakie,
                    previousDirection: prevDirection
                )
                
                trickObject.spinIn = selectedSpin
                
                // Update the skater's current stance based on chosen spin
                if let spinName = selectedSpin?.name {
                    if spinName.contains("In-Spin") || spinName.contains("Out-Spin") {
                        trickObject.grindStance = .forward
                    } else {
                        trickObject.grindStance = .fakie
                    }
                } else {
                    // Default if no spin is chosen
                    trickObject.grindStance = trickObject.initialStance
                }
                
                // Update spin direction info for debugging
                if let spinDirection = trickObject.spinIn?.direction {
                    switch spinDirection {
                    case .left:
                        print("Spinning Direction: Left")
                    case .right:
                        print("Spinning Direction: Right")
                    case .neutral:
                        print("Spinning Direction: Neutral")
                    }
                }
            }

            // Set the display name for the spin
            spinInStamp = trickObject.spinIn?.name ?? ""
            
            // 1.3 Choose topside
            if trickRepository.canHaveTopsideNegative(trickObject.trickName) {
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
            if trickRepository.topsideNegativeTricks.contains(trickObject.trickName) {
                var negativeChance = settings.negativeChance
                // Reduce chance of negative if trick is topside
                if trickObject.isTopside && negativeChance != 0 {
                    negativeChance = 0.05
                }
                // Set the negative chance according to difficulty
                trickObject.isNegative = (Double.random(in: 0...1) < negativeChance)
                if trickObject.isNegative {
                    negativeStamp = "Negative"
                } else {
                    negativeStamp = ""
                }
            }
            
            // 1.5 Choose Spin Out - NEW APPROACH
            var noSpinOut = false
            
            if trickMode == "single" || trickMode == "exit" {
                if trickObject.grindStance == .fakie {
                    let selectedSpin = selectRandomSpin(
                        from: trickRepository.fakieOutSpins,
                        forType: .spinOut,
                        initialStance: .fakie
                    )
                    
                    trickObject.spinOut = selectedSpin
                    
                    // Update the skater's current stance
                    if let spinName = selectedSpin?.name, spinName.contains("to Forward") {
                        trickObject.outStance = .forward
                    } else {
                        trickObject.outStance = .fakie
                    }
                    
                    // fakie grind + to fakie = no spin
                    if selectedSpin?.name == "to Fakie" {
                        noSpinOut = true
                    }
                } else if trickObject.grindStance == .forward {
                    let selectedSpin = selectRandomSpin(
                        from: trickRepository.forwardOutSpins,
                        forType: .spinOut,
                        initialStance: .forward
                    )
                    
                    trickObject.spinOut = selectedSpin
                    
                    // Update the skater's current stance
                    if let spinName = selectedSpin?.name, spinName.contains("to Fakie") {
                        trickObject.outStance = .fakie
                    } else {
                        trickObject.outStance = .forward
                    }
                    
                    // forward grind + to forward = no spin
                    if selectedSpin?.name == "to Forward" {
                        noSpinOut = true
                    }
                }
                
                // 1.6 Choose if Spin Out is Rewind
                let shouldBeRewind = (Double.random(in: 0...1) < settings.rewindOutChance)
                
                if !noSpinOut && trickObject.spinOut != nil {
                    if let spinDirection = trickObject.spinIn?.direction {
                        if shouldBeRewind {
                            // Update the isRewind property
                            if var currentSpinOut = trickObject.spinOut {
                                currentSpinOut.isRewind = shouldBeRewind
                                trickObject.spinOut = currentSpinOut
                                
                                // Set the appropriate rewind stamp
                                if spinDirection == .neutral {
                                    rewindStamp = "hard-way"
                                } else {
                                    rewindStamp = "rewind"
                                }
                            }
                        }
                    }
                } else {
                    rewindStamp = ""
                }
                
                // Clear rewind stamp for simple "to Forward" or "to Fakie" spins
                if let spinOutName = trickObject.spinOut?.name,
                   (spinOutName == "to Forward" || spinOutName == "to Fakie") {
                    rewindStamp = ""
                }
                
                // Update spinOutStamp if we have a spin out
                if let spinOut = trickObject.spinOut, !spinOut.name.isEmpty {
                    spinOutStamp = spinOut.name
                }
            }
            
            // 1.7 Handle edge cases: Special named tricks
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
            if (trickObject.trickName == "Mizou" && trickObject.isTopside == true && trickObject.grindStance == .forward) {
                trickNameStamp = "Sweatstance"
                topsideStamp = ""
            }
            
            // Edge Case: Top Mizou Fakie = Kind
            if (trickObject.trickName == "Mizou" && trickObject.isTopside == true && trickObject.grindStance == .fakie) {
                trickNameStamp = "Kind Grind"
                topsideStamp = ""
            }
            // For Mizou edge case
            if trickObject.trickName == "Mizou" && trickObject.isTopside == true && trickObject.spinIn?.name.contains("Alley-Oop") == true {
                spinInStamp = trickObject.spinIn?.name.replacingOccurrences(of: "Alley-Oop", with: "").trimmingCharacters(in: .whitespaces) ?? ""
            }
            // Edge Case: Top Mistrial Fakie = Misfit
            if (trickObject.trickName == "Mistrial" && trickObject.isTopside == true && trickObject.grindStance == .fakie) {
                trickNameStamp = "Misfit"
                topsideStamp = ""
            }
            // Mistrial edge case
            if trickObject.trickName == "Mistrial" && trickObject.isTopside == true && trickObject.spinIn?.name.contains("Alley-Oop") == true {
                spinInStamp = trickObject.spinIn?.name.replacingOccurrences(of: "Alley-Oop", with: "").trimmingCharacters(in: .whitespaces) ?? ""
            }
            
            // Edge Case: fakie stance + torque soul = soulyale
            if (trickObject.trickName == "Torque Soul" && trickObject.grindStance == .fakie) {
                trickNameStamp = "Soyale"
            }
            
        } else {
            // GROOVE TRICK CHOSEN
            trickObject.type = .groove
            
            // 2.2 Choose Spin in according to stance - NEW APPROACH
            let prevDirection = (trickMode == "mid" || trickMode == "exit") ? previousTrick?.spinIn?.direction : nil
            
            if trickObject.initialStance == .fakie {
                // Use our helper method to select a spin
                let selectedSpin = selectRandomSpin(
                    from: trickRepository.fakieToGrooveSpinsIn,
                    forType: .spinIn,
                    initialStance: .fakie,
                    previousDirection: prevDirection
                )
                
                trickObject.spinIn = selectedSpin
                
                // Update the skater's current stance
                if let spinName = selectedSpin?.name {
                    if spinName.contains("FS") {
                        trickObject.grindStance = .fs
                    } else if spinName.contains("BS") {
                        trickObject.grindStance = .bs
                    }
                }
                
            } else if trickObject.initialStance == .forward {
                // Use our helper method to select a spin
                let selectedSpin = selectRandomSpin(
                    from: trickRepository.forwardToGrooveSpinsIn,
                    forType: .spinIn,
                    initialStance: .forward,
                    previousDirection: prevDirection
                )
                
                trickObject.spinIn = selectedSpin
                
                // Update the skater's current stance
                if let spinName = selectedSpin?.name {
                    if spinName.contains("FS") {
                        trickObject.grindStance = .fs
                    } else if spinName.contains("BS") {
                        trickObject.grindStance = .bs
                    }
                }
                
            } else if trickObject.initialStance == .bs {
                // Use our helper method to select a spin
                let selectedSpin = selectRandomSpin(
                    from: trickRepository.bsToGrooveSpins,
                    forType: .switchUpSpin,
                    initialStance: .bs,
                    previousDirection: prevDirection
                )
                
                trickObject.spinIn = selectedSpin
                
                // Update grind stance
                if let spinName = selectedSpin?.name {
                    if spinName.contains("FS") {
                        trickObject.grindStance = .fs
                    } else if spinName.contains("BS") {
                        trickObject.grindStance = .bs
                    }
                }
                
            } else if trickObject.initialStance == .fs {
                // Use our helper method to select a spin
                let selectedSpin = selectRandomSpin(
                    from: trickRepository.fsToGrooveSpins,
                    forType: .switchUpSpin,
                    initialStance: .fs,
                    previousDirection: prevDirection
                )
                
                trickObject.spinIn = selectedSpin
                
                // Update grind stance
                if let spinName = selectedSpin?.name {
                    if spinName.contains("FS") {
                        trickObject.grindStance = .fs
                    } else if spinName.contains("BS") {
                        trickObject.grindStance = .bs
                    }
                }
            }

            // Set the display name for the spin
            spinInStamp = trickObject.spinIn?.name ?? ""
            
            // 2.3 Choose Spin Out - NEW APPROACH
            if trickMode == "single" || trickMode == "exit" {
                // Determine if we want a rewind
                let rewindChosen = (Double.random(in: 0...1) < settings.rewindOutChance)
                
                if trickObject.grindStance == .fs {
                    // Use our helper method to select a spin
                    let selectedSpin = selectRandomSpin(
                        from: trickRepository.fsOutSpins,
                        forType: .spinOut,
                        initialStance: .fs
                    )
                    
                    if var spinOut = selectedSpin {
                        // Determine if this is a rewind spin
                        if let spinIn = trickObject.spinIn {
                            spinOut.isRewind = rewindChosen && (
                                (spinIn.direction == .left && spinOut.direction == .right) ||
                                (spinIn.direction == .right && spinOut.direction == .left)
                            )
                        }
                        
                        trickObject.spinOut = spinOut
                        spinOutStamp = spinOut.name
                        
                        // Update rewindStamp
                        if spinOut.isRewind == true {
                            rewindStamp = "rewind"
                        } else {
                            rewindStamp = ""
                        }
                    }
                    
                } else if trickObject.grindStance == .bs {
                    // Use our helper method to select a spin
                    let selectedSpin = selectRandomSpin(
                        from: trickRepository.bsOutSpins,
                        forType: .spinOut,
                        initialStance: .bs
                    )
                    
                    if var spinOut = selectedSpin {
                        // Determine if this is a rewind spin
                        if let spinIn = trickObject.spinIn {
                            spinOut.isRewind = rewindChosen && (
                                (spinIn.direction == .left && spinOut.direction == .right) ||
                                (spinIn.direction == .right && spinOut.direction == .left)
                            )
                        }
                        
                        trickObject.spinOut = spinOut
                        spinOutStamp = spinOut.name
                        
                        // Update rewindStamp
                        if spinOut.isRewind == true {
                            rewindStamp = "rewind"
                        } else {
                            rewindStamp = ""
                        }
                    }
                }
                
                // Clear rewind stamp for simple "to Forward" or "to Fakie" spins
                if let spinOutName = trickObject.spinOut?.name,
                   (spinOutName == "to Forward" || spinOutName == "to Fakie") {
                    rewindStamp = ""
                }
            }

            // 2.4 Handle edge cases
            // Edge Case: BS Grind = Backside Grind
            if (trickObject.trickName == "Grind" && trickObject.spinIn?.name.contains("BS") == true) {
                trickNameStamp = "Backside Grind"
                if (trickObject.spinIn?.name == "BS") {
                    spinInStamp = ""
                } else if (trickObject.spinIn?.name == "270 BS") {
                    spinInStamp = "270"
                } else if (trickObject.spinIn?.name == "360 BS") {
                    spinInStamp = "360"
                } else if (trickObject.spinIn?.name == "450 BS") {
                    spinInStamp = "450"
                }
            }
            // Edge Case: FS Grind = Frontside Grind
            if (trickObject.trickName == "Grind" && trickObject.spinIn?.name.contains("FS") == true) {
                trickNameStamp = "Frontside Grind"
                if (trickObject.spinIn?.name == "FS") {
                    spinInStamp = ""
                } else if (trickObject.spinIn?.name == "270 FS") {
                    spinInStamp = "270"
                } else if (trickObject.spinIn?.name == "360 FS") {
                    spinInStamp = "360"
                } else if (trickObject.spinIn?.name == "450 FS") {
                    spinInStamp = "450"
                }
            }
        }

        // Debug output
        print("Spin In      \(trickObject.spinIn?.name ?? "None")")
        print("Trick        \(trickObject.trickName)")
        if trickMode == "single" || trickMode == "exit" {
            Swift.print("Spin Out     \(trickObject.spinOut?.name ?? "None")")
        }

        // Update trick name label
        if trickObject.type == .soulplate {
            trickObject.trickFullName = ("\(spinInStamp) \(negativeStamp) \(topsideStamp) \(trickNameStamp) \(rewindStamp) \(spinOutStamp)")
        } else if trickObject.type == .groove {
            trickObject.trickFullName = ("\(fakieStamp) \(spinInStamp) \(trickNameStamp) \(rewindStamp) \(spinOutStamp)")
        }
        
        // Clean up any extra spaces
        trickObject.trickFullName = trickObject.trickFullName.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression, range: nil)

        return trickObject
    }
    
    // MARK: - Repository Access Methods

    // IN SPINS:
    func getForwardToSoulplateSpinsIn() -> [Spin] {
        return getAvailableSpins(trickRepository.forwardToSoulplateSpinsIn, type: .spinIn)
    }

    func getFakieToSoulplateSpinsIn() -> [Spin] {
        return getAvailableSpins(trickRepository.fakieToSoulplateSpinsIn, type: .spinIn)
    }

    func getForwardToGrooveSpinsIn() -> [Spin] {
        return getAvailableSpins(trickRepository.forwardToGrooveSpinsIn, type: .spinIn)
    }

    func getFakieToGrooveSpinsIn() -> [Spin] {
        return getAvailableSpins(trickRepository.fakieToGrooveSpinsIn, type: .spinIn)
    }

    // OUT SPINS
    func getForwardOutSpins() -> [Spin] {
        return getAvailableSpins(trickRepository.forwardOutSpins, type: .spinOut)
    }

    func getFakieOutSpins() -> [Spin] {
        return getAvailableSpins(trickRepository.fakieOutSpins, type: .spinOut)
    }

    func getFsOutSpins() -> [Spin] {
        return getAvailableSpins(trickRepository.fsOutSpins, type: .spinOut)
    }

    func getBsOutSpins() -> [Spin] {
        return getAvailableSpins(trickRepository.bsOutSpins, type: .spinOut)
    }

    // SWITCH UP SPINS:
    func getForwardToSoulplateSwitchUpSpins() -> [Spin] {
        return getAvailableSpins(trickRepository.forwardToSoulplateSwitchUpSpins, type: .switchUpSpin)
    }

    func getForwardToGrooveSwitchUpSpins() -> [Spin] {
        return getAvailableSpins(trickRepository.forwardToGrooveSwitchUpSpins, type: .switchUpSpin)
    }

    func getFakieToSoulplateSwitchUpSpins() -> [Spin] {
        return getAvailableSpins(trickRepository.fakieToSoulplateSwitchUpSpins, type: .switchUpSpin)
    }

    func getFakieToGrooveSwitchUpSpins() -> [Spin] {
        return getAvailableSpins(trickRepository.fakieToGrooveSwitchUpSpins, type: .switchUpSpin)
    }

    func getFsToSoulplateSwitchUpSpins() -> [Spin] {
        return getAvailableSpins(trickRepository.fsToSoulplateSpins, type: .switchUpSpin)
    }

    func getFsToGrooveSwitchUpSpins() -> [Spin] {
        return getAvailableSpins(trickRepository.fsToGrooveSpins, type: .switchUpSpin)
    }

    func getBsToSoulplateSwitchUpSpins() -> [Spin] {
        return getAvailableSpins(trickRepository.bsToSoulplateSpins, type: .switchUpSpin)
    }

    func getBsToGrooveSwitchUpSpins() -> [Spin] {
        return getAvailableSpins(trickRepository.bsToGrooveSpins, type: .switchUpSpin)
    }

    // Trick Lists
    func getAllTricks() -> [String] {
        return trickRepository.allTricks
    }

    func getSoulplateTricks() -> [String] {
        return trickRepository.soulplateTricks
    }

    func getGrooveTricks() -> [String] {
        return trickRepository.grooveTricks
    }

    func getTopsideNegativeTricks() -> [String] {
        return trickRepository.topsideNegativeTricks
    }
}

extension TrickViewModel {
    
    // MARK: - Spin Selection Helper Methods
    
    /// Get all spins of a specific type from all relevant collections
    func getAllSpins(forType type: SpinType) -> [Spin] {
        var allSpins: [Spin] = []
        
        switch type {
        case .spinIn:
            allSpins.append(contentsOf: trickRepository.forwardToSoulplateSpinsIn)
            allSpins.append(contentsOf: trickRepository.fakieToSoulplateSpinsIn)
            allSpins.append(contentsOf: trickRepository.forwardToGrooveSpinsIn)
            allSpins.append(contentsOf: trickRepository.fakieToGrooveSpinsIn)
            
        case .spinOut:
            allSpins.append(contentsOf: trickRepository.forwardOutSpins)
            allSpins.append(contentsOf: trickRepository.fakieOutSpins)
            allSpins.append(contentsOf: trickRepository.fsOutSpins)
            allSpins.append(contentsOf: trickRepository.bsOutSpins)
            
        case .switchUpSpin:
            allSpins.append(contentsOf: trickRepository.forwardToSoulplateSwitchUpSpins)
            allSpins.append(contentsOf: trickRepository.fakieToSoulplateSwitchUpSpins)
            allSpins.append(contentsOf: trickRepository.forwardToGrooveSwitchUpSpins)
            allSpins.append(contentsOf: trickRepository.fakieToGrooveSwitchUpSpins)
            allSpins.append(contentsOf: trickRepository.fsToSoulplateSpins)
            allSpins.append(contentsOf: trickRepository.fsToGrooveSpins)
            allSpins.append(contentsOf: trickRepository.bsToSoulplateSpins)
            allSpins.append(contentsOf: trickRepository.bsToGrooveSpins)
        }
        
        return allSpins
    }
    
    /// Get available spins using hybrid approach - difficulty level for preset, max degree for custom
    func getAvailableSpins(_ spins: [Spin], type: SpinType) -> [Spin] {
        if currentDifficulty.isCustom {
            // For custom settings, filter by maximum rotation degree
            let maxDegree: Int
            switch type {
            case .spinIn:
                maxDegree = customSettings.inSpinMaxDegree
            case .spinOut:
                maxDegree = customSettings.outSpinMaxDegree
            case .switchUpSpin:
                maxDegree = customSettings.switchUpSpinMaxDegree
            }
            return spins.filter { $0.rotation <= maxDegree }
        } else {
            // For preset difficulties, filter by difficulty level
            let difficultyLevel = currentDifficulty.numericLevel
            return spins.filter { $0.difficulty <= difficultyLevel }
        }
    }
    
    /// Filter spins that would create rewind with a previous trick
    func filterSpinsForRewindPrevention(_ spins: [Spin], previousDirection: SpinDirection?) -> [Spin] {
        // If no previous direction or rewinds are allowed, return original list
        guard let prevDirection = previousDirection,
              !currentDifficulty.settings.switchUpRewindAllowed else {
            return spins
        }
        
        // Filter out spins that would create a rewind
        return spins.filter { spin in
            if prevDirection == .left {
                return spin.direction != .right
            } else if prevDirection == .right {
                return spin.direction != .left
            }
            return true
        }
    }
    
    /// Select a random spin from a collection with appropriate filtering
    func selectRandomSpin(from collection: [Spin],
                         forType spinType: SpinType,
                         initialStance: Stance,
                         previousDirection: SpinDirection? = nil) -> Spin? {
        
        // 1. Filter by stance
        let stanceFiltered = collection.filter { $0.initialStance == initialStance }
        
        // 2. Apply hybrid filtering approach - difficulty or degree based
        let availableSpins = getAvailableSpins(stanceFiltered, type: spinType)
        
        // If no spins available at this difficulty/degree, return nil
        if availableSpins.isEmpty {
            return nil
        }
        
        // 3. Apply rewind prevention if applicable
        let filteredSpins = filterSpinsForRewindPrevention(availableSpins, previousDirection: previousDirection)
        
        // 4. Select a random spin
        if filteredSpins.isEmpty {
            // If no spins after rewind prevention, fall back to any available spin
            return availableSpins.randomElement()
        } else {
            return filteredSpins.randomElement()
        }
    }
    
    /// Overloaded version that accepts SpinSettingsManager.SpinSettingsType
    func getAllSpins(forType type: SpinSettingsManager.SpinSettingsType) -> [Spin] {
        switch type {
        case .spinIn: return getAllSpins(forType: SpinType.spinIn)
        case .spinOut: return getAllSpins(forType: SpinType.spinOut)
        case .switchUpSpin: return getAllSpins(forType: SpinType.switchUpSpin)
        }
    }
}
