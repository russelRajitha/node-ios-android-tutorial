import SwiftUI

struct AppImageSlider: View {
    let imageURLs: [String]

    @State private var currentIndex = 0
    @Environment(\.appColors) private var colors

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $currentIndex) {
                ForEach(imageURLs.indices, id: \.self) { index in
                    slideImage(url: imageURLs[index])
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            if imageURLs.count > 1 {
                pageIndicator
                    .padding(.bottom, 12)
            }
        }
    }

    @ViewBuilder
    private func slideImage(url: String) -> some View {
        AsyncImage(url: URL(string: url)) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
            case .failure:
                Rectangle()
                    .fill(colors.backgroundElevated)
                    .overlay {
                        Image(systemName: "photo")
                            .font(.system(size: 40))
                            .foregroundStyle(colors.textDisabled)
                    }
            default:
                Rectangle()
                    .fill(colors.backgroundElevated)
                    .overlay { ProgressView() }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipped()
    }

    private var pageIndicator: some View {
        HStack(spacing: 6) {
            ForEach(imageURLs.indices, id: \.self) { index in
                Circle()
                    .fill(index == currentIndex ? colors.primary : Color.white.opacity(0.7))
                    .frame(
                        width: index == currentIndex ? 8 : 6,
                        height: index == currentIndex ? 8 : 6
                    )
                    .animation(.easeInOut(duration: 0.2), value: currentIndex)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.black.opacity(0.3))
        .clipShape(Capsule())
    }
}

// MARK: - Previews
#Preview("AppImageSlider – Multiple") {
    AppImageSlider(imageURLs: [
        "http://localhost:4000/assets/p1.jpg",
        "http://localhost:4000/assets/p2.jpg",
        "http://localhost:4000/assets/p3.jpg",
    ])
    .frame(height: 320)
    .applyAppColors()
}

#Preview("AppImageSlider – Single") {
    AppImageSlider(imageURLs: ["http://localhost:4000/assets/p1.jpg"])
        .frame(height: 320)
        .applyAppColors()
}

#Preview("AppImageSlider – Dark") {
    AppImageSlider(imageURLs: [
        "http://localhost:4000/assets/p1.jpg",
        "http://localhost:4000/assets/p2.jpg",
        "http://localhost:4000/assets/p3.jpg",
    ])
    .frame(height: 320)
    .applyAppColors()
    .preferredColorScheme(.dark)
}
