// SPDX-License-Identifier: MIT
pragma solidity >=0.8.16;
pragma experimental ABIEncoderV2;

/// @title New Market Place
/// @author Kunal Jain, P. Sahithi Reddy, Prince Varshney
/// @notice Market place implementation
contract NewMarketPlace {
    /// @dev Enum for the state of the auction the supplier is in
    /// @dev NOT_RUNNING : Auction is not running right now
    /// @dev BIDDING : Bidding phase of auction is going on
    /// @dev REVEALING : Reveal phase of auction is going on
    enum AuctionState {
        NOT_RUNNING,
        BIDDING,
        REVEALING
    }

    /// @dev Enum for the part type
    enum PartType {
        WHEEL,
        BODY
    }

    /// @dev Stores the details of the supplier
    struct Supplier {
        uint256 tag;
        PartType partType; // part type they are selling
        uint256 quantityAvailable; // quantity of the part available
        AuctionState currentState; // currest state of the auction
        address wallet; // wallet address
        uint256 maxBidders; // max bidders that can participate in the auction
        uint256 bidsPlaced; // bids that have been placed
        uint256 bidsRevealed; // bids that have been revealed
    }

    /// @notice Check whether user is supplier or not
    /// @return bool True if sender is supplier, false otherwise
    function isSupplier() public view returns (bool) {
        for (uint256 i = 1; i <= num_supplier; i++) {
            if (suppliers[i].wallet == msg.sender) return true;
        }
        return false;
    }

    /// @notice Check whether user is customer or not
    /// @return bool True if sender is customer, false otherwise
    function isCustomer() public view returns (bool) {
        for (uint256 i = 1; i <= num_customer; i++) {
            if (customers[i].wallet == msg.sender) return true;
        }
        return false;
    }

    /// @notice Get number of suppliers
    /// @return uint256 Number of suppliers
    function numSuppliers() public view returns (uint256) {
        return num_supplier;
    }

    /// @notice Get supplier details by their ID
    /// @dev partType is 0 for body and 1 for wheels
    /// @param id ID of the supplier
    /// @return tag ID of the supplier
    /// @return partType Part type the are selling
    /// @return quantityAvailable Quantity available with the supplier
    /// @return wallet Wallet address
    function getSupplierByID(uint256 id)
        public
        view
        returns (
            uint256 tag,
            uint256 partType,
            uint256 quantityAvailable,
            address wallet
        )
    {
        uint256 retType = 1;
        if (suppliers[id].partType == PartType.WHEEL) retType = 0;
        return (
            suppliers[id].tag,
            retType,
            suppliers[id].quantityAvailable,
            suppliers[id].wallet
        );
    }

    // function getAllSuppliers() public view returns (Supplier[] memory) {
    //     return allSuppliers;
    // }

    /// @dev Stores the details of the manufacturer
    struct Manufacturer {
        uint256 tag;
        uint256 wheelSupplier; // tag of supplier who supplies wheels
        uint256 wheelQuant; // number of wheels
        uint256 bodySupplier; // tag of supplier who supplies body
        uint256 bodyQuant; // number of bodies
        uint256 carsAvailable; // number of cars available
        uint256 carPrice; // price of the cars
        address wallet; // wallet address
    }

    /// @notice Check whether user is manufacturer or not
    /// @return bool True if sender is manufacturer, false otherwise
    function isManufacturer() public view returns (bool) {
        for (uint256 i = 1; i <= num_manufacturer; i++) {
            if (manufacturers[i].wallet == msg.sender) return true;
        }
        return false;
    }

    /// @dev Stores the details of the cars sold
    struct Car {
        uint256 tag;
        uint256 customerID;
        uint256 manufacturerID;
        uint256 wheelSupID;
        uint256 bodySupID;
    }

    /// @dev Stores the detail of the customer
    struct Customer {
        uint256 tag;
        address wallet;
    }

    /// @dev stores the details of the bids
    struct Bid {
        uint256 actualPrice;
        uint256 actualQuantity;
        uint256 actualKey;
        bytes32 blindPrice;
        bytes32 blindQuantity;
        bytes32 blindKey;
        uint256 limitingQuantity;
        uint256 buyerID;
        uint256 sellerID;
        uint256 moneySent;
        bool correctReveal;
        address payable bidderAddress;
    }

    /// @dev wallet address of the contract owner
    address payable public owner;

    mapping(uint256 => Supplier) public suppliers;
    mapping(uint256 => Manufacturer) public manufacturers;
    mapping(uint256 => Customer) public customers;
    mapping(uint256 => Car[]) cars;
    mapping(address => Bid[]) bidsTillNow;

    uint256 num_supplier;
    uint256 num_manufacturer;
    uint256 num_customer;
    uint256 num_cars;

    // Supplier[] allSuppliers;

    /// @notice Triggered when a supplier starts their bidding phase
    /// @param tag Tag of the supplier
    /// @param timestamp Block height when bidding phase starts
    event StartSupplierBidding(uint256 tag, uint256 timestamp);

    /// @notice Triggered when a supplier starts their reveal phase
    /// @param tag Tag of the supplier
    /// @param timestamp Block height when reveal phase starts
    event StartSupplierReveal(uint256 tag, uint256 timestamp);

    /// @notice Triggered when a supplier suppliers parts to a manufacturer
    /// @param supplierID Tag of the supplier
    /// @param manufacturerID Tag of the manufacturer
    /// @param quantity Quantities supplier
    /// @param price Price per unit
    event AllocateFromSupplier(
        uint256 supplierID,
        uint256 manufacturerID,
        uint256 quantity,
        uint256 price
    );

    /// @notice Triggered when a manufacturer places a bid
    /// @param manufacturerID Tag of the manufacturer
    /// @param supplierID Tag of the supplier
    /// @param blindPrice Hash of (Price + Key)
    /// @param blindQuantity Hash of (Quantity + Key)
    /// @param blindKey Hash of Key
    event ManufacturerBids(
        uint256 manufacturerID,
        uint256 supplierID,
        bytes32 blindPrice,
        bytes32 blindQuantity,
        bytes32 blindKey
    );

    /// @notice Triggered when a manufacturer reveals a bid
    /// @param manufacturerID Tag of the manufacturer
    /// @param supplierID Tag of the supplier
    /// @param actualPrice Price per quantity offered in the bid
    /// @param actualQuantity Quantity requested in the bid
    /// @param actualKey Key used to hide the bid
    event ManufacturerReveal(
        uint256 manufacturerID,
        uint256 supplierID,
        uint256 actualPrice,
        uint256 actualQuantity,
        uint256 actualKey
    );

    /// @notice Triggered when a car is sold by the manufacturer to a customer
    /// @param carID Tag of the car sold
    /// @param manufacturerID Tag of the manufacturer
    /// @param customerID Tag of the customer
    event CarSold(uint256 carID, uint256 manufacturerID, uint256 customerID);

    constructor() {
        num_cars = 0;
        num_customer = 0;
        num_manufacturer = 0;
        num_supplier = 0;
        owner = payable(msg.sender);
    }

    /// @dev Function to find the minumum of 2 unsigned integers
    function minimum(uint256 a, uint256 b) public pure returns (uint256) {
        return a >= b ? b : a;
    }

    /// @notice Function to start bidding of a supplier
    /// @dev Triggeers StartSupplierBidding event
    /// @param tag Tag of the supplier
    /// @return uint256 Block height when the bidding starts
    function supplierStartBidding(uint256 tag) public returns (uint256) {
        require(tag <= num_supplier, "Invalid supplier!");
        require(suppliers[tag].currentState == AuctionState.NOT_RUNNING);
        require(msg.sender == suppliers[tag].wallet, "Incorrect tag");
        suppliers[tag].currentState = AuctionState.BIDDING;
        suppliers[tag].bidsPlaced = 0;
        suppliers[tag].bidsRevealed = 0;
        emit StartSupplierBidding(tag, block.timestamp);
        return block.timestamp;
    }

    /// @notice Function to start reveal of a supplier
    /// @dev Triggeers StartSupplierReveal event
    /// @param tag Tag of the supplier
    /// @return uint256 Block height when the reveal starts
    function supplierStartReveal(uint256 tag) public returns (uint256) {
        require(tag <= num_supplier, "Invalid supplier!");
        require(suppliers[tag].currentState == AuctionState.BIDDING);
        require(msg.sender == suppliers[tag].wallet, "Incorrect tag");
        suppliers[tag].currentState = AuctionState.REVEALING;
        emit StartSupplierReveal(tag, block.timestamp);
        return block.timestamp;
    }

    /// @notice Function to end the auction of a supplier
    /// @dev Triggers AllocateFromSupplier and back payments on bids
    /// @param tag Tag of the supplier
    /// @return uint256 Block height when the auction ends
    function supplierEndAuction(uint256 tag) public returns (uint256) {
        require(tag <= num_supplier, "Invalid supplier!");
        require(suppliers[tag].currentState == AuctionState.REVEALING);
        require(msg.sender == suppliers[tag].wallet, "Incorrect tag");
        suppliers[tag].currentState = AuctionState.NOT_RUNNING;

        // bubble sorting the bids
        for (
            uint256 i = 0;
            i < bidsTillNow[suppliers[tag].wallet].length;
            i++
        ) {
            for (uint256 j = 0; j < i; j++)
                if (
                    bidsTillNow[suppliers[tag].wallet][i].actualPrice <
                    bidsTillNow[suppliers[tag].wallet][j].actualPrice
                ) {
                    Bid memory x = bidsTillNow[suppliers[tag].wallet][i];
                    bidsTillNow[suppliers[tag].wallet][i] = bidsTillNow[
                        suppliers[tag].wallet
                    ][j];
                    bidsTillNow[suppliers[tag].wallet][j] = x;
                }
        }

        // the allocations
        uint256[100] memory allocatingPrices;
        uint256[100] memory allocatingQuantities;
        uint256[100] memory moneySentWithBid;

        // optimal resource allocation
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
                bid.limitingQuantity
            );
            allocatingHere = minimum(allocatingHere, bid.actualQuantity);

            allocatingPrices[bid.buyerID] = bid.actualPrice;
            allocatingQuantities[bid.buyerID] = allocatingHere;
            suppliers[tag].quantityAvailable -= allocatingHere;
            bidsTillNow[suppliers[tag].wallet][i]
                .actualQuantity -= allocatingHere;
        }

        // allocating to maximize profit
        for (
            uint256 i = 0;
            i < bidsTillNow[suppliers[tag].wallet].length;
            i++
        ) {
            Bid memory bid = bidsTillNow[suppliers[tag].wallet][i];
            if (bid.correctReveal == false) continue;
            uint256 allocatingHere = minimum(
                suppliers[tag].quantityAvailable,
                bid.actualQuantity
            );

            allocatingQuantities[bid.buyerID] += allocatingHere;
            suppliers[tag].quantityAvailable -= allocatingHere;
            bidsTillNow[suppliers[tag].wallet][i]
                .actualQuantity -= allocatingHere;
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
                // non bid money to manufacturer
                require(
                    payable(manufacturers[i].wallet).send(
                        moneySentWithBid[i] -
                            allocatingPrices[i] *
                            allocatingQuantities[i]
                    ),
                    "Transaction failed"
                );
                // bid money to supplier
                require(
                    payable(suppliers[tag].wallet).send(
                        allocatingPrices[i] * allocatingQuantities[i]
                    ),
                    "Transaction failed"
                );
                //update all the manufacturers quanitites to make cars
                if (suppliers[tag].partType == PartType.BODY) {
                    manufacturers[i].bodyQuant += allocatingQuantities[i];
                } else if (suppliers[tag].partType == PartType.WHEEL) {
                    manufacturers[i].wheelQuant += allocatingQuantities[i];
                } else revert();
                updateManufacturerCars(i);
            }
        while (bidsTillNow[suppliers[tag].wallet].length > 0)
            bidsTillNow[suppliers[tag].wallet].pop();

        return block.timestamp;
    }

    /// @dev Updates the cars of a manufacturer based on the quantities of parts it has
    function updateManufacturerCars(uint256 tag) private {
        uint256 carsMade = minimum(
            manufacturers[tag].bodyQuant,
            manufacturers[tag].wheelQuant
        );
        manufacturers[tag].bodyQuant -= carsMade;
        manufacturers[tag].wheelQuant -= carsMade;
        manufacturers[tag].carsAvailable += carsMade;
    }

    /// @notice Function for manufacturers to place bids
    /// @dev Triggers ManufacturerBids event
    /// @param manufacturerID Tag of the manufacturer
    /// @param supplierID Tag of the supplier
    /// @param blindPrice Price per unit hidden using the key and SHA256 encryption
    /// @param blindQuantity Quantities requested hidden using the key and SHA256 encryption
    /// @param blindKey Key used to hide the price and quantity
    /// @return limitingQuantity Liming quantity of the manufacturer for optimal resource allocation
    function manufacturerPlacesBid(
        uint256 manufacturerID,
        uint256 supplierID,
        bytes32 blindPrice,
        bytes32 blindQuantity,
        bytes32 blindKey
    ) public payable returns (uint256 limitingQuantity) {
        require(manufacturerID <= num_manufacturer, "Invalid ID");
        require(supplierID <= num_supplier, "Invalid ID");
        require(
            msg.sender == manufacturers[manufacturerID].wallet,
            "Incorrect ID"
        );
        if (suppliers[supplierID].partType == PartType.WHEEL) {
            require(
                manufacturers[manufacturerID].wheelSupplier == supplierID,
                "Incorrect supplier"
            );
        } else {
            require(
                manufacturers[manufacturerID].bodySupplier == supplierID,
                "Incorrect supplier"
            );
        }
        require(
            suppliers[supplierID].bidsPlaced <=
                suppliers[supplierID].maxBidders,
            "Max bids recieved"
        );
        uint256 limiting;
        if (suppliers[supplierID].partType == PartType.BODY) {
            uint256 bodySupplier = manufacturers[manufacturerID].bodySupplier;
            limiting =
                suppliers[bodySupplier].quantityAvailable +
                manufacturers[manufacturerID].bodyQuant;
        } else {
            uint256 wheelSupplier = manufacturers[manufacturerID].wheelSupplier;
            limiting =
                suppliers[wheelSupplier].quantityAvailable +
                manufacturers[manufacturerID].wheelQuant;
        }
        bidsTillNow[suppliers[supplierID].wallet].push(
            Bid(
                0,
                0,
                0,
                blindPrice,
                blindQuantity,
                blindKey,
                limiting,
                manufacturerID,
                supplierID,
                msg.value,
                false,
                payable(msg.sender)
            )
        );
        suppliers[supplierID].bidsPlaced += 1;
        emit ManufacturerBids(
            manufacturerID,
            supplierID,
            blindPrice,
            blindQuantity,
            blindKey
        );
        return limiting;
    }

    /// @notice Function for manufacturers to reveal bids
    /// @dev Triggers ManufacturerReveal event
    /// @param manufacturerID Tag of the manufacturer
    /// @param supplierID Tag of the supplier
    /// @param actualPrice Price per unit
    /// @param actualQuantity Quantities requested
    /// @param actualKey Key used to hide the price and quantity
    /// @return bool Reveal was valid or not
    function manufacturerRevealsBid(
        uint256 manufacturerID,
        uint256 supplierID,
        uint256 actualPrice,
        uint256 actualQuantity,
        uint256 actualKey
    ) public returns (bool) {
        require(manufacturerID <= num_manufacturer, "Invalid ID");
        require(supplierID <= num_supplier, "Invalid ID");
        require(
            suppliers[supplierID].currentState == AuctionState.REVEALING,
            "Reveal phase not going on"
        );
        require(
            manufacturers[manufacturerID].wallet == msg.sender,
            "Invalid ID"
        );
        for (
            uint256 i = 0;
            i < bidsTillNow[suppliers[supplierID].wallet].length;
            i++
        ) {
            if (
                bidsTillNow[suppliers[supplierID].wallet][i].buyerID !=
                manufacturerID
            ) continue;
            Bid memory bid = bidsTillNow[suppliers[supplierID].wallet][i];
            require(bid.correctReveal == false, "Bid already revealed");
            require(
                keccak256(abi.encodePacked(actualKey)) == bid.blindKey,
                "Incorrect key -- keeping your money"
            );
            require(
                keccak256(abi.encodePacked(actualKey + actualQuantity)) ==
                    bid.blindQuantity,
                "Incorrect quantity -- keeping your money"
            );
            require(
                keccak256(abi.encodePacked(actualKey + actualPrice)) ==
                    bid.blindPrice,
                "Incorrect price -- keeping your money"
            );
            uint256 effectivePrice = actualPrice * actualQuantity;
            require(
                effectivePrice < bid.moneySent,
                "Insufficient funds sent -- keeping your money"
            );
            bidsTillNow[suppliers[supplierID].wallet][i].correctReveal = true;
            bidsTillNow[suppliers[supplierID].wallet][i]
                .actualPrice = actualPrice;
            bidsTillNow[suppliers[supplierID].wallet][i]
                .actualQuantity = actualQuantity;
            bidsTillNow[suppliers[supplierID].wallet][i].actualKey = actualKey;
            suppliers[supplierID].bidsRevealed += 1;
            emit ManufacturerReveal(
                manufacturerID,
                supplierID,
                actualPrice,
                actualQuantity,
                actualKey
            );
            return true;
        }
        return false;
    }

    /// @notice Function for customers to buy cars
    /// @dev Triggers CarSold event
    /// @param customerID Tag of the customer
    /// @param manufacturerID Tag of the manufacturer
    /// @param priceOfferedPerCar Price per unit
    /// @param quantityRequested Quantities requested
    /// @return uint256 Quantity supplied
    function customerBuysCar(
        uint256 customerID,
        uint256 manufacturerID,
        uint256 priceOfferedPerCar,
        uint256 quantityRequested
    ) public payable returns (uint256) {
        require(customerID <= num_customer, "Invalid customer");
        require(manufacturerID <= num_manufacturer, "Invalid customer");
        require(
            priceOfferedPerCar >= manufacturers[manufacturerID].carPrice,
            "Cost is higher"
        );
        require(
            msg.value >= priceOfferedPerCar * quantityRequested,
            "Insufficient funds sent"
        );
        require(
            msg.sender == payable(customers[customerID].wallet),
            "Incorrect ID"
        );
        uint256 selling = minimum(
            quantityRequested,
            manufacturers[manufacturerID].carsAvailable
        );
        for (uint256 i = 0; i < selling; i++) {
            num_cars++;
            cars[customerID].push(
                Car(
                    num_cars,
                    customerID,
                    manufacturerID,
                    manufacturers[manufacturerID].wheelSupplier,
                    manufacturers[manufacturerID].bodySupplier
                )
            );
            emit CarSold(num_cars, manufacturerID, customerID);
        }
        manufacturers[manufacturerID].carsAvailable -= selling;
        require(
            payable(manufacturers[manufacturerID].wallet).send(
                selling * priceOfferedPerCar
            ),
            "Transaction failed"
        );
        require(
            payable(msg.sender).send(msg.value - selling * priceOfferedPerCar),
            "Transaction failed"
        );
        return selling;
    }

    /// @notice Verify details of your car
    /// @param customerID Tag of the customer
    /// @param idx Tag of the car
    /// @return id Tag of the car
    /// @return manufacturerID Tag of the manufacturer who sold the car
    /// @return wheelSupplier Tag of wheel supplier
    /// @return bodySupplier Tag of body supplier
    function verifyCar(uint256 customerID, uint256 idx)
        public
        view
        returns (
            uint256 id,
            uint256 manufacturerID,
            uint256 wheelSupplier,
            uint256 bodySupplier
        )
    {
        require(customerID <= num_customer, "Invalid car");
        require(customers[customerID].wallet == msg.sender, "Incorrect ID");
        // require(carID <= num_cars, "Invalid car");
        require(cars[customerID].length > idx);
        return (
            cars[customerID][idx].tag,
            cars[customerID][idx].manufacturerID,
            cars[customerID][idx].wheelSupID,
            cars[customerID][idx].bodySupID
        );
        //        require(cars[carID].customerID == customerID, "Not your car!");
        // for(uint256 i = 0; i < cars[customerID].length; i++)
        // {
        //     if(cars[customerID][i].tag == carID) {
        //         return (
        //             carID,
        //             cars[customerID][i].manufacturerID,
        //             cars[customerID][i].wheelSupID,
        //             cars[customerID][i].bodySupID
        //         );
        //     }
        // }
        // return (0,0,0,0);
    }

    /// @notice Add a supplier to the supply chain
    /// @param partType Type of the part supplier is going to provide. 0 for body and 1 for wheels
    /// @param quantityAvailable Quantity available with the supplier
    /// @param addr Wallet address of the supplier
    /// @param auctionBidders Number of people that can bid in it's auction
    /// @return tag of the supplier added
    function addSupplier(
        uint256 partType,
        uint256 quantityAvailable,
        address payable addr,
        uint256 auctionBidders
    ) public payable returns (uint256 tag) {
        require(partType <= 1, "Invalid part type!");
        require(msg.sender == addr, "Invalid sign up");
        num_supplier++;
        PartType here = PartType.BODY;
        if (partType == 1) here = PartType.WHEEL;
        suppliers[num_supplier] = Supplier(
            num_supplier,
            here,
            quantityAvailable,
            AuctionState.NOT_RUNNING,
            addr,
            auctionBidders,
            0,
            0
        );
        // allSuppliers.push(
        //     Supplier(
        //         num_supplier,
        //         here,
        //         quantityAvailable,
        //         AuctionState.NOT_RUNNING,
        //         addr,
        //         auctionBidders,
        //         0,
        //         0
        //     )
        // );
        return num_supplier;
    }

    /// @notice Update the quantity available with a supplier
    /// @param tag Tag of the supplier
    /// @param newQuantity New quantity to add
    /// @return totalQuantity total quantity with the supplier
    function updateSupplierQuantity(uint256 tag, uint256 newQuantity)
        public
        returns (uint256 totalQuantity)
    {
        require(tag <= num_supplier, "Invalid ID");
        require(suppliers[tag].wallet == msg.sender, "Incorrect ID");
        suppliers[tag].quantityAvailable += newQuantity;
        return suppliers[tag].quantityAvailable;
    }

    /// @notice Add a supplier to the supply chain
    /// @param addr Wallet address of the supplier
    /// @param wheelSupplier Tag of supplier to buy wheels from
    /// @param bodySupplier Tag of supplier to buy body from
    /// @param askingPrice Minimum asking price for the cars
    /// @return tag of the manufacturer added
    function addManufacturer(
        address payable addr,
        uint256 wheelSupplier,
        uint256 bodySupplier,
        uint256 askingPrice
    ) public returns (uint256 tag) {
        require(
            wheelSupplier >= 1 && wheelSupplier <= num_supplier,
            "Invalid supplier!"
        );
        require(
            bodySupplier >= 1 && bodySupplier <= num_supplier,
            "Invalid supplier!"
        );
        require(
            suppliers[bodySupplier].partType == PartType.BODY,
            "Supplier doesn't suppl body"
        );
        require(
            suppliers[wheelSupplier].partType == PartType.WHEEL,
            "Supplier doesn't suppl wheels"
        );
        require(msg.sender == addr, "Invalid sign up");
        num_manufacturer++;
        manufacturers[num_manufacturer] = Manufacturer(
            num_manufacturer,
            wheelSupplier,
            0,
            bodySupplier,
            0,
            0,
            askingPrice,
            addr
        );
        return num_manufacturer;
    }

    /// @notice Add a supplier to the supply chain
    /// @param addr Wallet address of the supplier
    /// @return tag of the customer added
    function addCustomer(address payable addr) public returns (uint256 tag) {
        require(msg.sender == addr, "Invalid sign up");
        num_customer++;
        customers[num_customer] = Customer(num_customer, addr);
        return num_customer;
    }

    // /// @notice Get the number of customers
    // /// @return uint256 Number of customers
    // function getCustomers() public view returns (uint256) {
    //     return num_customer;
    // }

    // /// @notice Get the number of cars
    // /// @return uint256 Number of cars
    // function getCars() public view returns (uint256) {
    //     return num_cars;
    // }

    // // @notice Get the number of suppliers
    // // @return uint256 Number of suppliers
    // function getSuppliers() public view returns (uint256) {
    //     return num_supplier;
    // }

    // // @notice Get the number of cars
    // // @return uint256 Number of cars
    // function getCars() public view returns (uint256) {
    //     return num_cars;
    // }

    /// @notice Get quantity of each part and car with a manufacturer
    /// @return quantityWheel Number of wheels
    /// @return quantityBody Number of bodies
    /// @return quantityCar Number of prepared cars
    function getManufacturerQuantities(uint256 tag)
        public
        view
        returns (
            uint256 quantityWheel,
            uint256 quantityBody,
            uint256 quantityCar
        )
    {
        require(tag <= num_manufacturer);
        require(
            (msg.sender == owner || msg.sender == manufacturers[tag].wallet),
            "Permission denied"
        );
        return (
            manufacturers[tag].wheelQuant,
            manufacturers[tag].bodyQuant,
            manufacturers[tag].carsAvailable
        );
    }

    /// @notice Fetch the ID for a supplier
    /// @param supplier_addr The address of the supplier
    /// @return tag The ID of the supplier
    function getSupplierID(address supplier_addr)
        public
        view
        returns (uint256 tag)
    {
        for (uint256 i = 1; i <= num_supplier; i++) {
            if (suppliers[i].wallet == supplier_addr) {
                return suppliers[i].tag;
            }
        }
    }

    /// @notice Fetch the ID for a manufacturer
    /// @param manufacturer_addr The address of the manufacturer
    /// @return tag The ID of the manufacturer
    /// @return wheelSupplier ID of wheel supplier
    /// @return wheelQuant Quantity of wheels in inventory
    /// @return bodySupplier ID of body supplier
    /// @return bodyQuant Quantity of body in inventory
    /// @return carsAvailable Cars available for selling
    /// @return carPrice Price of a car
    function getManufacturerID(address manufacturer_addr)
        public
        view
        returns (
            uint256 tag,
            uint256 wheelSupplier,
            uint256 wheelQuant,
            uint256 bodySupplier,
            uint256 bodyQuant,
            uint256 carsAvailable,
            uint256 carPrice
        )
    {
        for (uint256 i = 1; i <= num_manufacturer; i++) {
            if (manufacturers[i].wallet == manufacturer_addr) {
                return (
                    manufacturers[i].tag,
                    manufacturers[i].wheelSupplier,
                    manufacturers[i].wheelQuant,
                    manufacturers[i].bodySupplier,
                    manufacturers[i].bodyQuant,
                    manufacturers[i].carsAvailable,
                    manufacturers[i].carPrice
                );
            }
        }
    }

    /// @notice Fetch the ID for the customer
    /// @param customer_addr The address of the customer
    /// @return tag The ID of the customer
    function getCustomerID(address customer_addr)
        public
        view
        returns (uint256 tag)
    {
        for (uint256 i = 1; i <= num_customer; i++) {
            if (customers[i].wallet == customer_addr) {
                return customers[i].tag;
            }
        }
    }

    /// @notice Get the auction state of the supplier
    /// @param tag Tag of supplier
    /// @return state State of the auction
    function getAuctionState(uint256 tag) public view returns (uint256 state) {
        require(tag <= num_supplier);
        if (suppliers[tag].currentState == AuctionState.NOT_RUNNING) {
            return 1;
        } else if (suppliers[tag].currentState == AuctionState.BIDDING) {
            return 2;
        } else if (suppliers[tag].currentState == AuctionState.REVEALING) {
            return 3;
        }
    }

    /// @notice Get number of bids for a supplier's auction
    /// @param wallet Address of the supplier
    /// @return uint256 Number of bids placed
    function getNumberOfBids(address wallet) public view returns (uint256) {
        return bidsTillNow[wallet].length;
    }

    /// @notice Get a bid at index for a supplier
    /// @param wallet Address of the supplier
    /// @param idx Index of bid
    /// @return blindPrice Bid price in blinded form
    /// @return blindQuantity Bid quantity in blinded form
    /// @return buyerID ID of bidder
    /// @return correctReveal If bid has been correctly revealed
    function getSupplierBids(address wallet, uint256 idx)
        public
        view
        returns (
            bytes32 blindPrice,
            bytes32 blindQuantity,
            uint256 buyerID,
            bool correctReveal
        )
    {
        if (bidsTillNow[wallet].length < idx)
            return (bytes32(0), bytes32(0), uint256(0), false);
        return (
            bidsTillNow[wallet][idx].blindPrice,
            bidsTillNow[wallet][idx].blindQuantity,
            bidsTillNow[wallet][idx].buyerID,
            bidsTillNow[wallet][idx].correctReveal
        );
    }

    /// @notice Get number of suppliers
    function getSuppliers() public view returns (uint256) {
        return num_supplier;
    }

    /// @notice Get number of manufacturers
    function getManufacturers() public view returns (uint256) {
        return num_manufacturer;
    }

    /// @notice Get number of customers
    function getCustomers() public view returns (uint256) {
        return num_customer;
    }

    /// @notice Set price of car
    /// @param manufacturerID ID of manufacturer to set price for
    /// @param price Price to set
    function setCarsprice(uint256 manufacturerID, uint256 price)
        public
        returns (uint256)
    {
        manufacturers[manufacturerID].carPrice = price;
        return price;
    }

    /// @notice Number of cars bought by customer
    /// @param customerID ID of the customer
    /// @return uint256 Number of cars
    function numberOfCarsBought(uint256 customerID)
        public
        view
        returns (uint256)
    {
        return cars[customerID].length;
    }
}
