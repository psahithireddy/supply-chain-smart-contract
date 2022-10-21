pragma solidity >=0.8.16;

import {MarketPlace_Events} from "./MarketPlace_Events.sol";

contract MarketPlace_Bidding is MarketPlace_Events {
    // @notice Transfer money to address
    // @param senderaddr Wallet address of the person to send money to
    // @param effectivePrice Amount to send
    function transferMoney(address senderaddr, uint256 effectivePrice)
        public
        payable
    {
        // do eth transactions here
        require(payable(senderaddr).send(effectivePrice), "Transfer failed!");
    }

    // @notice Supplier start their auction here
    // @param tag Tag ID of the supplier
    function supplierStartAuction(uint256 tag) public returns (uint256) {
        require(tag <= num_supplier, "User doesn't exist");
        require(
            suppliers[tag].currentState != AuctionState.RUNNING,
            "Auction in-progress already"
        );

        // TODO: UNCOMMENT THE FOLLOWING TO ENSURE PEOPLE ARE STARTING AUCTIONS FOR THEMSELVES ONLY
        // require(
        //     suppliers[tag].wallet == msg.sender,
        //     "Start auction only for yourself!"
        // );

        suppliers[tag].currentState = AuctionState.RUNNING;
        suppliers[tag].bidsPlaced = 0;
        suppliers[tag].bidsRevealed = 0;
        emit StartSupplierAuction(tag, block.timestamp);
        return block.timestamp;
    }

    // @notice Supplier end their auction here
    // @param tag Tag ID of the supplier
    function supplierEndAuction(uint256 tag) public returns (uint256) {
        // function for suppilier to end their auction
        require(tag <= num_supplier, "User doesn't exist");
        require(
            suppliers[tag].currentState == AuctionState.RUNNING,
            "Auction ended already"
        );

        // TODO: UNCOMMENT THE FOLLOWING TO ENSURE PEOPLE ARE ENDING AUCTIONS FOR THEMSELVES ONLY
        // require(
        //     suppliers[tag].wallet == msg.sender,
        //     "End auction only for yourself!"
        // );

        suppliers[tag].currentState = AuctionState.REVEALING;
        suppliers[tag].bidsRevealed = 0;
        emit EndSupplierAuction(tag, block.timestamp);
        return block.timestamp;
    }

    // @notice Supplier end their reveal phase and allocate resources
    // @param tag Tag ID of the supplier
    function supplierEndReveal(uint256 tag)
        public
        returns (
            // afterOnly(supplierEndAuction(tag))
            uint256
        )
    {
        require(tag <= num_supplier, "Supplier doesn't exist");
        require(
            suppliers[tag].currentState == AuctionState.REVEALING,
            "Reveal phase not running"
        );

        // TODO: UNCOMMENT THE FOLLOWING TO ENSURE PEOPLE ARE ALLOCATING FOR THEMSELVES ONLY
        // require(
        //     (suppliers[tag].wallet == msg.sender || owner == msg.sender),
        //     "Operation now allowed"
        // );

        suppliers[tag].currentState = AuctionState.FINISHED;

        // do allocation logic and emit

        // bubble sort according to bid value
        for (uint256 i = 0; i < bidsTillNow[suppliers[tag].wallet].length; i++)
            for (uint256 j = 0; j < i; j++)
                if (
                    bidsTillNow[suppliers[tag].wallet][i].valuePrice <
                    bidsTillNow[suppliers[tag].wallet][j].valuePrice
                ) {
                    Bid memory x = bidsTillNow[suppliers[tag].wallet][i];
                    bidsTillNow[suppliers[tag].wallet][i] = bidsTillNow[
                        suppliers[tag].wallet
                    ][j];
                    bidsTillNow[suppliers[tag].wallet][j] = x;
                }
        // allocate according to limiting resource first
        uint256[100] memory allocatingPrices;
        uint256[100] memory allocatingQuantities;
        uint256[100] memory moneySentWithBid;

        for (
            uint256 i = 0;
            i < bidsTillNow[suppliers[tag].wallet].length;
            i++
        ) {
            Bid memory bid = bidsTillNow[suppliers[tag].wallet][i];
            if (bid.correctReveal == false) continue;

            moneySentWithBid[bid.buyerID] = bid.moneySent;

            uint256 allocatingHere = minimum(
                suppliers[tag].quantityAvailable,
                bid.limitingResourceQuantity
            );
            allocatingHere = minimum(allocatingHere, bid.valueQuantity);

            allocatingPrices[bid.buyerID] = bid.valuePrice;
            allocatingQuantities[bid.buyerID] = allocatingHere;
            suppliers[tag].quantityAvailable -= allocatingHere;
            bidsTillNow[suppliers[tag].wallet][i]
                .valueQuantity -= allocatingHere;
        }

        // allocate remaining for maximum profit
        for (
            uint256 i = 0;
            i < bidsTillNow[suppliers[tag].wallet].length;
            i++
        ) {
            Bid memory bid = bidsTillNow[suppliers[tag].wallet][i];
            if (bid.correctReveal == false) continue;

            uint256 allocatingHere = minimum(
                suppliers[tag].quantityAvailable,
                bid.valueQuantity
            );

            allocatingQuantities[bid.buyerID] += allocatingHere;
            suppliers[tag].quantityAvailable -= allocatingHere;
            bidsTillNow[suppliers[tag].wallet][i]
                .valueQuantity -= allocatingHere;
        }

        // emit all allocations
        for (uint256 i = 1; i <= num_manufacturer; i++)
            if (allocatingQuantities[i] > 0) {
                emit AllocateFromSupplier(
                    tag,
                    i,
                    allocatingQuantities[i],
                    allocatingPrices[i]
                );
                transferMoney(
                    manufacturers[i].wallet,
                    (moneySentWithBid[i] -
                        allocatingPrices[i] *
                        allocatingQuantities[i])
                );
                transferMoney(
                    suppliers[tag].wallet,
                    (allocatingPrices[i] * allocatingQuantities[i])
                );
                //update all the manufacturers quanitites to make cars
                if (suppliers[tag].partType == 1)
                    updateManufacturerQuantities(
                        i,
                        allocatingQuantities[i],
                        0,
                        tag,
                        0
                    );
                else if (suppliers[tag].partType == 2)
                    updateManufacturerQuantities(
                        i,
                        0,
                        allocatingQuantities[i],
                        0,
                        tag
                    );
                else revert();
            }
        while (bidsTillNow[suppliers[tag].wallet].length > 0)
            bidsTillNow[suppliers[tag].wallet].pop();
        return block.timestamp;
    }

    // @notice Manufacturer place their bids
    // @param manufacturerID Tag ID of the manufacturer
    // @param supplierID Tag ID of the supplier
    // @param blindPrice Bidding price blinded using encryption
    // @param blindQuantity Bidding quantity blinded using encryption
    // @param limit Limiting resource of the manufacturer
    function manufacturerPlacesBid(
        uint256 manufacturerID,
        uint256 supplierID,
        bytes32 blindPrice,
        bytes32 blindQuantity,
        uint256 limit
    ) public payable {
        require(
            num_manufacturer >= manufacturerID,
            "Manufacturer doesn't exist"
        );
        require(num_supplier >= supplierID, "Supplier doesn't exist");
        require(
            suppliers[supplierID].currentState == AuctionState.RUNNING,
            "Supplier isn't running an auction right now"
        );
        require(
            supplierID == manufacturerID || supplierID == 3,
            "Supplier doesnt sell you"
        );

        // TODO: UNCOMMENT THE FOLLOWING TO ENSURE PEOPLE ARE ONLY PLACING BIDS FOR THEMSELVES
        // require(
        //     manufacturers[manufacturerID].wallet == msg.sender,
        //     "You can only bid for yourself!"
        // );

        Bid memory newbid;
        newbid.bidderAddress = payable(msg.sender);
        newbid.moneySent = msg.value;
        newbid.buyerID = manufacturerID;
        newbid.sellerID = supplierID;
        newbid.blindBidPrice = blindPrice;
        newbid.blindBidQuantity = blindQuantity;
        newbid.limitingResourceQuantity = limit;
        newbid.valuePrice = 0;
        newbid.valueQuantity = 0;
        newbid.correctReveal = false;

        address supplieraddr = suppliers[supplierID].wallet;
        bidsTillNow[supplieraddr].push(newbid);

        suppliers[supplierID].bidsPlaced += 1;

        emit ManufacturerBids(
            supplierID,
            manufacturerID,
            blindPrice,
            blindQuantity
        );
    }

    // @notice Manufacturer reveal their bids
    // @param manufacturerID Tag ID of the manufacturer
    // @param supplierID Tag ID of the supplier
    // @param price Bidding price
    // @param quantity Bidding quantity
    function manufactuerRevealBid(
        uint256 manufacturerID,
        uint256 supplierID,
        uint256 price,
        uint256 quantity
    ) public returns (bool) {
        require(manufacturerID <= num_manufacturer, "Invalid manufacturer");
        require(suppliers[supplierID].currentState == AuctionState.REVEALING);
        // TODO: UNCOMMENT THE FOLLOWING TO ENSURE PEOPLE ARE ONLY REVEALING BIDS FOR THEMSELVES
        // require(
        //     manufacturers[manufacturerID].wallet == msg.sender,
        //     "Reveal only for yourself!"
        // );

        for (
            uint256 i = 0;
            i < bidsTillNow[suppliers[supplierID].wallet].length;
            i++
        )
            if (
                bidsTillNow[suppliers[supplierID].wallet][i].buyerID ==
                manufacturerID
            ) {
                require(
                    keccak256(abi.encodePacked(price)) ==
                        bidsTillNow[suppliers[supplierID].wallet][i]
                            .blindBidPrice,
                    "Incorrect price -- keeping your money"
                );
                require(
                    keccak256(abi.encodePacked(quantity)) ==
                        bidsTillNow[suppliers[supplierID].wallet][i]
                            .blindBidQuantity,
                    "Incorrect quantity -- keeping your money"
                );

                uint256 effectivePrice = price * quantity;
                require(
                    effectivePrice <=
                        bidsTillNow[suppliers[supplierID].wallet][i].moneySent,
                    "Insufficient funds sent -- keeping your money"
                );

                bidsTillNow[suppliers[supplierID].wallet][i]
                    .correctReveal = true;

                bidsTillNow[suppliers[supplierID].wallet][i].valuePrice = price;
                bidsTillNow[suppliers[supplierID].wallet][i]
                    .valueQuantity = quantity;
                emit ManufacturerReveal(
                    supplierID,
                    manufacturerID,
                    price,
                    quantity
                );

                suppliers[supplierID].bidsRevealed += 1;
                return true;
            }
        return false;
    }

    // @notice Updates quantities for manufacturers including cars
    // @param manufacturerID Tag ID of the manufacturer
    // @param quantityA Quantity of product A
    // @param quantityB Quantitu of product B
    // @param supplierA Supplier of product A
    // @param supplierB Supplier of product B
    function updateManufacturerQuantities(
        uint256 manufacturerID,
        uint256 quantityA,
        uint256 quantityB,
        uint256 supplierA,
        uint256 supplierB
    ) private {
        manufacturers[manufacturerID].quantityA += quantityA;
        manufacturers[manufacturerID].quantityB += quantityB;
        uint256 max_cars = minimum(
            manufacturers[manufacturerID].quantityA,
            manufacturers[manufacturerID].quantityB
        );
        manufacturers[manufacturerID].quantityA -= max_cars;
        manufacturers[manufacturerID].quantityB -= max_cars;
        manufacturers[manufacturerID].cars += max_cars;

        Product memory newcar;
        num_products++;
        newcar.tag = num_products;
        newcar.manufacturerID = manufacturerID;
        newcar.sellerA = manufacturerID;
        newcar.sellerB = 3;
        productsTillNow[manufacturers[manufacturerID].wallet].push(newcar);
    }

    function supplierAddQuantity(uint256 suppliedID, uint256 quantityToAdd)
        public
    {
        require(suppliers[suppliedID].wallet == msg.sender);
        require(num_supplier >= suppliedID);
        // increase the supplier quantity
        suppliers[suppliedID].quantityAvailable += quantityToAdd;
    }

    function set_cars_price(uint256 manufacturerID, uint256 price) public {
        require(
            msg.sender == manufacturers[manufacturerID].wallet ||
                msg.sender == owner,
            "Cannot be set by you"
        );
        manufacturers[manufacturerID].carsprice = price;
    }

    modifier beforeOnly(uint256 _time) {
        require(block.timestamp < _time);
        _;
    }
    modifier afterOnly(uint256 _time) {
        require(block.timestamp > _time);
        _;
    }
}
