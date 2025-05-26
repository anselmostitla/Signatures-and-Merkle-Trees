// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

// forge install OpenZeppelin/openzeppelin-contracts --no-commit 
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract BaguelToken is ERC20, Ownable {

   constructor() ERC20("Baguel", "BAGUEL") Ownable(msg.sender){
   }

   function mint(address to, uint256 amount) external onlyOwner{
      _mint(to, amount);
   }
   
}