pragma solidity >=0.8.16;

import {MarketPlace_Bidding} from "./MarketPlace_Bidding.sol";

contract MarketPlace_CustomerInterface is MarketPlace_Bidding {
    constructor() {
        owner = payable(msg.sender);
        num_manufacturer = 0;
        num_supplier = 0;
        num_customer = 0;
    }

    function customerPurchase(
        uint256 customerID,
        uint256 manufacturerID,
        uint256 quantity
    ) external payable {
        require(
            customers[customerID].wallet == msg.sender || owner == msg.sender,
            "Access Denied"
        );
        Purchase memory newpurchase;
        newpurchase.sellerID = manufacturerID;
        newpurchase.customeraddr = payable(msg.sender);
        newpurchase.quantity = quantity;
        newpurchase.buyerID = customerID;
        newpurchase.money = msg.value;
        uint256 unit_cost = manufacturers[manufacturerID].carsprice;
        uint256 total_cost = unit_cost * quantity;
        require(newpurchase.money >= total_cost, "Money not enough");
        address manf_adrr = manufacturers[manufacturerID].wallet;
        purchasesTillNow[manf_adrr].push(newpurchase);
        emit CustomerRequest(
            customerID,
            manufacturerID,
            quantity,
            manufacturers[manufacturerID].carsprice
        );
    }

    function manufacturerSupplyCars(uint256 manufacturerID) public {
        require(num_manufacturer >= manufacturerID);
        require(
            msg.sender == manufacturers[manufacturerID].wallet ||
                msg.sender == owner
        );
        for (
            uint256 i = 0;
            i < purchasesTillNow[manufacturers[manufacturerID].wallet].length;
            i++
        ) {
            //Money is already checked, Quantity check is done here
            if (
                purchasesTillNow[manufacturers[manufacturerID].wallet][i]
                    .quantity <= manufacturers[manufacturerID].cars
            ) {
                uint256 effective_price = purchasesTillNow[
                    manufacturers[manufacturerID].wallet
                ][i].quantity * manufacturers[manufacturerID].carsprice;
                uint256 refund_amount = purchasesTillNow[
                    manufacturers[manufacturerID].wallet
                ][i].money - effective_price;

                manufacturers[manufacturerID].cars -= purchasesTillNow[
                    manufacturers[manufacturerID].wallet
                ][i].quantity;
                uint256 num_of_cars = purchasesTillNow[
                    manufacturers[manufacturerID].wallet
                ][i].quantity;
                address mf_adrr = manufacturers[manufacturerID].wallet;
                uint256[100] memory carTags;
                uint256 carTagsIdx = 0;
                for (uint256 j = 0; j < num_of_cars; j++) {
                    uint256 idx = productsTillNow[mf_adrr].length - 1;
                    Car memory newcar;
                    newcar.tag = productsTillNow[mf_adrr][idx].tag;
                    newcar.manufacturerID = manufacturerID;
                    newcar.sellerIDA = productsTillNow[mf_adrr][idx].sellerA;
                    newcar.sellerIDB = productsTillNow[mf_adrr][idx].sellerB;
                    carsBought[purchasesTillNow[mf_adrr][idx].buyerID].push(
                        newcar
                    );
                    productsTillNow[mf_adrr].pop();
                    carTags[carTagsIdx++] = newcar.tag;
                }
                transferMoney(
                    manufacturers[manufacturerID].wallet,
                    effective_price
                );
                transferMoney(
                    customers[
                        purchasesTillNow[manufacturers[manufacturerID].wallet][
                            i
                        ].buyerID
                    ].wallet,
                    refund_amount
                );
                // refundMoney(
                // customers[purchasesTillNow[manufacturers[manufacturerID].wallet][i].buyerID].wallet,
                // refund_amount);
                emit AllocateFromManufacturer(
                    manufacturerID,
                    purchasesTillNow[manufacturers[manufacturerID].wallet][i]
                        .buyerID,
                    purchasesTillNow[manufacturers[manufacturerID].wallet][i]
                        .quantity,
                    effective_price,
                    carTags
                );
            } else {
                //send them back the amount saying quantity not available
                revert("Quantity not Available"); //gas to caller
            }
        }
        while (
            purchasesTillNow[manufacturers[manufacturerID].wallet].length > 0
        ) purchasesTillNow[manufacturers[manufacturerID].wallet].pop();
    }

    function addSupplier(
        int256 partType,
        uint256 quantityAvailable,
        address payable addr,
        uint256 auctionBidders
    ) public returns (uint256 tag) {
        num_supplier++;
        suppliers[num_supplier] = Supplier(
            num_supplier,
            partType,
            quantityAvailable,
            AuctionState.NOT_STARTED,
            addr,
            auctionBidders,
            0,
            0
        );
        return num_supplier;
    }

    function addManufacturer(address payable addr, uint256 auctionBidders)
        public
        returns (uint256 tag)
    {
        num_manufacturer++;
        manufacturers[num_manufacturer] = Manufacturer(
            num_manufacturer,
            0,
            0,
            0,
            0,
            AuctionState.NOT_STARTED,
            addr,
            auctionBidders,
            0,
            0
        );
        return num_manufacturer;
    }

    function addCustomer(address payable addr) public returns (uint256 tag) {
        num_customer++;
        customers[num_customer] = Customer(num_customer, addr);
        return num_customer;
    }

    function verifyproduct(uint256 customerID, uint256 car_tag)
        public
        view
        returns (
            uint256 carID,
            uint256 manfID,
            uint256 sellerIDA,
            uint256 sellerIDB
        )
    {
        for (uint256 i = 0; i < carsBought[customerID].length; i++) {
            if (carsBought[customerID][i].tag == car_tag)
                return (
                    car_tag,
                    carsBought[customerID][i].manufacturerID,
                    carsBought[customerID][i].sellerIDA,
                    carsBought[customerID][i].sellerIDB
                );
        }
        require(0 == 1, "Car not found in they buyers purchases");
        return (0, 0, 0, 0);
    }
}
