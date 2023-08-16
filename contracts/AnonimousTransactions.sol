// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./balanceVerifier.sol";
import "./divBalanceVerifier.sol";
import "./pairing.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

using Strings for uint256;


contract AnonimousTransactions {

    BalanceVerifier public balanceVerifier;
    DivBalanceVerifier public divBalanceVerifier;


    constructor(address verifyBalanceAddress, address verifyDivBalanceAddress) {
        balanceVerifier = BalanceVerifier(verifyBalanceAddress);
        divBalanceVerifier = DivBalanceVerifier(verifyDivBalanceAddress);
    }


    struct CompleteProofOwnership {
        Pairing.Proof proof;
        uint[3] input;
    }

    struct CompleteProofDivision {  
        Pairing.Proof proof;
        uint[7] input;
    }


    bytes32[] deposits;

    
    function bytes32ToString(bytes32 _bytes32) public pure returns (string memory) {
        uint8 i = 0;
        while(i < 32 && _bytes32[i] != 0) {
            i++;
        }
        bytes memory bytesArray = new bytes(i);
        for (i = 0; i < 32 && _bytes32[i] != 0; i++) {
            bytesArray[i] = _bytes32[i];
        }
        return string(bytesArray);
    }

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
    function sendAmount(string memory hashedSecret) payable public returns (string memory){
        uint amount = msg.value;

        require(msg.sender.balance >= amount, "Insufficient Balance"); 
        payable(msg.sender).transfer(amount);

        bytes32 hashBalance = sha256(bytes(amount.toString()));

        string memory concatinatedSecretAndAmount = string.concat(
            bytes32ToString(hashBalance), hashedSecret
        );

        deposits.push(sha256(bytes(concatinatedSecretAndAmount)));
        return concatinatedSecretAndAmount;
    }


    // splitting the amount into two parts
    function amountSplitting(
        bytes32 oldSecretAndValue, string memory newAmount1, string memory newAmount2, 
        string memory secret1, string memory secret2,
        CompleteProofOwnership memory proofOwnership, CompleteProofDivision memory proofCorrectSplitting
    ) public {
        // .. verification
        require(balanceVerifier.verifyTx(proofOwnership.proof, proofOwnership.input), "you doesn't pass verification");
        require(divBalanceVerifier.verifyTx(proofCorrectSplitting.proof, proofCorrectSplitting.input), "incorrect splitting");
        
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


    function withdrawal(CompleteProofOwnership memory proofOwnership, bytes32 secretAndAmount, uint amount
    ) public payable {
        // .. verification
        require(balanceVerifier.verifyTx(proofOwnership.proof, proofOwnership.input), "you doesn't pass verification");

        deleteByValue(secretAndAmount);
        payable(msg.sender).transfer(amount);
    }
}