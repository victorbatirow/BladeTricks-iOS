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
    var id = UUID()
    var initialStance: Stance
    var spinIn: String
    var spinInDirection: String
    var trickName: String
    var type: TrickType
    var isTopside: Bool
    var isNegative: Bool
    var grindStance: Stance
    var spinOut: String
    var spinOutDirection: String
    var isSpinOutRewind: Bool
    var outStance: Stance
    var trickFullName: String

    init(initialStance: Stance = .forward,
        spinIn: String = "",
        spinInDirection: String = "",
        trickName: String = "",
         type: TrickType = .soulplate,
        isTopside: Bool = false,
        isNegative: Bool = false,
        grindStance: Stance = .forward,
        spinOut: String = "",
        spinOutDirection: String = "",
        isSpinOutRewind: Bool = false,
        outStance: Stance = .forward,
        trickFullName: String = "") {
        
        self.initialStance = initialStance
        self.spinIn = spinIn
        self.spinInDirection = spinInDirection
        self.trickName = trickName
        self.type = type
        self.isTopside = isTopside
        self.isNegative = isNegative
        self.grindStance = grindStance
        self.spinOut = spinOut
        self.spinOutDirection = spinOutDirection
        self.isSpinOutRewind = isSpinOutRewind
        self.outStance = outStance
        self.trickFullName = trickFullName
    }
}

