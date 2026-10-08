import SwiftUI
import Foundation

extension Notification.Name {
    static let showConfetti = Notification.Name("showConfetti")
}

struct ConfettiView: View {
    @State private var particles: [ConfettiParticle] = []
    var baseColor: Color? = nil   // Color from the goal

    var body: some View {
        ZStack {
            ForEach(particles) { particle in
                ConfettiShape(type: particle.shape)
                    .fill(particle.color)
                    .frame(width: particle.size, height: particle.size)
                    .rotationEffect(.degrees(particle.rotation))
                    .position(particle.position)
                    .opacity(particle.opacity)
            }
        }
        .ignoresSafeArea()
        .onAppear(perform: emitConfetti)
    }

    private func emitConfetti() {
        let confettiColors: [Color]
        if let baseColor = baseColor {
            confettiColors = [
                baseColor,
                baseColor.opacity(0.8),
                baseColor.opacity(0.6)
            ]
        } else {
            confettiColors = [.red, .orange, .yellow, .green, .blue, .purple]
        }

        for _ in 0..<60 {
            let newParticle = ConfettiParticle.random(colors: confettiColors)
            particles.append(newParticle)

            withAnimation(.easeOut(duration: newParticle.lifetime)) {
                if let index = particles.firstIndex(where: { $0.id == newParticle.id }) {
                    // Smooth vertical fall with slight horizontal drift
                    particles[index].position.y += CGFloat.random(in: 700...1000)
                    particles[index].position.x += CGFloat.random(in: -60...60)
                    particles[index].rotation += Double.random(in: 180...720)
                    particles[index].opacity = 0
                }
            }
        }

        // Clean up after ~3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            particles.removeAll()
        }
    }
}

// MARK: - Particle Model

struct ConfettiParticle: Identifiable, Equatable {
    let id = UUID()
    var color: Color
    var shape: ConfettiShapeType
    var position: CGPoint
    var size: CGFloat
    var opacity: Double
    var rotation: Double
    var lifetime: Double

    static func random(colors: [Color]) -> ConfettiParticle {
        ConfettiParticle(
            color: colors.randomElement() ?? .gray,
            shape: ConfettiShapeType.allCases.randomElement() ?? .circle,
            position: CGPoint(
                x: CGFloat.random(in: 0...(UIApplication.shared.connectedScenes
                        .compactMap { ($0 as? UIWindowScene)?.screen.bounds.width }
                        .first ?? 390)), // 390 = fallback for iPhone width
                y: -20
            ),
            size: CGFloat.random(in: 6...14),
            opacity: 1.0,
            rotation: Double.random(in: 0...360),
            lifetime: Double.random(in: 2.0...3.2)
        )
    }
}

// MARK: - Shape Variety

enum ConfettiShapeType: CaseIterable {
    case circle, rectangle, capsule, triangle
}

struct ConfettiShape: Shape {
    let type: ConfettiShapeType

    func path(in rect: CGRect) -> Path {
        switch type {
        case .circle:
            return Circle().path(in: rect)
        case .rectangle:
            return Rectangle().path(in: rect)
        case .capsule:
            return Capsule().path(in: rect)
        case .triangle:
            var path = Path()
            path.move(to: CGPoint(x: rect.midX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.closeSubpath()
            return path
        }
    }
}



