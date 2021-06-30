//SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.0 <0.9.0;

contract MyTokens{
    string[] public tokens = ['BTS', 'ETH', 'BNB'];
    uint256[] public prices = [40123, 3231, 321];

    // setter method
    function changeTokens() public {
        string[] storage t = tokens; // this will update the state variable, 'memory' will not
        t[0] = 'VET';
    }
    
}