//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {DSTest} from "ds-test/test.sol";
import {console} from "forge-std/Script.sol";
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
        ttt = new TicTacToken(OWNER);
        playerX = new User(PLAYER_X, ttt,vm );
        playerO = new User(PLAYER_O, ttt,vm );
        ttt.newGame(PLAYER_X, PLAYER_O);
    }

    function test_owner() public {
        assertEq(ttt.owner(), OWNER);
    }

    function test_hasEmptyBoard() public {
        for (uint256 i = 0; i < 9; ++i) {
            assertEq(ttt.getBoard(0)[i], EMPTY);
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
        uint256[9] memory actual = ttt.getBoard(0);

        for (uint256 i = 0; i < 9; ++i) {
            assertEq(actual[i], expected[i]);
        }
    }

    function test_canMarkSpaceWithX() public {
        playerX.markSpace(0, 0);
        assertEq(ttt.getBoard(0)[0], 1);
    }

    function test_canMarkSpaceWithO() public {
        playerX.markSpace(0, 1);
        playerO.markSpace(0, 3);
        assertEq(ttt.getBoard(0)[3], O);
    }

    // function test_canNotMarkSpaceWithZ() public {
    //     vm.expectRevert("Invalid mark");
    //     playerX.markSpace(3);
    // }

    function test_alreadyMarked() public {
        playerX.markSpace(0, 1);
        vm.expectRevert("Space is already marked");
        playerO.markSpace(0, 1);
    }

    function test_playersMustGoInTurn() public {
        playerX.markSpace(0, 0);
        vm.expectRevert("Not your turn");
        playerX.markSpace(0, 1);
    }

    function test_tracksCurrentTurn() public {
        assertEq(ttt.currentTurn(0), X);
        playerX.markSpace(0, 0);
        assertEq(ttt.currentTurn(0), O);
        playerO.markSpace(0, 1);
        assertEq(ttt.currentTurn(0), X);
    }

    function test_horizontalWinnerRow1() public {
        playerX.markSpace(0, 0);
        playerO.markSpace(0, 3);
        playerX.markSpace(0, 1);
        playerO.markSpace(0, 4);
        playerX.markSpace(0, 2);
        assertEq(ttt.winner(0), X);
    }

    function test_horizontalWinnerRow2() public {
        playerX.markSpace(0, 3);
        playerO.markSpace(0, 0);
        playerX.markSpace(0, 4);
        playerO.markSpace(0, 1);
        playerX.markSpace(0, 5);
        assertEq(ttt.winner(0), X);
    }

    function test_drawReturnsNoWinner() public {
        playerX.markSpace(0, 4);
        playerO.markSpace(0, 0);
        playerX.markSpace(0, 1);
        playerO.markSpace(0, 7);
        playerX.markSpace(0, 2);
        playerO.markSpace(0, 6);
        playerX.markSpace(0, 8);
        playerO.markSpace(0, 5);
        assertEq(ttt.winner(0), 0);
    }

    function test_emptyReturnsNoWinner() public {
        assertEq(ttt.winner(0), 0);
    }

    function test_gameInProgressReturnsNoWinner() public {
        playerX.markSpace(0, 4);
        assertEq(ttt.winner(0), 0);
    }

    function test_msgSender() public {
        Caller caller1 = new Caller(ttt);
        Caller caller2 = new Caller(ttt);

        assertEq(ttt.msgSender(), address(this));
        assertEq(caller1.call(), address(caller1));
        assertEq(caller2.call(), address(caller2));
    }

    function test_ownerCanResetBoard() public {
        playerX.markSpace(0, 1);
        playerO.markSpace(0, 7);
        vm.prank(OWNER);
        ttt.resetBoard(0);
        for (uint256 i = 0; i < 9; ++i) {
            assertEq(ttt.getBoard(0)[i], EMPTY);
        }
    }

    function test_nonOwnerCanNotResetBoard() public {
        playerX.markSpace(0, 1);
        playerO.markSpace(0, 7);
        assertEq(ttt.getBoard(0)[1], X);
        assertEq(ttt.getBoard(0)[7], O);
        vm.expectRevert("Unauthorized");
        ttt.resetBoard(0);
        assertEq(ttt.getBoard(0)[1], X);
        assertEq(ttt.getBoard(0)[7], O);
    }

    function test_onlyAuthPlayerCanMark() public {
        vm.prank(address(0x43));
        vm.expectRevert("Unauthorized");

        ttt.markSpace(0, 1);
    }

    function test_storesPlayerX() public {
        (address playerXAddr,,) = ttt.games(0);
        assertEq(playerXAddr, PLAYER_X);
    }

    function test_sotorePlayerO() public {
        (, address playerOAddr,) = ttt.games(0);
        assertEq(playerOAddr, PLAYER_O);
    }

    function test_createsNewGame() public {
        ttt.newGame(address(5), address(6));
        (address playerXAddr, address playerOAddr, uint256 turns) = ttt.games(1);
        assertEq(playerXAddr, address(5));
        assertEq(playerOAddr, address(6));
        assertEq(turns, 0);
    }

    function test_gamesAreIsolated() public {
        playerX.markSpace(0, 1);
        playerO.markSpace(0, 0);
        playerX.markSpace(0, 2);
        playerO.markSpace(0, 3);
        playerX.markSpace(0, 4);
        playerO.markSpace(0, 6);

        ttt.newGame(PLAYER_X, PLAYER_O);
        playerX.markSpace(1, 0);
        playerO.markSpace(1, 1);
        playerX.markSpace(1, 4);
        playerO.markSpace(1, 5);
        playerX.markSpace(1, 8);

        assertEq(ttt.winner(0), O);
        assertEq(ttt.winner(1), X);
    }

    function test_playerXWinsStartAt0() public {
        assertEq(ttt.totalWins(PLAYER_X), 0);
    }

    function test_playerOWinsStartAt0() public {
        assertEq(ttt.totalWins(PLAYER_O), 0);
    }

    function test_winCountIncrementsOnWin() public {
        playerX.markSpace(0, 0);
        playerO.markSpace(0, 3);
        playerX.markSpace(0, 1);
        playerO.markSpace(0, 4);
        playerX.markSpace(0, 2);
        assertEq(ttt.totalWins(PLAYER_X), 1);

        ttt.newGame(PLAYER_X, PLAYER_O);
        playerX.markSpace(1, 1);
        playerO.markSpace(1, 2);
        playerX.markSpace(1, 3);
        playerO.markSpace(1, 4);
        playerX.markSpace(1, 5);
        playerO.markSpace(1, 6);
        assertEq(ttt.totalWins(PLAYER_O), 1);
    }

    function test_threeMoveWinX() public {
        // x | x | x
        // o | o | .
        // . | . | .
        playerX.markSpace(0, 0);
        playerO.markSpace(0, 3);
        playerX.markSpace(0, 1);
        playerO.markSpace(0, 4);
        playerX.markSpace(0, 2);
        assertEq(ttt.totalPoints(PLAYER_X), 300);
    }

    function test_threeMoveWinO() public {
        // x | x | .
        // o | o | o
        // x | . | .
        playerX.markSpace(0, 0);
        playerO.markSpace(0, 3);
        playerX.markSpace(0, 1);
        playerO.markSpace(0, 4);
        playerX.markSpace(0, 6);
        playerO.markSpace(0, 5);
        assertEq(ttt.totalPoints(PLAYER_O), 300);
    }

    function test_fourMoveWinX() public {
        // x | x | x
        // o | o | .
        // x | o | .
        playerX.markSpace(0, 0);
        playerO.markSpace(0, 3);
        playerX.markSpace(0, 1);
        playerO.markSpace(0, 4);
        playerX.markSpace(0, 6);
        playerO.markSpace(0, 7);
        playerX.markSpace(0, 2);
        assertEq(ttt.totalPoints(PLAYER_X), 200);
    }

    function test_fourMoveWinO() public {
        // x | x | .
        // o | o | o
        // x | o | x
        playerX.markSpace(0, 0);
        playerO.markSpace(0, 3);
        playerX.markSpace(0, 1);
        playerO.markSpace(0, 4);
        playerX.markSpace(0, 6);
        playerO.markSpace(0, 7);
        playerX.markSpace(0, 8);
        playerO.markSpace(0, 5);
        assertEq(ttt.totalPoints(PLAYER_O), 200);
    }

    function test_fiveMoveWinX() public {
        // x | x | x
        // o | o | x
        // x | o | o
        playerX.markSpace(0, 0);
        playerO.markSpace(0, 3);
        playerX.markSpace(0, 1);
        playerO.markSpace(0, 4);
        playerX.markSpace(0, 6);
        playerO.markSpace(0, 7);
        playerX.markSpace(0, 5);
        playerO.markSpace(0, 8);
        playerX.markSpace(0, 2);
        assertEq(ttt.totalPoints(PLAYER_X), 100);
    }
}
