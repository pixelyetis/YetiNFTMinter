const CatLoot = artifacts.require('CatLoot.sol');
const YetiMinter = artifacts.require('YetiMinter.sol');

module.exports = function(deployer) {
	deployer.deploy(YetiMinter);
	// deployer.deploy(CatLoot);
}