import Foundation
import SwiftUI
import Combine

/// A manager for spin settings that handles both degree-based (custom) and difficulty-based (preset) filtering
class SpinSettingsManager: ObservableObject {
    // MARK: - Enums and Types
    
    /// Represents the type of spin settings
    enum SpinSettingsType {
        case spinIn
        case spinOut
        case switchUpSpin
        
        var title: String {
            switch self {
            case .spinIn: return "In Spins"
            case .spinOut: return "Out Spins"
            case .switchUpSpin: return "Switch-Up Spins"
            }
        }
        
        var icon: String {
            switch self {
            case .spinIn: return "arrow.down.forward.circle"
            case .spinOut: return "arrow.up.forward.circle"
            case .switchUpSpin: return "arrow.triangle.2.circlepath.circle"
            }
        }
        
        // Add a property to get the corresponding max degree from settings
        func getMaxDegree(from settings: Difficulty.DifficultySettings) -> Int {
            switch self {
            case .spinIn: return settings.inSpinMaxDegree
            case .spinOut: return settings.outSpinMaxDegree
            case .switchUpSpin: return settings.switchUpSpinMaxDegree
            }
        }
        
        // Add a method to set the corresponding max degree in settings
        func setMaxDegree(value: Int, in settings: inout Difficulty.DifficultySettings) {
            switch self {
            case .spinIn: settings.inSpinMaxDegree = value
            case .spinOut: settings.outSpinMaxDegree = value
            case .switchUpSpin: settings.switchUpSpinMaxDegree = value
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
        
        // Helper to find the closest option for a given degree value
        static func closestOption(for degree: Int) -> SimpleDegreeOption {
            return SimpleDegreeOption.allCases.first { $0.rawValue >= degree } ?? .oneEighty
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
        
        // Initial setup
        updateDisplayForCurrentDifficulty()
        
        // Set up observers
        setupObservers()
    }
    
    // MARK: - Public Methods
    
    /// Updates the UI to reflect the current difficulty settings
    func updateDisplayForCurrentDifficulty() {
        guard let viewModel = viewModel else { return }
        
        if viewModel.currentDifficulty.isCustom {
            // For custom settings, use the saved degree values from the settings
            let maxDegree = spinType.getMaxDegree(from: viewModel.customSettings)
            self.simpleDegree = SimpleDegreeOption.closestOption(for: maxDegree)
        } else {
            // For preset difficulties, calculate from the available spins
            self.simpleDegree = findHighestDegreeFromSettings()
        }
    }
    
    /// Set the simple degree and update related settings
    func setSimpleDegree(_ degree: SimpleDegreeOption) {
        // Only update if the value actually changes to avoid unnecessary saves
        if simpleDegree != degree {
            simpleDegree = degree
            updateSettingsFromSimpleDegree()
        }
    }
    
    // MARK: - Private Methods
    
    private func setupObservers() {
        // Observe settings changes from the SettingsService
        viewModel?.settingsServiceChanged
            .sink { [weak self] in
                self?.updateDisplayForCurrentDifficulty()
            }
            .store(in: &cancellables)
        
        // Observe changes to the current difficulty
        viewModel?.$currentDifficulty
            .dropFirst()
            .sink { [weak self] _ in
                self?.updateDisplayForCurrentDifficulty()
            }
            .store(in: &cancellables)
    }
    
    private func updateSettingsFromSimpleDegree() {
        guard let viewModel = viewModel else { return }
        
        // Only modify settings if we're using custom difficulty
        if viewModel.currentDifficulty.isCustom {
            // Create a local copy of settings to modify
            var settings = viewModel.customSettings
            
            // Update the max degree value based on the spin type
            spinType.setMaxDegree(value: simpleDegree.rawValue, in: &settings)
            
            // Apply updated settings
            viewModel.customSettings = settings
            viewModel.applyCustomSettings()
        }
    }
    
    /// Find the highest allowed degree for current settings
    func findHighestDegreeFromSettings() -> SimpleDegreeOption {
        guard let viewModel = viewModel else { return .oneEighty }
        
        // For preset difficulties, determine max degree based on difficulty level
        let difficultyLevel = viewModel.currentDifficulty.numericLevel
        
        // Get all spins across all collections for this spin type
        let availableSpins = viewModel.getAllSpins(forType: spinType)
            .filter { $0.difficulty <= difficultyLevel }
        
        // Find the highest rotation degree among available spins
        let highestDegree = availableSpins.max(by: { $0.rotation < $1.rotation })?.rotation ?? 180
        
        // Convert to SimpleDegreeOption
        return SimpleDegreeOption.closestOption(for: highestDegree)
    }
}
