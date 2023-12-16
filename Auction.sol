// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

contract Auction {

    address public owner;
    uint public start;
    uint public end;
    uint public highestBid = 0;
    address public highestBidder;
    uint public previousHighestBid = 0;
    bool public cancel = false;

    //constructor(uint days) {
    constructor(uint mins) {
        owner = msg.sender;
        //start = toTimestamp(14, 12, 2023, 0, 0) + 5 hours;
        //end = toTimestamp(14, 12, 2023, 13, 0) + 5 hours;
        start = block.timestamp;
        end = block.timestamp + mins * 1 minutes;
        //end = block.timestamp + days * 1 days;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "You do not have permission to call this function");
        _;
    }

    modifier validTime() {
        //require(block.timestamp >= start && block.timestamp <= end, "Auction is not active");
        require(block.timestamp >= start, "Auction has not started");
        require(block.timestamp <= end, "Auction has ended");
        _;
    }

    function getCurrentTime() public view returns (uint) {
        return block.timestamp;
    }

    // Function to convert human-readable date to Unix timestamp
    function toTimestamp(uint day, uint month, uint year, uint hour, uint minute) public pure returns (uint) {
        return
            (year - 1970) * 365 days +
            (year - 1969) / 4 days -
            (year - 1901) / 100 days +
            (year - 1601) / 400 days +
            (month * 306001) / 10000 +
            day * 86400 +
            hour * 3600 +
            minute * 60;
    }

    //Cancel auction, only owner has the right. 
    function cancelAuction() public onlyOwner validTime{
        cancel = true;
        end = block.timestamp;
        highestBindingBid = 0;
        highestBidder = address(0);
    }

    mapping(address => uint) public bids;
    uint public numberOfBids;
    address[] public highestBidders;
    uint public l = highestBidders.length;

    /*function placeBid() payable public validTime{
        require(msg.sender != owner, "Owner can not bid in their own auction");
        require(msg.value > 0, "Invalid value for bidding");
        require(msg.value >= highestBid, "Invalid bid, a higher bid exists");
        previousHighestBid = highestBid;
        highestBid = msg.value;
        highestBidder = msg.sender;
        if(bids[msg.sender] > 0){
            payable(msg.sender).transfer(bids[msg.sender]);
        }
        bids[msg.sender] = msg.value;
        numberOfBids++;
    }*/

    function placeBid() payable public validTime {
        require(msg.sender != owner, "Owner can not bid in their own auction");
        require(msg.value > 0, "Invalid value for bidding");
        require(msg.value >= highestBid, "Invalid bid, a higher bid exists");

        if (msg.value > highestBid) {
            highestBidders = new address[](0);
            highestBidders.push(msg.sender);
            highestBid = msg.value;
        } 
        else if (msg.value == highestBid) {
            highestBidders.push(msg.sender);
        }

        if (bids[msg.sender] > 0) {
            payable(msg.sender).transfer(bids[msg.sender]);
        }

        bids[msg.sender] = msg.value;
        numberOfBids++;
    }


    uint public highestBindingBid;

    uint public increment; 

    /*function finalizeAuction() public onlyOwner{
        require(cancel == false, "Auction has been cancelled");
        require(block.timestamp >= end, "Auction is still in progress");
        require(numberOfBids > 0, "No bids available");
        increment = (highestBid-previousHighestBid)/2;
        highestBindingBid = previousHighestBid + increment;
        payable(owner).transfer(highestBindingBid);
    }*/

    function finalizeAuction() public onlyOwner {
        require(cancel == false, "Auction has been cancelled");
        require(block.timestamp >= end, "Auction is still in progress");
        require(numberOfBids > 0, "No bids available");

        //uint pseudoRandom = uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, highestBidders)));
        uint pseudoRandom = uint(keccak256(abi.encodePacked(block.timestamp, highestBidders.length)));
        uint selectedBidderIndex = pseudoRandom % highestBidders.length-1;
        address selectedBidder = highestBidders[selectedBidderIndex];

        payable(owner).transfer(bids[selectedBidder]);

        highestBidder = selectedBidder;
    }


    function withdrawAmount() public {
        require(block.timestamp >= end, "Auction is still in progress");
        require(bids[msg.sender] > 0, "No bid to withdraw");
        require(msg.sender != highestBidder, "You are the winner");
        //if(msg.sender == highestBidder) {
            //payable(msg.sender).transfer(bids[msg.sender]-highestBindingBid);
            //bids[msg.sender] = 0;
        //}
        //else {
            payable(msg.sender).transfer(bids[msg.sender]);
            bids[msg.sender] = 0;
        //}
    }

}