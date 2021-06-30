// ERC20 is a layer between applications and tokens
//SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0;

// must have 6 functions and 2 specific events to be fully ERC20 compliant
interface ERC20Interface {
    function totalSupply() external view returns (uint);
    function balanceOf(address tokenOwner) external view returns (uint balance);
    function transfer(address to, uint tokens) external returns (bool success);

    function allowance(address tokenOwner, address spender) external view returns (uint remaining);
    function approve(address spender, uint tokens) external returns (bool success);
    function transferFrom(address from, address to, uint tokens) external returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract Token is ERC20Interface {
    string public name = "TokenName";
    string public symbol = "TN";
    uint public decimals = 18;
    uint public override totalSupply;

    address public founder;
    mapping(address => uint) public balances;

    mapping(address => mapping(address => uint)) allowed; // last word is the variable name

    constructor() {
        totalSupply = 1000000;
        founder = msg.sender;
        balances[founder] = totalSupply;
    }

    function balanceOf(address tokenOwner) public view override returns (uint balance) {
        return balances[tokenOwner];
    }

    // virtual means that a child contract can override the parent functions 
    function transfer(address to, uint tokens) public virtual override returns (bool success) {
        // on failure, revert. no need to return false
        require(balances[msg.sender] >= tokens);
        balances[to] += tokens;
        balances[msg.sender] -= tokens;
        emit Transfer(msg.sender, to, tokens);

        return true;
    }

    function allowance(address tokenOwner, address spender) view public override returns(uint) {
        // allowed[Brad][pancake_swap]
        return allowed[tokenOwner][spender];
    }

    // called by tokenOwner that sets the amount that spender can spend on their behalf
    function approve(address spender, uint tokens) public override returns (bool success) {
         require(balances[msg.sender] >= tokens);
         require(tokens > 0);

         allowed[msg.sender][spender] = tokens;
         
         emit Approval(msg.sender, spender, tokens);
         return true;
    }

   function transferFrom(address from, address to, uint tokens) public virtual override returns (bool success) {
       require(allowed[from][to] >= tokens);
       require(balances[from] >= tokens);

       balances[from] -= tokens;
       balances[to] += tokens;

       allowed[from][to] -= tokens;

       return true;
   } 
}

// Brad wants to allow PS to spend 2 of his 35 BNB tokens
// Brad will call approve(address pancake_swap, uint amount)
// allowed[address Brad][address pancake_swap] = 2;
// if Pancake Swap wants to transfer 30 BNB tokens from Brad to PancakeSwap, PancakeSwap will execute the transferFrom(address Brad, addresss pancake_swap, 30)
        // how does it know which token to choose from Brad's wallet?


contract ICO is Token {
    address public admin;
    address payable public deposit;
    uint tokenPrice = 0.001 ether; // 1 eth = 1000 test tokens
    uint public hardCap = 300 ether;
    uint public raisedAmount;
    uint public saleStart = block.timestamp; 
    uint public saleEnd = block.timestamp + 604800; // deployment time + 1 week
    uint public tokenTradeStart = saleEnd + 604800; // they can sell a week after the sale ends
    uint public maxInvestment = 5 ether;
    uint public minInvestment = 0.1 ether;
    
    enum State { beforeStart, running, afterEnd, halted }
    State public icoState;

    constructor(address payable _deposit) {
        deposit = _deposit;
        admin = msg.sender;
        icoState = State.beforeStart;
    }

    modifier onlyAdmin() { // what is a modifier?
        require(msg.sender == admin);
        _; // why do they put lines like this?
    }

    function halt() public onlyAdmin{ // stop ICO if there is an emergency
        icoState = State.halted;
    }

    function resume() public onlyAdmin{
        icoState = State.running;
    }

    function changeDepositAddress(address payable newDeposit) public onlyAdmin{
        deposit = newDeposit;
    }

    function getCurrentState() public view returns(State){
        if (icoState == State.halted) {
            return State.halted;
        } else if (block.timestamp < saleStart) {
            return State.beforeStart;
        } else if (block.timestamp >= saleStart && block.timestamp <= saleEnd){
            return State.running;
        } else {
            return State.afterEnd;
        }
    }

    event Invest(address investor, uint value, uint tokens);

    // main function
    function invest() payable public returns(bool) {
        icoState = getCurrentState();
        require(icoState == State.running);
        
        require(msg.value >= minInvestment && msg.value <= maxInvestment);
        raisedAmount += msg.value;
        require(raisedAmount <= hardCap);

        uint tokens = msg.value;

        balances[msg.sender] += tokens;
        balances[founder] -= tokens;
        deposit.transfer(msg.value);
    }

    // this will be called when someone sends ETH directly to the contract address
    receive() payable external{
        invest();
    }

    function transfer(address to, uint tokens) public override returns(bool success) {
        require(block.timestamp > tokenTradeStart);
        Token.transfer(to, tokens);
        return true;
    }

    function transferFrom(address from, address to, uint tokens) public virtual override returns (bool success) {
        require(block.timestamp > tokenTradeStart);
        Token.transferFrom(from, to, tokens);
        return true;
    }

    function burn() public returns(bool){
        icoState = getCurrentState();
        require(icoState == State.afterEnd);
        balances[founder] = 0;
        return true;
    }
}