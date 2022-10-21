pragma solidity >=0.8.16;

import {MarketPlace_Structures} from "./MarketPlace_Structures.sol";

contract MarketPlace_Storage is MarketPlace_Structures {
    uint256 public num_supplier;
    uint256 public num_manufacturer;
    uint256 public num_customer;
    uint256 public num_products;

    mapping(uint256 => Supplier) public suppliers;
    mapping(uint256 => Manufacturer) public manufacturers;
    mapping(uint256 => Customer) public customers;
    mapping(address => Bid[]) bidsTillNow;
    mapping(address => Purchase[]) purchasesTillNow;
    mapping(address => Product[]) productsTillNow;
    mapping(uint256 => Car[]) carsBought;
}
