import SwiftUI

struct GoalDashboardView: View {
    @EnvironmentObject var store: MomentumGoalStore
    @State private var showCreateGoal = false
    @State private var isEditing = false
    @State private var showMonthlySection = true   // NEW: controls dropdown visibility
    @Namespace private var animation
    @State private var showBanner = false
    @State private var bannerMessage = ""
    @State private var bannerColor: Color = .accentColor
    @State private var showingSettings = false

    // Two-column grid layout
    let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        NavigationStack {
            ScrollView {
                // MARK: - Weekly Section
                VStack(alignment: .leading, spacing: 16) {
                    Spacer().frame(height: 8)
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(store.weeklyGoals) { goal in
                            IndicatorCard(goal: goal, isEditing: isEditing)
                                .animation(.easeInOut(duration: 0.2), value: isEditing)
                        }

                        // Inline “Add Goal” button
                        Button(action: { showCreateGoal = true }) {
                            VStack {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray.opacity(0.7))
                                Text("Add Goal")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            .frame(maxWidth: .infinity, minHeight: 120)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)
                }

                // MARK: - Monthly Section
                if !store.monthlyGoals.isEmpty {
                    Divider().padding(.horizontal)
                    MonthlyGoalsView()
                        .environmentObject(store)
                        .padding(.top, 8)
                        .padding(.bottom, 24)
                }

                // MARK: - Empty State
                if store.weeklyGoals.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "target")
                            .font(.system(size: 42))
                            .foregroundColor(.gray.opacity(0.7))
                        Text("No goals yet this week.")
                            .font(.headline)
                            .foregroundColor(.gray)
                        Text("Tap “+ Add Goal” to get started!")
                            .font(.subheadline)
                            .foregroundColor(.gray.opacity(0.8))
                    }
                    .padding(.top, 60)
                }
            }
            .overlay(
                ZStack {
                    if let message = store.completionMessage {
                        // MARK: - Confetti (appears first)
                        ConfettiView(baseColor: store.currentGoalColor ?? .accentColor)
                            .opacity(1)
                            .transition(.opacity)
                            .zIndex(1)
                            .task {
                                // Auto dismiss after 2s total
                                try? await Task.sleep(for: .seconds(2.0))
                                withAnimation(.easeInOut(duration: 0.4)) {
                                    store.completionMessage = nil
                                    store.currentGoalColor = nil // ✅ reset color here instead
                                }
                            }

                        // MARK: - Banner (slides in slightly after confetti)
                        CompletionBanner(
                            message: message,
                            color: store.currentGoalColor ?? .accentColor,
                            isVisible: .constant(true)
                        )
                        .padding(.bottom, 20)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .zIndex(2)
                        .task {
                            // Auto dismiss after 2s total
                            try? await Task.sleep(for: .seconds(2.0))
                            withAnimation(.easeInOut(duration: 0.4)) {
                                store.completionMessage = nil
                            }
                        }
                    }
                },
                alignment: .top
            )
            .navigationTitle("Weekly Indicators")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        Button(isEditing ? "Done" : "Edit") {
                            withAnimation { isEditing.toggle() }
                        }
                        Button {
                            showingSettings = true
                        } label: {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 22))
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
                    .presentationDetents([.medium, .large])
            }
            .sheet(isPresented: $showCreateGoal) {
                GoalTemplateSelectionView()
                    .environmentObject(store)
            }
        }
    }
}



