//
//  TrickRepository.swift
//  BladeTricks
//
//  Created by Victor on 2025-03-28.
//

import Foundation

class TrickRepository {
    // MARK: - Singleton
    static let shared = TrickRepository()
    
    private init() {
        // Initialize trick collections
        setupTrickCollections()
    }
    
    // MARK: - Trick Collections
    
    // All trick names in order of difficulty
    private(set) var allTricks: [String] = []
    
    // Categorized trick collections
    private(set) var soulplateTricks: [String] = []
    private(set) var grooveTricks: [String] = []
    private(set) var topsideNegativeTricks: [String] = []
    
    // MARK: - Spin Collections
    
    // SPINS IN:
    // Forward to Soulplate
    private(set) var forwardToSoulplateSpinsIn: [Spin] = []
    // Forward to Groove
    private(set) var forwardToGrooveSpinsIn: [Spin] = []
    // Fakie to Soulplate
    private(set) var fakieToSoulplateSpinsIn: [Spin] = []
    // Fakie to Groove
    private(set) var fakieToGrooveSpinsIn: [Spin] = []
    
    // SPINS OUT:
    // Forward Out Spins
    private(set) var forwardOutSpins: [Spin] = []
    // Fakie Out Spins
    private(set) var fakieOutSpins: [Spin] = []
    // FS Out Spins
    private(set) var fsOutSpins: [Spin] = []
    // BS Out Spins
    private(set) var bsOutSpins: [Spin] = []
    
    // SWITCH UP SPINS:
    // Forward to Soulplate
    private(set) var forwardToSoulplateSwitchUpSpins: [Spin] = []
    // Forward to Groove
    private(set) var forwardToGrooveSwitchUpSpins: [Spin] = []
    // Fakie to Soulplate
    private(set) var fakieToSoulplateSwitchUpSpins: [Spin] = []
    // Fakie to Groove
    private(set) var fakieToGrooveSwitchUpSpins: [Spin] = []
    // FS to Soulplate
    private(set) var fsToSoulplateSpins: [Spin] = []
    // FS to Groove
    private(set) var fsToGrooveSpins: [Spin] = []
    // BS to Soulplate
    private(set) var bsToSoulplateSpins: [Spin] = []
    // BS to Groove
    private(set) var bsToGrooveSpins: [Spin] = []
    
    // MARK: - Setup Methods
    
    private func setupTrickCollections() {
        // Initialize all trick collections
        setupTrickNames()
        setupSpinCollections()
    }
    
    private func setupTrickNames() {
        // All tricks in order of difficulty
        allTricks = ["Makio", "Grind", "Soul", "Mizou", "Porn Star", "Acid", "Fahrv", "Royale", "Unity", "X-Grind", "Torque Soul", "Mistrial", "Savannah", "UFO", "Torque", "Backslide", "Cab Driver", "Christ Makio", "Fastslide", "Stub Soul", "Tea Kettle", "Pudslide"]
        
        // Categorize tricks
        soulplateTricks = ["Makio", "Soul", "Mizou", "Porn Star", "Acid", "X-Grind", "Torque Soul", "Mistrial", "Christ Makio", "Stub Soul", "Tea Kettle"]
        
        grooveTricks = ["Grind", "Fahrvergnugen ", "Royale", "Unity", "Savannah", "Torque", "Backslide", "Cab Driver", "UFO", "Fastslide", "Pudslide"]
        
        topsideNegativeTricks = ["Makio", "Soul", "Mizou", "Porn Star", "Acid", "X-Grind", "Torque Soul", "Mistrial", "Christ Makio", "Tea Kettle"]
    }
    
    private func setupSpinCollections() {
        // Initialize all spin collections
        setupSpinsIn()
        setupSpinsOut()
        setupSwitchUpSpins()
    }
    
