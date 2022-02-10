// SPDX-License-Identifier: MIT
pragma solidity >= 0.5.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract YetiMinter {
	using SafeMath for uint256;
	
	// struct Yeti {
	// 	string accessory;
	// 	string eyes;
	// 	string fur;
	// 	string horns;
	// 	string mouth;
	// 	string skin;
	// }

	Yeti[] public yetis;

	string[] private eyes = [
		"Angry Eyes",
		"Bored Eyes",
		"Eye Patch",
		"Glasses",
		"Happy Eyes",
		"Normal Eyes",
		"Pissed Eyes",
		"Shades",
		"Sleeping Eyes"];

	// Function to mint A new Yeti NFT.
	function mintYeti() public {


		// yetis.push(Yeti(
		// 	accessory, 
		// 	eyes, 
		// 	fur, 
		// 	horns, 
		// 	mouth, 
		// 	skin
		// 	));
	}

	function _generateRandomAttribute(uint256 _yetiId, string memory _attribute, string[] memory _attributeList) private view returns(uint256) {
		// Use attribute name and NFT number to generate randomness.
		// string yetiId = toString(_yetiId);
		// string str = string( abi.encodePacked(_attribute, yetiId) );
		string memory str = string(abi.encodePacked(toString(_yetiId), _attribute));
		uint256 rand = uint256(keccak256(abi.encodePacked(str)));
		return rand % _attributeList.length;
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

