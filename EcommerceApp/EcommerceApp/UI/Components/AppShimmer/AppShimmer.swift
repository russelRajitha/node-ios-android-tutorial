import SwiftUI

extension View {
    func shimmering() -> some View {
        modifier(AppShimmerModifier())
    }
}

private struct AppShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = -1

    func body(content: Content) -> some View {
        content
            .overlay {
                GeometryReader { geo in
                    let width = geo.size.width * 2.5
                    LinearGradient(
                        stops: [
                            .init(color: .clear,                          location: 0),
                            .init(color: .white.opacity(0.35),            location: 0.4),
                            .init(color: .white.opacity(0.55),            location: 0.5),
                            .init(color: .white.opacity(0.35),            location: 0.6),
                            .init(color: .clear,                          location: 1),
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: width)
                    .offset(x: phase * width)
                }
            }
            .clipped()
            .onAppear {
                withAnimation(.linear(duration: 1.2).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
    }
}

// MARK: - Preview
private struct AppShimmerPreviewContent: View {
    @Environment(\.appColors) private var colors

    var body: some View {
        VStack(spacing: 16) {
            LazyVGrid(
                columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)],
                spacing: 12
            ) {
                ForEach(0..<4, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 16)
                        .fill(colors.backgroundElevated)
                        .aspectRatio(1, contentMode: .fit)
                        .shimmering()
                }
            }
            RoundedRectangle(cornerRadius: 8)
                .fill(colors.backgroundElevated)
                .frame(height: 16)
                .shimmering()
            RoundedRectangle(cornerRadius: 8)
                .fill(colors.backgroundElevated)
                .frame(width: 180, height: 16)
                .shimmering()
        }
        .padding()
    }
}

#Preview("AppShimmer") {
    AppShimmerPreviewContent()
        .applyAppColors()
}

#Preview("AppShimmer – Dark") {
    AppShimmerPreviewContent()
        .preferredColorScheme(.dark)
        .applyAppColors()
}
