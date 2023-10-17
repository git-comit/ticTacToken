//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {DSTest} from "ds-test/test.sol";
import {Vm} from "forge-std/Vm.sol";
import {TicTacToken} from "../src/TicTacToken.sol";
import {Caller} from "./helpers/Caller.sol";
import {User} from "./helpers/User.sol";

contract TicTacTokenTest is DSTest {
    Vm internal vm = Vm(HEVM_ADDRESS);
    TicTacToken internal ttt;
    User internal playerX;
    User internal playerO;

    address internal constant OWNER = address(0x1);

    address internal constant PLAYER_X = address(0x2);
    address internal constant PLAYER_O = address(0x3);
    uint256 internal constant EMPTY = 0;
    uint256 internal constant X = 1;
    uint256 internal constant O = 2;

    function setUp() public {
        ttt = new TicTacToken(OWNER,PLAYER_X,PLAYER_O);
        playerX = new User(PLAYER_X, ttt, vm);
        playerO = new User(PLAYER_O, ttt, vm);
    }

    function test_owner() public {
        assertEq(ttt.owner(), OWNER);
    }

    function test_hasEmptyBoard() public {
        for (uint256 i = 0; i < 9; ++i) {
            assertEq(ttt.board(i), EMPTY);
        }
    }

    function test_playerX() public {
        assertEq(PLAYER_X, address(0x2));
    }

    function test_playerO() public {
        assertEq(PLAYER_O, address(0x3));
    }

    function test_getBoard() public {
        uint256[9] memory expected = [EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY];
        uint256[9] memory actual = ttt.getBoard();

        for (uint256 i = 0; i < 9; ++i) {
            assertEq(actual[i], expected[i]);
        }
    }

    function test_canMarkSpaceWithX() public {
        playerX.markSpace(0);
        assertEq(ttt.board(0), 1);
    }

    function test_canMarkSpaceWithO() public {
        playerX.markSpace(1);
        playerO.markSpace(3);
        assertEq(ttt.board(3), O);
    }

    // function test_canNotMarkSpaceWithZ() public {
    //     vm.expectRevert("Invalid mark");
    //     playerX.markSpace(3);
    // }

    function test_alreadyMarked() public {
        playerX.markSpace(1);
        vm.expectRevert("Space is already marked");
        playerO.markSpace(1);
    }

    function test_playersMustGoInTurn() public {
        playerX.markSpace(0);
        vm.expectRevert("Not your turn");
        playerX.markSpace(1);
    }

    function test_tracksCurrentTurn() public {
        assertEq(ttt.currentTurn(), X);
        playerX.markSpace(0);
        assertEq(ttt.currentTurn(), O);
        playerO.markSpace(1);
        assertEq(ttt.currentTurn(), X);
    }

    function test_horizontalWinnerRow1() public {
        playerX.markSpace(0);
        playerO.markSpace(3);
        playerX.markSpace(1);
        playerO.markSpace(4);
        playerX.markSpace(2);
        assertEq(ttt.winner(), X);
    }

    function test_horizontalWinnerRow2() public {
        playerX.markSpace(3);
        playerO.markSpace(0);
        playerX.markSpace(4);
        playerO.markSpace(1);
        playerX.markSpace(5);
        assertEq(ttt.winner(), X);
    }

    function test_drawReturnsNoWinner() public {
        playerX.markSpace(4);
        playerO.markSpace(0);
        playerX.markSpace(1);
        playerO.markSpace(7);
        playerX.markSpace(2);
        playerO.markSpace(6);
        playerX.markSpace(8);
        playerO.markSpace(5);
        assertEq(ttt.winner(), 0);
    }

    function test_emptyReturnsNoWinner() public {
        assertEq(ttt.winner(), 0);
    }

    function test_gameInProgressReturnsNoWinner() public {
        playerX.markSpace(4);
        assertEq(ttt.winner(), 0);
    }

    function test_msgSender() public {
        Caller caller1 = new Caller(ttt);
        Caller caller2 = new Caller(ttt);

        assertEq(ttt.msgSender(), address(this));
        assertEq(caller1.call(), address(caller1));
        assertEq(caller2.call(), address(caller2));
    }

    function test_ownerCanResetBoard() public {
        playerX.markSpace(1);
        playerO.markSpace(7);
        assertEq(ttt.board(1), X);
        assertEq(ttt.board(7), O);
        vm.prank(OWNER);
        ttt.resetBoard();
        for (uint256 i = 0; i < 9; ++i) {
            assertEq(ttt.board(i), EMPTY);
        }
    }

    function test_nonOwnerCanNotResetBoard() public {
        playerX.markSpace(1);
        playerO.markSpace(7);
        assertEq(ttt.board(1), X);
        assertEq(ttt.board(7), O);
        vm.expectRevert("Unauthorized");
        ttt.resetBoard();
        assertEq(ttt.board(1), X);
        assertEq(ttt.board(7), O);
    }

    function test_onlyAuthPlayerCanMark() public {
        vm.prank(address(0x43));
        vm.expectRevert("Unauthorized");

        ttt.markSpace(1);
    }

    function test_playerXCanMark() public {
        playerX.markSpace(1);
        assertEq(ttt.board(1), X);
    }

    function test_playerOCanMark() public {
        playerX.markSpace(2);
        playerO.markSpace(1);
        assertEq(ttt.board(1), O);
    }
}
