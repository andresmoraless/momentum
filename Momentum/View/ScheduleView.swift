import SwiftUI
import Combine

struct ScheduleView: View {
    @State private var selectedDay = Date()
    @State private var showingAddSheet = false
    @State private var tappedHour: Double? = nil
    @GestureState private var dragOffset: CGFloat = 0
    @State private var editingBlock: TimeBlock? = nil
    @State private var showingEditSheet = false
    @State private var showingActionSheet = false
    @State private var tempEditingBlock: TimeBlock? = nil
    
    @State private var blocks: [TimeBlock] = [
        TimeBlock(title: "Study", startHour: 8.0, endHour: 9.0, color: .blue, date: Date()),
        TimeBlock(title: "Class", startHour: 10.0, endHour: 12.0, color: .green, date: Date()),
        TimeBlock(title: "Workout", startHour: 17.0, endHour: 18.0, color: .orange, date: Date())
    ]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                WeekStrip(selectedDay: $selectedDay)
                    .padding(.bottom, 4)
                
                Divider()
                
                ScrollView {
                    ScheduleContentView(
                        blocks: $blocks,
                        selectedDay: selectedDay,
                        tappedHour: $tappedHour,
                        showingAddSheet: $showingAddSheet,
                        editingBlock: $editingBlock,
                        showingEditSheet: $showingEditSheet,
                        showingActionSheet: $showingActionSheet,
                        tempEditingBlock: $tempEditingBlock
                    )
                }
            }
            .navigationTitle(formattedDate(selectedDay))
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
            
            .sheet(isPresented: $showingAddSheet) {
                AddEventView { newBlock in   // trailing closure = onSave:
                    var block = newBlock
                    block.date = selectedDay
                    if let hour = tappedHour {
                        block.startHour = hour
                        block.endHour = hour + 1.0
                        tappedHour = nil
                    }
                    blocks.append(block)
                }
            }
            
            .sheet(item: $editingBlock) { block in
                // Convert the block’s hour values into Date objects
                let startTime = Calendar.current.date(
                    bySettingHour: Int(block.startHour),
                    minute: Int((block.startHour.truncatingRemainder(dividingBy: 1)) * 60),
                    second: 0, of: Date()
                ) ?? Date()
                
                let endTime = Calendar.current.date(
                    bySettingHour: Int(block.endHour),
                    minute: Int((block.endHour.truncatingRemainder(dividingBy: 1)) * 60),
                    second: 0, of: Date()
                ) ?? Date()
                
                // 👇 Here’s the fixed AddEventView call for editing mode
                AddEventView(
                    isEditing: true,          // ✅ tells AddEventView it’s in edit mode
                    startTime: startTime,
                    endTime: endTime,
                    color: block.color
                ) { updatedBlock in           // ✅ onSave closure
                    if let index = blocks.firstIndex(where: { $0.id == block.id }) {
                        var edited = updatedBlock
                        edited.date = block.date
                        blocks[index] = edited
                    }
                }
            }
            
            .confirmationDialog(
                "What would you like to do?",
                isPresented: $showingActionSheet,
                titleVisibility: .visible
            ) {
                Button("Edit") {
                    if let block = tempEditingBlock {
                        editingBlock = block  // ✅ assign only here
                    }
                }
                Button("Delete", role: .destructive) {
                        if let block = tempEditingBlock,
                           let index = blocks.firstIndex(where: { $0.id == block.id }) {
                            blocks.remove(at: index)
                        }
                        tempEditingBlock = nil
                    }
                Button("Cancel", role: .cancel) {
                        tempEditingBlock = nil
                    }
                }
        }
    }
    
    private struct BlockView: View {
        let block: TimeBlock
        let index: Int
        let groupIndex: Int
        let groupSize: Int
        @Binding var blocks: [TimeBlock]
        @Binding var editingBlock: TimeBlock?
        @Binding var showingEditSheet: Bool
        @Binding var showingActionSheet: Bool
        @Binding var tempEditingBlock: TimeBlock?   // ✅ add this

        
        var body: some View {
            GeometryReader { geometry in
                // Vertical position & height
                let yOffset = CGFloat(block.startHour * 60.7)
                let blockHeight = CGFloat(block.durationHours * 60)
                
                // Horizontal layout (for overlapping)
                let labelWidth: CGFloat = 60
                let availableWidth = geometry.size.width - labelWidth - 40
                
                let (blockWidth, xOffset): (CGFloat, CGFloat) = {
                    if groupSize > 1 {
                        let w = availableWidth / CGFloat(groupSize)
                        let x = labelWidth + CGFloat(groupIndex) * w
                        return (w, x)
                    } else {
                        return (availableWidth, labelWidth)
                    }
                }()
                
                RoundedRectangle(cornerRadius: 8)
                    .fill(block.color.opacity(0.35))
                    .frame(width: blockWidth, height: blockHeight)
                    .overlay(
                        VStack(alignment: .leading, spacing: 2) {
                            Text(block.title)
                                .font(.subheadline)
                                .fontWeight(.regular)
                                .foregroundColor(.primary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Text("\(ScheduleView.hourLabel(for: block.startHour)) - \(ScheduleView.hourLabel(for: block.endHour))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            if block.repeatOption != .never {
                                Text(block.repeatOption.rawValue)
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                            }
                        }
                            .padding(6)
                    )
                    .contentShape(Rectangle())        // full block tappable
                    .offset(x: xOffset, y: yOffset)    // IMPORTANT: inside GeometryReader
                    .zIndex(10)
                    .allowsHitTesting(true)
                    .highPriorityGesture(
                        TapGesture().onEnded {
                            tempEditingBlock = block
                            showingActionSheet = true
                        }
                    )
            }
        }
    }
    
    // MARK: - Hour Grid View
    private struct HourGridView: View {
        var onHourTap: (Double) -> Void
        
        var body: some View {
            VStack(spacing: 0) {
                ForEach(Array(stride(from: 0.0, to: 24.0, by: 1.0)), id: \.self) { hour in
                    VStack(spacing: 0) {
                        HStack {
                            Text(hourLabel(for: hour))
                                .font(.caption2)
                                .foregroundColor(.gray)
                                .frame(width: 45, alignment: .trailing)
                            Rectangle()
                                .fill(Color.gray.opacity(0.15))
                                .frame(height: 1)
                        }
                        .frame(height: 30, alignment: .top)
                        
                        HStack {
                            Text("")
                                .frame(width: 45)
                            Rectangle()
                                .fill(Color.gray.opacity(0.07))
                                .frame(height: 1)
                        }
                        .frame(height: 30, alignment: .top)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        onHourTap(hour)
                    }
                    
                }
            }
        }
    }
    // MARK: - Schedule Content View
    private struct ScheduleContentView: View {
        @Binding var blocks: [TimeBlock]
        var selectedDay: Date
        @Binding var tappedHour: Double?
        @Binding var showingAddSheet: Bool
        @Binding var editingBlock: TimeBlock?
        @Binding var showingEditSheet: Bool
        @Binding var showingActionSheet: Bool
        @Binding var tempEditingBlock: TimeBlock?
        @GestureState private var dragOffset: CGFloat = 0
        
        var body: some View {
            ZStack(alignment: .topLeading) {
                HourGridView { hour in
                    tappedHour = hour
                    showingAddSheet = true
                }
                .zIndex(0)
                
                let groups = ScheduleView.groupOverlappingBlocks(blocks)
                
                ForEach(Array(groups.enumerated()), id: \.offset) { groupIndex, group in
                    ForEach(group.indices, id: \.self) { index in
                        let block = group[index]
                        BlockView(
                            block: block,
                            index: index,
                            groupIndex: groupIndex,
                            groupSize: group.count,
                            blocks: $blocks,
                            editingBlock: $editingBlock,
                            showingEditSheet: $showingEditSheet,
                            showingActionSheet: $showingActionSheet,
                            tempEditingBlock: $tempEditingBlock    // ✅ add this line
                        )
                        .zIndex(1)
                    }
                }
                CurrentTimeLine()
                    .zIndex(2)
            }
        }
    }
    
    private struct TapCatcher: View {
        var onTapHour: (Double) -> Void
        
        var body: some View {
            GeometryReader { geo in
                // Transparent, but receives taps
                Color.clear
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onEnded { value in
                                // Your layout uses 60pt per hour.
                                let hour = max(0, min(24,
                                                      Double(value.location.y / 60.0).rounded(.down)
                                                     ))
                                onTapHour(hour)
                            }
                    )
            }
        }
    }
    
    // MARK: - Current Time Line
    private struct CurrentTimeLine: View {
        @State private var now = Date()
        private let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
        
        var body: some View {
            let hour = Calendar.current.component(.hour, from: now)
            let minute = Calendar.current.component(.minute, from: now)
            let yOffset = CGFloat(Double(hour * 60 + minute))
            
            Rectangle()
                .fill(Color.red)
                .frame(height: 2)
                .offset(y: yOffset)
                .padding(.leading, 45)
                .onReceive(timer) { _ in now = Date() }
        }
    }
    
    // MARK: - Shared helpers (file scope)
    fileprivate static func hourLabel(for hour: Double) -> String {
        // show 7:00, 10:30, etc.
        let totalMinutes = Int(hour * 60)
        let hourInt = totalMinutes / 60
        let minuteInt = totalMinutes % 60
        return String(format: "%d:%02d", hourInt, minuteInt)
    }
    
    fileprivate func formattedDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "EEEE, MMM d"
        return f.string(from: date)
    }
    
    // Checks if two blocks overlap in time
    fileprivate static func overlap(_ a: TimeBlock, _ b: TimeBlock) -> Bool {
        // Returns true if the two time ranges intersect
        return a.startHour < b.endHour && b.startHour < a.endHour
    }
    
    
    // Groups events that actually overlap in time — for proper side-by-side layout
    fileprivate static func groupOverlappingBlocks(_ blocks: [TimeBlock]) -> [[TimeBlock]] {
        // Sort by start time first
        let sorted = blocks.sorted { $0.startHour < $1.startHour }
        var groups: [[TimeBlock]] = []
        
        for block in sorted {
            var placed = false
            
            // Try to add this block into an existing group if it overlaps any block in that group
            for i in groups.indices {
                if groups[i].contains(where: { overlap($0, block) }) {
                    groups[i].append(block)
                    placed = true
                    break
                }
            }
            
            // Otherwise, start a new group
            if !placed {
                groups.append([block])
            }
        }
        
        // Sort blocks *within each group* by start time for consistent stacking order
        return groups.map { $0.sorted { $0.startHour < $1.startHour } }
    }
    
}
