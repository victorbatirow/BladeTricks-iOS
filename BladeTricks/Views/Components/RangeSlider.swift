import SwiftUI

// Compact FlowLayout for displaying tricks in a more space-efficient layout
struct CompactFlowLayout: Layout {
    var spacing: CGFloat = 6 // Reduced spacing
    var rowLimit: Int? = nil // Optional limit to number of rows shown
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) -> CGSize {
        let containerWidth = proposal.width ?? .infinity
        
        // Calculate lines
        var lines: [[LayoutSubview]] = [[]]
        var lineWidths: [CGFloat] = [0]
        var lineIndex = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            
            if lineWidths[lineIndex] + size.width + (lines[lineIndex].isEmpty ? 0 : spacing) > containerWidth {
                // Start a new line
                lineIndex += 1
                if let rowLimit = rowLimit, lineIndex >= rowLimit {
                    break // Stop adding rows if we've hit the limit
                }
                lines.append([])
                lineWidths.append(0)
            }
            
            lines[lineIndex].append(subview)
            lineWidths[lineIndex] += size.width + (lines[lineIndex].count > 1 ? spacing : 0)
        }
        
        // Calculate height
        var height: CGFloat = 0
        for line in lines {
            let lineHeight = line.map { $0.sizeThatFits(.unspecified).height }.max() ?? 0
            height += lineHeight
        }
        
        // Add spacing between lines
        height += CGFloat(lines.count - 1) * spacing
        
        return CGSize(width: containerWidth, height: height)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) {
        guard !subviews.isEmpty else { return }
        
        let containerWidth = bounds.width
        
        var lines: [[LayoutSubview]] = [[]]
        var lineWidths: [CGFloat] = [0]
        var lineIndex = 0
        var placedViews = 0
        
        // First pass: group elements into lines
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            
            if lineWidths[lineIndex] + size.width + (lines[lineIndex].isEmpty ? 0 : spacing) > containerWidth {
                // Start a new line
                lineIndex += 1
                if let rowLimit = rowLimit, lineIndex >= rowLimit {
                    break // Stop adding rows if we've hit the limit
                }
                lines.append([])
                lineWidths.append(0)
            }
            
            lines[lineIndex].append(subview)
            lineWidths[lineIndex] += size.width + (lines[lineIndex].count > 1 ? spacing : 0)
            placedViews += 1
        }
        
        // Second pass: position elements
        var y = bounds.minY
        
        for (lineIdx, line) in lines.enumerated() {
            // Calculate the height of this line
            let lineHeight = line.map { $0.sizeThatFits(.unspecified).height }.max() ?? 0
            
            // Start at the left edge
            var x = bounds.minX
            
            for view in line {
                let size = view.sizeThatFits(.unspecified)
                view.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(width: size.width, height: size.height))
                x += size.width + spacing
            }
            
            // Add "... more" indicator if we didn't place all views and this is the last row
            if let rowLimit = rowLimit, lineIdx == rowLimit - 1 && placedViews < subviews.count {
                // We'd add an indicator here in a real implementation
            }
            
            // Move to the next line
            y += lineHeight + spacing
        }
    }
}

struct CompactRangeSlider: View {
    @Binding var value: Int
    var title: String
    var range: ClosedRange<Int>
    var totalItems: Int
    var valueDescription: String? = nil
    var items: [String]? = nil
    var showMoreButton: Bool = false // Option to add a "show more" button
    
    @State private var isDragging = false
    @State private var showOnlyActive = false // Track if we're showing only active items
    
    // Color theme
    var color: Color = Color.purple
    
    var body: some View {
        VStack(spacing: 8) { // Reduced spacing
            // Title and current value
            HStack(spacing: 4) {
                Image(systemName: "bag")
                    .foregroundColor(color)
                    .font(.system(size: 14))
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                Text("- \(value)/\(totalItems)")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                Spacer()
                
                // Toggle button to switch between "Show All" and "Show Active"
                if showMoreButton && items != nil && (items?.count ?? 0) > 6 {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showOnlyActive.toggle()
                        }
                    }) {
                        Text(showOnlyActive ? "Show All" : "Show Active")
                            .font(.caption)
                            .foregroundColor(color)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                }
            }
            
