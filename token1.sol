// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

//interface do token

interface ERC20Interface {
    function totalSupply()external view returns (uint);
    function balanceOf(address tokenOwner) external view returns (uint balance);
    function allowance(address tokenOwner, address spender) external view returns (uint remaining);

    function transfer(address to, uint tokens) external returns (bool success);
    function approve(address spender, uint tokens) external returns (bool success);
    function transferFrom(address from, address to, uint tokens) external returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

//função do contrato de receber aprovação e executar a função
contract ApproveAndCallFallBack{
    function receiveApproval(address from, uint256 tokens, address token, bytes data) public;
}


//token contract

contract IAToken is ERC20Interface, SafeMath{
    string public symbol;
    string public  name;
    uint8 public decimals;
    uint public _totalSupply;
 
    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;
 
    constructor() {
        symbol = "IA";
        name = "IA Coin";
        decimals = 2;
        _totalSupply = 1000000;
        balances[0xBE52448ca5165C6C5cA40d3D07E127a083F7D6ff] = _totalSupply;
        emit Transfer(address(0), 0xBE52448ca5165C6C5cA40d3D07E127a083F7D6ff, _totalSupply);
    }

     function totalSupply() public constant returns (uint) {
        return _totalSupply - balances[address(0)];
    }

     function balanceOf(address tokenOwner) public constant returns (uint balance) {
        return balances[tokenOwner];
    }

    function transfer(address to, uint tokens) public override returns (bool success) {
        require(tokens <= balances[msg.sender]);

        balances[msg.sender] = safeSub([msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        emit Transfer(msg.sender, to, tokens);
        return true;
    }

    function approve(address spender, uint256 tokens) public override returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }

  function allowance(address tokenOwner, address spender) public override view returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }

     function transferFrom(address from, address to, uint256 tokens) public override returns (bool success) {
        require(tokens <= balances[msg.sender]);
        require(tokens <= allowed[from][msg.sender]);

        balances[from] = balances[from] - tokens;
        allowed[from][msg.sender] = allowed[from][msg.sender] - tokens;
        balances[to] = balances[to] + tokens;
        emit Transfer(from, to, tokens);
        return true;
    }

    function approveAndCall(address spender, uint tokens, bytes data) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, this, data);
        return true;
    }

    function () public payable{
        revert();
    }
}
