//SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.0 <0.9.0;

contract CryptosToken{
    string public constant name = "Cryptos";
    uint supply;
    address public owner;

    constructor (uint256 _supply) public {
        owner = msg.sender;
        supply = _supply;
    }

    function getSupply() public view returns (uint256) { // view reduces gas fees since EVM acknowledges it as a simple getter
        return supply;
    }

    function setSupply(uint new_supply) public {
        supply = new_supply;
    } 

}