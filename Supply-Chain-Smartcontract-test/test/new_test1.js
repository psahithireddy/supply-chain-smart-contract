const testcontract = artifacts.require("NewMarketPlace");

contract("testcontract", (accounts) => {
    it("Add all the actors", async () => {
        const instance = await testcontract.deployed();
        const sup1ID = await instance.addSupplier(0, 20, accounts[0], 1, {
            from: accounts[0]
        }); // Selling body
        const sup2ID = await instance.addSupplier(0, 15, accounts[1], 1, {
            from: accounts[1]
        }); // Selling body
        const sup3ID = await instance.addSupplier(1, 40, accounts[2], 2, {
            from: accounts[2]
        }); // Selling wheels
        const num_supplier = await instance.getSuppliers();
        assert.equal(num_supplier, 3);
        const manufacturer1ID = await instance.addManufacturer(accounts[3], 3, 1, 30, {
            from: accounts[3]
        }); // Body from 1, wheels from 3
        const manufacturer2ID = await instance.addManufacturer(accounts[4], 3, 2, 35, {
            from: accounts[4]
        }); // Body from 2, wheels from 3
        const num_manufacturer = await instance.getManufacturers();
        assert.equal(num_manufacturer, 2);
        const customer1ID = await instance.addCustomer(accounts[5], {
            from: accounts[5]
        });
        const customer2ID = await instance.addCustomer(accounts[6], {
            from: accounts[6]
        });
        const num_customer = await instance.getCustomers();
        assert.equal(num_customer, 2);
    });
    it("Single manufacturer buying from supplier", async () => {
        const instance = await testcontract.deployed();
        await instance.supplierStartBidding(1, {
            from: accounts[0]
        });
        await instance.supplierStartBidding(2, {
            from: accounts[1]
        });
        const limitingQuantity1 = await instance.manufacturerPlacesBid(
            1, 1, web3.utils.soliditySha3(22 + 42),
            web3.utils.soliditySha3(15 + 42), web3.utils.soliditySha3(42), {
                value: 1000,
                from: accounts[3]
            }
        );
        const limitingQuantity2 = await instance.manufacturerPlacesBid(
            2, 2, web3.utils.soliditySha3(25 + 69),
            web3.utils.soliditySha3(12 + 69), web3.utils.soliditySha3(69), {
                value: 1000,
                from: accounts[4]
            }
        );
        await instance.supplierStartReveal(1, {
            from: accounts[0]
        });
        await instance.supplierStartReveal(2, {
            from: accounts[1]
        });
        const ret1 = await instance.manufacturerRevealsBid(
            1, 1, 22, 15, 42, {
                from: accounts[3]
            }
        );
        const ret2 = await instance.manufacturerRevealsBid(2, 2, 25, 12, 69, {
            from: accounts[4]
        });
        await instance.supplierEndAuction(1, {from: accounts[0]});
        await instance.supplierEndAuction(2, {from: accounts[1]});
        const quantity1 = await instance.getManufacturerQuantities(1);
        const quantity2 = await instance.getManufacturerQuantities(2);
        assert.equal(quantity1.quantityWheel, 0);
        assert.equal(quantity2.quantityWheel, 0);
        assert.equal(quantity1.quantityBody, 15);
        assert.equal(quantity2.quantityBody, 12);
        assert.equal(quantity1.quantityCar, 0);
        assert.equal(quantity2.quantityCar, 0);
    });
    it("2 person auction and car manufacturing", async() =>{
        const instance = await testcontract.deployed();
        await instance.supplierStartBidding(3, {from: accounts[2]});
        const limitingQuantity1 = await instance.manufacturerPlacesBid(
            1, 3, web3.utils.soliditySha3(25 + 13), 
            web3.utils.soliditySha3(25 + 13), web3.utils.soliditySha3(13),
            {from: accounts[3], value: 1000}
        );
        const limitingQuantity2 = await instance.manufacturerPlacesBid(
            2, 3, web3.utils.soliditySha3(28 + 7), 
            web3.utils.soliditySha3(20 + 7), web3.utils.soliditySha3(7),
            {from: accounts[4], value: 1000}
        );
        await instance.supplierStartReveal(3, {from: accounts[2]});
        const ret1 = await instance.manufacturerRevealsBid(1, 3, 25, 25, 13, {from: accounts[3]});
        const ret2 = await instance.manufacturerRevealsBid(2, 3, 28, 20, 7, {from: accounts[4]});
        await instance.supplierEndAuction(3, {from: accounts[2]});
        const quantity1 = await instance.getManufacturerQuantities(1);
        const quantity2 = await instance.getManufacturerQuantities(2);
        assert.equal(quantity1.quantityWheel, 10);
        assert.equal(quantity2.quantityWheel, 3);
        assert.equal(quantity1.quantityBody, 0);
        assert.equal(quantity2.quantityBody, 0);
        assert.equal(quantity1.quantityCar, 15);
        assert.equal(quantity2.quantityCar, 12);
    });
    it("Customer buys", async() => {
        const instance = await testcontract.deployed();
        await instance.customerBuysCar(1, 1, 32, 5, {from: accounts[5], value: 180});
        await instance.customerBuysCar(2, 2, 35, 3, {from: accounts[6], value: 110});
        for(let i = 1; i <= 5; i++) {
            const here = await instance.verifyCar(1, i, {from: accounts[5]});
            assert.equal(here.id, i);
            assert.equal(here.manufacturerID, 1);
            assert.equal(here.wheelSupplier, 3);
            assert.equal(here.bodySupplier, 1);
        }
        for(let i = 6; i <= 8; i++) {
            const here = await instance.verifyCar(2, i, {from: accounts[6]});
            assert.equal(here.id, i);
            assert.equal(here.manufacturerID, 2);
            assert.equal(here.wheelSupplier, 3);
            assert.equal(here.bodySupplier, 2);
        }
    });
});