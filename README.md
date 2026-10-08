# Momentum

Momentum is an AI-assisted SwiftUI productivity app for tracking weekly and monthly goals.

## Features

- Weekly goal tracking
- Monthly progress aggregation
- Reusable goal templates
- Goal notes and target editing
- Haptic feedback
- Completion animations and confetti
- Visual time-block scheduling
- SwiftUI tab-based navigation

## Technologies

- Swift
- SwiftUI
- UIKit haptic feedback
- Xcode

## Architecture

The app uses SwiftUI views for presentation and an observable `MomentumGoalStore` for weekly and monthly goal state.

Weekly and monthly goals are represented using Swift structs. Monthly progress is calculated by aggregating weekly progress associated with the same goal template.

## Current Limitations

The current version stores goal and schedule data in memory, so data resets when the app is relaunched.

Future improvements include:

- SwiftData persistence
- Unit tests
- A unified data layer
- Completed progress analytics
- More calendar-aware monthly targets

## AI-Assisted Development

I used AI as a coding assistant to generate initial SwiftUI implementations, explain compiler errors, suggest UI approaches, and help with debugging. I reviewed and adapted the generated code while studying the underlying Swift and SwiftUI concepts.