    private func setupSpinsIn() {
        // Spin In - Forward to Soulplate (difficulty 1-10 maps to required level)
        forwardToSoulplateSpinsIn = [
            Spin(name: "", type: .spinIn, direction: .neutral, rotation: 0, difficulty: 1, initialStance: .forward),
            Spin(name: "Alley-Oop", type: .spinIn, direction: .right, rotation: 180, difficulty: 2, initialStance: .forward),
            Spin(name: "Truespin", type: .spinIn, direction: .left, rotation: 180, difficulty: 3, initialStance: .forward),
            Spin(name: "360", type: .spinIn, direction: .right, rotation: 360, difficulty: 6, initialStance: .forward),
            Spin(name: "Hurricane", type: .spinIn, direction: .left, rotation: 360, difficulty: 7, initialStance: .forward),
            Spin(name: "540 Alley-Oop", type: .spinIn, direction: .right, rotation: 540, difficulty: 9, initialStance: .forward),
            Spin(name: "540 Truespin", type: .spinIn, direction: .left, rotation: 540, difficulty: 10, initialStance: .forward)
        ]
        
        // Spin In - Forward to Groove
        forwardToGrooveSpinsIn = [
            Spin(name: "FS", type: .spinIn, direction: .right, rotation: 90, difficulty: 1, initialStance: .forward),
            Spin(name: "BS", type: .spinIn, direction: .left, rotation: 90, difficulty: 1, initialStance: .forward),
            Spin(name: "270 BS", type: .spinIn, direction: .right, rotation: 270, difficulty: 4, initialStance: .forward),
            Spin(name: "270 FS", type: .spinIn, direction: .left, rotation: 270, difficulty: 4, initialStance: .forward),
            Spin(name: "450 FS", type: .spinIn, direction: .right, rotation: 450, difficulty: 7, initialStance: .forward),
            Spin(name: "450 BS", type: .spinIn, direction: .left, rotation: 450, difficulty: 7, initialStance: .forward)
        ]
        
        // Spin In - Fakie to Soulplate
        fakieToSoulplateSpinsIn = [
            Spin(name: "In-Spin", type: .spinIn, direction: .left, rotation: 180, difficulty: 2, initialStance: .fakie),
            Spin(name: "Out-Spin", type: .spinIn, direction: .right, rotation: 180, difficulty: 2, initialStance: .fakie),
            Spin(name: "Zero Spin", type: .spinIn, direction: .neutral, rotation: 0, difficulty: 1, initialStance: .fakie),
            Spin(name: "Cab Alley-Oop", type: .spinIn, direction: .right, rotation: 360, difficulty: 6, initialStance: .fakie),
            Spin(name: "Cab Truespin", type: .spinIn, direction: .left, rotation: 360, difficulty: 7, initialStance: .fakie),
            Spin(name: "540 In-Spin", type: .spinIn, direction: .left, rotation: 540, difficulty: 9, initialStance: .fakie),
            Spin(name: "540 Out-Spin", type: .spinIn, direction: .right, rotation: 540, difficulty: 10, initialStance: .fakie)
        ]
        
        // Spin In - Fakie to Groove
        fakieToGrooveSpinsIn = [
            Spin(name: "FS", type: .spinIn, direction: .left, rotation: 90, difficulty: 1, initialStance: .fakie),
            Spin(name: "BS", type: .spinIn, direction: .right, rotation: 90, difficulty: 2, initialStance: .fakie),
            Spin(name: "270 BS", type: .spinIn, direction: .left, rotation: 270, difficulty: 4, initialStance: .fakie),
            Spin(name: "270 FS", type: .spinIn, direction: .right, rotation: 270, difficulty: 5, initialStance: .fakie),
            Spin(name: "450 FS", type: .spinIn, direction: .left, rotation: 450, difficulty: 8, initialStance: .fakie),
            Spin(name: "450 BS", type: .spinIn, direction: .right, rotation: 450, difficulty: 9, initialStance: .fakie)
        ]
    }
    
