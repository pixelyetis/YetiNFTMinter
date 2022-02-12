// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Blizz is ERC20{
	
	constructor(string memory name, string memory symbol) ERC20(name, symbol){
		// Mint 1000 token to msg.sender
		_mint(msg.sender, 1000 * 10 ** uint(decimals()));
	}
}