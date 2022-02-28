const truffleAssert = require('truffle-assertions')
const YetiMinter = artifacts.require('YetiMinter.sol');
const Blizz = artifacts.require('Blizz.sol')
var assert = require('assert');


contract('YetiMinter', (accounts) =>{

	let yeti = YetiMinter.new();
	let blizz = Blizz.new('Blizz', 'blz');
	let blzAddr = '0x8c7a60ac2B87CDFfD7b3d9d5e3F8f814d4D596a2';
	const sender = accounts[0]

	it('Should deploy ERC20 token and mint 100k to deployer', async() =>{
		blizz = await Blizz.new('Blizz', 'blz');
		blzAddr = await blizz.getAddr();
	})


	it('Should change Mint Token address', async() =>{
		yeti = await YetiMinter.new();
		await yeti.setMintTokenAddress(blzAddr);
		const newMintToken = await yeti.getMintTokenAddress();
		assert.equal(newMintToken.toLowerCase(), blzAddr.toLowerCase());
	})

	it('Should approve and pay to successfully mint a new NFT', async()=>{
		
		// Approve spending amount
		await blizz.approve(await yeti.getAddr(), '0xffffffffffffffffffffff')

		// Mint
		const beforeMint = await yeti.totalSupply()
		await yeti.mintYeti(1);
		const afterMint = await yeti.totalSupply()
		assert(afterMint > beforeMint)
	})

	it('Should not give any traits of unminted yetis', async()=>{
		await yeti.getBackground(await yeti.totalSupply())
		await yeti.getFur(await yeti.totalSupply())
		await truffleAssert.reverts(yeti.getBackground(await yeti.totalSupply()+1), "Yeti not minted yet!")
		await truffleAssert.reverts(yeti.getFur(await yeti.totalSupply()+1), "Yeti not minted yet!")
	})

	it('Should fail to mint more NFTs than maximum supply', async()=>{
		await yeti.setMaxSuply(4)

		// Mint till supply cap
		for(let i = await yeti.totalSupply(); i < await yeti.MAX_SUPPLY(); i++){
			await yeti.mintYeti(1);
		}

		await truffleAssert.reverts(yeti.mintYeti(1), 'Max supply reached.')
	})

	it('Should not mint more than maximum session amount', async()=>{
		// const price1 = '0x2B5E3AF16B1880000'; // 50 ether units in hex
		// const price5 = '0xD8D726B7177A80000'; // 250 ether units
		// const price6 = '0x1043561A8829300000'; // 300 ether units

		const newSupply = 4 + 10*2 - 1
		const price1 = 50 * 10 ** 18

		await yeti.setMaxSuply(newSupply)

		await truffleAssert.reverts(yeti.mintYeti(11), "Invalid amount to mint at once.")
		await yeti.mintYeti(10)
		await truffleAssert.reverts(yeti.mintYeti(10), "Purchase would exceed max supply.")
	})

	it('Should withdraw balance of contract to owner', async()=>{
		const contractBefore = await blizz.balanceOf(await yeti.getAddr())
		const ownerBefore = await blizz.balanceOf(sender)
		
		// console.log('Balance of contract before withdraw: ' + await blizz.balanceOf(await yeti.getAddr()))
		// console.log('Balance of owner before withdraw: ' + await blizz.balanceOf(sender))
		
		await yeti.withdraw()

		const contractAfter = await blizz.balanceOf(await yeti.getAddr())
		const ownerAfter = await 	blizz.balanceOf(sender)

		assert(ownerAfter - ownerBefore > 0)
		assert(contractBefore - contractAfter > 0)
		assert(contractAfter == 0)
		
		// console.log('Balance of contract after withdraw: ' + await blizz.balanceOf(await yeti.getAddr()))
		// console.log('Balance of owner after withdraw: ' + await blizz.balanceOf(sender))
	})

	it('Should change base URI', async()=>{
		let testURI = 'ipfs://test-base/'
		await yeti.setBaseURI(testURI)

		assert.equal(await yeti.tokenURI(0), 'ipfs://test-base/0')
	})
	
	it('Should change when price increase happens', async()=>{
		
		let _yeti = await YetiMinter.new();
		await _yeti.setMintTokenAddress(blzAddr);

		// Approve spending amount
		await blizz.approve(await _yeti.getAddr(), '0xffffffffffffffffffffff')

		let currentNumnber = Number(await _yeti.priceIncrease())
		let newNumber = 0

		// Set new number
		await _yeti.setPriceIncreaseNumber(newNumber)
		
		// Ensure priceIncreaseNumber is changed
		assert(Number(await _yeti.priceIncrease()) !== currentNumnber)
		assert(Number(await _yeti.priceIncrease()) === newNumber)

		// Ensure new price is automatically changed once priceIncreaseNumber is passed
		let beforePrice = await _yeti.getMintingPrice()

		// If this is false then next assert may get a false positive
		assert(String(await _yeti.getMintingPrice()) === String(beforePrice)) 
		await _yeti.mintYeti(1)
		let afterPrice = await _yeti.getMintingPrice()
		assert(String(afterPrice) !== String(beforePrice))
	})
	

	// Test only owner can make crucial changes.
	it('Should ensure only owner can make changes to contract', async()=>{
		const ownErrMsg = 'Ownable: caller is not the owner'

		// onlyOwner Setters
		await truffleAssert.reverts(yeti.setMintingPrice(1, {from: accounts[1]}), ownErrMsg)
		await truffleAssert.reverts(yeti.setMintTokenAddress(blzAddr, {from: accounts[1]}), ownErrMsg)
		await truffleAssert.reverts(yeti.setMaxSuply(10000, {from: accounts[1]}), ownErrMsg)
		await truffleAssert.reverts(yeti.setBaseURI('Attack!!', {from: accounts[1]}), ownErrMsg)
		await truffleAssert.reverts(yeti.setPriceIncreaseNumber(420, {from: accounts[1]}), ownErrMsg)

		// Withdrawal
		await truffleAssert.reverts(yeti.withdraw({from: accounts[1]}), ownErrMsg)
	})


	// it('Should get contract ABIs', async()=> {			
	// 	const fs = require('fs');
	// 	const contract = JSON.parse(fs.readFileSync('./build/contracts/YetiMinter.json', 'utf8'));
	// 	console.log(JSON.stringify(contract.abi));
	// })
})