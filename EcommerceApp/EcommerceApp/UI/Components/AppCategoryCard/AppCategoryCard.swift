import SwiftUI

struct AppCategoryCard: View {
    let title: String
    let imageURL: String
    var onTap: (() -> Void)? = nil

    @Environment(\.appColors) private var colors

    var body: some View {
        ZStack(alignment: .bottom) {
            backgroundImage
            titleBar
        }
        .frame(maxWidth: .infinity)
        .aspectRatio(1, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .contentShape(Rectangle())
        .modifier(OptionalTapModifier(action: onTap))
    }

    // MARK: - Background
    @ViewBuilder
    private var backgroundImage: some View {
        AsyncImage(url: URL(string: imageURL)) { phase in
            switch phase {
            case .success(let image):
                Color.clear.overlay(
                    image.resizable().scaledToFill()
                )
            case .failure:
                Rectangle()
                    .fill(colors.backgroundElevated)
                    .overlay {
                        Image(systemName: "tag")
                            .font(.system(size: 32))
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

    // MARK: - Title

    private var titleBar: some View {
        Text(title)
            .font(.caption)
            .fontWeight(.semibold)
            .multilineTextAlignment(.center)
            .foregroundStyle(.primary)
            .lineLimit(2)
            .padding(.horizontal, 10)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(.ultraThinMaterial.opacity(0.5))
    }
}

// MARK: - Tap modifier
private struct OptionalTapModifier: ViewModifier {
    let action: (() -> Void)?
    func body(content: Content) -> some View {
        if let action {
            content.onTapGesture(perform: action)
        } else {
            content
        }
    }
}

// MARK: - Preview
#Preview("AppCategoryCard") {
    HStack(spacing: 12) {
        AppCategoryCard(title: "Food & Beverages", imageURL: "http://localhost:4000/assets/food_beverages.png")
        AppCategoryCard(title: "Clothing & Accessories", imageURL: "http://localhost:4000/assets/food_beverages.png")
    }
    .padding()
    .applyAppColors()
}

#Preview("AppCategoryCard – Dark") {
    HStack(spacing: 12) {
        AppCategoryCard(title: "Food & Beverages", imageURL: "http://localhost:4000/assets/categories/food_beverages.png")
        AppCategoryCard(title: "Clothing & Accessories", imageURL: "http://localhost:4000/assets/categories/food_beverages.png")
    }
    .padding()
    .preferredColorScheme(.dark)
    .applyAppColors()
}