    private func setupSpinsOut() {
        // Spin Out - Forward Out Spins
        forwardOutSpins = [
            Spin(name: "to Forward", type: .spinOut, direction: .neutral, rotation: 0, difficulty: 1, initialStance: .forward),
            Spin(name: "to Fakie", type: .spinOut, direction: .neutral, rotation: 180, difficulty: 2, initialStance: .forward),
            Spin(name: "360 Out to Forward", type: .spinOut, direction: .right, rotation: 360, difficulty: 6, initialStance: .forward),
            Spin(name: "540 to Fakie", type: .spinOut, direction: .right, rotation: 540, difficulty: 9, initialStance: .forward)
        ]
        
        // Spin Out - Fakie Out Spins
        fakieOutSpins = [
            Spin(name: "to Fakie", type: .spinOut, direction: .neutral, rotation: 0, difficulty: 1, initialStance: .fakie),
            Spin(name: "to Forward", type: .spinOut, direction: .neutral, rotation: 180, difficulty: 2, initialStance: .fakie),
            Spin(name: "360 Out to Fakie", type: .spinOut, direction: .right, rotation: 360, difficulty: 6, initialStance: .fakie),
            Spin(name: "540 to Forward", type: .spinOut, direction: .right, rotation: 540, difficulty: 9, initialStance: .fakie)
        ]
        
        // Spin Out - FS Out Spins
        fsOutSpins = [
            Spin(name: "to Fakie", type: .spinOut, direction: .right, rotation: 90, difficulty: 1, initialStance: .fs),
            Spin(name: "to Forward", type: .spinOut, direction: .left, rotation: 90, difficulty: 2, initialStance: .fs),
            Spin(name: "270 Out to Fakie", type: .spinOut, direction: .left, rotation: 270, difficulty: 5, initialStance: .fs),
            Spin(name: "270 Out to Forward", type: .spinOut, direction: .right, rotation: 270, difficulty: 5, initialStance: .fs),
            Spin(name: "450 Out to Fakie", type: .spinOut, direction: .right, rotation: 450, difficulty: 8, initialStance: .fs),
            Spin(name: "450 Out to Forward", type: .spinOut, direction: .left, rotation: 450, difficulty: 8, initialStance: .fs)
        ]
        
        // Spin Out - BS Out Spins
        bsOutSpins = [
            Spin(name: "to Forward", type: .spinOut, direction: .right, rotation: 90, difficulty: 1, initialStance: .bs),
            Spin(name: "to Fakie", type: .spinOut, direction: .left, rotation: 90, difficulty: 2, initialStance: .bs),
            Spin(name: "270 Out to Fakie", type: .spinOut, direction: .right, rotation: 270, difficulty: 5, initialStance: .bs),
            Spin(name: "270 Out to Forward", type: .spinOut, direction: .left, rotation: 270, difficulty: 5, initialStance: .bs),
            Spin(name: "450 Out to Fakie", type: .spinOut, direction: .left, rotation: 450, difficulty: 8, initialStance: .bs),
            Spin(name: "450 Out to Forward", type: .spinOut, direction: .right, rotation: 450, difficulty: 8, initialStance: .bs)
        ]
    }
    
