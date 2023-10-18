// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {DSTest} from "ds-test/test.sol";
import {Vm} from "forge-std/Vm.sol";
import {NFT} from "../src/NFT.sol";
import {ERC721Holder} from "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";

contract NFTTest is DSTest, ERC721Holder {
    Vm internal vm = Vm(HEVM_ADDRESS);
    NFT internal nft;

    function setUp() public {
        nft = new NFT();
    }

    function test_tokenName() public {
        assertEq(nft.name(), "Tic Tac NFT");
    }

    function test_tokenSymbol() public {
        assertEq(nft.symbol(), "TTN");
    }

    function test_mint() public {
        nft.mint(address(this), 1);
        assertEq(nft.balanceOf(address(this)), 1);
        assertEq(nft.ownerOf(1), address(this));
    }

    function test_nonOwnerCanNotMintToken() public {
        vm.prank(address(1));
        vm.expectRevert();
        nft.mint(address(this), 1);
    }
}
