import SwiftUI

enum AppIcon {
    case system(String)
    case svg(String)
}

extension AppIcon {
    @ViewBuilder
    func view(size: CGFloat, tintColor: Color) -> some View {
        switch self {
        case .system(let name):
            Image(systemName: name)
                .foregroundStyle(tintColor)
        case .svg(let name):
            SVGFileIcon(name, size: size, tintColor: tintColor)
        }
    }

    @ViewBuilder
    var inheritedView: some View {
        switch self {
        case .system(let name):
            Image(systemName: name)
        case .svg(let name):
            SVGFileIcon(name, size: 20, tintColor: .primary)
        }
    }
}