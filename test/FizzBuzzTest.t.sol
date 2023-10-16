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
        assertEq(fizzBuzz.fizzBuzz(6), "Fizz");
        assertEq(fizzBuzz.fizzBuzz(9), "Fizz");
        assertEq(fizzBuzz.fizzBuzz(27), "Fizz");
    }

    function test_returnsBuzzWhenDicisibleByFive() public {
        assertEq(fizzBuzz.fizzBuzz(5), "Buzz");
        assertEq(fizzBuzz.fizzBuzz(10), "Buzz");
        assertEq(fizzBuzz.fizzBuzz(605), "Buzz");
        assertEq(fizzBuzz.fizzBuzz(25), "Buzz");
        assertEq(fizzBuzz.fizzBuzz(455), "Buzz");
    }

    function test_returnsNumberAsStringOtherwise() public {
        assertEq(fizzBuzz.fizzBuzz(1), "1");
        assertEq(fizzBuzz.fizzBuzz(1001), "1001");
        assertEq(fizzBuzz.fizzBuzz(34), "34");
        assertEq(fizzBuzz.fizzBuzz(91), "91");
    }

    function test_returns_fizzbuzz_when_divisible_by_three_and_five() public {
        assertEq(fizzBuzz.fizzBuzz(15), "fizzbuzz");
        assertEq(fizzBuzz.fizzBuzz(705), "fizzbuzz");
        assertEq(fizzBuzz.fizzBuzz(900), "fizzbuzz");
        assertEq(fizzBuzz.fizzBuzz(660), "fizzbuzz");
    }
}
