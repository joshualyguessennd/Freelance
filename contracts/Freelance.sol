pragma solidity ^0.6.9;
pragma experimental ABIEncoderV2;



contract Freelance{
    address payable public freelancer;
    address payable public employer;
    uint public deadline;
    uint public price;
    bool locked = false;
    event RequestUnlocked(bool locked);
    event RequestCreated(string title, uint256 amount, bool locked, bool paid);
    event RequestPaid(address receiver, uint256 amount);

    struct Request {
        string title;
        uint256 amount;
        bool locked;
        bool paid;
    }

    Request[] public requests;

    constructor(address _freelancer, uint _deadline) payable public {
        freelance = payable(_freelancer);
        deadline = _deadline;
        employer = msg.sender;
        price = msg.value;
    }

    modifier onlyFreelancer() {
        require(msg.sender == freelancer, "Only Freelancer can do this action");
        _;
    }

    modifier onlyEmployer() {
        require(msg.sender == employer, "Only Employer can do this action");
        _;
    }


    function createRequest(string memory _title, uint256 _amount) public onlyFreelancer{
        Request memory request = Request({
            title: _title,
            amount: _amount,
            locked: true,
            paid: false,
        });
        requests.push(request);
        emit RequestCreated(_title, _amount, request.locked, request.paid);
    }

    function PayRequest(uint256 _index) public onlyFreelancer{
        require(!locked, "Reetrant detected");
        Request storage request = requests[_index];
        require(!request.locked, "Request is locked");
        require(!request.paid, "Request is already paid");

        locked = true;
        (bool success, bytes memory transactionBytes) = 
        freelancer.call{value:request.amount}('');

        request.paid = true;
        locked = false;
        emit RequestPaid(msg.sender, request.amount);
    }


    function unlockRequest(uint256 _index) public onlyEmployer{
        Request storage request = requests[_index];
        require(request.locked, "already unlocked");
        request.locked = false;

        emit RequestUnlocked(request.locked);
    }

    function getAllRequest() public view returns (Request[] memory) {
        return requests;
    }

    receive() external payable {
        price += value;
    }

    



}