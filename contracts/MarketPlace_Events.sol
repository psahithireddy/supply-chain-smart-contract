pragma solidity >=0.8.16;

import {MarketPlace_Storage} from "./MarketPlace_Storage.sol";

contract MarketPlace_Events is MarketPlace_Storage {
    // @notice Triggered to start auction for a supplier
    // @param supplierID Tag ID of the supplier
    // @param startTime Blockheight when auction started
    event StartSupplierAuction(uint256 supplierID, uint256 startTime);

    // @notice Triggered to end auction for a supplier
    // @param supplierID Tag ID of the supplier
    // @param startTime Blockheight when auction ended
    event EndSupplierAuction(uint256 supplierID, uint256 endTime);

    // @notice Triggered to allocate resources from supplier to manufacturer
    // @param supplierID Tag ID of the supplier
    // @param manufacturerID Tag ID of the manufacturer
    // @param quantity Quantities ordered
    // @param price Price offered per unit
    event AllocateFromSupplier(
        uint256 supplierID,
        uint256 manufacturerID,
        uint256 quantity,
        uint256 price
    );

    // @notice Triggered to end auction for a manufacturer
    // @param manufacturerID Tag ID of the manufacturer
    // @param startTime Blockheight when auction ended
    event StartManufacturerAuction(uint256 manufacturerID, uint256 startTime);

    // @notice Triggered to end auction for a manufacturer
    // @param manufacturerID Tag ID of the manufacturer
    // @param startTime Blockheight when auction ended
    event EndManufacturerAuction(uint256 manufacturerID, uint256 endTime);

    // @notice Triggered when a customer requests to buy cars from a manufacturer
    // @param CustomerID Tag ID of the customer
    // @param ManufacturerID Tag ID of the manufacturer
    // @param Quantities Quantities requested
    // @param Price Price offered
    event CustomerRequest(
        uint256 CustomerID,
        uint256 ManufacturerID,
        uint256 Quantity,
        uint256 Price
    );

    // @notice Triggered to allocate cars from manufacturer to customer
    // @dev Limited to buying only 100 cars at once
    // @param manufacturerID Tag ID of the manufacturer
    // @param customerID Tag ID of the customer
    // @param quantity Quantities ordered
    // @param price Price offered per unit
    // @param carTag List of tags associated with the cars sold
    event AllocateFromManufacturer(
        uint256 manufacturerID,
        uint256 customerID,
        uint256 quantity,
        uint256 price,
        uint256[100] carTag
    );

    // @notice Manufacturer places a blind bid to the supplier
    // @param manufacturerID Tag ID of the manufacturer
    // @param supplierID Tag ID of the supplier
    // @param blindBidPrice bidding price blinded using keccak256
    // @param blindBidQuantity bidding quantity blinded using keccak256
    event ManufacturerBids(
        uint256 supplierID,
        uint256 manufacturerID,
        bytes32 blindBidPrice,
        bytes32 blindBidQuantity
    );

    // @notice Manufacturer reveals it's bid to the supplier
    // @param manufacturerID Tag ID of the manufacturer
    // @param supplierID Tag ID of the supplier
    // @param price bidding price
    // @param quantity bidding quantity
    event ManufacturerReveal(
        uint256 supplierID,
        uint256 manufacturerID,
        uint256 price,
        uint256 quantity
    );
}
