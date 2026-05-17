import SwiftUI

struct AppSpinner: View {
    var body: some View {
        ProgressView()
            .progressViewStyle(.circular)
            .scaleEffect(1.4)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
