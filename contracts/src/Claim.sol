// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract Claim is Ownable, ReentrancyGuard {
    bytes32 public root;
    address public immutable treasury;
    ERC20 public immutable rewardToken;
    uint256 public epochDuration;
    uint256 public claimPeriod;
    mapping(uint256 => mapping(address => bool)) public claims;
    uint256 public currentEpoch;

    error InvalidProof();
    error AlreadyClaimed();
    error ClaimPeriodExpired();
    error ClaimPeriodNotExpired();

    modifier onlyExpired() {
        if (block.timestamp <= claimPeriod) {
            revert ClaimPeriodNotExpired();
        }
        _;
    }

    constructor(
        bytes32 _root,
        address _treasury,
        ERC20 _rewardToken,
        uint256 _epochDuration
    ) Ownable(msg.sender) {
        root = _root;
        treasury = _treasury;
        rewardToken = _rewardToken;
        epochDuration = _epochDuration;
        /// @notice We assume deploy starts the first reward epoch
        claimPeriod = block.timestamp + _epochDuration;
    }

    function claim(
        bytes32[] memory proof,
        address _account,
        uint256 _amount
    ) external nonReentrant {
        if (block.timestamp > claimPeriod) {
            revert ClaimPeriodExpired();
        }
        if (isClaimed(_account)) {
            revert AlreadyClaimed();
        }
        bytes32 leaf = keccak256(
            bytes.concat(keccak256(abi.encode(_account, _amount)))
        );
        if (!MerkleProof.verify(proof, root, leaf)) {
            revert InvalidProof();
        }
        claims[currentEpoch][_account] = true;
        rewardToken.transfer(_account, _amount);
    }

    function newEpoch(bytes32 _root) external onlyOwner onlyExpired {
        root = _root;
        currentEpoch++;
        claimPeriod = block.timestamp + epochDuration;
    }

    function endAirdrop() external onlyOwner onlyExpired nonReentrant {
        rewardToken.transfer(treasury, rewardToken.balanceOf(address(this)));
    }

    function isClaimed(address _account) public view returns (bool) {
        return claims[currentEpoch][_account];
    }
}