    private func setupSwitchUpSpins() {
        // Switch Up Spin - Forward to Soulplate
        forwardToSoulplateSwitchUpSpins = [
            Spin(name: "", type: .switchUpSpin, direction: .neutral, rotation: 0, difficulty: 1, initialStance: .forward),
            Spin(name: "Alley-Oop", type: .switchUpSpin, direction: .right, rotation: 180, difficulty: 3, initialStance: .forward),
            Spin(name: "Truespin", type: .switchUpSpin, direction: .left, rotation: 180, difficulty: 4, initialStance: .forward),
            Spin(name: "360", type: .switchUpSpin, direction: .right, rotation: 360, difficulty: 7, initialStance: .forward),
            Spin(name: "Hurricane", type: .switchUpSpin, direction: .left, rotation: 360, difficulty: 8, initialStance: .forward),
            Spin(name: "540 Alley-Oop", type: .switchUpSpin, direction: .right, rotation: 540, difficulty: 9, initialStance: .forward),
            Spin(name: "540 Truespin", type: .switchUpSpin, direction: .left, rotation: 540, difficulty: 10, initialStance: .forward)
        ]
        
        // Switch Up Spin - Forward to Groove
        forwardToGrooveSwitchUpSpins = [
            Spin(name: "FS", type: .switchUpSpin, direction: .right, rotation: 90, difficulty: 2, initialStance: .forward),
            Spin(name: "BS", type: .switchUpSpin, direction: .left, rotation: 90, difficulty: 2, initialStance: .forward),
            Spin(name: "270 BS", type: .switchUpSpin, direction: .right, rotation: 270, difficulty: 5, initialStance: .forward),
            Spin(name: "270 FS", type: .switchUpSpin, direction: .left, rotation: 270, difficulty: 5, initialStance: .forward),
            Spin(name: "450 FS", type: .switchUpSpin, direction: .right, rotation: 450, difficulty: 8, initialStance: .forward),
            Spin(name: "450 BS", type: .switchUpSpin, direction: .left, rotation: 450, difficulty: 8, initialStance: .forward)
        ]
        
        // Switch Up Spin - Fakie to Soulplate
        fakieToSoulplateSwitchUpSpins = [
            Spin(name: "In-Spin", type: .switchUpSpin, direction: .left, rotation: 180, difficulty: 3, initialStance: .fakie),
            Spin(name: "Out-Spin", type: .switchUpSpin, direction: .right, rotation: 180, difficulty: 3, initialStance: .fakie),
            Spin(name: "Zero Spin", type: .switchUpSpin, direction: .neutral, rotation: 0, difficulty: 2, initialStance: .fakie),
            Spin(name: "Cab Alley-Oop", type: .switchUpSpin, direction: .right, rotation: 360, difficulty: 7, initialStance: .fakie),
            Spin(name: "Cab Truespin", type: .switchUpSpin, direction: .left, rotation: 360, difficulty: 7, initialStance: .fakie),
            Spin(name: "540 In-Spin", type: .switchUpSpin, direction: .left, rotation: 540, difficulty: 9, initialStance: .fakie),
            Spin(name: "540 Out-Spin", type: .switchUpSpin, direction: .right, rotation: 540, difficulty: 10, initialStance: .fakie)
        ]
        
        // Switch Up Spin - Fakie to Groove
        fakieToGrooveSwitchUpSpins = [
            Spin(name: "FS", type: .switchUpSpin, direction: .left, rotation: 90, difficulty: 2, initialStance: .fakie),
            Spin(name: "BS", type: .switchUpSpin, direction: .right, rotation: 90, difficulty: 2, initialStance: .fakie),
            Spin(name: "270 BS", type: .switchUpSpin, direction: .left, rotation: 270, difficulty: 5, initialStance: .fakie),
            Spin(name: "270 FS", type: .switchUpSpin, direction: .right, rotation: 270, difficulty: 5, initialStance: .fakie),
            Spin(name: "450 FS", type: .switchUpSpin, direction: .left, rotation: 450, difficulty: 8, initialStance: .fakie),
            Spin(name: "450 BS", type: .switchUpSpin, direction: .right, rotation: 450, difficulty: 9, initialStance: .fakie)
        ]
        
        // Switch Up Spin - FS to Soulplate
        fsToSoulplateSpins = [
            Spin(name: "", type: .switchUpSpin, direction: .left, rotation: 90, difficulty: 2, initialStance: .fs),
            Spin(name: "Alley-Oop", type: .switchUpSpin, direction: .right, rotation: 90, difficulty: 3, initialStance: .fs),
            Spin(name: "270", type: .switchUpSpin, direction: .right, rotation: 270, difficulty: 5, initialStance: .fs),
            Spin(name: "270 Truespin", type: .switchUpSpin, direction: .left, rotation: 270, difficulty: 6, initialStance: .fs),
            Spin(name: "450 Alley-Oop", type: .switchUpSpin, direction: .right, rotation: 450, difficulty: 8, initialStance: .fs),
            Spin(name: "450 (Hurricane)", type: .switchUpSpin, direction: .left, rotation: 450, difficulty: 9, initialStance: .fs)
        ]
        
        // Switch Up Spin - FS to Groove
        fsToGrooveSpins = [
            Spin(name: "FS", type: .switchUpSpin, direction: .neutral, rotation: 0, difficulty: 2, initialStance: .fs),
            Spin(name: "BS", type: .switchUpSpin, direction: .left, rotation: 180, difficulty: 3, initialStance: .fs),
            Spin(name: "Rewind BS", type: .switchUpSpin, direction: .right, rotation: 180, isRewind: true, difficulty: 4, initialStance: .fs),
            Spin(name: "360 FS", type: .switchUpSpin, direction: .left, rotation: 360, difficulty: 7, initialStance: .fs),
            Spin(name: "Rewind 360 FS", type: .switchUpSpin, direction: .right, rotation: 360, isRewind: true, difficulty: 8, initialStance: .fs)
        ]
        
        // Switch Up Spin - BS to Soulplate
        bsToSoulplateSpins = [
            Spin(name: "", type: .switchUpSpin, direction: .right, rotation: 90, difficulty: 2, initialStance: .bs),
            Spin(name: "Truespin", type: .switchUpSpin, direction: .left, rotation: 90, difficulty: 3, initialStance: .bs),
            Spin(name: "270", type: .switchUpSpin, direction: .left, rotation: 270, difficulty: 5, initialStance: .bs),
            Spin(name: "270 Alley-Oop", type: .switchUpSpin, direction: .right, rotation: 270, difficulty: 6, initialStance: .bs),
            Spin(name: "450 Truespin", type: .switchUpSpin, direction: .left, rotation: 450, difficulty: 8, initialStance: .bs),
            Spin(name: "450", type: .switchUpSpin, direction: .right, rotation: 450, difficulty: 9, initialStance: .bs)
        ]
        
        // Switch Up Spin - BS to Groove
        bsToGrooveSpins = [
            Spin(name: "BS", type: .switchUpSpin, direction: .neutral, rotation: 0, difficulty: 2, initialStance: .bs),
            Spin(name: "FS", type: .switchUpSpin, direction: .left, rotation: 180, difficulty: 3, initialStance: .bs),
            Spin(name: "Rewind FS", type: .switchUpSpin, direction: .right, rotation: 180, isRewind: true, difficulty: 4, initialStance: .bs),
            Spin(name: "360 BS", type: .switchUpSpin, direction: .left, rotation: 360, difficulty: 7, initialStance: .bs),
            Spin(name: "Rewind 360 BS", type: .switchUpSpin, direction: .right, rotation: 360, isRewind: true, difficulty: 8, initialStance: .bs)
        ]
    }
    
