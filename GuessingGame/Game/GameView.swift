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
			NavigationView {
				Group {
					switch viewStore.gameState {
					case .unknown:
						Text("Loading...")
					case .waitingForQuestion(let asker):
						AskingView(viewStore: viewStore, asker: asker)
					case .answeringQuestion(let answeringState):
						AnsweringView(viewStore: viewStore, answeringState: answeringState)
					}
				}
				.navigationTitle("Guessing Game")
				.toolbar {
					Button {
						viewStore.send(.refreshState)
					} label: {
						Image(systemName: "arrow.clockwise")
					}

				}
			}
			.onAppear {
				viewStore.send(.refreshState)
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
		VStack(alignment: .leading, spacing: 20) {

			Text("Prompt")
				.font(.subheadline)

			Text("\"\(answeringState.prompt)\"")
				.font(.body)
				.italic()

			Divider()

			if answeringState.clues.isEmpty {
				Text("No clues yet...")
					.font(.subheadline)
			} else {
				Text("Clues")
					.font(.subheadline)

				ForEach(answeringState.clues.indices, id: \.self) { index in
					HStack(alignment: .firstTextBaseline) {
						Text("\(index + 1).")
							.font(.footnote)
						Text(answeringState.clues[index])
							.font(.callout)
					}
				}
			}

			Divider()

			VStack(alignment: .center) {
				Button("Submit Guess") {
					print("Submitting guess...")
				}
				.disabled(answeringState.askerIsUser)

				if answeringState.askerIsUser {
					Text("You asked this question")
						.font(.caption)
				}
			}
		}
		.padding()
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
