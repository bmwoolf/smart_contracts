/**
 *Submitted for verification at BscScan.com on 2021-05-18
*/
 
/**
 *Submitted for verification at BscScan.com on 2021-05-17
*/
 
//SPDX-License-Identifier: GPL-3.0
 
pragma solidity ^0.8.4;
 
interface IERC20{
 
  function totalSupply() external view returns (uint256);
 
  function decimals() external view returns (uint256);
 
  function symbol() external view returns (string memory);
 
  function name() external view returns (string memory);
 
  function balanceOf(address account) external view returns (uint256);
 
  function transfer(address recipient, uint256 amount) external returns (bool);
 
  function allowance(address _owner, address spender) external view returns (uint256);
 
  function approve(address spender, uint256 amount) external returns (bool);
 
  function increaseAllowance(address spender, uint256 addedValue) external;
 
  function decreaseAllowance(address spender, uint256 subtractedValue) external;
 
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
 
  function burn(uint256 amount) external;
 
  event Transfer(address indexed from, address indexed to, uint256 value);
 
  event Approval(address indexed owner, address indexed spender, uint256 value); 
 
}
 
contract ERC20 is IERC20{
 
    uint256 private _deploymentBlock;
 
    address private _dev; //1%
    address private _marketing; //3%
    address private _Wallet1; //1%
    address private _Wallet2; //1%
    address private _Wallet3; //0.5%
    address private _Wallet4; //0.1%
    address private _charity; //2.5%
    address private _owner;
    //distributed : 2.5%
 
    mapping (address => uint256) private _balances;
    mapping (address => uint256) private _claimedDays;
 
    mapping (address => mapping (address => uint256)) private _allowances;
 
    mapping (uint256 => uint256) private _dayrewards;
    mapping (uint256 => uint256) private _totalSupplyOnDay;
 
    mapping (address => uint256) private _stakingBlock;
 
    uint256 private _totalSupply = 700000000000000000000000000000;
 
    string private _name = "WaterWell";
    string private _symbol = "WWT";
 
 
    constructor (address developer, address marketing, address Wallet1, address Wallet2, address Wallet3, address Wallet4, address charity) {
 
        _deploymentBlock = block.number;
        _dev = developer;
        _marketing = marketing;
        _Wallet1 = Wallet1;
        _Wallet2 = Wallet2;
        _Wallet3 = Wallet3;
        _Wallet4 = Wallet4;
        _charity = charity;
        _owner = msg.sender;
                uint256 devAmount= (_totalSupply * 10 / 1000);
        _balances[_dev] += devAmount;
         emit Transfer(msg.sender,_dev,devAmount);
 
         uint256 marketingAmount= (_totalSupply * 30 / 1000);
        _balances[_marketing] += marketingAmount;
         emit Transfer(msg.sender,_marketing,marketingAmount);
 
          uint256 wallet1Amount= (_totalSupply * 10 / 1000);
        _balances[_Wallet1] += wallet1Amount;
         emit Transfer(msg.sender,_Wallet1,wallet1Amount);
 
          uint256 wallet2Amount= (_totalSupply * 10 / 1000);
        _balances[_Wallet2] += wallet2Amount;
         emit Transfer(msg.sender,_Wallet2,wallet2Amount);
 
          uint256 wallet3Amount= (_totalSupply * 5 / 1000);
        _balances[_Wallet3] += wallet3Amount;
         emit Transfer(msg.sender,_Wallet3,wallet3Amount);
 
        uint256 wallet4Amount= (_totalSupply * 1 / 1000);
        _balances[_Wallet4] += wallet4Amount;
         emit Transfer(msg.sender,_Wallet4,wallet4Amount);
 
        uint256 deployerBalance= _totalSupply
            - devAmount
            - marketingAmount
            - wallet1Amount
            - wallet2Amount
            - wallet3Amount
            - wallet4Amount;
 
        _balances[msg.sender]=deployerBalance;
        emit Transfer(address(0),msg.sender,deployerBalance);
    }
 
    function name() external view override  returns (string memory) {
        return _name;
    }
 
    function symbol() external view override  returns (string memory) {
        return _symbol;
 
    }
    function decimals() external view override returns (uint256) {
        return 18;
    }
 
    function totalSupply() external view override  returns (uint256) {
        return _totalSupply;
    }
 
    function currentBlock() external view returns(uint256){
        return block.number;
    }
 
    function balanceOf(address user) external view override returns (uint256) {
         uint256 day = (block.number - _deploymentBlock) / 50;
         uint256 rewards;
         uint256 balance = _balances[user]; 
         for(uint256 t = _claimedDays[user]; t < day; ++t){
             rewards += _dayrewards[t] * balance / (_totalSupplyOnDay[t] + 1);
         }
         rewards += (_balances[user] * (block.number - _stakingBlock[user]) * 4 / 1000000000);  
        return _balances[user] + rewards;
    }
    function allowance(address owner, address spender) external view override returns (uint256) {
        return _allowances[owner][spender];
    }
 
    function applyFee(uint256 amount) internal returns(uint256){
        uint256 day = (block.number - _deploymentBlock + 201600) / 28800; //28800
        uint256 fee = (amount * 50) / 1000;
 
          uint256 charityAmount= (amount * 25 / 1000);
        _balances[_charity] += charityAmount;
         emit Transfer(msg.sender,_charity,charityAmount);
 
        _dayrewards[day] += (amount * 25 / 1000);
 
        _totalSupply -= (amount * 25 / 1000);
        _totalSupplyOnDay[day] = _totalSupply;
        return amount - fee;
 
    }
 
    function claimRewards(address user) internal {
        uint256 day = (block.number - _deploymentBlock + 201600) / 28800;
        uint256 rewards;
        uint256 balance = _balances[user];
        for(uint256 t = _claimedDays[user]; t < day; ++t){
            rewards += _dayrewards[t] * balance / (_totalSupplyOnDay[t] + 1);
        }
 
        _claimedDays[user] = day;
        _balances[user] += rewards;
    }
 
    function claimStakingRewards(address user) internal{
        uint256 rewards = _balances[user] * (block.number - _stakingBlock[user]) * 4 / 1000000000;  
        if(_totalSupply + rewards > 1000000000000000000000000000000) {rewards = 1000000000000000000000000000000 - _totalSupply;}
 
        _balances[user] += rewards;
        _stakingBlock[user] = block.number;
 
    }
 
  function transfer(address recipient, uint256 amount) external override returns (bool) {
 
    claimStakingRewards(msg.sender);
    claimStakingRewards(recipient);
 
    claimRewards(msg.sender);
    claimRewards(recipient);
 
    _balances[msg.sender] -= amount;
 
    uint256 _transferAmount=amount;
 
    if(msg.sender != _owner){
        _transferAmount=applyFee(amount);
    }
 
    _balances[recipient] += _transferAmount;
 
    emit Transfer(msg.sender, recipient, _transferAmount);
    return true;
  }
 
  function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
      require(_allowances[sender][msg.sender] >= amount);
 
      claimStakingRewards(msg.sender);
      claimStakingRewards(recipient);
 
      claimRewards(msg.sender);
      claimRewards(recipient);
 
      _balances[sender] -= amount;
 
       uint256 _transferAmount=amount;
 
        if(msg.sender != _owner){
            _transferAmount=applyFee(amount);
        }
      _balances[recipient] += _transferAmount;
      _allowances[sender][msg.sender] -= amount;
 
    emit Transfer(msg.sender, recipient, _transferAmount);
    return true;
  }
 
  function approve(address spender, uint256 amount) external override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, _allowances[msg.sender][spender]);   
        return true;
    }
 
  function increaseAllowance(address spender, uint256 addedValue) external override {
      _allowances[msg.sender][spender] += addedValue;
      emit Approval(msg.sender, spender, _allowances[msg.sender][spender]);      
  }
 
  function decreaseAllowance(address spender, uint256 subtractedValue) external override {
      if(subtractedValue > _allowances[msg.sender][spender]){_allowances[msg.sender][spender] = 0;}
      else {_allowances[msg.sender][spender] -= subtractedValue;}
      emit Approval(msg.sender, spender, _allowances[msg.sender][spender]);       
  }
 
  function burn(uint256 amount) external override {
 
      claimStakingRewards(msg.sender);
      claimRewards(msg.sender);
 
      _balances[msg.sender] -= amount;
      _totalSupply -= amount;
  }
 
}