//
//  GameFunctions.swift
//  GuessingGame
//
//  Created by Dalton Claybrook on 7/11/22.
//

import BigInt
import Foundation
import web3

/// A namespace to use for accessing game functions
enum GameFunctions {}

// MARK: - Asker functions

extension GameFunctions {
	/// Submit the next question
	///
	/// ```
	/// function submitQuestion(string calldata _prompt, bytes32 _answerHash) external onlyEligibleSubmitter
	/// ```
	struct SubmitQuestion: ABIFunction {
		static let name = "submitQuestion"

		var gasPrice: BigUInt?
		var gasLimit: BigUInt?
		var contract: EthereumAddress
		var from: EthereumAddress?

		// Function parameters
		var prompt: String
		var answerHash: Data32

		func encode(to encoder: ABIFunctionEncoder) throws {
			try encoder.encode(prompt)
			try encoder.encode(answerHash)
		}
	}

	/// Check whether a new clue can be submitted
	///
	/// ```
	/// function canSubmitNewClue() public view returns (bool)
	/// ```
	struct CanSubmitNewClue: ABIFunction {
		static let name = "canSubmitNewClue"

		var gasPrice: BigUInt?
		var gasLimit: BigUInt?
		var contract: EthereumAddress
		var from: EthereumAddress?

		func encode(to encoder: ABIFunctionEncoder) throws {}
	}

	/// Submit a new clue
	///
	/// ```
	/// function submitClue(string calldata _newClue) external onlyAsker
	/// ```
	struct SubmitClue: ABIFunction {
		static let name = "submitClue"

		var gasPrice: BigUInt?
		var gasLimit: BigUInt?
		var contract: EthereumAddress
		var from: EthereumAddress?

		// Function parameters
		var newClue: String

		func encode(to encoder: ABIFunctionEncoder) throws {
			try encoder.encode(newClue)
		}
	}
}

// MARK: - Guessing functions

extension GameFunctions {
	/// Check whether there is an active question
	///
	/// ```
	/// function isCurrentQuestionActive() public view returns (bool)
	/// ```
	struct IsCurrentQuestionActive: ABIFunction {
		static let name = "isCurrentQuestionActive"

		var gasPrice: BigUInt?
		var gasLimit: BigUInt?
		var contract: EthereumAddress
		var from: EthereumAddress?

		func encode(to encoder: ABIFunctionEncoder) throws {}
	}

	/// Check whether the current question is expired
	///
	/// ```
	/// function isCurrentQuestionExpired() public view returns (bool)
	/// ```
	struct IsCurrentQuestionExpired: ABIFunction {
		static let name = "isCurrentQuestionActive"

		var gasPrice: BigUInt?
		var gasLimit: BigUInt?
		var contract: EthereumAddress
		var from: EthereumAddress?

		func encode(to encoder: ABIFunctionEncoder) throws {}
	}

	/// Get the clue for the provided index
	///
	/// ```
	/// function getClue(uint8 index) public view returns (string memory)
	/// ```
	struct GetClue: ABIFunction {
		static let name = "getClue"

		var gasPrice: BigUInt?
		var gasLimit: BigUInt?
		var contract: EthereumAddress
		var from: EthereumAddress?

		// Function parameters
		var index: UInt8

		func encode(to encoder: ABIFunctionEncoder) throws {
			try encoder.encode(index)
		}
	}

	/// Check whether the provided answer is correct
	///
	/// ```
	/// function checkAnswer(string calldata _answer) public view returns (bool)
	/// ```
	struct CheckAnswer: ABIFunction {
		static let name = "checkAnswer"

		var gasPrice: BigUInt?
		var gasLimit: BigUInt?
		var contract: EthereumAddress
		var from: EthereumAddress?

		// Function parameters
		var answer: String

		func encode(to encoder: ABIFunctionEncoder) throws {
			try encoder.encode(answer)
		}
	}

	/// Submit an answer to the question
	///
	/// ```
	/// function submitAnswer(string calldata _answer) external anyoneButAsker
	/// ```
	struct SubmitAnswer: ABIFunction {
		static let name = "submitAnswer"

		var gasPrice: BigUInt?
		var gasLimit: BigUInt?
		var contract: EthereumAddress
		var from: EthereumAddress?

		// Function parameters
		var answer: String

		func encode(to encoder: ABIFunctionEncoder) throws {
			try encoder.encode(answer)
		}
	}

	/// Expire the question if it is eligible, and queue up next asker
	///
	/// ```
	/// function expireQuestion() external anyoneButAsker
	/// ```
	struct ExpireQuestion: ABIFunction {
		static let name = "expireQuestion"

		var gasPrice: BigUInt?
		var gasLimit: BigUInt?
		var contract: EthereumAddress
		var from: EthereumAddress?

		func encode(to encoder: ABIFunctionEncoder) throws {}
	}
}
