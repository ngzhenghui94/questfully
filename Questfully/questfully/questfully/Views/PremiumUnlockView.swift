import SwiftUI

struct PremiumUnlockView: View {
    let title: String
    let message: String
    let actionTitle: String
    let onUnlock: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "lock.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundColor(.gray)

            Text(title)
                .font(.title2.bold())
                .multilineTextAlignment(.center)

            Text(message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Button(action: onUnlock) {
                Text(actionTitle)
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.indigo)
                    .foregroundColor(.white)
                    .cornerRadius(14)
                    .padding(.horizontal, 24)
            }

            Spacer()
        }
    }
}

struct PremiumUnlockView_Previews: PreviewProvider {
    static var previews: some View {
        PremiumUnlockView(title: "Random Questions are Premium",
                          message: "Upgrade to unlock random questions and more!",
                          actionTitle: "Unlock Premium",
                          onUnlock: {})
    }
}


