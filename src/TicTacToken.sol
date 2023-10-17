// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract TicTacToken {
    address public owner;
    uint256[9] public board;
    uint256 internal _turns;

    address public PLAYER_X;
    address public PLAYER_O;
    uint256 internal constant EMPTY = 0;
    uint256 internal constant X = 1;
    uint256 internal constant O = 2;

    modifier onlyOwner() {
        require(msg.sender == owner, "Unauthorized");
        _;
    }

    modifier onlyPlayer() {
        require(_authPlayer(), "Unauthorized");
        _;
    }

    constructor(address _owner, address _playerX, address _playerO) {
        owner = _owner;
        PLAYER_X = _playerX;
        PLAYER_O = _playerO;
    }

    function getBoard() public view returns (uint256[9] memory) {
        return board;
    }

    function markSpace(uint256 index) public onlyPlayer {
        uint256 mark = _getMark();
        require(_emptySpace(index), "Space is already marked");
        require(_validSpace(index), "Invalid space");
        require(_validTurn(), "Not your turn");
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
    // Inside the TicTacToken contract

    function msgSender() public view returns (address) {
        return msg.sender;
    }

    function resetBoard() public onlyOwner {
        delete board;
    }

    // function _compareStrings(string memory a, string memory b) internal pure returns (bool) {
    //     return keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b));
    // }

    // checking board and turn helper functions
    function _emptySpace(uint256 i) internal view returns (bool) {
        return board[i] == EMPTY;
    }

    function _validTurn() internal view returns (bool) {
        return currentTurn() == _getMark();
    }

    function _validSpace(uint256 i) internal pure returns (bool) {
        return i < 9;
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

    function _authPlayer() internal view returns (bool) {
        return msg.sender == PLAYER_X || msg.sender == PLAYER_O;
    }

    function _getMark() public view returns (uint256) {
        if (msg.sender == PLAYER_X) {
            return X;
        } else if (msg.sender == PLAYER_O) {
            return O;
        } else {
            return EMPTY;
        }
    }
}
