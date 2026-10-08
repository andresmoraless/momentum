import SwiftUI

/// Matches the Momentum "M" logo (single continuous stroke)
struct LogoMShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height

        // FINAL 5-POINT TRUE "M" — matches your real logo
        let p1 = CGPoint(x: 0.14 * w, y: 0.62 * h)   // bottom-left
        let p2 = CGPoint(x: 0.33 * w, y: 0.30 * h)   // upper-left shoulder
        let p3 = CGPoint(x: 0.50 * w, y: 0.58 * h)   // inner valley
        let p4 = CGPoint(x: 0.80 * w, y: 0.20 * h)   // upper-right shoulder
        let p5 = CGPoint(x: 0.86 * w, y: 0.62 * h)   // bottom-right

        path.move(to: p1)
        path.addLine(to: p2)
        path.addLine(to: p3)
        path.addLine(to: p4)
        path.addLine(to: p5)

        return path
    }
}



