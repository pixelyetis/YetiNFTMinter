// SPDS-License-Identifier: MIT
pragma solidity >= 0.5.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract YetiMinter {
	
	struct Yeti {
		string accessory;
		string eyes;
		string fur;
		string horns
		string mouth;
		string skin;
	}

	Yeti[] public yetis;

	// Function to mint A new Yeti NFT.
	function mintYeti() public {


		yetis.push(Yeti(accessory, eyes, fur, horns, mouth, skin));
	}

	function _generateRandomAttributes(uint256 yetiId) private vew returns(uint) {
		// Use attribute name and NFT number to generate randomness.
		uint randAccessory = uint(keccak256(abi.encodePacked("Accessory", toString(yetiId))));
	}

}