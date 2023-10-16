// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "ds-test/test.sol";
import {FizzBuzz} from "../src/FizzBuzz.sol";

contract FizzBuzzTest is DSTest {
    FizzBuzz internal fizzBuzz;

    function setUp() public {
        fizzBuzz = new FizzBuzz();
    }

    function test_returnsFizzWhenDicisibleByThree() public {
        assertEq(fizzBuzz.fizzBuzz(3), "Fizz");
    }

    function test_returnsBuzzWhenDicisibleByFive() public {
        assertEq(fizzBuzz.fizzBuzz(5), "Buzz");
    }

    function test_returnsNumberAsStringOtherwise() public {
        assertEq(fizzBuzz.fizzBuzz(1), "1");
    }
}
