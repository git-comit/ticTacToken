// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {TicTacToken} from "../../src/TicTacToken.sol";
import {Vm} from "forge-std/Vm.sol";

contract User {
    TicTacToken internal ttt;
    Vm internal vm;
    address internal _address;

    constructor(address address_, TicTacToken _ttt, Vm _vm) {
        _address = address_;
        ttt = _ttt;
        vm = _vm;
    }

    function markSpace(uint256 space) public {
        vm.prank(_address);
        ttt.markSpace(space);
    }
}
