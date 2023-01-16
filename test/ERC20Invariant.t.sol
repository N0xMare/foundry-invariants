pragma solidity 0.8.17;

import { Test } from "forge-std/Test.sol";
import { InvariantTest } from "forge-std/InvariantTest.sol";
import { MockERC20 } from "./mocks/MockERC20.sol";
import { ERC20User } from "../src/ERC20User.sol";

contract ERC20InvariantTest is Test, InvariantTest {
    MockERC20 public token;
    ERC20User public controller;
    
    function setUp() public {
        token = new MockERC20("Foobar", "FOO", 18); //deploy token
        controller = new ERC20User(token); //deploy contract that uses the token's MockERC20 interface
        targetContract(address(controller)); //target token
    }

    function invariant_accounting() public {
        assertEq(token.totalSupply(), controller.supply());
    }
}