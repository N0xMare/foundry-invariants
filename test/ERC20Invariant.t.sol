pragma solidity 0.8.17;

import { Test } from "forge-std/Test.sol";
import { InvariantTest } from "forge-std/InvariantTest.sol";
import { MockERC20 } from "./mocks/MockERC20.sol";
import { ERC20User } from "../src/ERC20User.sol";

contract ERC20InvariantTest is Test, InvariantTest {
    MockERC20 public token;
    ERC20User public controller;
    
    function setUp() public {
        token = new MockERC20("Foobar", "FOO", 18); // deploy token
        controller = new ERC20User(token); // deploy contract that uses MockERC20
        targetContract(address(controller)); // target controller
    }

    /// @notice This invariant test is fuzzing all the functions available to be called within
    /// the "ERC20User" contract, which is the basic interface for the ERC20 standard (MockERC20). The point
    /// is to test the functions that change ownership of the token balances (transfer and transferFrom) as
    /// well as the functions that change the total supply (mint and burn) to make certain that balances/ownership
    /// rules are working as intended and cant be broken. Also included is the permit function (approve).
    ///
    /// Having a contract that uses "MockERC20" (the contract/functions we actually want to test here) allows the invariant
    /// in this test file to use ERC20User's functions in order to input fuzzed parameters during the test process and different 
    /// call-chain orderings to each function we want to test in MockERC20. In this case ERC20User serves as a wrapper
    /// to make calls with fuzzing capabilities to each function that is present from MockERC20. This principle can be applied
    /// more generally as well to other contracts and their respective interfaces.
    function invariant_accounting() public {
        assertEq(token.totalSupply(), controller.supply());
    }
}