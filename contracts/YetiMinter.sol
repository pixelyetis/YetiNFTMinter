// SPDX-License-Identifier: MIT
pragma solidity >= 0.5.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";


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


contract YetiMinter is ERC721Enumerable, Ownable{
	using SafeMath for uint256;

	uint256 public MAX_SUPPLY = 420;
	uint256 public mintPrice = 50 ether;

	address mintToken = 0x9a946c3Cb16c08334b69aE249690C236Ebd5583E;
	ERC20Interface tokenInterface = ERC20Interface(mintToken);

	
	struct Yeti {
		string accessory;
		string eyes;
		string fur;
		string horns;
		string mouth;
		string skin;
	}

	Yeti[] private yetis;

	// String array of all available traits.
	string[] private accessories = ["Beanie", "Bowtie", "Cigarette", "Fast Food","Headphones", "None", "Nose Piercing"];
	string[] private eyes = ["Angry Eyes","Bored Eyes", "Eye Patch", "Glasses", "Happy Eyes", "Normal Eyes", "Pissed Eyes", "Shades", "Sleeping Eyes"];
	string[] private fur = ["Beige Fur", "Blue Fur", "Blue Fur Striped", "Gray Fur", "Gray Fur Checkered", "Gray Fur", "Pixelated Fur", "Rainbow Fur", "White Fur", "White Fur Striped"];
	string[] private horns = ["Black Horns", "Blue Horns", "Orange Horns", "Red Horns", "Yellow Horns"];
	string[] private mouth = ["Happy Mouth", "Normal Mouth", "Rainbow Mouth", "Rainbow Mouth Wave 1", "Rainbow Mouth Wave 2", "Sad Mouth", "Teeth"];
	string[] private skin = ["Blue Skin", "Dark Blue Skin", "Green Skin",  "Orange Skin", "Pink Skin", "Purple Skin"];


	constructor() ERC721('TestNFT', 'TN') {
	}


	// Use for testing purposes. Not needed for deployment.
	function getAddr() external view returns(address){
		return address(this);
	}

	// Function to mint A new Yeti NFT.
	function mintYeti(uint256 _amount) public payable{
		require(totalSupply() < MAX_SUPPLY, "Max supply reached.");
		require(_amount == mintPrice, "Incorrect minting price given.");

		// Transfer token from wallet to contract
		tokenInterface.transferFrom(address(msg.sender), address(this), _amount);

		uint256 mintIndex = totalSupply();

		yetis.push(Yeti(
			accessories[_generateRandomAttribute(mintIndex, "ACCESSORIES", accessories)],
			eyes[_generateRandomAttribute(mintIndex, "EYES", eyes)], 
			fur[_generateRandomAttribute(mintIndex, "FUR", fur)],
			horns[_generateRandomAttribute(mintIndex, "HORNS", horns)], 
			mouth[_generateRandomAttribute(mintIndex, "MOUTH", mouth)], 
			skin[_generateRandomAttribute(mintIndex, "SKIN", skin)]
			));

		_safeMint(msg.sender, mintIndex);


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

	function setMintTokenAddress(address _newMintToken) external onlyOwner{
		mintToken = _newMintToken;
		tokenInterface = ERC20Interface(mintToken);
	}

	function withdraw() external onlyOwner{
        payable(msg.sender).transfer(address(this).balance);
	}

	function _generateRandomAttribute(uint256 _yetiId, string memory _attribute, string[] memory _attributeList) private pure returns(uint256) {
		// Use attribute name and NFT number to generate randomness.
		// string yetiId = toString(_yetiId);
		// string str = string( abi.encodePacked(_attribute, yetiId) );
		string memory str = string(abi.encodePacked(toString(_yetiId), _attribute));
		uint256 rand = uint256(keccak256(abi.encodePacked(str)));
		return rand % _attributeList.length;
	}

	// Implement tokenURI

	function getAccessory(uint256 _tokenId) public view returns(string memory){
		return(yetis[_tokenId].accessory);
	}

	function getEyes(uint256 _tokenId) public view returns(string memory){
		return(yetis[_tokenId].eyes);
	}

	function getFur(uint256 _tokenId) public view returns(string memory){
		return(yetis[_tokenId].fur);
	}

	function getHorns(uint256 _tokenId) public view returns(string memory){
		return(yetis[_tokenId].horns);
	}

	function getMouth(uint256 _tokenId) public view returns(string memory){
		return(yetis[_tokenId].mouth);
	}

	function getSkin(uint256 _tokenId) public view returns(string memory){
		return(yetis[_tokenId].skin);
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

