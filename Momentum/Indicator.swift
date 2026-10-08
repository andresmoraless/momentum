import SwiftUI

struct Indicator: Identifiable {
    let id = UUID()
    var title: String
    var icon: String
    var current: Int
    var target: Int
    var color: Color  
}


