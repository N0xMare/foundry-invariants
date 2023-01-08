pragma solidity 0.8.17;

contract StorageInvariant {
    address public owner;
    bool public flag = true;
    uint256 public num1 = 1;
    uint256 public num2 = 0;

    error OnlyOwner();
    error FlagLocked();

    constructor() {
        owner = address(0xbeef);
    }

    function getNum1() public view returns (uint256) {
        return num1;
    }

    function getNum2() public view returns (uint256) {
        return num2;
    }

    /// @notice lock/unlock use of "protectedStore()" by the owner
    function lock(bool _state) public {
        if (msg.sender != owner) {
            revert OnlyOwner();
        }
        flag = _state;
    }

    /// @notice mutate num2 from 0 to 1
    function store(uint256 _num) public {
        if (_num == num2) {
            num2 = 1;
        }
    }

    /// @notice mutate num1, only callable by the owner when lock is false
    function protectedStore(uint256 _number) public {
        if (msg.sender != owner) {
            revert OnlyOwner();
        }
        if (flag = true) {
            revert FlagLocked();
        }
        num1 = _number;
    }
}
