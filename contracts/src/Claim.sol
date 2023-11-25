// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

error InvalidProof();

contract Claim {
    bytes32 public root;
    address public immutable treasury;
    ERC20 public immutable rewardToken;
    uint256 public timeout;
    mapping(uint256 => mapping( address => bool)) public claims;
    uint256 currentEpoch;

    constructor(bytes32 _root, address _treasury, ERC20 _rewardToken, uint256 _timeout) {
        root = _root;
        treasury = _treasury;
        rewardToken = _rewardToken;
        timeout = _timeout;
    }

    function isClaimed(address _account) public view returns(bool) {
        return claims[currentEpoch][_account];
    }

    function claim(
        bytes32[] memory proof,
        address _account,
        uint256 _amount
    ) public {
        bytes32 leaf = keccak256(
            bytes.concat(keccak256(abi.encode(_account, _amount)))
        );
        if(!MerkleProof.verify(proof, root, leaf)){
            revert InvalidProof();
        }
        rewardToken.transfer(_account,_amount);
        claims[currentEpoch][_account] = true;
    }

    function endAirdrop() public {
      require(
         block.timestamp > timeout,
         "Claim: Timeout hasn't expired"
      );
      rewardToken.transfer(treasury, rewardToken.balanceOf(address(this)));
   }
}
