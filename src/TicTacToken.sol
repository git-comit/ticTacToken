// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract TicTacToken {
    address public owner;

    uint256 internal constant EMPTY = 0;
    uint256 internal constant X = 1;
    uint256 internal constant O = 2;
    uint256 internal _nextGameId;

    struct Game {
        address playerX;
        address playerO;
        uint256 turns;
        uint256[9] board;
    }

    mapping(uint256 => Game) public games;
    mapping(address => uint256) public totalWins;
    mapping(address => uint256) public totalPoints;

    modifier onlyOwner() {
        require(msg.sender == owner, "Unauthorized");
        _;
    }

    modifier onlyPlayer(uint256 id) {
        require(_authPlayer(id), "Unauthorized");
        _;
    }

    constructor(address _owner) {
        owner = _owner;
    }

    function getBoard(uint256 id) public view returns (uint256[9] memory) {
        return games[id].board;
    }

    function newGame(address x, address o) public {
        games[_nextGameId].playerX = x;
        games[_nextGameId].playerO = o;
        _nextGameId++;
    }

    function markSpace(uint256 id, uint256 index) public onlyPlayer(id) {
        require(_emptySpace(id, index), "Space is already marked");
        require(_validSpace(index), "Invalid space");
        require(_validTurn(id), "Not your turn");
        games[id].board[index] = _getMark(id);
        games[id].turns++;
        if (winner(id) != 0) {
            address winnerAddress = _getAddress(id, winner(id));
            totalWins[winnerAddress] += 1;
            totalPoints[winnerAddress] += _pointsEarned(id);
        }
    }

    function winner(uint256 id) public view returns (uint256) {
        uint256[8] memory wins = [
            _row(id, 0),
            _row(id, 1),
            _row(id, 2),
            _coloums(id, 0),
            _coloums(id, 1),
            _coloums(id, 2),
            _diagonal(id),
            _antiDiagonal(id)
        ];
        for (uint256 i = 0; i < wins.length; i++) {
            uint256 win = _checkWin(wins[i]);
            if (win == X || win == O) return win;
        }

        return 0;
    }

    function currentTurn(uint256 id) public view returns (uint256) {
        return (games[id].turns % 2 == 0) ? X : O;
    }
    // Inside the TicTacToken contract

    function msgSender() public view returns (address) {
        return msg.sender;
    }

    function resetBoard(uint256 id) public onlyOwner {
        delete games[id].board;
    }

    // function _compareStrings(string memory a, string memory b) internal pure returns (bool) {
    //     return keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b));
    // }

    function _getAddress(uint256 id, uint256 mark) internal view returns (address) {
        if (mark == X) {
            return games[id].playerX;
        }
        if (mark == O) {
            return games[id].playerO;
        } else {
            return address(0);
        }
    }

    function _pointsEarned(uint256 id) internal view returns (uint256) {
        uint256 turns = games[id].turns;
        uint256 moves;
        if (winner(id) == X) {
            moves = (turns + 1) / 2;
        }
        if (winner(id) == O) {
            moves = turns / 2;
        }
        return 600 - (moves * 100);
    }
    // checking board and turn helper functions

    function _emptySpace(uint256 id, uint256 i) internal view returns (bool) {
        return games[id].board[i] == EMPTY;
    }

    function _validTurn(uint256 id) internal view returns (bool) {
        return currentTurn(id) == _getMark(id);
    }

    function _validSpace(uint256 i) internal pure returns (bool) {
        return i < 9;
    }

    // check for winner helper functions

    function _row(uint256 id, uint256 row) internal view returns (uint256) {
        require(row < 3, "Row must be less than 3");
        uint256 index = 3 * row;
        return games[id].board[index] * games[id].board[index + 1] * games[id].board[index + 2];
    }

    function _coloums(uint256 id, uint256 coloum) internal view returns (uint256) {
        require(coloum < 3, "Coloum must be less than 3");
        return games[id].board[coloum] * games[id].board[coloum + 3] * games[id].board[coloum + 6];
    }

    function _diagonal(uint256 id) internal view returns (uint256) {
        return games[id].board[0] * games[id].board[4] * games[id].board[8];
    }

    function _antiDiagonal(uint256 id) internal view returns (uint256) {
        return games[id].board[2] * games[id].board[4] * games[id].board[6];
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

    function _authPlayer(uint256 id) internal view returns (bool) {
        return msg.sender == games[id].playerX || msg.sender == games[id].playerO;
    }

    function _getMark(uint256 id) public view returns (uint256) {
        if (msg.sender == games[id].playerX) {
            return X;
        } else if (msg.sender == games[id].playerO) {
            return O;
        } else {
            return EMPTY;
        }
    }
}
