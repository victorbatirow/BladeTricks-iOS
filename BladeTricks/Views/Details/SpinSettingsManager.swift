//
//  SpinSettingsManager.swift
//  BladeTricks
//
//  Created by Victor on 2025-03-20.
//

import Foundation
import SwiftUI
import Combine

/// A simplified manager for spin settings that focuses on maximum degree selection
class SpinSettingsManager: ObservableObject {
    // MARK: - Enums and Types
    
    /// Represents the type of spin settings
    enum SpinSettingsType {
        case inSpin
        case outSpin
        case switchUpSpin
        
        var title: String {
            switch self {
            case .inSpin: return "In Spins"
            case .outSpin: return "Out Spins"
            case .switchUpSpin: return "Switch-Up Spins"
            }
        }
        
        var icon: String {
            switch self {
            case .inSpin: return "arrow.down.forward.circle"
            case .outSpin: return "arrow.up.forward.circle"
            case .switchUpSpin: return "arrow.triangle.2.circlepath.circle"
            }
        }
    }
    
    /// Simple spin degree options
    enum SimpleDegreeOption: Int, CaseIterable {
        case zero = 0
        case ninety = 90
        case oneEighty = 180
        case twoSeventy = 270
        case threeSixty = 360
        case fourFifty = 450
        case fiveForty = 540
        
        var displayName: String {
            switch self {
            case .zero: return "0°"
            case .ninety: return "90°"
            case .oneEighty: return "180°"
            case .twoSeventy: return "270°"
            case .threeSixty: return "360°"
            case .fourFifty: return "450°"
            case .fiveForty: return "540°"
            }
        }
    }
    
    // MARK: - Properties
    
    /// The type of spin settings this manager handles
    let spinType: SpinSettingsType
    
    /// The current simple degree setting
    @Published var simpleDegree: SimpleDegreeOption = .oneEighty
    
    /// Reference to the view model to access spin options
    private weak var viewModel: TrickViewModel?
    
    /// Cancellables for Combine subscribers
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init(spinType: SpinSettingsType, viewModel: TrickViewModel) {
        self.spinType = spinType
        self.viewModel = viewModel
        
        // Set initial degree based on the current settings
        self.simpleDegree = findHighestDegreeFromSettings()
        
        // Set up observers to update settings when simple degree changes
        setupObservers()
    }
    
    // MARK: - Public Methods
    
    /// Set the simple degree and update all related settings
    func setSimpleDegree(_ degree: SimpleDegreeOption) {
        simpleDegree = degree
        updateSettingsFromSimpleDegree()
    }
    
    // MARK: - Private Methods
    
    private func setupObservers() {
        // Observe changes to the simple degree setting
        $simpleDegree
            .dropFirst()
            .sink { [weak self] _ in
                self?.updateSettingsFromSimpleDegree()
            }
            .store(in: &cancellables)
    }
    
    /// Updates all settings based on the current simple degree setting
    private func updateSettingsFromSimpleDegree() {
        guard let viewModel = viewModel, viewModel.currentDifficulty.isCustom else { return }
        
        // Create a local copy of settings to modify
        var settings = viewModel.customSettings
        
        // Filter spin options based on the maximum degree
        let maxDegree = simpleDegree.rawValue
        
        switch spinType {
        case .inSpin:
            // Update in-spin settings
            settings.soulplateForwardInSpinsCAP = calculateCapValue(
                for: viewModel.forwardToSoulplateSpins,
                maxDegree: maxDegree
            )
            
            settings.soulplateFakieInSpinsCAP = calculateCapValue(
                for: viewModel.fakieToSoulplateSpins,
                maxDegree: maxDegree
            )
            
            settings.grooveForwardInSpinsCAP = calculateCapValue(
                for: viewModel.forwardToGrooveSpins,
                maxDegree: maxDegree
            )
            
            settings.grooveFakieInSpinsCAP = calculateCapValue(
                for: viewModel.fakieToGrooveSpins,
                maxDegree: maxDegree
            )
            
        case .outSpin:
            // Update out-spin settings
            settings.soulplateForwardOutSpinsCAP = calculateCapValue(
                for: viewModel.forwardOutSpins,
                maxDegree: maxDegree
            )
            
            settings.soulplateFakieOutSpinsCAP = calculateCapValue(
                for: viewModel.fakieOutSpins,
                maxDegree: maxDegree
            )
            
            settings.fsOutSpinsCAP = calculateCapValue(
                for: viewModel.fsOutSpins,
                maxDegree: maxDegree
            )
            
            settings.bsOutSpinsCAP = calculateCapValue(
                for: viewModel.bsOutSpins,
                maxDegree: maxDegree
            )
            
        case .switchUpSpin:
            // Update switch-up spin settings
            settings.grooveFSToSoulplateSpinsCAP = calculateCapValue(
                for: viewModel.fsToSoulplateSpins,
                maxDegree: maxDegree
            )
            
            settings.grooveBSToSoulplateSpinsCAP = calculateCapValue(
                for: viewModel.bsToSoulplateSpins,
                maxDegree: maxDegree
            )
            
            settings.grooveFSToGrooveSpinsCAP = calculateCapValue(
                for: viewModel.fsToGrooveSpins,
                maxDegree: maxDegree
            )
            
            settings.grooveBSToGrooveSpinsCAP = calculateCapValue(
                for: viewModel.bsToGrooveSpins,
                maxDegree: maxDegree
            )
        }
        
        // Apply updated settings
        viewModel.customSettings = settings
        viewModel.applyCustomSettings()
    }
    
