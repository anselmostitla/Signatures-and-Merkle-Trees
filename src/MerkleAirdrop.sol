// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";


contract MerkleAirdrop is EIP712{
   using SafeERC20 for IERC20;
   // I have a list of some addresses
   // Allow someone in the list to claim tokens
   error MerkleAirdrop__InvalidProof();
   error MerkleAirdrop__AlreadyClaimed();
   error MerkleAirdrop__InvalidSignatere();

   address[] claimers;
   bytes32 private immutable i_merkleRoot;
   IERC20 private immutable i_airdropToken;
   mapping (address claimer => bool claimed ) private s_hasClaimed;

   bytes32 MESSAGE_TYPEHASH = keccak256(
      "AirdropClaim(address account, uint256 amount)"
   ); // This is the hash of the complete type AirdropClaim

   struct AirdropClaim {
      address account;
      uint256 amount;
   }

   event Claim(address account, uint256 amount);
   
   constructor(bytes32 merkleRoot, IERC20 airdropToken) EIP712("MerkleAirdrop", "1"){
      i_merkleRoot = merkleRoot;
      i_airdropToken = airdropToken;
   }

   function claim(address account, uint256 amount, bytes32[] calldata merkleProof, uint8 v, bytes32 r, bytes32 s) external {
      if(s_hasClaimed[account]) revert MerkleAirdrop__AlreadyClaimed();
      if(!_isValidSignature(account, getMessage(account, amount), v, r, s)){
         revert MerkleAirdrop__InvalidSignatere();
      }
      // Calculate using the account and the amount, the hash which is going to be the leaf node
      bytes32 leaf = keccak256(abi.encode(account, amount));
      // Hash twice this avoids collisions (prevents second preimage attack)
      bytes32 leaf2 = keccak256(bytes.concat(leaf));

      if(!MerkleProof.verify(merkleProof, i_merkleRoot, leaf2)){
         revert MerkleAirdrop__InvalidProof();
      }

      s_hasClaimed[account] = true;
      emit Claim(account, amount);
      i_airdropToken.safeTransfer(account, amount);

   }

   function getMessage(address account, uint256 amount) public view returns(bytes32){
      return _hashTypedDataV4(
         keccak256(
            abi.encode(
               MESSAGE_TYPEHASH,
               AirdropClaim({account: account, amount: amount})
            )
         )
      );
   }

   function _isValidSignature(address account, bytes32 digest, uint8 v, bytes32 r, bytes32 s) internal pure returns(bool){
      require(account != address(0));
      (address veryRealSigner, ,) = ECDSA.tryRecover(digest, v, r, s);
      return veryRealSigner == account;
   }

   function getMerkleRoot() external view returns(bytes32) {
      return i_merkleRoot;
   }

   function getAirdropToken() external view returns(IERC20) {
      return i_airdropToken;
   }

   

}