            // Compact trick display using tags
            if let items = items, !items.isEmpty {
                VStack(alignment: .leading, spacing: 4) { // Reduced spacing
                    // Filter items based on the showOnlyActive state
                    let filteredItems = showOnlyActive
                        ? Array(items.enumerated()).filter { $0.offset < value }
                        : Array(items.enumerated())
                    
                    if filteredItems.isEmpty && showOnlyActive {
                        // Show message when no active tricks
                        Text("No active tricks selected")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.vertical, 4)
                    } else {
                        CompactFlowLayout(spacing: 4) {
                            ForEach(filteredItems, id: \.element) { index, item in
                                // More compact tag style
                                Text(item)
                                    .font(.caption2) // Smaller font
                                    .padding(.horizontal, 6) // Reduced padding
                                    .padding(.vertical, 2) // Reduced padding
                                    .background(
                                        RoundedRectangle(cornerRadius: 3) // Smaller corners
                                            .fill(Color.secondary.opacity(index < value ? 0.15 : 0.05))
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 3)
                                            .strokeBorder(
                                                index < value ? color.opacity(0.4) : Color.clear,
                                                lineWidth: 1
                                            )
                                    )
                                    .foregroundColor(index < value ? .primary : .secondary.opacity(0.6))
                            }
                        }
                    }
                }
                .animation(.easeInOut(duration: 0.2), value: value)
                .animation(.easeInOut(duration: 0.2), value: showOnlyActive)
            }
            
            // Slider track
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Inset calculation
                    let sliderInset: CGFloat = 10  // Reduced inset
                    let usableWidth = geometry.size.width - (sliderInset * 2)
                    
                    // Background track
                    Rectangle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: usableWidth, height: 8) // Match PercentageSlider track height
                        .position(x: geometry.size.width/2, y: 12)
                    
                    // Progress bar
                    Rectangle()
                        .fill(color)
                        .frame(width: calculateWidth(totalWidth: usableWidth), height: 8) // Match PercentageSlider track height
                        .position(x: sliderInset + calculateWidth(totalWidth: usableWidth)/2, y: 12)
                    
                    // Simplified notch markers - fewer of them
                    ZStack {
                        let maxSteps = min(5, totalItems) // Fewer notches
                        let stepSize = Double(totalItems) / Double(maxSteps)
                        
                        ForEach(0..<(maxSteps + 1), id: \.self) { i in
                            let stepValue = Int(Double(i) * stepSize)
                            if stepValue <= totalItems {
                                let percent = Double(stepValue) / Double(totalItems)
                                let markerX = sliderInset + (usableWidth * CGFloat(percent))
                                
                                Rectangle()
                                    .fill(Color.white.opacity(0.5))
                                    .frame(width: 1, height: 6) // Match track height
                                    .position(x: markerX, y: 10)
                            }
                        }
                    }
                    
                    // Draggable thumb - match PercentageSlider thumb size
                    Circle()
                        .fill(Color.white)
                        .frame(width: 24, height: 24) // Match PercentageSlider thumb size
                        .shadow(color: color.opacity(0.5), radius: isDragging ? 4 : 2, x: 0, y: 0)
                        .overlay(
                            Circle()
                                .stroke(color, lineWidth: 2)
                        )
                        .position(x: calculateThumbPosition(totalWidth: usableWidth, inset: sliderInset), y: 12)
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { gesture in
                                    isDragging = true
                                    
                                    // Convert drag location to value
                                    let adjustedX = max(sliderInset, min(gesture.location.x, geometry.size.width - sliderInset))
                                    let percentage = (adjustedX - sliderInset) / usableWidth
                                    let newValue = range.lowerBound + Int(round(percentage * Double(range.upperBound - range.lowerBound)))
                                    
                                    if value != newValue {
                                        value = max(range.lowerBound, min(range.upperBound, newValue))
                                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                    }
                                }
                                .onEnded { _ in
                                    isDragging = false
                                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                }
                        )
                }
                .contentShape(Rectangle())
                .frame(height: 24) // Match PercentageSlider track area height
                .onTapGesture { location in
                    // Calculate the inset and usable width
                    let sliderInset: CGFloat = 10
                    let usableWidth = geometry.size.width - (sliderInset * 2)
                    
                    // Adjust for the inset when calculating value
                    let adjustedX = max(sliderInset, min(location.x, geometry.size.width - sliderInset))
                    let percentage = (adjustedX - sliderInset) / usableWidth
                    let newValue = range.lowerBound + Int(round(percentage * Double(range.upperBound - range.lowerBound)))
                    
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        value = max(range.lowerBound, min(range.upperBound, newValue))
                    }
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }
            }
            .frame(height: 24) // Match PercentageSlider height
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8) // Reduced vertical padding
        .background(
            RoundedRectangle(cornerRadius: 10) // Smaller corner radius
                .fill(Color.black.opacity(0.15)) // Lighter background
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(color.opacity(0.25), lineWidth: 1) // Thinner border
                )
        )
        .padding(.horizontal)
    }
    
    // Helper functions
    private func calculateWidth(totalWidth: CGFloat) -> CGFloat {
        let percentage = Double(value - range.lowerBound) / Double(range.upperBound - range.lowerBound)
        return CGFloat(percentage) * totalWidth
    }
    
    private func calculateThumbPosition(totalWidth: CGFloat, inset: CGFloat) -> CGFloat {
        let percentage = Double(value - range.lowerBound) / Double(range.upperBound - range.lowerBound)
        return inset + (CGFloat(percentage) * totalWidth)
    }
}

// Preview
struct CompactRangeSlider_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color(red: 0.1, green: 0.1, blue: 0.2).edgesIgnoringSafeArea(.all)
            VStack(spacing: 20) {
                CompactRangeSlider(
                    value: .constant(8),
                    title: "Bag of Tricks ",
                    range: 1...20,
                    totalItems: 20,
                    items: ["Mizou", "Makio", "Acid", "Unity", "Pornstar", "Torque", "Sweatstance", "Backslide",
                           "X-Grind", "Royale", "Fishbrain", "Soul", "Mistrial", "Savannah", "Full Torque",
                           "Pudslide", "Kindgrind", "AO Makio", "AO Soul", "Half Cab Soul"],
                    showMoreButton: true
                )
                
                CompactRangeSlider(
                    value: .constant(4),
                    title: "Spin Options ",
                    range: 0...6,
                    totalItems: 6,
                    color: Color.blue
                )
            }
            .padding(24)
        }
    }
}
