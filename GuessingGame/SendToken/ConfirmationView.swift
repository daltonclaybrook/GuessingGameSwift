import ComposableArchitecture
import SwiftUI

/// Ideas of things to show on the confirmation page:
/// - From/To addresses (with "blockies")
/// - Contract address
/// - Token amount to send
/// - Estimated gas and gas limit
/// - Suggested gas price (with ability to change)
/// - Total estimated fee in ETH and USD
/// - Raw transaction hex data
/// - Confirm button with FaceID confirmation
struct ConfirmationView: View {
	let store: Store<ConfirmationViewState, ConfirmationViewAction>
	let shouldDismiss: () -> Void

	var body: some View {
		WithViewStore(store) { viewStore in
			NavigationView {
				VStack {
					ScrollView {
						VStack(alignment: .leading) {
							amountToSend(viewStore: viewStore)

							SendToAddressView(
								fromAddress: viewStore.fromAddress,
								toAddress: viewStore.toAddress
							).padding(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))

							Divider()

							AddressView(label: "Contract", address: viewStore.contractAddress, image: viewStore.contractAddressBlockyImage)

							ConfirmationLabel(label: "Estimated gas") {
								Text(viewStore.estimatedGasString)
							}

							gasPricePicker(viewStore: viewStore)

							estimatedTransactionFee(viewStore: viewStore)
						}
						.listStyle(.plain)
					}

					RoundedButton(title: "Confirm") {
						viewStore.send(.showSendConfirmation)
					}
					.padding()
				}
				.navigationBarTitle("Sending")
				.navigationBarTitleDisplayMode(.inline)
			}
			.alert(store.scope(state: \.alert), dismiss: .dismissAlert)
			.onChange(of: viewStore.shouldDismissView) { dismiss in
				if dismiss {
					shouldDismiss()
				}
			}
			.onAppear {
				viewStore.send(.fetchETHPriceInUSD)
				viewStore.send(.fetchGasOracle)
				viewStore.send(.fetchEstimatedGas)
			}
		}
	}

	// MARK: - Private helpers

	private func amountToSend(viewStore: ViewStore<ConfirmationViewState, ConfirmationViewAction>) -> some View {
		HStack {
			Spacer()

			VStack(spacing: 4) {
				HStack(alignment: .firstTextBaseline, spacing: 4) {
					Text(viewStore.tokenAmountToSend.description)
						.font(.system(size: 48, weight: .thin))
					Text("GUESS")
						.font(.body)
				}

				Divider()
			}

			Spacer()
		}

	}

	private func gasPricePicker(viewStore: ViewStore<ConfirmationViewState, ConfirmationViewAction>) -> some View {
		ConfirmationLabel(label: "Gas price (Gwei)") {
			Picker("Gas price (Gwei)", selection: viewStore.binding(
				get: \.selectedGasPrice.rawValue,
				send: { .selectGasPrice(index: $0) }
			)) {
				ForEach(SelectedGasPrice.allCases) { price in
					Text(viewStore.state.gasPriceString(for: price))
						.tag(price.rawValue)
				}
			}
			.pickerStyle(.segmented)
		}
	}

	private func estimatedTransactionFee(viewStore: ViewStore<ConfirmationViewState, ConfirmationViewAction>) -> some View {
		ConfirmationLabel(label: "Estimated transaction fee") {
			VStack(alignment: .leading, spacing: 4) {
				HStack(alignment: .firstTextBaseline, spacing: 4) {
					Text(viewStore.transactionPriceStringInUSD)
						.font(.title)
					Text("USD")
						.font(.subheadline)
				}
				Text(viewStore.transactionPriceStringInETH)
					.font(.subheadline)
			}
		}
	}
}

struct AddressView: View {
	let label: String
	let address: String
	let image: UIImage?

	var body: some View {
		ConfirmationLabel(label: label) {
			HStack {
				if let image = image {
					Image(uiImage: image)
						.interpolation(.none)
						.mask(Circle())
				}
				Text(address)
					.font(.callout)
					.lineLimit(1)
					.truncationMode(.middle)
			}
		}
	}
}

struct ConfirmationLabel<C: View>: View {
	let label: String
	let value: () -> C

	private let leadingTrailingSpace: CGFloat = 16

	var body: some View {
		VStack(alignment: .leading, spacing: 4) {
			Text(label)
				.font(.caption)
				.padding(EdgeInsets(top: 0, leading: leadingTrailingSpace, bottom: 0, trailing: leadingTrailingSpace))

			value()
				.padding(EdgeInsets(top: 0, leading: leadingTrailingSpace, bottom: 4, trailing: leadingTrailingSpace))

			Divider()
		}
	}
}

struct ConfirmationView_Previews: PreviewProvider {
	static var previews: some View {
		ConfirmationView(store: .preview, shouldDismiss: {})
	}
}
