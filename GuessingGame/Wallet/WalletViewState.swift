import BigInt
import Combine
import ComposableArchitecture
import web3

struct WalletViewState: Equatable {
	var tokenBalanceString: String = "--"
	var ethBalanceString: String = "--"
	@BindableState var isShowingReceiveSheet = false

	// Child states
	var sendViewState: SendViewState? = nil
	var receiveViewState: ReceiveViewState
}

enum WalletViewAction: BindableAction {
	case refreshBalances
	case refreshBalancesOnInterval
	case stopRefreshingBalances
	case updateBalances(ethBalance: BigUInt?, tokenBalance: BigUInt?)
	case sendToken(amount: BigUInt, to: EthereumAddress)
	case showReceiveSheet
	case showSendSheet
	case dismissSendSheet

	// Binding
	case binding(BindingAction<WalletViewState>)

	// Child actions
	case sendViewAction(SendViewAction)
	case receiveViewAction(ReceiveViewAction)
}

struct WalletViewEnvironment {
	let client: TokenClient
	let sendViewEnvironment: SendViewEnvironment
	let receiveViewEnvironment: ReceiveViewEnvironment
}

// MARK: - Reducers

private let _walletViewReducer = Reducer<WalletViewState, WalletViewAction, WalletViewEnvironment> {
	state, action, environment -> Effect in
	struct RefreshBalanceId: Hashable {}
	let refreshInterval: RunLoop.SchedulerTimeType.Stride = 6.0

	switch action {
	case .refreshBalances:
		print("Refreshing balances...")
		return Future.async { () -> WalletViewAction in
			async let ethBalance = environment.client.ethBalance()
			async let tokenBalance = environment.client.tokenBalance()
			return await .updateBalances(ethBalance: ethBalance, tokenBalance: tokenBalance)
		}
		.receive(on: RunLoop.main)
		.eraseToEffect()

	case .refreshBalancesOnInterval:
		return Effect.merge(
			Effect
				.timer(id: RefreshBalanceId(), every: refreshInterval, on: RunLoop.main)
				.map { _ in .refreshBalances },
			Effect(value: .refreshBalances) // Refresh immediately
		)

	case .stopRefreshingBalances:
		return .cancel(id: RefreshBalanceId())

	case .updateBalances(let ethBalance, let tokenBalance):
		state.ethBalanceString = ethBalance?.stringByAddingDecimalAndTrimming() ?? "--"
		state.tokenBalanceString = tokenBalance?.description ?? "--"
		return .none

	case .sendToken(let amount, let to):
		return .none

	case .showReceiveSheet:
		state.isShowingReceiveSheet = true
		return .none

	case .showSendSheet:
		state.sendViewState = SendViewState()
		return .none

	case .dismissSendSheet:
		state.sendViewState = nil
		return .none

	case .binding, .sendViewAction, .receiveViewAction:
		return .none
	}
}
	.binding()

let walletViewReducer: Reducer<WalletViewState, WalletViewAction, WalletViewEnvironment> = Reducer.combine(
	_walletViewReducer,
	sendViewReducer.optional().pullback(
		state: \.sendViewState,
		action: /WalletViewAction.sendViewAction,
		environment: { $0.sendViewEnvironment }
	),
	receiveViewReducer.pullback(
		state: \.receiveViewState,
		action: /WalletViewAction.receiveViewAction,
		environment: { $0.receiveViewEnvironment }
	)
)
