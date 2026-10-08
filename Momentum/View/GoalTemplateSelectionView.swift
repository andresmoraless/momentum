import SwiftUI

struct GoalTemplateSelectionView: View {
    @EnvironmentObject var store: MomentumGoalStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section("Select a Goal Type") {
                    ForEach(store.templates) { template in
                        HStack(spacing: 16) {
                            Image(systemName: template.icon)
                                .font(.system(size: 28))
                                .foregroundColor(template.color)
                                .frame(width: 40, height: 40)
                            VStack(alignment: .leading, spacing: 4) {
                                Text(template.title)
                                    .font(.headline)
                                Text(template.description)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.vertical, 6)
                        .onTapGesture {
                            store.selectedTemplate = template
                            store.showSetGoalTarget = true
                        }
                    }
                }
            }
            .navigationTitle("Choose a Goal")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .sheet(isPresented: $store.showSetGoalTarget) {
                SetGoalTargetView()
                    .environmentObject(store)
            }
        }
    }
}


