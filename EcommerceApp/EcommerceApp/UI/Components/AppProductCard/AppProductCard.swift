import SwiftUI

struct AppProductCard: View {
    let name: String
    let price: String
    let imageURL: String

    @Environment(\.appColors) private var colors

    var body: some View {
        VStack(spacing: 0) {
            productImage
            detailsSection
        }
        .background(colors.backgroundElevated)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Image
    @ViewBuilder
    private var productImage: some View {
        AsyncImage(url: URL(string: imageURL)) { phase in
            switch phase {
            case .success(let image):
                Color.clear.overlay(image.resizable().scaledToFill())
            case .failure:
                Rectangle()
                    .fill(colors.backgroundDefault)
                    .overlay {
                        Image(systemName: "photo")
                            .font(.system(size: 28))
                            .foregroundStyle(colors.textDisabled)
                    }
            default:
                Rectangle()
                    .fill(colors.backgroundDefault)
                    .overlay { ProgressView() }
            }
        }
        .frame(maxWidth: .infinity)
        .aspectRatio(1, contentMode: .fit)
        .clipped()
    }

    // MARK: - Details
    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(name)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(colors.textPrimary)
                .lineLimit(1)
            Text("$\(price)")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(colors.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 10)
        .padding(.vertical, 10)
        .background(colors.backgroundElevated)
    }
}

// MARK: - Preview
#Preview("AppProductCard") {
    HStack(spacing: 12) {
        AppProductCard(name: "Wireless Headphones", price: "49.99", imageURL: "http://localhost:4000/assets/p1.jpg")
        AppProductCard(name: "T-Shirt", price: "19.99", imageURL: "http://localhost:4000/assets/p2.jpg")
    }
    .padding()
    .applyAppColors()
}

#Preview("AppProductCard – Dark") {
    HStack(spacing: 12) {
        AppProductCard(name: "Wireless Headphones", price: "49.99", imageURL: "http://localhost:4000/assets/p1.jpg")
        AppProductCard(name: "T-Shirt", price: "19.99", imageURL: "http://localhost:4000/assets/p2.jpg")
    }
    .padding()
    .preferredColorScheme(.dark)
    .applyAppColors()
}
