// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
using Strings for uint256;


contract AnonimousTransactions {
    uint public unlockTime;
    address payable public owner;

    bytes32[] deposits;

    // this function delete element from array by value
    // .the language features do not allow you to put this function in a separate contract, 
    // ..because otherwise you would have to pass an array as an input argument
    // ...and it will costs a lot of gas [hahahaha, we're talking about optimisation)))))]
    function delete_by_value(bytes32 value) internal {
        uint pointer = 0;
        while (deposits[pointer] != value) {
            pointer++;
        }
        delete deposits[pointer];
    }

    // maske deposit
    function send_amount(uint amount, string memory hashed_secret) payable public returns (string memory status) {
        
        if (msg.sender.balance >= amount) {
            payable(msg.sender).transfer(amount);
            string memory concatinated_secret_and_amount = string.concat(
                hashed_secret, amount.toString()
            );
            deposits.push(sha256(bytes(concatinated_secret_and_amount )));

            return "succes";
        } else {
            return "bad balance";
        }
    }

    // splitting the amount into two parts
    function amount_splitting(
        bytes32 old_secret_and_value, string memory new_amount1, string memory new_amount2, 
        string memory secret1, string memory secret2,
        bytes32 Po_ownership, bytes32 Po_not_negative_amount1, bytes32 Po_not_negative_amount2, bytes32 Po_correct_splitting
        ) public returns (string memory status) {
            // ..
            // ...verification...
            //..
            delete_by_value(old_secret_and_value);
            // create record for new amounts
            string memory concatinated_secret_and_amount1 = string.concat(
                secret1, new_amount1
            );
            deposits.push(sha256(bytes(concatinated_secret_and_amount1)));
            //
            string memory concatinated_secret_and_amount2 = string.concat(
                secret2, new_amount2
            );
            deposits.push(sha256(bytes(concatinated_secret_and_amount2)));

            return "succes";
        }

    function withdrawal(bytes32 Po_ownership, bytes32 secret_and_amount, uint amount)
      public payable returns(string memory status){
        // ..
        // ...verification...
        // ..
        payable(msg.sender).send(amount);
        delete_by_value(secret_and_amount);

        return "succes";
    }
    
}