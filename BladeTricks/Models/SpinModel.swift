//
//  SpinModel.swift
//  BladeTricks
//
//  Created by Victor on 2025-03-27.
//

import Foundation

enum SpinType {
    case spinIn, spinOut, switchUpSpin
}

enum SpinDirection {
    case left, right, neutral
}

struct Spin: Identifiable {
    let id = UUID()
    let name: String
    let type: SpinType
    let direction: SpinDirection
    let rotation: Int
    let difficulty: Int // This now represents the minimum difficulty level (1-10) required
    let initialStance: Stance
    let finalStance: Stance
    var isRewind: Bool?
    
    // Constructor that automatically calculates finalStance, isRewind is nil
    init(name: String, type: SpinType, direction: SpinDirection, rotation: Int,
         difficulty: Int, initialStance: Stance) {
        self.name = name
        self.type = type
        self.direction = direction
        self.rotation = rotation
        self.difficulty = difficulty
        self.initialStance = initialStance
        self.isRewind = nil
        self.finalStance = Self.calculateFinalStance(initialStance: initialStance,
                                                     rotation: rotation,
                                                     direction: direction)
    }
    
    // Constructor with explicit isRewind
    init(name: String, type: SpinType, direction: SpinDirection, rotation: Int,
         isRewind: Bool, difficulty: Int, initialStance: Stance) {
        self.name = name
        self.type = type
        self.direction = direction
        self.rotation = rotation
        self.difficulty = difficulty
        self.initialStance = initialStance
        self.isRewind = isRewind
        self.finalStance = Self.calculateFinalStance(initialStance: initialStance,
                                                     rotation: rotation,
                                                     direction: direction)
    }
    
    // Helper function to calculate final stance
    private static func calculateFinalStance(initialStance: Stance, rotation: Int, direction: SpinDirection) -> Stance {
        // For neutral direction, return the same stance
        if direction == .neutral {
            return initialStance
        }
        
        // Define the stance order in clockwise direction
        let stanceOrder: [Stance] = [.forward, .fs, .fakie, .bs]
        
        // Find the initial index in the stance order
        guard let initialIndex = stanceOrder.firstIndex(of: initialStance) else {
            return initialStance // Fallback if stance is not found
        }
        
        // Calculate how many 90-degree increments we need to rotate
        let steps = (rotation / 90) % 4
        
        // Adjust the step direction based on spin direction
        let adjustedSteps: Int
        if direction == .left {
            adjustedSteps = -steps // Counter-clockwise
        } else {
            adjustedSteps = steps // Clockwise
        }
        
        // Calculate the final index, ensuring it wraps around properly
        let finalIndex = (initialIndex + adjustedSteps + 4) % 4
        
        return stanceOrder[finalIndex]
    }
}
