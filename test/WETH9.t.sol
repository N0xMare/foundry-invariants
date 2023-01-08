pragma solidity 0.7.6;
pragma abicoder v2;

import { InvariantTest } from "forge-std/InvariantTest.sol";
import { Test } from "forge-std/Test.sol";
import { WETH9 } from "../src/WETH9.sol";

////////////////////////////////////////////////////////////////
//                      INVARIANT TESTS                       //
////////////////////////////////////////////////////////////////

/// @notice Tests the following invariants of WETH9:
/// SOLVENCY:
///  1. Depositing `n` ETH should yield exactly `n` WETH every time.
///  2. Withdrawing `n` WETH should yield exactly `n` ETH every time.
/// ACCOUNTING:
///  1. The `totalSupply` of the WETH contract should be equal to the amount of
///     ETH in the contract, and as implied by the solvency invariants, the amount
///     of WETH in circulation.
///
/// To begin with, we define an actor that has the ability to deposit and withdraw
/// from the WETH9 contract. After this, we use the `InvariantTest`'s `targetContract`
/// to specify that we only want the invariant fuzzer to consider this actor contract
/// in its search for a failing sequence of calls.
///
/// https://github.com/mds1/solidity-sandbox/blob/main/test/4_InvariantNonceGoUp.t.sol
/// Some extra context as to what is going on in the background from Matt Solomon's
/// `solidity-sandbox` example:
///  1. Run `setUp()` and save off resulting state.
///  2. for (i = 0; i < numberOfInvariantRuns; i++) {
///       0. Set global state to post `setUp()` state.
///       1. Check that the invariant holds.
///       2. Choose "random" contract + "random" non-view calldata to call on that
///          contract.
///       3. If `fail_on_revert = true` and call reverts, invariant failed.
///       4. If `fail_on_revert = false` and call reverts, continue.
///       5. Check invariant.
///       6. Repeat steps 2-5 `depth` number of times.
///     }
/// Note: The "random" contract and "random" non-view calldata are chosen depending
/// on the configured `dictionary_weight` configuration value. For example, if
/// `dictionary_weight = 50`, the fuzzer will use values collected from the compilation
/// artifacts 50% of the time and random values the other 50% of the time.
contract WETH_Invariants is InvariantTest, Test {
    WETH9 public weth;
    WETHActor public actor;

    function setUp() public {
        // Deploy WETH9
        weth = new WETH9();

        // Deploy the WETHActor
        actor = new WETHActor(weth);

        // Give the test actor uint128 max ETH
        vm.deal(address(actor), type(uint128).max);

        // Target the Actor contract
        targetContract(address(actor));
    }

    /// INVARIANT: Depositing `n` ETH should yield exactly `n` WETH tokens every time.
    /// INVARIANT: Withdrawing `n` WETH tokens should yield exactly `n` ETH every time.
    ///
    /// @dev The fuzzer is likely to include both deposit and withdrawal calls in its
    /// search for a failing sequence of calls, so we can test both invariants at once.
    function invariant_solvency() public {
        uint256 delta = type(uint128).max - address(actor).balance;
        assertEq(weth.balanceOf(address(actor)), delta);
    }

    /// INVARIANT: The `totalSupply` should always equal the amount of ETH in the contract,
    /// and as implied by the solvency invariants, the amount of WETH in circulation.
    ///
    /// @dev See the `WETHActor` contract's `burnSelfDestruct` function- it is possible
    /// to break this invariant!
    function invariant_accounting() public {
        uint256 delta = type(uint128).max - address(actor).balance;
        assertEq(weth.totalSupply(), delta);
    }
}

////////////////////////////////////////////////////////////////
//                          HELPERS                           //
////////////////////////////////////////////////////////////////

/// @dev Used to force-send ETH to an address.
contract SelfDestruct {
    constructor(address _to) payable {
        selfdestruct(payable(_to));
    }
}

/// @title WETHActor
/// @notice A simple actor that can deposit/withdraw with the WETH9 contract.
contract WETHActor is Test {
    /// @notice The modified WETH9 contract.
    WETH9 public weth;

    constructor(WETH9 _weth) {
        weth = _weth;
    }

    /// @notice Deposit `amount` ETH to the WETH9 contract.
    function deposit(uint128 amount) public {
        weth.deposit{value: amount}();
    }

    /// @notice Deposit `amount` ETH to the WETH9 contract via a call.
    function depositCall(uint128 amount) public {
        (bool success,) = address(weth).call{value: amount}("");
        require(success);
    }

    /// @notice Withdraw `amount` ETH from the WETH9 contract.
    function withdraw(uint128 amount) public {
        weth.withdraw(amount);
    }

    /// @notice Burns `amount` ETH tokens by force-sending them to the WETH9 contract.
    /// @dev If you uncomment this function, the accounting invariant will fail!
    /// Although WETH9's fallback function triggers a deposit, force-sending ETH
    /// via the `SELFDESTRUCT` opcode will not. Because of this, it is possible for
    /// the accounting invariant to fail, but the solvency invariants continue to hold.
    // function burnSelfDestruct(uint128 amount) public {
    //     // Act as `0xbeef` and force-send an amount of ETH bound to [0, type(uint128).max]
    //     // to the WETH9 contract.
    //     vm.deal(address(0xbeef), amount);
    //     vm.prank(address(0xbeef));
    //     new SelfDestruct{value: amount}(address(weth));
    // }
}
