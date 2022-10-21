const testcontract = artifacts.require("Marketplace");

contract("testcontract", (accounts) => {
  it("Add all the actors", async () => {
    const instance = await testcontract.deployed();
    await instance.addSupplier(1, 50, accounts[0], 1);
    await instance.addSupplier(1, 50, accounts[1], 1);
    await instance.addSupplier(2, 100, accounts[2], 2);
    const value = await instance.getsuppliers();
    assert.equal(value, 3);
    //value.should.be.bignumber.equal('1');
    await instance.addManufacturer(accounts[3], 5);
    await instance.addManufacturer(accounts[4], 5);
    const val1 = await instance.getmanufacturers();
    assert.equal(val1, 2);
    await instance.addCustomer(accounts[5]);
    await instance.addCustomer(accounts[6]);
  });
  it("Single manufacturer buying from supplier", async () => {
    const instance = await testcontract.deployed();
    await instance.supplierStartAuction(1);
    await instance.supplierStartAuction(2);
    await instance.supplierStartAuction(3);
    await instance.manufacturerPlacesBid(
      1,
      1,
      web3.utils.soliditySha3(22 + 42),
      web3.utils.soliditySha3(15 + 42),
      web3.utils.soliditySha3(42),
      1000,
      { value: 1000000 }
    );
    const ret = await instance.getbidcount(1);
    assert.equal(ret, 1);
    await instance.manufacturerPlacesBid(
      2,
      2,
      web3.utils.soliditySha3(22 + 42),
      web3.utils.soliditySha3(10 + 42),
      web3.utils.soliditySha3(42),
      1000,
      { value: 1000000 }
    );
    const ret1 = await instance.getbidcount(2);
    assert.equal(ret1, 1);
    // make some assertions here
    await instance.supplierEndAuction(1);
    await instance.supplierEndAuction(2);
    await instance.manufactuerRevealBid(1, 1, 22, 15, 42);
    await instance.manufactuerRevealBid(2, 2, 22, 10, 42);
    await instance.supplierEndReveal(1);
    await instance.supplierEndReveal(2);
    const m1_data = await instance.get_manufacturer_data(1);
    assert.equal(m1_data.quantA, 15);
    const m2_data = await instance.get_manufacturer_data(2);
    assert.equal(m2_data.quantA, 10);
  });
  it("2 person auction -- resource allocation", async () => {
    const instance = await testcontract.deployed();
    await instance.manufacturerPlacesBid(
      1,
      3,
      web3.utils.soliditySha3(20 + 69),
      web3.utils.soliditySha3(18 + 69),
      web3.utils.soliditySha3(69),
      15,
      { value: 10000000 }
    );
    await instance.manufacturerPlacesBid(
      2,
      3,
      web3.utils.soliditySha3(18 + 69),
      web3.utils.soliditySha3(8 + 69),
      web3.utils.soliditySha3(69),
      10,
      { value: 10000000 }
    );

    await instance.supplierEndAuction(3);

    await instance.manufactuerRevealBid(1, 3, 20, 18, 69);
    await instance.manufactuerRevealBid(2, 3, 18, 8, 69);

    await instance.supplierEndReveal(3);
    const m1_data = await instance.get_manufacturer_data(1);
    assert.equal(m1_data.quantA, 0);
    assert.equal(m1_data.quantB, 3);
    assert.equal(m1_data.cars, 15);
    const m2_data = await instance.get_manufacturer_data(2);
    assert.equal(m2_data.quantA, 2);
    assert.equal(m2_data.quantB, 0);
    assert.equal(m2_data.cars, 8);
  });
  it("Customer buys from manufacturer", async () => {
    const instance = await testcontract.deployed();
    await instance.set_cars_price(1, 30);
    await instance.set_cars_price(2, 35);

    await instance.addCustomer(accounts[5]);
    await instance.addCustomer(accounts[6]);
    await instance.addCustomer(accounts[7]);

    await instance.customerPurchase(1, 1, 1, { value: 32 });
    await instance.customerPurchase(2, 1, 1, { value: 30 });

    await instance.manufacturerSupplyCars(1);

    const ret1 = await instance.verifyproduct(1, 1);
    assert.equal(ret1.carID, 1);
    assert.equal(ret1.manfID, 1);

    const ret2 = await instance.verifyproduct(2, 3);
    assert.equal(ret2.carID, 3);
    assert.equal(ret2.manfID, 1);
  });
});
