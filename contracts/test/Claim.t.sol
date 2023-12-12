// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import "../src/Claim.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract ClaimTest is Test {
    // the identifiers of the forks
    uint256 mainnetFork;
    uint256 blockNumber = 18_643_049;

    // variables
    Claim public claim;
    ERC20 ctx = ERC20(0x321C2fE4446C7c963dc41Dd58879AF648838f98D);
    address treasury = 0xa54074b2cc0e96a43048d4a68472F7F046aC0DA8;
    bytes32 merkleRoot =
        0xec14f6f339cb57f9487917cbc578a8f05ec78d0b2c54b94ecc0e600b7b540042;
    address account1 = 0x097A3a6cE1D77a11Bda1AC40C08fDF9F6202103F;
    uint256 timeout = 4 weeks;
    bytes32[] merkleProof1 = [
        bytes32(
            0x581a2e80c5c62766708abb9f162e2a52b55dd4ba0bafe917881389da1d6a76d6
        )
    ];
    bytes32 merkleRoot2 =
        0xef9783ca85748ad7f54f24f9a88ec14ba2ab3c8341b5831d03d0ae428ecbcceb;
    bytes32[] merkleProof2 = [
        bytes32(
            0xb20c626570fbfd805f8f925a84ebd487bd84e1536f833ade93ebe7d03a4724e1
        ),
        bytes32(
            0x022fb3149ddd5136ffa457821dbffdd9d4ef9cfaca49f1938b4b3c0011339080
        )
    ];
    address account2 = 0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045;

    function setUp() public {
        //set fork
        mainnetFork = vm.createSelectFork(vm.rpcUrl("mainnet"), blockNumber);
        claim = new Claim(merkleRoot, treasury, ctx, timeout);
        vm.prank(treasury);
        ctx.transfer(address(claim), 50_000 ether);
    }

    function test_SetUpState() public view {
        assert(claim.root() == merkleRoot);
        assert(address(claim.rewardToken()) == address(ctx));
        assert(claim.timeout() == 4 weeks);
        assert(ctx.balanceOf(address(claim)) == 50_000 ether);
        assert(claim.treasury() == treasury);
        assert(claim.owner() == address(this));
        assert(claim.claimPeriod() == block.timestamp + timeout);
    }

    function test_claim_Revert_WhenInvalidProof() public {
        vm.expectRevert(Claim.InvalidProof.selector);
        claim.claim(merkleProof2, account1, 50 ether);
    }

    function test_claim_Revert_WhenInvalidValue() public {
        vm.expectRevert(Claim.InvalidProof.selector);
        claim.claim(merkleProof1, account1, 250 ether);
    }

    function test_claim_Revert_WhenInvalidAccount() public {
        vm.expectRevert(Claim.InvalidProof.selector);
        claim.claim(merkleProof1, account2, 50 ether);
    }

    function test_claim() public {
        assertEq(claim.isClaimed(account1), false, "already claimed");
        assertEq(ctx.balanceOf(account1), 0, "Balance not 0");
        claim.claim(merkleProof1, account1, 100 ether);
        assertEq(ctx.balanceOf(account1), 100 ether, "Balance not 100 CTX");
        assertEq(
            ctx.balanceOf(address(claim)),
            (50_000 ether - 100 ether),
            "Claim contract balance didn't change"
        );
        assertEq(claim.isClaimed(account1), true, "isClaimed should be true");
    }

    function test_claim_WhenCalledFromOtherAddress() public {
        assertEq(claim.isClaimed(account1), false, "already claimed");
        assertEq(ctx.balanceOf(account1), 0, "Balance not 0");
        vm.prank(account2);
        claim.claim(merkleProof1, account1, 100 ether);
        assertEq(ctx.balanceOf(account1), 100 ether, "Balance not 100 CTX");
        assertEq(
            ctx.balanceOf(address(claim)),
            (50_000 ether - 100 ether),
            "Claim contract balance didn't change"
        );
        assertEq(claim.isClaimed(account1), true, "isClaimed should be true");
    }

    function test_claim_ShouldFail_IfClaimed() public {
        claim.claim(merkleProof1, account1, 100 ether);
        vm.expectRevert(Claim.AlreadyClaimed.selector);
        claim.claim(merkleProof1, account1, 100 ether);
        assertEq(ctx.balanceOf(account1), 100 ether, "Balance not 100 CTX");
        assertEq(
            ctx.balanceOf(address(claim)),
            (50_000 ether - 100 ether),
            "Claim contract balance didn't change"
        );
        assertEq(claim.isClaimed(account1), true, "isClaimed should be true");
    }

    function test_claim_ShouldFail_IfClaimPeriodExpired() public {
        vm.warp(claim.claimPeriod() + 1 seconds);
        vm.expectRevert(Claim.ClaimPeriodExpired.selector);
        claim.claim(merkleProof1, account1, 100 ether);
    }

    function test_endAirdrop_ShouldFail_WhenNotOwner() public {
        vm.prank(account1);
        vm.expectRevert(
            abi.encodeWithSelector(
                Ownable.OwnableUnauthorizedAccount.selector,
                account1
            )
        );
        claim.endAirdrop();
    }

    function test_endAirdrop_ShouldFail_WhenClaimPeriodNotExpired() public {
        vm.expectRevert(Claim.ClaimPeriodNotExpired.selector);
        claim.endAirdrop();
    }

    function test_endAirdrop_ShouldTransferTokens_WhenExpired() public {
        uint256 oldBalance = ctx.balanceOf(treasury);
        vm.warp(claim.claimPeriod() + 1 seconds);
        claim.endAirdrop();
        assert(ctx.balanceOf(address(claim)) == 0);
        assert(ctx.balanceOf(treasury) == oldBalance + 50_000 ether);
    }

    function test_newEpoch_ShouldRevert_WhenClaimPeriodNotExpired() public {
        vm.expectRevert(Claim.ClaimPeriodNotExpired.selector);
        claim.newEpoch(merkleRoot2);
    }

    function test_newEpoch_ShouldRevert_WhenNotOwner() public {
        vm.prank(account1);
        vm.expectRevert(
            abi.encodeWithSelector(
                Ownable.OwnableUnauthorizedAccount.selector,
                account1
            )
        );
        claim.newEpoch(merkleRoot2);
    }

    function test_newEpoch_ShouldStartNewEpoch() public {
          assertEq(claim.isClaimed(account1), false, "already claimed");
        assertEq(ctx.balanceOf(account1), 0, "Balance not 0");
        claim.claim(merkleProof1, account1, 100 ether);
        assertEq(ctx.balanceOf(account1), 100 ether, "Balance not 100 CTX");
        assertEq(
            ctx.balanceOf(address(claim)),
            (50_000 ether - 100 ether),
            "Claim contract balance didn't change"
        );
        assertEq(claim.isClaimed(account1), true, "isClaimed should be true");

        uint256 oldEpoch = claim.currentEpoch();
        uint256 oldPeriod = claim.claimPeriod() + 1 seconds;
        vm.warp(oldPeriod);
        claim.newEpoch(merkleRoot2);
        assertEq(claim.currentEpoch(), oldEpoch + 1, "Epoch didn't increase");
        assertEq(claim.claimPeriod(), oldPeriod + timeout);
        assertEq(claim.root(), merkleRoot2, "Merkle didn't change");
        // test claims after
        assertEq(claim.isClaimed(account1), false, "already claimed");
        assertEq(ctx.balanceOf(account1), 100 ether, "Balance not 100 CTX");
        claim.claim(merkleProof2, account1, 100 ether);
        assertEq(ctx.balanceOf(account1), 200 ether, "Balance not 200 CTX");
        assertEq(
            ctx.balanceOf(address(claim)),
            (50_000 ether - 200 ether),
            "Claim contract balance didn't change"
        );
        assertEq(claim.isClaimed(account1), true, "isClaimed should be true");
    }
}
