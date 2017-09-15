pragma solidity ^0.4.11;


import "zeppelin-solidity/contracts/token/StandardToken.sol";
import "zeppelin-solidity/contracts/ownership/Ownable.sol";


contract Token is StandardToken, Ownable {
    string public name;
    string public symbol;
    uint8 public decimals;

    function Token(
        string _name,
        string _symbol,
        uint8 _decimals,
        uint256 _totalSupply
        ) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        totalSupply = _totalSupply;
        balances[msg.sender] = totalSupply;
        owner = msg.sender;
    }
}