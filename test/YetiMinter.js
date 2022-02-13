const YetiMinter = artifacts.require('YetiMinter.sol');
const Blizz = artifacts.require('Blizz.sol')
var assert = require('assert');



contract('YetiMinter', () =>{
	// it('Should mint new NFT', async() =>{
	// 	const yeti = await YetiMinter.new();
	// 	console.log('Before mint: ' + await yeti.totalSupply());
	// 	await yeti.mintYeti('0x2B5E3AF16B1880000');
	// 	console.log('After mint: ' + await yeti.totalSupply());

	// })

	let yeti = YetiMinter.new();
	let blizz = Blizz.new('Blizz', 'blz');
	let blzAddr = '0x8c7a60ac2B87CDFfD7b3d9d5e3F8f814d4D596a2';
	const sender = '0x54f48e7daafAdA259033a05fa0AaEd3b99ae72f3';

	it('Should deploy ERC20 token and mint 1k to deployer', async() =>{
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
		console.log('Before mint: ' + await yeti.totalSupply());
		await yeti.mintYeti(amount);
		console.log('After mint: ' + await yeti.totalSupply());
	})

	it('Should fail to mint more NFTs than maximum supply', async()=>{
		const amount = '0x2B5E3AF16B1880000';

		// Mint till supply cap
		for(let i = await yeti.totalSupply(); i < await yeti.getMaxSupply(); i++){
			await yeti.mintYeti(amount);
		}
		console.log('MAX SUPPLY: ' + await yeti.getMaxSupply())
		console.log('Current supply: ' + await yeti.totalSupply())

		try{
			await yeti.mintYeti(amount)
		}catch(err){
			assert(err.message.search('Max supply reached.') > 0)
		}
	})

	// it('Should deploy ERC20 token and mint 1k to deployer', async() =>{
	// 	const blizz = await Blizz.new('Blizz', 'blz')
	// 	console.log(await blizz.balanceof(msg.sender))
	// })

	// it('Temp', async() =>{
	// 	const yeti = await YetiMinter.new();
	// 	const price = await yeti.getMintingPrice();
	// 	console.log(BigInt(await yeti.getMintingPrice()));
	// })


	// Create ERC20 token to test contract with.
})