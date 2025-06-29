// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Test, console} from "forge-std/Test.sol";

// importing our protocol
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {BaguelToken} from "../src/BaguelToken.sol";

// importing our deployer
import { DeployMerkleAirdrop } from "../script/DeployMerkleAirdrop.s.sol";

// importing the rest
import { ZkSyncChainChecker } from "lib/foundry-devops/src/ZkSyncChainChecker.sol";


contract MerkleAirdropTest is ZkSyncChainChecker, Test{
   // Our protocol variables
   MerkleAirdrop public airdrop;
   BaguelToken public token;

   bytes32 public ROOT = 0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;
   uint256 public AMOUNT_TO_CLAIM = 25*1e18;
   uint256 public AMOUNT_TO_SEND = AMOUNT_TO_CLAIM * 4;
   bytes32[] public PROOF;

   address gasPayer;
   address user;
   uint256 userPrivKey;

   function setUp() public{
      if(!isZkSyncChain()){
         // deploy with the script
         DeployMerkleAirdrop deployer = new DeployMerkleAirdrop();
         (airdrop, token) = deployer.deployMerkleAirdrop(); 
      }
      token = new BaguelToken();
      airdrop = new MerkleAirdrop(ROOT, token);
      token.mint(token.owner(), AMOUNT_TO_SEND);
      token.transfer(address(airdrop), AMOUNT_TO_SEND);
      (user, userPrivKey) = makeAddrAndKey("user");
      gasPayer = makeAddr("gasPayer");

      // Set PROOF dynamically
      PROOF.push(0x0fd7c981d39bece61f7499702bf59b3114a90e66b51ba2c53abdf7b62986c00a);
      PROOF.push(0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576);
   }

   function testUserCanClaim() public{
      console.log("use addr: %s", user);
      uint256 startingBalance = token.balanceOf(user);
      console.log("startingBalance: ", startingBalance);

      bytes32[] memory proof = new bytes32[](PROOF.length);
      for (uint256 i = 0; i< PROOF.length; i++){
         proof[i] = PROOF[i];
      }

      bytes32 digest = airdrop.getMessage(user, AMOUNT_TO_CLAIM);
      (uint8 v, bytes32 r, bytes32 s) = vm.sign(userPrivKey, digest);

      vm.prank(gasPayer);
      airdrop.claim(user, AMOUNT_TO_CLAIM, proof, v, r, s);  
      

      uint256 endingBalance = token.balanceOf(user);

      console.log("Ending Balance: ", endingBalance);
   }

}

