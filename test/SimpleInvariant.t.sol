pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/InvariantTest";
import "../src/SimpleInvariant.sol";

contract SimpleInvariantTest is Test, InvariantTest {
    SimpleInvariant public simpleInvariant;

    function setUp() public {
        simpleInvariant = new SimpleInvariant();
        targetContract(address(simpleInvariant));
    }

    function invariantTest() public {
        assertFalse(simpleInvariant.foobar());
    }

}
