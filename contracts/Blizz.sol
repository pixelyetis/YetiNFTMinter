// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Blizz is ERC20{

	constructor(string memory name, string memory symbol) ERC20(name, symbol){
		// Mint 1000 token to msg.sender
		_mint(msg.sender, 100000 * 10 ** uint(decimals()));
	}

	function getAddr() external view returns(address){
		return address(this);
	}

	function gimmieSome(uint _amount) external {
		_mint(msg.sender, _amount * 10 ** uint(decimals()));
	}
}