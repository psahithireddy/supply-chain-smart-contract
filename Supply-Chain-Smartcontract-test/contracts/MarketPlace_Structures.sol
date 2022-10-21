pragma solidity >=0.8.16;

contract MarketPlace_Structures {
    address payable public owner;

    // @dev State of the auction
    // @param RUNNING auction is running and bids are being places
    // @param REVEALING auction has ended and bidders are revealing their bids
    // @param NOT_STARTED auction hasn't started yet
    // @param FINISHED auction has finished
    enum AuctionState {
        RUNNING,
        REVEALING,
        NOT_STARTED,
        FINISHED
    }

    // @dev Stores details of the bids
    struct Bid {
        uint256 valuePrice;
        uint256 valueQuantity;
        address payable bidderAddress;
        bytes32 blindBidPrice;
        bytes32 blindBidQuantity;
        uint256 limitingResourceQuantity;
        uint256 buyerID;
        uint256 sellerID;
        uint256 moneySent;
        bool correctReveal;
    }

    // @dev Stores details of purchases requested
    struct Purchase {
        uint256 sellerID;
        uint256 buyerID;
        uint256 quantity;
        address payable customeraddr;
        uint256 money;
    }

    // @dev Stores details of successful purchases or products bought
    struct Product {
        uint256 tag;
        uint256 manufacturerID;
        uint256 sellerA;
        uint256 sellerB;
    }

    // @dev Stores details of all the suppliers
    // @note partType is 0 for wheels and 1 for car parts
    struct Supplier {
        uint256 tag;
        int256 partType; // 0 is wheels, 1 is car_parts
        uint256 quantityAvailable;
        AuctionState currentState;
        address wallet;
        uint256 maxBidders;
        uint256 bidsPlaced;
        uint256 bidsRevealed;
    }

    // @dev Stores details of all the manufacturers
    struct Manufacturer {
        uint256 _tag;
        uint256 quantityA;
        uint256 quantityB;
        uint256 cars;
        uint256 carsprice;
        AuctionState currentState;
        address wallet;
        uint256 maxBidders;
        uint256 QA_sellerID;
        uint256 QB_sellerID;
    }

    // @dev Stores details of all the cars developed
    struct Car {
        uint256 tag;
        uint256 manufacturerID;
        uint256 sellerIDA;
        uint256 sellerIDB;
    }

    // @dev Stores details of all the customers
    struct Customer {
        uint256 _tag;
        address wallet;
    }

    // @dev Returns minimum of 2 uint256 integers
    function minimum(uint256 a, uint256 b) public pure returns (uint256) {
        return a >= b ? b : a;
    }
}
