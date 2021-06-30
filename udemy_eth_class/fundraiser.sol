pragma solidity ^0.8.0;

contract Fundraising {
    mapping(address => uint) public contributors;
    address public admin;
    uint256 public noOfContributors;
    uint256 public minimumContribution;
    uint256 public deadline;
    uint256 public goal;
    uint256 public raisedAmount = 0;
    // mapping (uint256 => Request) public requests;

    struct Request{
        string description;
        address recipient;
        uint256 value;
        bool completed;
        uint256 noOfVoters;
        mapping(address => bool) voters; // by default, every address has false values. when a contributor comes and vote, it will change to true
    }

    Request[] public requests;

    event ContributeEvent(address sender, uint256 value);
    event CreateRequestEvent(string _description, address _recipient, uint8 _value);
    event makePaymentEvent(address recipient, uint8 value);

    constructor (uint256 _goal, uint256 _deadline) { // public means you can read the contract from a dapp
        goal = _goal;
        deadline = block.timestamp + _deadline;

        admin = msg.sender;
        minimumContribution = 10000;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin);
        _;
    }

    function contribute() public payable {
        require(block.timestamp < deadline);
        require(msg.value >= minimumContribution);
        
        // increment hodler count if there is a new contributor
        if (contributors[msg.sender] == 0) {
            noOfContributors++;
        }

        contributors[msg.sender] += msg.value;
        raisedAmount += msg.value;

        emit ContributeEvent(msg.sender, msg.value);
    }

    function getContractBalance() public view returns(uint256) {
        return address(this).balance;
    }

    // if the campaign is not reached in time, the contributors can get a refund
    function getRefund() public {
        require(block.timestamp > deadline);
        require(raisedAmount < goal);
        require(contributors[msg.sender] > 0);
        
        address payable recipient = payable(msg.sender);
        uint256 value = contributors[msg.sender];

        recipient.transfer(value);
        contributors[msg.sender] = 0;
    }

    function createRequest(string memory _description, address _recipient, uint256 _value) public {
        Request memory newRequest = Request({
            description: _description,
            recipient: _recipient,
            value: _value,
            completed: false,
            noOfVoters: 0
        });

        requests.push(newRequest);
        emit CreateRequestEvent(_description, _recipient, _value);
    }

    function voteRequest(uint256 index) public {
        // the array has been stored, so it is not in short term storage
        Request storage thisRequest = requests[index];
        // values sent by msg.sender 
        require(contributors[msg.sender] > 0);
        // make sure user hasnt already voted- since the value starts out as false, need to then change it to true
        require(this.Request.voters[msg.sender] == false);

        thisRequest.voters[msg.sender] = true;
        thisRequest.noOfVoters++;
    }
    
    // transfers money ot a supplier/vendor from the admin- > 50% of people have to OK the payment before the admin can send the payment
    function makePayment(uint256 index) public onlyAdmin {
        Request storage thisRequest = requests[index]; // index of a dynamic array must be an unsigned integer
        require(thisRequest.completed == false);
        require(thisRequest.noOfVoters > noOfContributors / 2);
        thisRequest.recipient.transfer(thisRequest.value);

        thisRequest.completed = true;

        emit makePaymentEvent(thisRequest.recipient, thisRequest.value);
    }

     
}