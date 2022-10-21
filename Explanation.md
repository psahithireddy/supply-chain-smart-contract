# Marketplace

A smart contract for a market place.

Made by:

- Kunal Jain (2019111037)
- P. Sahithi Reddy (2020121011)
- Prince Varshney (2020121012)

## Front End

### Landing page
- Select the type of user you are in the marketplace
- The page takes you to a registration page for either Supplier, Manufacturer or Customer
- After registration or if you have been already registered, you go to the home page

### Supplier Registration
- Select part type you are selling and the quantities available with you
- Select number of bidders

### Manufacturer Registration
- Select your suppliers
- Select your selling price

### Supplier Home Page
- You can start your bid phase, reveal phase or end  you auction\
- You can monitor the bids you have recieved (blinded fashion)
- You can update your quantity

### Manufacturer Home Page
- You can monitor the state of auction of your suppliers
- You can place bids for your suppliers
- You can update your selling price

### Supplier Home Page
- You can monitor what the manufacturers are selling
- You can try to buy from manufacturers

## Public API

### User control operations

- addSupplier: Adds a supplier
- addManufacturer: Adds a manufacturer
- addCustomer: Adds a customer

### Supplier side operations

- supplierStartAuction: Allows supplier to start their auction
- supplierEndAuction: Allows supplier to end bidding phase of auction
- supplierEndReveal: Allows supplier to end reveal phase and allocate
- supplierAddQuantity: Allows supplier to add inventory

### Manufacturer side operations

- manufacturerPlacesBid: Allows manufacturer to place bid to supplier
- manufactuerRevealBid: Allows manufacturer to reveal their bid
- manufacturerSupplyCars: Allows manufacturer to supply cars

### Customer side operations

- customerPurchase: Allows customers to place a purchase
- verifyproduct: Allows customer to verify their purchases

## Code Flow

The flow is divided into 2 segments:

1. Auction between the manufacturers to the suppliers for parts
2. Fixed price purchases by the customers from the manufacturers.

The bidding proceeds as follows:

1. A supplier starts an auction in bidding phase
2. Manufacturers commit their bids to the suppliers by encrypting them with a key and putting them on the blockchain
3. The supplier starts the reveal phase after it has collected the bids
4. Manufacturers reveal their bids by emitting their prices, quantities and secret key on the blockchain
5. The supplier starts allocation after it has collected the reveals.

Note that a manufacturer needs to generate a new secret key for every bid it makes.

The purchases proceed as follows:

1. A customer requests a purchase to the manufacturer
2. The manufacture fulfills the order if it has the said quantity and price offered is suitable to it.

## Goals

### Secret bidding

- All bids are placed using a commit reveal mechanism
- The price and quantity is sent after adding a secret key to them and encrypting all 3 using keccak256 with the `manufacturerPlacesBid` API.
- These are emitted on the blockchain
- During reveal phase, the manufacturers send their bids along with the key, which is also emitted on the blockchain for everyone to verify with the `manufactuerRevealBid` API.

### Optimal resource allocation

- During bids, the manufacturers send their current limiting resource
- When the supplier ends it's reveal phase with the `supplierEndReveal` API, we do resource optimal allocation
- First , we supply the each bidder in the order of their bids the minimum of the quantity they ordered, their limiting quantity and the quantity available. If units are still available, they are sent to the highest bidder

### Validity of product

- The code is written in a modular and extensible fashion such that each product sold can be traced back to how it was produced.
- The `Product` class stores high level information like where each of the parts were produced and assembled.

## Bonus

- The code is written in a generalized fashion such that we are not limited to the marketplace posed in the question. We have implemented an open marketplace where any number of buyers can bid and buy from any number of sellers

## Tests

The parameters of the bids change across each test

1. Create 3 suppliers, 2 manufacturers and 2 customers
2. Manufacturers buy from their unique suppliers
3. Manufacturers bid for the common resource, resource allocation is done in supply chain optimal fashion
4. Customers buy from manufacturers and verify their product and it's suppliers
