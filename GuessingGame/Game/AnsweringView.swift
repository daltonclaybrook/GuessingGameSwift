//
//  AnsweringView.swift
//  GuessingGame
//
//  Created by Dalton Claybrook on 7/12/22.
//

import ComposableArchitecture
import SwiftUI

struct AnsweringView: View {
	let viewStore: ViewStore<GameViewState, GameViewAction>
	let answeringState: AnsweringState
	@State var answeringQuestion: Bool = false
	@State var answerText: String = ""
	@State var submittingClue: Bool = false
	@State var clueText: String = ""

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

			if answeringState.askerIsUser && answeringState.canSubmitClue {
				Button("Submit Clue") {
					submittingClue = true
				}
			}

			Divider()

			if answeringState.askerIsUser {
				Text("You asked this question")
					.font(.caption)
					.italic()
			} else {
				Button("Submit Guess") {
					answeringQuestion = true
				}
			}
		}
		.padding()
		.sheet(isPresented: $answeringQuestion) {
			VStack(spacing: 20) {
				TextField("Answer", text: $answerText)
				Button("Submit") {
					if !answerText.isEmpty {
						viewStore.send(
							.submitGuess(answer: answerText)
						)
					}
					answeringQuestion = false
					answerText = ""
				}
			}
			.padding()
		}
		.sheet(isPresented: $submittingClue) {
			VStack(spacing: 20) {
				TextField("Clue", text: $clueText)
				Button("Submit") {
					if !clueText.isEmpty {
						viewStore.send(
							.submitClue(clue: clueText)
						)
					}
					submittingClue = false
					clueText = ""
				}
			}
			.padding()
		}
	}
}
