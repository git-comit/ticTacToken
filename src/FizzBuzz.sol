// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {LibString} from "@solady/src/utils/LibString.sol";

contract FizzBuzz {
    function fizzBuzz(uint256 n) public pure returns (string memory) {
        if (n % 3 == 0 && n % 5 == 0) {
            return "fizzbuzz";
        }
        if (n % 3 == 0) {
            return "Fizz";
        }
        if (n % 5 == 0) {
            return "Buzz";
        } else {
            return LibString.toString(n);
        }
    }
}
