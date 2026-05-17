import SwiftUI

struct AppQuantityControl: View {
    let quantity: Int
    let onIncrease: () -> Void
    let onDecrease: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onDecrease) {
                Image(systemName: "minus.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Decrease quantity")

            Text("\(quantity)")
                .font(.headline)
                .frame(minWidth: 24, alignment: .center)
                .accessibilityHidden(true)

            Button(action: onIncrease) {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundStyle(Color.accentColor)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Increase quantity")
        }
        .accessibilityElement(children: .contain)
    }
}
