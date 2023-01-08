pragma solidity ^0.8.15;

import "forge-std/Test.sol";
import "forge-std/InvariantTest.sol";
import "../src/StorageInvariant.sol";

contract StorageInvariantTest is Test, InvariantTest {
    StorageInvariant public storageInvariant;
    uint256 initNum1;
    uint256 initNum2;

    function setUp() public {
        storageInvariant = new StorageInvariant(); // deploy example contract
        targetContract(address(storageInvariant)); // target "StorageInvariant"

        vm.prank(address(0xbeef)); 
        storageInvariant.lock(true);               // storageInvariant's owner calls "unlock()" setting "flag" to true

        initNum1 = storageInvariant.getNum1();     // get initial value of num1
        initNum2 = storageInvariant.getNum2();     // get initial value of num2
    }

    /// @notice this invariant intentionally fails to show that any address can call "store()" changing num2's value to 1.
    /// run the test multiple times and you will notice the invariant fuzzer forming different pseudo-random call-chains 
    /// before arriving at store(0) which changes num2 to 1 breaking the invariant.
    function invariantTestStore() public {
        assertEq(storageInvariant.getNum2(), 0);
    }

    /// @notice During the setUp() process storageInvariant's owner (0xbeef) calls "lock()". This function sets "flag" to
    /// false which then stops the storage slot corresponding to "num1" from being able to be mutated by the owner using
    /// "protectedStore()". As long as "flag" is false and the lock is activated the invariant holds.
    function invariantTestProtectedStore() public {
        emit log_named_uint("Initial number", initNum1);
        assertEq(initNum1, storageInvariant.getNum1());
    }

}