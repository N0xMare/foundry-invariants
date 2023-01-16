# Why invariants?

The Invariant testing feature in Foundry comprises of a fuzzing utility which uses both random and "dictionary" values. The dictionary contains items in the compilation artifacts of the contract(s) which is then used in the invariant test alongside randomized inputs. The "dictionary_weight" determines the percentage of "random" contract and "random" non-view calldata used by the fuzzer. With a dictionary_weight of X%, the fuzzer will use random values for (100 - X)% of the runs.

- Run `setUp()` and save off resulting state.
- For (i = 0; i < numberOfInvariantRuns; i++) {
  - Set global state to post `setUp()` state.
  - Check that the invariant holds.
  - Choose "random" contract + "random" non-view calldata to call on that contract.
  - If `fail_on_revert = true` and call reverts, invariant failed.
  - If `fail_on_revert = false` and call reverts, continue.
  - Check invariant.
-Repeat steps 2-5 `depth` number of times.

The main advantage in using invariant tests rather than unit/integration tests with the same test assertions, is in order to traverse different call-chain possibilties within the contract(s) without explicitly defining them all. Access control in evm contracts is meant be highly verbose and we can use this to our advantage when invariant testing by defining the set of callers that can possibly call functions in the contract(s). This could be simply a single address like "onlyOwner", a set of addresses, or plain external/public functions. Specifying both the caller(s) and the targeted contract(s) for the fuzzer to run simulations on is how one can isolate and test invariants for specific cases presented in the contract code.

In the case of "SimpleInvariant" it is reasonable to assume that a developer would be able to map out manually with unit tests all possible call chains and things that could happen in the contract, testing each of them individually, only because of how simple it is. Nonetheless, for situations involving more complicated contracts, or several contracts, the ability to find all these call-chain possibilities becomes more cumbersome or straight up impossible. It is better to define an invariant you want to hold and have the foundry back-end do the work for you fuzzing it with programmatically generated call-chains, than to think about all the possible call chains in that same scenario and write out test functions for each call chain possibility starting from the initial state made by the setUp() function.
