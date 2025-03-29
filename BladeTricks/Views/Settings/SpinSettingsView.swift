import SwiftUI

struct SpinSettingsView: View {
    @ObservedObject var manager: SpinSettingsManager
    @EnvironmentObject var viewModel: TrickViewModel
    @State private var showDescriptions = false
    
    var body: some View {
        VStack(spacing: 12) {
            // Section header
            HStack(spacing: 4) {
                Image(systemName: manager.spinType.icon)
                    .foregroundColor(.blue)
                    .font(.system(size: 14))
                Text(manager.spinType.title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                Spacer()
            }
            .padding(.horizontal)
            
            // Max degree selector
            VStack(spacing: 8) {
                HStack {
                    Text("Maximum Spin Degree:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(manager.simpleDegree.displayName)
                        .font(.subheadline.bold())
                        .foregroundColor(.primary)
                }
                .padding(.horizontal)
                
                // Degree buttons
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 4) {
                        ForEach(SpinSettingsManager.SimpleDegreeOption.allCases, id: \.self) { option in
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    manager.setSimpleDegree(option)
                                    
                                    // Add debug output to verify
                                    if viewModel.currentDifficulty.isCustom {
                                        let settingType = manager.spinType.title
                                        print("Set \(settingType) to \(option.rawValue)°")
                                    }
                                }
                            }) {
                                Text(option.displayName)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(manager.simpleDegree == option ? .white : .secondary)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(manager.simpleDegree == option ? Color.blue : Color.gray.opacity(0.1))
                                    )
                            }
                            .buttonStyle(BorderlessButtonStyle())
                            .disabled(!viewModel.currentDifficulty.isCustom)
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Trick descriptions (expandable)
                VStack(alignment: .center, spacing: 0) {
                    if showDescriptions {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Included Spins:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.bottom, 2)
                            
                            Text(getIncludedSpinsDescription())
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 4)
                        .padding(.top, 2)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    // Toggle button
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showDescriptions.toggle()
                        }
                    }) {
                        HStack(spacing: 4) {
                            Text(showDescriptions ? "Hide details" : "Show details")
                                .font(.system(size: 10))
                                .foregroundColor(.secondary)
                            
                            Image(systemName: showDescriptions ? "chevron.up" : "chevron.down")
                                .font(.system(size: 8))
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 2)
                        .padding(.horizontal, 6)
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(8)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                }
                .padding(8)
                .background(Color.secondary.opacity(0.05))
                .cornerRadius(6)
                .padding(.horizontal)
            }
        }
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Color.blue.opacity(0.25), lineWidth: 1)
                )
        )
        .padding(.horizontal)
        .padding(.vertical, 4)
        .disabled(!viewModel.currentDifficulty.isCustom)
        .opacity(viewModel.currentDifficulty.isCustom ? 1.0 : 0.6)
        .onChange(of: viewModel.currentDifficulty.id) { _ in
            // Ensure spin settings are updated when difficulty changes
            DispatchQueue.main.async {
                manager.updateDisplayForCurrentDifficulty()
            }
        }
    }
    
    // Helper method to generate list of spins included at current degree setting
    private func getIncludedSpinsDescription() -> String {
        let maxDegree = manager.simpleDegree.rawValue
        let difficultyLevel = viewModel.currentDifficulty.numericLevel
        
        // Helper struct to organize spins by degree
        struct SpinInfo: Comparable, Hashable {
            let name: String
            let degree: Int
            
            static func < (lhs: SpinInfo, rhs: SpinInfo) -> Bool {
                return lhs.degree < rhs.degree
            }
            
            func hash(into hasher: inout Hasher) {
                hasher.combine(name)
                hasher.combine(degree)
            }
            
            static func == (lhs: SpinInfo, rhs: SpinInfo) -> Bool {
                return lhs.name == rhs.name && lhs.degree == rhs.degree
            }
        }
        
        var allSpins = Set<SpinInfo>()
        
        // Get all spins for this type using the view model's helper method
        let availableSpins = viewModel.getAllSpins(forType: manager.spinType)
            .filter { spin in
                // Apply the hybrid filtering
                if viewModel.currentDifficulty.isCustom {
                    return spin.rotation <= maxDegree
                } else {
                    return spin.difficulty <= difficultyLevel
                }
            }
        
        // Convert to SpinInfo objects for display
        for spin in availableSpins {
            allSpins.insert(
                SpinInfo(
                    name: spin.name.isEmpty ? "No Spin" : spin.name,
                    degree: spin.rotation
                )
            )
        }
        
        // Convert set to array and sort
        let sortedSpins = Array(allSpins).sorted()
        
        // Group spins by degree for display
        var result = ""
        var currentDegree = -1
        
        for spin in sortedSpins {
            if spin.degree != currentDegree {
                // Add a separator between degree groups (except for the first one)
                if currentDegree != -1 {
                    result += "\n"
                }
                
                // Add degree header if non-zero
                if spin.degree > 0 {
                    result += "• \(spin.degree)°: "
                } else {
                    result += "• No Rotation: "
                }
                
                currentDegree = spin.degree
            } else {
                result += ", "
            }
            
            result += spin.name
        }
        
        return result
    }
}
