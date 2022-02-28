// SPDX-License-Identifier: MIT
pragma solidity >= 0.5.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";


interface ERC20Interface {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool) ;
    function approve(address spender, uint256 amount) external returns (bool) ;
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract YetiMinter is ERC721Enumerable, Ownable, ReentrancyGuard{
	using SafeMath for uint256;

	uint256 public MAX_SUPPLY = 420;
	uint256 public MAX_MINT = 10;
	uint256 public mintPrice = 50 ether;
	uint256 public priceIncrease = 100;
	string private _customBaseURI = "https://pixelyetis.fra1.digitaloceanspaces.com/metadata/";

	address mintToken = 0x9a946c3Cb16c08334b69aE249690C236Ebd5583E;
	ERC20Interface tokenInterface = ERC20Interface(mintToken);

	// String array of all available traits.
	string[] private _background = ["Dark Green and Dark Blue", "Green and Purple", "Purple and Brown", "Purple and Dark Red", "Teal and Red"];
	string[] private _eyes = ["Angry Eyes","Bored Eyes", "Eye Patch", "Glasses", "Happy Eyes", "Normal Eyes", "Pissed Eyes", "Shades", "Sleeping Eyes"];
	string[] private _fur = ["Beige Fur", "Blue Fur", "Blue Fur Striped", "Gray Fur", "Gray Fur Checkered", "Gray Fur", "Pixelated Fur", "Rainbow Fur", "White Fur", "White Fur Striped"];
	string[] private _horns = ["Black Horns", "Blue Horns", "Orange Horns", "Red Horns", "Yellow Horns"];
	string[] private _mouth = ["Happy Mouth", "Normal Mouth", "Rainbow Mouth", "Rainbow Mouth Wave", "Sad Mouth", "Teeth"];
	string[] private _skin = ["Blue Skin", "Dark Blue Skin", "Green Skin",  "Orange Skin", "Pink Skin", "Purple Skin"];

	uint256[] private _weightsFur = [8,8,4,8,4,8,4,1,8,4];
	uint256[] private _weightsMouth = [5,5,1,1,5,2];


	// constructor() ERC721('Pixel Yetis', 'PY') {
	// }

	/*-------------------------------------------------*/
	// // Use for testing purposes. Not needed for deployment.
	function getAddr() external view returns(address){
		return address(this);
	}

	function setMaxSuply(uint256 _newSupply) external onlyOwner{
		MAX_SUPPLY = _newSupply;
	}

	constructor() ERC721('TestNFT', 'TN') {
		setMintTokenAddress(0x8c7a60ac2B87CDFfD7b3d9d5e3F8f814d4D596a2);
	}

	/*-------------------------------------------------*/

	// CHECK REENTRANCY
	// Function to mint A new Yeti NFT.
	function mintYeti(uint256 _amount, uint256 _tokenAmount) public payable nonReentrant{
		require(totalSupply() < MAX_SUPPLY, "Max supply reached.");
		require(_amount == mintPrice.mul(_tokenAmount), "Incorrect minting price given.");
		require(totalSupply().add(_tokenAmount) <= MAX_SUPPLY, "Purchase would exceed max supply.");
		require(_tokenAmount <= MAX_MINT, "Invalid amount to mint at once.");

		// Transfer token from wallet to contract
		tokenInterface.transferFrom(address(msg.sender), address(this), _amount);

		for(uint i = 0; i < _tokenAmount; i++){
			_safeMint(msg.sender, totalSupply()+1);
		}

		if(totalSupply() > priceIncrease){
			mintPrice = 100 ether;
		}
	}



	function setPriceIncreaseNumber(uint256 _newNumber) external onlyOwner{
		priceIncrease = _newNumber;
	}

	function getMintingPrice() external view returns(uint256){
		return mintPrice;
	}

	function setMintingPrice(uint256 _price) external onlyOwner{
		mintPrice = _price;
	}

	function getMintTokenAddress() external view returns(address){
		return mintToken;
	}

	function setMintTokenAddress(address _newMintToken) public onlyOwner{
		mintToken = _newMintToken;
		tokenInterface = ERC20Interface(mintToken);
	}

	function withdraw() external onlyOwner{
        tokenInterface.transfer(address(msg.sender),tokenInterface.balanceOf(address(this)));
	}

	function _generateRandomAttribute(uint256 _yetiId, string memory _attribute, string[] memory _attributeList) private view returns(uint256) {
		require(_yetiId <= totalSupply(), "Yeti not minted yet!");
		// Use attribute name and NFT number to generate randomness.
		string memory str = string(abi.encodePacked(toString(_yetiId), _attribute));
		uint256 rand = uint256(keccak256(abi.encodePacked(str)));

		return rand % _attributeList.length;
	}

	function _generateRandomWeightedAttribute(uint256 _yetiId, string memory _attribute, uint256[] memory _weights) private view returns(uint256) {
		require(_yetiId <= totalSupply(), "Yeti not minted yet!");
		// Use attribute name and NFT number to generate randomness.
		string memory str = string(abi.encodePacked(toString(_yetiId), _attribute));
		uint256 rand = uint256(keccak256(abi.encodePacked(str)));

		// Calculate the sum of all the weights
		uint256 weightSum = 0;
		for(uint i = 0; i < _weights.length; i++){
			weightSum += _weights[i];
		}
		rand = rand % weightSum;
		
		uint256 sumTrait = 0;

		for(uint256 i = 0; i < _weights.length; i++){
			sumTrait += _weights[i];
			if(rand <= sumTrait){
				return i;
			}
		}

		return 0;
	}

	// Implement tokenURI
	function _baseURI() internal view virtual override returns(string memory){
		return _customBaseURI;
	}
	function setBaseURI(string memory _newURI) external onlyOwner{
		_customBaseURI = _newURI;
	}

	function getBackground(uint256 _tokenId) public view returns(string memory){
		return _background[_generateRandomAttribute(_tokenId, "BACKGROUND", _background)];
	}

	function getEyes(uint256 _tokenId) public view returns(string memory){
		return _eyes[_generateRandomAttribute(_tokenId, "EYES", _eyes)];
	}

	function getFur(uint256 _tokenId) public view returns(string memory){
		return _fur[_generateRandomWeightedAttribute(_tokenId, "FUR", _weightsFur)];
	}

	function getHorns(uint256 _tokenId) public view returns(string memory){
		return _horns[_generateRandomAttribute(_tokenId, "HORNS", _horns)];
	}

	function getMouth(uint256 _tokenId) public view returns(string memory){
		return _mouth[_generateRandomWeightedAttribute(_tokenId, "MOUTH", _weightsMouth)];
	}

	function getSkin(uint256 _tokenId) public view returns(string memory){
		return _skin[_generateRandomAttribute(_tokenId, "SKIN", _skin)];
	}



	// Function for converting uint256 to string
	function toString(uint256 value) internal pure returns (string memory) {
	    // Inspired by OraclizeAPI's implementation - MIT license
	    // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

	        if (value == 0) {
	            return "0";
	        }
	        uint256 temp = value;
	        uint256 digits;
	        while (temp != 0) {
	            digits++;
	            temp /= 10;
	        }
	        bytes memory buffer = new bytes(digits);
	        while (value != 0) {
	            digits -= 1;
	            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
	            value /= 10;
	        }
	        return string(buffer);
	    }

}

