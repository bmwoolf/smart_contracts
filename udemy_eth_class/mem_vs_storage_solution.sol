//SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.0 <0.9.0;

contract A {
    string[] public crypto = ['BTC', 'ETH', 'BNB'];

    function addCrypto() public { // 'Function state mutability can be restricted to view'- this is because the memory wont change
        string[] memory s = crypto; // when modifying, it wont change the state variable
        s[2] = 'XMR';
    }

    function addCrypto2() public {
        string[] storage s = crypto; // when modifying, this will change the state variable
        s[2] = 'XMR';
    }
}