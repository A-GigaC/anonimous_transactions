// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
using Strings for uint256;


contract AnonimousTransactions {

    bytes32[] deposits;

    // this function delete element from array of deposits by value
    // .the language features do not allow you to put this function in a separate contract, 
    // ..because otherwise you would have to pass an array as an input argument
    // ...and it will costs a lot of gas [hahahaha, we're talking about optimisation)))))]
    function deleteByValue(bytes32 value) internal {
        uint pointer = 0;
        while (deposits[pointer] != value) {
            pointer++;
        }
        if (deposits[pointer] == value) {
            delete deposits[pointer];
        }
    }

    // maske deposit
    function sendAmount(uint amount, string memory hashedSecret) payable public {
        require(msg.sender.balance >= amount, "Insufficient Balance"); 

        payable(msg.sender).transfer(amount);
        string memory concatinatedSecretAndAmount = string.concat(
            hashedSecret, amount.toString()
        );
        deposits.push(sha256(bytes(concatinatedSecretAndAmount )));
    }

    // splitting the amount into two parts
    function amountSplitting(
        bytes32 oldSecretAndValue, string memory newAmount1, string memory newAmount2, 
        string memory secret1, string memory secret2,
        bytes32 proofOwnership, bytes32 proofNotNegativeAmount1, bytes32 proofNotNegativeAmount2, bytes32 proofCorrectSplitting
    ) public {
        // .. verification
        // ... by using zokrates -
        // .. generated smartcontract

        deleteByValue(oldSecretAndValue);
        // create record for new amounts
        string memory concatinatedSecretAndAmount1 = string.concat(
            secret1, newAmount1
        );
        deposits.push(sha256(bytes(concatinatedSecretAndAmount1)));
        //
        string memory concatinatedSecretAndAmount2 = string.concat(
            secret2, newAmount2
        );
        deposits.push(sha256(bytes(concatinatedSecretAndAmount2)));
    }

    function withdrawal(bytes32 proofOwnership, bytes32 secretAndAmount, uint amount)
      public payable {
        // .. verification
        // ... by using zokrates -
        // .. generated smartcontract

        deleteByValue(secretAndAmount);
        payable(msg.sender).send(amount);
    }  
}