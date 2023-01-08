/*
pragma solidity ^0.8.15;

contract SimpleInvariant {

    bool public foo = false;
    bool public bar = false;

    function setFoo() public {
        foo = false;
    }

    function setBar() public {
        bar = true;
    }

    function foobar() public view returns(bool) {
        return foo && bar;
    }

}*/

pragma solidity ^0.8.15;

import "forge-std/Test.sol";
import "forge-std/InvariantTest.sol";
import "../src/SimpleInvariant.sol";

contract SimpleInvariantTest is Test, InvariantTest {
    SimpleInvariant public simpleInvariant;

    /// @notice without targeting the SimpleInvariant contract the invariant test will traverse across all the contracts in src/
    /// because no scope has been defined in setUp() using targetContract()
    /// In other examples, multi contract invariants will be shown so stay tuned for more features of forge-std's InvariantTest.sol
    function setUp() public {
        simpleInvariant = new SimpleInvariant(); // deploy example contract
        targetContract(address(simpleInvariant)); // set target for invariant testing to only "SimpleInvariant"
    }

    /// @notice After the setUp() function is run, the state of the target contract is taken in this case. There after
    /// a loop runs executing in pseudo-random sequence any functions available to the invariant test based on the invariant's scope defined
    /// in the setUp() function. In this test we are only using targetContract() for SimpleInvariant and nothing else so external functions of
    /// SimpleInvariant will be called to see if the invariant is broken by any possible sequence.
    ///
    /// As you can see, the invariant passes because the && operator has left-to-right associativity with the boolean variable "foo" which
    /// remains false always. Even if setFoo() is called by the invariant test the variable will remain in the same state, false, and therefore
    /// the return value from "foobar()" remains constant. Go ahead and change the SimpleInvariant contract's foo or bar values as well as
    /// what setFoo() and setBar() do to make the invariant fail and you will see forge test output specific call chains that make it fail.
    function invariantTest() public {
        assertFalse(simpleInvariant.foobar());
    }
}
