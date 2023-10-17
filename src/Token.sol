// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@solady/src/auth/Ownable.sol";

contract Token is ERC20, Ownable {
    constructor() ERC20("Tic Tac Token", "TTT") {
        _setOwner(msg.sender);
    }

    function mint(address account, uint256 amount) public onlyOwner {
        _mint(account, amount);
    }
}
