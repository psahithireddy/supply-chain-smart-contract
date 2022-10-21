pragma solidity >=0.8.16;

contract FirstAuction {
    struct Bid {
        uint256 valuePrice;
        uint256 valueQuantity;
        address payable bidderAddress;
        bytes32 blindBidPrice; // will have price and quantity you are bidding  
        bytes32 blindBidQuantity;
        uint limitingResourceQuantity;
    }
    uint totalBidders = 0;
    uint bidsTillNow = 0;

    mapping (address => Bid) bids;

    function setBidders(uint bidders) public {
        totalBidders = bidders;
    }

    function makeBid(bytes32 blindPrice, bytes32 blindQuantity, address bidder, uint limitingResource) public {
        bids[bidder] = Bid(0, 0, payable(bidder), blindPrice, blindQuantity, limitingResource);
    }

    function revealBid(uint bidPrice, uint bidQuantity) public {

    }

}