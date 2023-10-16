// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract TicTacToken {
    uint256[9] public board;
    uint256 internal _turns;

    uint256 internal constant EMPTY = 0;
    uint256 internal constant X = 1;
    uint256 internal constant O = 2;

    function getBoard() public view returns (uint256[9] memory) {
        return board;
    }

    function markSpace(uint256 index, uint256 mark) public {
        require(_validMark(mark), "Invalid mark");
        require(_emptySpace(index), "Space is already marked");
        require(_validTurn(mark), "Not your turn");
        board[index] = mark;
        ++_turns;
    }

    function winner() public view returns (uint256) {
        uint256[6] memory wins = [_row(0), _row(1), _row(2), _coloums(0), _coloums(1), _coloums(2)];
        for (uint256 i = 0; i < wins.length; i++) {
            uint256 win = _checkWin(wins[i]);
            if (win == X || win == O) return win;
        }
        return 0;
    }

    function currentTurn() public view returns (uint256) {
        return _turns % 2 == 0 ? X : O;
    }

    function _validMark(uint256 mark) internal pure returns (bool) {
        return mark == X || mark == O;
    }

    // function _compareStrings(string memory a, string memory b) internal pure returns (bool) {
    //     return keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b));
    // }

    // checking board and turn helper functions
    function _emptySpace(uint256 i) internal view returns (bool) {
        return board[i] == EMPTY;
    }

    function _validTurn(uint256 mark) internal view returns (bool) {
        return mark == currentTurn();
    }

    // check for winner helper functions

    function _row(uint256 row) internal view returns (uint256) {
        require(row < 3, "Row must be less than 3");
        uint256 index = 3 * row;
        return board[index] * board[index + 1] * board[index + 2];
    }

    function _coloums(uint256 coloum) internal view returns (uint256) {
        require(coloum < 3, "Coloum must be less than 3");
        return board[coloum] * board[coloum + 3] * board[coloum + 6];
    }

    function _diagonal() internal view returns (uint256) {
        return board[0] * board[4] * board[8];
    }

    function _antiDiagonal() internal view returns (uint256) {
        return board[2] * board[4] * board[6];
    }

    function _checkWin(uint256 product) internal pure returns (uint256) {
        if (product == 1) {
            return X;
        } else if (product == 8) {
            return O;
        } else {
            return 0;
        }
    }
}
