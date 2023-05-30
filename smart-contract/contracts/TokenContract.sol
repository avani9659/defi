// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.18;

import "./ERC20Interface.sol";

contract Token is ERC20Interface {
    string public name;
    string public symbol;
    uint256 public totalSupply;
    uint8 public decimals;
    address public owner;

    mapping(address => uint256) private tokenBalances;
    mapping(address => mapping(address => uint256)) public allowed; //this will help us enable transferFrom() in the interface

    constructor(
        uint256 _initialAmount,
        string memory _tokenName,
        uint8 _decimalUnits,
        string memory _tokenSymbol
    ) {
        name = _tokenName;
        symbol = _tokenSymbol;
        decimals = _decimalUnits;
        totalSupply = _initialAmount * (10 ** uint8(decimals)); //since ethereum does not allow decimals, we store the number without decimal and then display it by dividing by the decimalUnits
        tokenBalances[msg.sender] = totalSupply;
        owner = msg.sender;
    }

    function transfer(
        address _to,
        uint256 _value
    ) public override returns (bool success) {
        require(tokenBalances[msg.sender] >= _value, "Insufficient balance");

        tokenBalances[msg.sender] = tokenBalances[msg.sender] - _value;
        tokenBalances[_to] = tokenBalances[_to] + _value;

        emit Transfer(msg.sender, _to, _value);

        return true;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public override returns (bool success) {
        require(
            allowance(_from, msg.sender) >= _value,
            "Insufficient allowance"
        );
        require(tokenBalances[_from] >= _value, "Insufficient balance");

        tokenBalances[_to] = tokenBalances[_to] + _value;
        tokenBalances[_from] = tokenBalances[_from] - _value;
        allowed[_from][msg.sender] = allowed[_from][msg.sender] - _value;

        emit Transfer(_from, _to, _value);

        return true;
    }

    //allow someone else to spend tokens on my behalf (give them approval)
    function approve(
        address _sender,
        uint256 _value
    ) public override returns (bool success) {
        require(balanceOf(msg.sender) >= _value, "Insuffient balance");

        allowed[msg.sender][_sender] = _value;

        emit Approval(msg.sender, _sender, _value);

        return true;
    }

    function allowance(
        address _owner,
        address _spender
    ) public view override returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    function balanceOf(
        address _owner
    ) public view override returns (uint256 balance) {
        return tokenBalances[_owner];
    }
}
