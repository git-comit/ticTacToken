// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {DSTest} from "ds-test/test.sol";
import {Vm} from "forge-std/Vm.sol";
import {Token} from "../src/Token.sol";

contract TokenTest is DSTest {
    Vm internal vm = Vm(HEVM_ADDRESS);

    Token internal token;

    function setUp() public {
        token = new Token();
    }

    function test_tokenName() public {
        assertEq(token.name(), "Tic Tac Token");
    }

    function test_tokenSymbol() public {
        assertEq(token.symbol(), "TTT");
    }

    function test_tokenDecimals() public {
        assertEq(token.decimals(), 18);
    }

    function test_mintToOwner() public {
        token.mint(address(this), 100 ether);
    }

    function test_transferTokens() public {
        token.mint(address(this), 100 ether);

        token.transfer(address(0x42), 10 ether);
        assertEq(token.balanceOf(address(this)), 90 ether);
        assertEq(token.balanceOf(address(0x42)), 10 ether);
    }

    function test_nonOwnerCanNotMint() public {
        vm.prank(address(0x1));
        vm.expectRevert();
        token.mint(address(this), 100 ether);
    }
}
