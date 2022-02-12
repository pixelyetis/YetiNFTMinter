const CatLoot = artifacts.require('CatLoot.sol');
const YetiMinter = artifacts.require('YetiMinter.sol');
const Blizz = artifacts.require('Blizz.sol')

module.exports = function(deployer) {
	deployer.deploy(YetiMinter);
	deployer.deploy(Blizz, 'Blizz', 'blz')
	// deployer.deploy(CatLoot);
}