    // MARK: - Helper Methods
    
    /// Check if a trick is a soulplate trick
    func isSoulplateTrick(_ trickName: String) -> Bool {
        return soulplateTricks.contains(trickName)
    }
    
    /// Check if a trick is a groove trick
    func isGrooveTrick(_ trickName: String) -> Bool {
        return grooveTricks.contains(trickName)
    }
    
    /// Check if a trick can have topside/negative variations
    func canHaveTopsideNegative(_ trickName: String) -> Bool {
        return topsideNegativeTricks.contains(trickName)
    }
    
    /// Get a random trick name based on the difficulty cap
    func getRandomTrick(withCap cap: Int) -> String {
        let actualCap = min(cap, allTricks.count)
        return allTricks[Int.random(in: 0..<actualCap)]
    }
    
    /// Get spins available for the current difficulty level
    func getSpinsForDifficulty(_ spins: [Spin], difficultyLevel: Int) -> [Spin] {
        return spins.filter { $0.difficulty <= difficultyLevel }
    }
    
    /// Filter spins by direction (for rewind prevention)
    func filterSpins(_ spins: [Spin], excludingDirection direction: SpinDirection) -> [Spin] {
        return spins.filter { $0.direction != direction }
    }
    
    /// Find a spin by name in a specific collection
    func findSpin(named name: String, in collection: [Spin]) -> Spin? {
        return collection.first { $0.name == name }
    }
}
