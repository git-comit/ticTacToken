// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract FizzBuzz {
    function fizzBuzz(uint256 n) public pure returns (string memory) {
        if (n % 3 == 0) {
            return "Fizz";
        }
        if (n % 5 == 0) {
            return "Buzz";
        } else {
            return uintToString(n);
        }
    }

    function uintToString(uint256 v) internal pure returns (string memory) {
        if (v == 0) return "0";

        uint256 j = v;
        uint256 length;

        while (j != 0) {
            length++;
            j /= 10;
        }

        bytes memory bstr = new bytes(length);
        int256 k = int256(length) - 1; // change k to int256 to allow negative values

        while (v != 0) {
            bstr[uint256(k)] = bytes1(uint8(48 + v % 10)); // cast k back to uint256 for indexing
            if (k > 0) {
                // check if k is greater than 0 before decrementing
                k--;
            }
            v /= 10;
        }

        return string(bstr);
    }
}
