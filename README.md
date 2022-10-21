# Supply-Chain-Management
A transparent supply chain which can be used by 5 clients and their customers.


## Actors
### Manufacturers : 
There are 2 clients who manufacture cars, and sell them to the customers.For manufacturing cars we need cars_body and wheels.

### Suppliers : 
There are 3 suppliers.  </br>
Supplier 1 (S1) supplies wheels to Manufacturer 1 (M1) </br>
Supplier 3 (S3) supplies cars_body to both M1 and M2.
</br>
Supplier 2 (S2) supplies wheels to Manufacturer 2.

### Customers :
They buy cars from manufacturers at retail price

## Market Interactions
Manufacturers bids to suppliers and bids are secret.
Once auction is over, resource allocation is based on optimal resource allocation and profit maximising strategy.

## Goals
We ensure 3 goals are met :
1. Secret Bidding
2. Optimal resource allocation & Profit maximization
3. Validity of the product

To test in truffle

- Compile:
```bash
truffle compile
```
- Open console in development mode:
```bash
truffle develop
```

- Deploy
```bash
truffle deploy
```

- Start contract
```bash
let instance = await Marketplace.deployed()
```

- Call a function
```bash
instance.function(args)
```

- Get a mapping:
```bash
var balance = await instance.<mapping name>.call(account);
console.log(balance);
```
- 


## Rough documentation for us right now
### Functions
- supplierStartAuction : suppliers can start their auctions
- supplierEndAuction : suppliers can end their auctions
- supplierEndReveal : Reveal phase of the bidding is finished and allocation happens now (implements resource optimal allocation)
- transferMoney : transfer money
- manufacturerPlacesBid : manufacturer places bid to supplier from this if bidding phase is on
- manufactuerRevealBid : manufacturer reveals their bid to supplier from this if reveal phase is on
- addSupplier, addManufacturer, addCustomer : adds the actors
- supplierAddQuantity : adds quantity for the supplier
- updateManufacturerQuantities : updates cars from quantities;
- manufacturerSuppliesCars : manufacturer sells cars 
- customerPurchase : customer places a order
- set_cars_price : manufacturer can set cars price
- get_cars_price : returns quantity and price (per each piece) by the mentioned manufacturer

### Events
- StartSupplierAuction : supplier starts auction
- EndSupplierAuction : supplier ends auction
- AllocateFromSupplier : supplier sends goods to manufacturer
- ManufacturerBids : manufacturer places a bid to the supplier
- ManufacturerReveal : manufacturer reveals their bid to the supplier
- CustomerRequest : customer requested for a purchase from manufacturer
- AllocateFromManufacturer : manufacturer supplied to customer

### Note points
- Only 1 bid per auction is supported. Incase of multiple bids, first bid is considered
- keccak256 encryption for hiding the bids
- no penalties right now for incorrect reveals, just ignore from auction
- 