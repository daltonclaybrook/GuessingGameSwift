//
//  GameFunctions.swift
//  GuessingGame
//
//  Created by Dalton Claybrook on 7/11/22.
//

import BigInt
import Foundation
import web3

protocol UpdatableABIFunction: ABIFunction {
	var gasPrice: BigUInt? { get set }
	var gasLimit: BigUInt? { get set }
	var from: EthereumAddress? { get set }
}

/// A namespace to use for accessing game functions
enum GameFunctions {}

// MARK: - Properties

extension GameFunctions {
	/// Get the next asker
	struct NextAsker: UpdatableABIFunction {
		static let name = "nextAsker"

		var gasPrice: BigUInt?
		var gasLimit: BigUInt?
		var contract: EthereumAddress
		var from: EthereumAddress?

		func encode(to encoder: ABIFunctionEncoder) throws {}
	}

	/// Get the date when the next asker times out and anyone can submit a question
	struct NextAskerTimeoutDate: UpdatableABIFunction {
		static let name = "nextAskerTimeoutDate"

		var gasPrice: BigUInt?
		var gasLimit: BigUInt?
		var contract: EthereumAddress
		var from: EthereumAddress?

		func encode(to encoder: ABIFunctionEncoder) throws {}
	}
}

// MARK: - Asker functions

extension GameFunctions {
	/// Submit the next question
	///
	/// ```
	/// function submitQuestion(string calldata _prompt, bytes32 _answerHash) external onlyEligibleSubmitter
	/// ```
	struct SubmitQuestion: UpdatableABIFunction {
		static let name = "submitQuestion"

		var gasPrice: BigUInt?
		var gasLimit: BigUInt?
		var contract: EthereumAddress
		var from: EthereumAddress?

		// Function parameters
		var prompt: String
		var answerHash: Data

		func encode(to encoder: ABIFunctionEncoder) throws {
			try encoder.encode(prompt)
//			try encoder.encode("0x\(answerHash.toHexString())")
			try encoder.encode(answerHash, staticSize: 32)
		}
	}

	/// Check whether a new clue can be submitted
	///
	/// ```
	/// function canSubmitNewClue() public view returns (bool)
	/// ```
	struct CanSubmitNewClue: UpdatableABIFunction {
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
	struct SubmitClue: UpdatableABIFunction {
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
	struct IsCurrentQuestionActive: UpdatableABIFunction {
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
	struct IsCurrentQuestionExpired: UpdatableABIFunction {
		static let name = "isCurrentQuestionActive"

		var gasPrice: BigUInt?
		var gasLimit: BigUInt?
		var contract: EthereumAddress
		var from: EthereumAddress?

		func encode(to encoder: ABIFunctionEncoder) throws {}
	}

	/// Returns the current question asker
	///
	/// ```
	/// function currentQuestionAsker() public view returns (address)
	/// ```
	struct CurrentQuestionAsker: UpdatableABIFunction {
		static let name = "currentQuestionAsker"

		var gasPrice: BigUInt?
		var gasLimit: BigUInt?
		var contract: EthereumAddress
		var from: EthereumAddress?

		func encode(to encoder: ABIFunctionEncoder) throws {}
	}

	/// Returns the current question prompt
	///
	/// ```
	/// function currentQuestionPrompt() public view returns (string memory)
	/// ```
	struct CurrentQuestionPrompt: UpdatableABIFunction {
		static let name = "currentQuestionPrompt"

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
	struct GetClue: UpdatableABIFunction {
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
	struct CheckAnswer: UpdatableABIFunction {
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
	struct SubmitAnswer: UpdatableABIFunction {
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
	struct ExpireQuestion: UpdatableABIFunction {
		static let name = "expireQuestion"

		var gasPrice: BigUInt?
		var gasLimit: BigUInt?
		var contract: EthereumAddress
		var from: EthereumAddress?

		func encode(to encoder: ABIFunctionEncoder) throws {}
	}
}
