//
//  TrickModel.swift
//  BladeTricks
//
//  Created by Victor on 2024-05-09.
//

import Foundation

enum Stance: String, Codable, CaseIterable {
    case forward = "Forward"
    case fakie = "Fakie"
    case fs = "FS"
    case bs = "BS"
}

enum TrickType: String, Codable, CaseIterable {
    case soulplate = "Soulplate"
    case groove = "Groove"
}


struct Trick {
    var initialStance: Stance
    var spinIn: Spin?  // Changed from String to Spin?
    var trickName: String
    var type: TrickType
    var isTopside: Bool
    var isNegative: Bool
    var grindStance: Stance
    var spinOut: Spin?  // Changed from String to Spin?
    var outStance: Stance
    var trickFullName: String

    init(initialStance: Stance = .forward,
        spinIn: Spin? = nil,
        trickName: String = "",
        type: TrickType = .soulplate,
        isTopside: Bool = false,
        isNegative: Bool = false,
        grindStance: Stance = .forward,
        spinOut: Spin? = nil,
        outStance: Stance = .forward,
        trickFullName: String = "") {
        
        self.initialStance = initialStance
        self.spinIn = spinIn
        self.trickName = trickName
        self.type = type
        self.isTopside = isTopside
        self.isNegative = isNegative
        self.grindStance = grindStance
        self.spinOut = spinOut
        self.outStance = outStance
        self.trickFullName = trickFullName
    }
    
    // Helper computed properties for backward compatibility
    var spinInName: String {
        return spinIn?.name ?? ""
    }
    
    var spinOutName: String {
        return spinOut?.name ?? ""
    }
}
