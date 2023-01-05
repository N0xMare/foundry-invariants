pragma solidity ^0.8.15;

contract SimpleInvariant {

    bool public foo = false;
    bool public bar = false;

    function setFoo() public {
        foo = true;
    }

    function setBar() public {
        bar = true;
    }

    function foobar() public view returns(bool) {
        return foo && bar;
    }

}
