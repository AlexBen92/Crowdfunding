pragma solidity ^0.8.0;

contract Funding {
    address payable public owner;
    uint public finishesAt;
    uint public goal;
    uint public raised;
    mapping (address => uint) public balances;
    

    constructor(uint _duration, uint _goal) public {
      owner = msg.sender;
      finishesAt = now + _duration;
      goal = _goal;
    }

    modifier onlyOwner() {
          require(owner == msg.sender, "You must be the owner");
          _;
      }

    modifier onlyFunded() {
        require(isFunded(), "Not funded");
        _;
    }

    modifier onlyNotFunded() {
        require(!isFunded(), "Is funded");
        _;
    }

    modifier onlyNotFinished() {
        require(!isFinished(), "Donation window already finished.");
        _;
    }

    modifier onlyFinished() {
        require(isFinished(), "Donation window is not finished/timed out");
        _;
    }

    function refund() public onlyFinished onlyNotFunded {
        uint amount = balances[msg.sender];
        require(amount > 0, "Not enough balance to transfer");

        balances[msg.sender] = 0;
        msg.sender.transfer(amount);
    }

    function isFinished() public view returns(bool) {
        return finishesAt <= now;
    }

    function donate() public onlyNotFinished payable {
        balances[msg.sender] += msg.value;
        raised += msg.value;
    }

    function isFunded() view public returns (bool) {
        return raised >= goal;
    }

    function withdraw() public onlyOwner onlyFunded {
        owner.transfer(address(this).balance);
         
    }

}