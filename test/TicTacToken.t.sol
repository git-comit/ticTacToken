//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {DSTest} from "ds-test/test.sol";
import {Vm} from "forge-std/Vm.sol";
import {TicTacToken} from "../src/TicTacToken.sol";

contract TicTacTokenTest is DSTest {
    Vm internal vm = Vm(HEVM_ADDRESS);
    TicTacToken internal ttt;

    uint256 internal constant EMPTY = 0;
    uint256 internal constant X = 1;
    uint256 internal constant O = 2;

    function setUp() public {
        ttt = new TicTacToken();
    }

    function test_hasEmptyBoard() public {
        for (uint256 i = 0; i < 9; ++i) {
            assertEq(ttt.board(i), EMPTY);
        }
    }

    function test_getBoard() public {
        uint256[9] memory expected = [EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY];
        uint256[9] memory actual = ttt.getBoard();

        for (uint256 i = 0; i < 9; ++i) {
            assertEq(actual[i], expected[i]);
        }
    }

    function test_canMarkSpaceWithX() public {
        ttt.markSpace(0, 1);
        assertEq(ttt.board(0), 1);
    }

    function test_canMarkSpaceWithO() public {
        ttt.markSpace(1, X);
        ttt.markSpace(3, O);
        assertEq(ttt.board(3), O);
    }

    function test_canNotMarkSpaceWithZ() public {
        vm.expectRevert("Invalid mark");
        ttt.markSpace(3, 3);
    }

    function test_alreadyMarked() public {
        ttt.markSpace(1, X);
        vm.expectRevert("Space is already marked");
        ttt.markSpace(1, O);
    }

    function test_playersMustGoInTurn() public {
        ttt.markSpace(0, X);
        vm.expectRevert("Not your turn");
        ttt.markSpace(1, X);
    }

    function test_tracksCurrentTurn() public {
        assertEq(ttt.currentTurn(), X);
        ttt.markSpace(0, X);
        assertEq(ttt.currentTurn(), O);
        ttt.markSpace(1, O);
        assertEq(ttt.currentTurn(), X);
    }

    function test_horizontalWinnerRow1() public {
        ttt.markSpace(0, X);
        ttt.markSpace(3, O);
        ttt.markSpace(1, X);
        ttt.markSpace(4, O);
        ttt.markSpace(2, X);
        assertEq(ttt.winner(), X);
    }

    function test_horizontalWinnerRow2() public {
        ttt.markSpace(3, X);
        ttt.markSpace(0, O);
        ttt.markSpace(4, X);
        ttt.markSpace(1, O);
        ttt.markSpace(5, X);
        assertEq(ttt.winner(), X);
    }

    function test_drawReturnsNoWinner() public {
        ttt.markSpace(4, X);
        ttt.markSpace(0, O);
        ttt.markSpace(1, X);
        ttt.markSpace(7, O);
        ttt.markSpace(2, X);
        ttt.markSpace(6, O);
        ttt.markSpace(8, X);
        ttt.markSpace(5, O);
        assertEq(ttt.winner(), 0);
    }

    function test_emptyReturnsNoWinner() public {
        assertEq(ttt.winner(), 0);
    }

    function test_gameInProgressReturnsNoWinner() public {
        ttt.markSpace(4, X);
        assertEq(ttt.winner(), 0);
    }
}
