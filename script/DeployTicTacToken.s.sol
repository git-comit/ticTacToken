// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {TicTacToken} from "../src/TicTacToken.sol";

/**
 * @title DeployWhaleConfig
 * @notice deploys WhaleConfig contract
 */

contract DeployTicTacToken is Script {
    function run() external returns (TicTacToken) {
        vm.startBroadcast();
        TicTacToken ticTacToken = new TicTacToken(msg.sender, address(0x2), address(0x3));
        vm.stopBroadcast();
        return ticTacToken;
    }
}
