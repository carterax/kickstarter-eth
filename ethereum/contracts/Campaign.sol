pragma solidity ^0.4.17;

// The factory serves as an intermediary between our main 
// campaign contract and other users who wish to create a Campaign
// this way they pay the fees not us
contract CampaignFactory {
    address[] public deployedCampaigns;
    
    function createCampaign(uint minimum) public {
        address newCampaign = new Campaign(minimum, msg.sender);
        deployedCampaigns.push(newCampaign);
    }
    
    function getDeployedCampaigns() public view returns(address[]) {
        return deployedCampaigns;
    }
    
}

contract Campaign {
    struct Request {
        string description;
        uint value;
        address recepient;
        bool complete;
        uint approvalCount;
        mapping(address => bool) approvals;
    }
    
    Request[] public requests;
    address public manager;
    uint public minimumContribution;
    mapping(address => bool) public approvers;
    uint public approversCount;
    
    modifier restricted() {
        require(msg.sender == manager);
        _;
    }
    
    // class constructor
    function Campaign(uint minimum, address creator) public {
        // person who launches the contract first is the manager
        manager = creator;
        
        // set the minimumContribution value on instanciation
        minimumContribution = minimum;
    }
    
    // contributor function for enrolling as approvers
    function contribute() public payable {
        // check that the senders amount is above the set 
        // minimum contrubution 
        require(msg.value > minimumContribution);
        
        // add the sender to the approvers mapping
        approvers[msg.sender] = true;
        
        // increment the total number of contributors
        approversCount++;
    }
    
    // manager function for creating a request
    function createRequest(string description, uint value, address recepient) 
        public restricted 
    {
        // create a Request struct instance in memory
        // reference values are not compulsory during 
        // instanciation
        Request memory newRequest = Request({
            description: description,
            value: value,
            recepient: recepient,
            complete: false,
            approvalCount: 0
        });
        
        // add the new request to requests array
        requests.push(newRequest);
    }
    
    // contributor function for approving manager requests
    function approveRequest(uint index) public {
        // create a request var and assign at a
        // specified index a request struct in storage
        // not in memory
        Request storage request = requests[index];
        
        // check if sender is a valid contributor
        require(approvers[msg.sender]);
        
        // check if sender has approved before
        require(!request.approvals[msg.sender]);
        
        // inside the mapping property approvals in Request 
        // we set the senders address key value pair to true
        request.approvals[msg.sender] = true;
        
        // increment number of votes so far
        request.approvalCount++;
    }
    
    // manager function for finalizing a request with appropriate 
    // amount of votes from contributors, this sends out the fund to 
    // the recipient address in the address struct
    function finalizeRequest(uint index) public restricted {
        Request storage request = requests[index];
        
        // check that number of approvals is greater than 50% of approvers
        require(request.approvalCount > (approversCount / 2));
        
        // check that request hasn't been finalized before
        require(!request.complete);
        
        request.recepient.transfer(request.value);
        request.complete = true;
    }
}