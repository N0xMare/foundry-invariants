pragma solidity 0.8.17;

import { MockERC20 } from "../test/mocks/MockERC20.sol";

contract ERC20User {
    MockERC20 token;
    uint256 public supply;

    constructor(MockERC20 _token) {
        token = _token;
    }

    function mint(address from, uint256 amount) public {
        token.mint(from, amount);
        supply += amount;
    }

    function burn(address from, uint256 amount) public {
        token.burn(from, amount);
        supply -= amount;
    }

    function approve(address to, uint256 amount) public {
        token.approve(to, amount);
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public {
        token.transferFrom(from, to, amount);
    }

    function transfer(address to, uint256 amount) public {
        token.transfer(to, amount);
    }
}