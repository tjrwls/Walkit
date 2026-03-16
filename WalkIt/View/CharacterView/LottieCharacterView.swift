
import SwiftUI
import Lottie

struct LottieCharacterView: View {
    let json: [String: Any]

    var body: some View {
        if let data = try? JSONSerialization.data(withJSONObject: json) {
            LottieView {
                try LottieAnimation.from(data: data)
            }
            .looping()
            .resizable()
            .scaledToFit()
            .id(data.hashValue)
        } else {
            ProgressView()
        }
    }
}
