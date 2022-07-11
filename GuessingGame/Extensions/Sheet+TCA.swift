import ComposableArchitecture
import SwiftUI

private struct SheetModifier<SheetContent: View, State, Action, SubAction>: ViewModifier {
	@ObservedObject var viewStore: ViewStore<State?, Action>
	let store: Store<State?, Action>
	let dismiss: Action
	let sheetContent: (Store<State, SubAction>) -> SheetContent
	let subAction: (SubAction) -> Action
	let onDismiss: () -> Void

	func body(content: Content) -> some View {
		content.sheet(
			isPresented: viewStore.binding(send: dismiss).isPresent(),
			onDismiss: onDismiss,
			content: {
				IfLetStore(store.scope(state: { $0 }, action: subAction), then: sheetContent)
			}
		)
	}
}

extension View {
	func sheet<State, Action, SubAction, Content>(
		_ store: Store<State?, Action>,
		dismiss: Action,
		subAction: @escaping (SubAction) -> Action,
		onDismiss: @escaping () -> Void = {},
		content: @escaping (Store<State, SubAction>) -> Content
	) -> some View where State: Identifiable, Content: View {
		self.modifier(
			SheetModifier(
				viewStore: ViewStore(store, removeDuplicates: { $0?.id == $1?.id }),
				store: store,
				dismiss: dismiss,
				sheetContent: content,
				subAction: subAction,
				onDismiss: onDismiss
			)
		)
	}
}

private extension Binding {
	func isPresent<Wrapped>() -> Binding<Bool> where Value == Wrapped? {
		.init(
			get: { self.wrappedValue != nil },
			set: { isPresent, transaction in
				guard !isPresent else { return }
				self.transaction(transaction).wrappedValue = nil
			}
		)
	}
}
