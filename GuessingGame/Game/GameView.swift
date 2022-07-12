//
//  GameView.swift
//  GuessingGame
//
//  Created by Dalton Claybrook on 7/11/22.
//

import ComposableArchitecture
import SwiftUI
import web3

struct GameView: View {
	let store: Store<GameViewState, GameViewAction>

	var body: some View {
		WithViewStore(store) { viewStore in
			switch viewStore.gameState {
			case .unknown:
				Text("Loading...").onAppear {
					viewStore.send(.refreshState)
				}
			case .waitingForQuestion(let asker):
				AskingView(viewStore: viewStore, asker: asker)
			case .answeringQuestion(let answeringState):
				AnsweringView(viewStore: viewStore, answeringState: answeringState)
			}
		}
	}
}

struct AskingView: View {
	let viewStore: ViewStore<GameViewState, GameViewAction>
	let asker: Asker
	@State var askingQuestion: Bool = false
	@State var questionText: String = ""
	@State var answerText: String = ""

	var body: some View {
		VStack(spacing: 20) {
			Text("Waiting for next question")
				.font(.headline)

			if viewStore.userIsEligibleToSubmitQuestion {
				Button {
					askingQuestion = true
				} label: {
					Text("Ask question")
				}
			}
		}
		.sheet(isPresented: $askingQuestion) {
			VStack(spacing: 20) {
				TextField("Question", text: $questionText)
				TextField("Answer", text: $answerText)
				Button("Submit") {
					askingQuestion = false
					if !questionText.isEmpty && !answerText.isEmpty {
						viewStore.send(
							.submitQuestion(prompt: questionText, answer: answerText)
						)
					}
				}
			}
			.padding()
		}
	}
}

struct AnsweringView: View {
	let viewStore: ViewStore<GameViewState, GameViewAction>
	let answeringState: AnsweringState

	var body: some View {
		Text("todo")
	}
}

struct GameView_Previews: PreviewProvider {
	static var previews: some View {
		GameView(
			store: Store(
				initialState: GameViewState(),
				reducer: gameViewReducer,
				environment: GameViewEnvironment(
					client: GameClient()
				)
			)
		)
	}
}