    /// Calculate the CAP value (maximum index) for a spin option array based on maximum degree
    private func calculateCapValue(for spinOptions: [TrickViewModel.SpinOption], maxDegree: Int) -> Int {
        // Filter options by degree and return the count
        let allowedOptions = spinOptions.filter { spinOption in
            let spinDegree = extractDegreeFromDirection(spinOption.direction)
            return spinDegree <= maxDegree
        }
        
        return allowedOptions.count
    }
    
    /// Extract the degree value from a spin direction string
    private func extractDegreeFromDirection(_ direction: String) -> Int {
        if direction == "N0" {
            return 0
        }
        
        // Extract numeric part from the string
        let numericPart = direction.filter { $0.isNumber }
        return Int(numericPart) ?? 0
    }
    
    /// Find the highest degree from current settings
    func findHighestDegreeFromSettings() -> SimpleDegreeOption {
        guard let viewModel = viewModel else { return .oneEighty }
        
        var highestDegree = 0
        
        switch spinType {
        case .inSpin:
            // Check all in-spin settings
            if viewModel.customSettings.soulplateForwardInSpinsCAP > 0 {
                for i in 0..<min(viewModel.customSettings.soulplateForwardInSpinsCAP, viewModel.forwardToSoulplateSpins.count) {
                    highestDegree = max(highestDegree, extractDegreeFromDirection(viewModel.forwardToSoulplateSpins[i].direction))
                }
            }
            
            if viewModel.customSettings.soulplateFakieInSpinsCAP > 0 {
                for i in 0..<min(viewModel.customSettings.soulplateFakieInSpinsCAP, viewModel.fakieToSoulplateSpins.count) {
                    highestDegree = max(highestDegree, extractDegreeFromDirection(viewModel.fakieToSoulplateSpins[i].direction))
                }
            }
            
            if viewModel.customSettings.grooveForwardInSpinsCAP > 0 {
                for i in 0..<min(viewModel.customSettings.grooveForwardInSpinsCAP, viewModel.forwardToGrooveSpins.count) {
                    highestDegree = max(highestDegree, extractDegreeFromDirection(viewModel.forwardToGrooveSpins[i].direction))
                }
            }
            
            if viewModel.customSettings.grooveFakieInSpinsCAP > 0 {
                for i in 0..<min(viewModel.customSettings.grooveFakieInSpinsCAP, viewModel.fakieToGrooveSpins.count) {
                    highestDegree = max(highestDegree, extractDegreeFromDirection(viewModel.fakieToGrooveSpins[i].direction))
                }
            }
            
        case .outSpin:
            // Check all out-spin settings
            if viewModel.customSettings.soulplateForwardOutSpinsCAP > 0 {
                for i in 0..<min(viewModel.customSettings.soulplateForwardOutSpinsCAP, viewModel.forwardOutSpins.count) {
                    highestDegree = max(highestDegree, extractDegreeFromDirection(viewModel.forwardOutSpins[i].direction))
                }
            }
            
            if viewModel.customSettings.soulplateFakieOutSpinsCAP > 0 {
                for i in 0..<min(viewModel.customSettings.soulplateFakieOutSpinsCAP, viewModel.fakieOutSpins.count) {
                    highestDegree = max(highestDegree, extractDegreeFromDirection(viewModel.fakieOutSpins[i].direction))
                }
            }
            
            if viewModel.customSettings.fsOutSpinsCAP > 0 {
                for i in 0..<min(viewModel.customSettings.fsOutSpinsCAP, viewModel.fsOutSpins.count) {
                    highestDegree = max(highestDegree, extractDegreeFromDirection(viewModel.fsOutSpins[i].direction))
                }
            }
            
            if viewModel.customSettings.bsOutSpinsCAP > 0 {
                for i in 0..<min(viewModel.customSettings.bsOutSpinsCAP, viewModel.bsOutSpins.count) {
                    highestDegree = max(highestDegree, extractDegreeFromDirection(viewModel.bsOutSpins[i].direction))
                }
            }
            
        case .switchUpSpin:
            // Check all switch-up spin settings
            if viewModel.customSettings.grooveFSToSoulplateSpinsCAP > 0 {
                for i in 0..<min(viewModel.customSettings.grooveFSToSoulplateSpinsCAP, viewModel.fsToSoulplateSpins.count) {
                    highestDegree = max(highestDegree, extractDegreeFromDirection(viewModel.fsToSoulplateSpins[i].direction))
                }
            }
            
            if viewModel.customSettings.grooveBSToSoulplateSpinsCAP > 0 {
                for i in 0..<min(viewModel.customSettings.grooveBSToSoulplateSpinsCAP, viewModel.bsToSoulplateSpins.count) {
                    highestDegree = max(highestDegree, extractDegreeFromDirection(viewModel.bsToSoulplateSpins[i].direction))
                }
            }
            
            if viewModel.customSettings.grooveFSToGrooveSpinsCAP > 0 {
                for i in 0..<min(viewModel.customSettings.grooveFSToGrooveSpinsCAP, viewModel.fsToGrooveSpins.count) {
                    highestDegree = max(highestDegree, extractDegreeFromDirection(viewModel.fsToGrooveSpins[i].direction))
                }
            }
            
            if viewModel.customSettings.grooveBSToGrooveSpinsCAP > 0 {
                for i in 0..<min(viewModel.customSettings.grooveBSToGrooveSpinsCAP, viewModel.bsToGrooveSpins.count) {
                    highestDegree = max(highestDegree, extractDegreeFromDirection(viewModel.bsToGrooveSpins[i].direction))
                }
            }
        }
        
        // Convert the raw degree to a SimpleDegreeOption
        return SimpleDegreeOption.allCases.first { $0.rawValue >= highestDegree } ?? .oneEighty
    }
}
