const MarketPlace_CustomerInterface = artifacts.require("MarketPlace_CustomerInterface.sol");
module.exports = function (deployer) {
  deployer.deploy(MarketPlace_CustomerInterface);
}
