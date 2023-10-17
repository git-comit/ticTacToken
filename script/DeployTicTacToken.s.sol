// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {TicTacToken} from "../src/TicTacToken.sol";
import {Token} from "../src/Token.sol";

contract DeployTicTacToken is Script {
    function run() external returns (Token, TicTacToken) {
        vm.startBroadcast();
        Token token = new Token();
        TicTacToken ticTacToken = new TicTacToken(msg.sender, address(token));
        vm.stopBroadcast();
        return (token, ticTacToken);
    }
}
