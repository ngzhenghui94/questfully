import SwiftUI

struct PaywallView: View {
    enum CTA {
        case subscribe(plan: SubscriptionManager.Plan)
        case limited
    }

    let onDismiss: () -> Void
    let onContinueLimited: () -> Void

    @EnvironmentObject private var subscriptionManager: SubscriptionManager

    @State private var selectedPlan: SubscriptionManager.Plan = .annual

    private var isProcessing: Bool { subscriptionManager.isProcessing }

    var body: some View {
        VStack(spacing: 24) {
            Capsule()
                .fill(Color.white.opacity(0.3))
                .frame(width: 60, height: 6)
                .padding(.top, 12)

            ScrollView {
                VStack(spacing: 32) {
                    header
                    featuresList
                    planPicker
                    primaryCTA
                    limitedCTA
                    restoreButton
                    legalLinks
                }
                .padding(.horizontal, 24)
            }
        }
        .padding(.bottom, 16)
        .background(
            LinearGradient(colors: [Color(hex: "4C1D95"), Color(hex: "1E1B4B")], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
        )
        .overlay(alignment: .topTrailing) {
            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .foregroundColor(.white.opacity(0.7))
                    .padding(16)
            }
        }
        .alert("Purchase Error", isPresented: Binding(
            get: { subscriptionManager.errorMessage != nil },
            set: { _ in subscriptionManager.errorMessage = nil }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            if let message = subscriptionManager.errorMessage {
                Text(message)
            }
        }
    }

    private var header: some View {
        VStack(spacing: 8) {
            Text("Unlock Questfully Premium")
                .font(.largeTitle.bold())
                .foregroundColor(.white)
                .multilineTextAlignment(.center)

            Text("Dive deeper into meaningful conversations")
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
        }
    }

    private var featuresList: some View {
        VStack(alignment: .leading, spacing: 16) {
            featureRow(icon: "infinity", title: "Unlimited Questions", subtitle: "Access every category and question")
            featureRow(icon: "slider.horizontal.3", title: "Smart Reminders", subtitle: "Stay engaged with gentle nudges")
            featureRow(icon: "heart.fill", title: "Unlimited Favorites", subtitle: "Save everything you love")
            featureRow(icon: "cloud.fill", title: "Cloud Sync", subtitle: "Pick up where you left off on any device")
            featureRow(icon: "sparkles", title: "Exclusive Content", subtitle: "Unlock premium collections")
        }
        .padding()
        .background(Color.white.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }

    private func featureRow(icon: String, title: String, subtitle: String) -> some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .foregroundColor(.white)
                .font(.title2)
                .frame(width: 36, height: 36)
                .background(Color.white.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .foregroundColor(.white)
                    .font(.headline)
                Text(subtitle)
                    .foregroundColor(.white.opacity(0.7))
                    .font(.subheadline)
            }
            Spacer()
        }
    }

    private var planPicker: some View {
        VStack(spacing: 16) {
            Text("Choose Your Plan")
                .foregroundColor(.white)
                .font(.title2.bold())

            VStack(spacing: 16) {
                planCard(plan: .annual,
                         price: "$49.99/year",
                         description: "Billed annually – Save 15%",
                         highlights: ["Full access", "2 months free", "Priority support"],
                         badge: "Most Popular")

                planCard(plan: .monthly,
                         price: "$4.99/month",
                         description: "Billed monthly",
                         highlights: ["Full access", "Cancel anytime"],
                         badge: nil)
            }
        }
    }

    private func planCard(plan: SubscriptionManager.Plan,
                          price: String,
                          description: String,
                          highlights: [String],
                          badge: String?) -> some View {
        let isSelected = selectedPlan == plan

        return Button {
            selectedPlan = plan
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(plan.displayName)
                        .foregroundColor(.white)
                        .font(.headline)
                    Spacer()
                    if let badge = badge {
                        Text(badge)
                            .font(.caption.bold())
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.pink)
                            .clipShape(Capsule())
                            .foregroundColor(.white)
                    }
                }

                Text(price)
                    .font(.title2.bold())
                    .foregroundColor(.white)

                Text(description)
                    .foregroundColor(.white.opacity(0.7))
                    .font(.subheadline)

                ForEach(highlights, id: \.self) { highlight in
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text(highlight)
                            .foregroundColor(.white)
                            .font(.callout)
                    }
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 28)
                    .fill(Color.white.opacity(isSelected ? 0.18 : 0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 28)
                            .stroke(isSelected ? Color.white : Color.white.opacity(0.1), lineWidth: 2)
                    )
            )
        }
        .disabled(isProcessing)
    }

    private var primaryCTA: some View {
        Button {
            Task { await subscriptionManager.purchase(plan: selectedPlan) }
        } label: {
            Text(buttonTitle)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(LinearGradient(colors: [Color.orange, Color.pink], startPoint: .leading, endPoint: .trailing))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .foregroundColor(.white)
        }
        .padding(.top, 8)
        .disabled(isProcessing)
        .overlay(
            Group {
                if isProcessing {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                }
            }
        )
    }

    private var limitedCTA: some View {
        Button(action: onContinueLimited) {
            Text("Continue with Limited Questions")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .foregroundColor(.white)
        }
        .padding(.top, 4)
        .disabled(isProcessing)
    }

    private var restoreButton: some View {
        Button {
            Task { await subscriptionManager.restorePurchases() }
        } label: {
            Text("Restore Purchases")
                .underline()
                .foregroundColor(.white.opacity(0.8))
        }
        .padding(.top, 8)
        .disabled(isProcessing)
    }

    private var legalLinks: some View {
        HStack(spacing: 24) {
            link(title: "Terms of Use", url: URL(string: "https://example.com/terms")!)
            link(title: "Privacy Policy", url: URL(string: "https://example.com/privacy")!)
        }
        .font(.footnote)
        .foregroundColor(.white.opacity(0.7))
        .padding(.top, 12)
        .padding(.bottom, 24)
    }

    private func link(title: String, url: URL) -> some View {
        Link(title, destination: url)
    }

    private var buttonTitle: String {
        switch selectedPlan {
        case .annual:
            return "Subscribe for $49.99/year"
        case .monthly:
            return "Subscribe for $4.99/month"
        }
    }
}

struct PaywallView_Previews: PreviewProvider {
    static var previews: some View {
        PaywallView(onDismiss: {}, onContinueLimited: {})
            .environmentObject(SubscriptionManager())
    }
}


