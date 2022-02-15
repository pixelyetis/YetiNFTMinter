const YetiMinter = artifacts.require('YetiMinter.sol');
const Blizz = artifacts.require('Blizz.sol')
var assert = require('assert');


contract('YetiMinter', (accounts) =>{
	// it('Should mint new NFT', async() =>{
	// 	const yeti = await YetiMinter.new();
	// 	console.log('Before mint: ' + await yeti.totalSupply());
	// 	await yeti.mintYeti('0x2B5E3AF16B1880000');
	// 	console.log('After mint: ' + await yeti.totalSupply());

	// })

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
		const amount = '0x2B5E3AF16B1880000';
		
		// Approve spending amount
		await blizz.approve(await yeti.getAddr(), '0xffffffffffffffffffffff')

		// Mint
		// console.log('Before mint: ' + await yeti.totalSupply());
		const beforeMint = await yeti.totalSupply()
		await yeti.mintYeti(amount);
		const afterMint = await yeti.totalSupply()
		assert(afterMint > beforeMint)
		// console.log('After mint: ' + await yeti.totalSupply());
	})

	it('Should fail to mint more NFTs than maximum supply', async()=>{
		const amount = '0x2B5E3AF16B1880000'; // 100 ether units in hex
		await yeti.setMaxSuply(4)

		// Mint till supply cap
		for(let i = await yeti.totalSupply(); i < await yeti.getMaxSupply(); i++){
			await yeti.mintYeti(amount);
		}
		// console.log('MAX SUPPLY: ' + await yeti.getMaxSupply())
		// console.log('Current supply: ' + await yeti.totalSupply())

		try{
			await yeti.mintYeti(amount)
		}catch(err){
			assert(err.message.search('Max supply reached.') > 0)
		}
		// console.log('Current supply: ' + await yeti.totalSupply())
	})

	// Test only owner can make crucial changes.
	it('Should ensure only owner can make changes to contract', async()=>{
		// From deployer
		await yeti.setMintTokenAddress(blzAddr, {from: accounts[0]})

		try{
			await yeti.setMintingPrice(1, {from: accounts[1]})
			await yeti.setMintTokenAddress(blzAddr, {from: accounts[1]})
			await yeti.withdraw({from: accounts[1]})
			await yeti.setMaxSuply(10000, {from: accounts[1]})
		}catch(err){
			assert(err.message.search('Ownable: caller is not the owner') > 0)
		}
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

	it('Should get contract ABIs', async()=> {			
		const fs = require('fs');
		const contract = JSON.parse(fs.readFileSync('./build/contracts/YetiMinter.json', 'utf8'));
		// console.log(JSON.stringify(contract.abi));
	})
})