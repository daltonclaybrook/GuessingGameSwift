import SwiftUI

struct RoundedButton: View {
	let title: String
	let action: () -> Void

	var body: some View {
		Button(action: action, label: {
			Text(title)
				.frame(maxWidth: .infinity)
				.foregroundColor(.white)
				.padding(EdgeInsets(top: 12, leading: 20, bottom: 12, trailing: 20))
				.background(RoundedRectangle(cornerRadius: 8))
		})
	}
}
