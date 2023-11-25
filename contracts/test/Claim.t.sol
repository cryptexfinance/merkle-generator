// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {Claim, InvalidProof} from "../src/Claim.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

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
    address account2 = 0xFa6863A6507c94ed52e9276F8A72479924E77a36;
    bytes32[] merkleProof2 = [
        bytes32(
            0xd5f83ff4c6a8aeac795e6eb5299f189d1b3607c97d2437d8429b33ad8daa95ec
        ),
        bytes32(
            0xcaa3f5d0507f2afd15a0ceeb98651a72787d45010683f4904d2320e37649ca27
        ),
        bytes32(
            0x868f547c5f517c4a7431baf4f2c63a9eee71159a37b7228b7ca503e8420b69bd
        ),
        bytes32(
            0x0dfa4119ebd28170dc436f4b1e0ec0292cf402eb443713cd0e66b8bec9b717bb
        ),
        bytes32(
            0xc818964e0b2b91dcaa9806e807da3cb7fd7ecc97daced9830ea2e8515a6500ff
        ),
        bytes32(
            0x49378176c3d375977f0cfea5ea21c593ae4ccf0dca8144bd77119ead42bb060c
        ),
        bytes32(
            0x047fe3d4474b8e980fc72bca8f3e338b722c49b5124a4d4948d30d2313cc1a8b
        ),
        bytes32(
            0xf3f0cc06e84f018ce89e529119dfe5d3435ff03d8d72cf85ccc94945cda29596
        )
    ];
    address account3 = 0xEf6FE9C9B351824c96e5C7a478C1e52BAdCBAEe0;

    function setUp() public {
        //set fork
        mainnetFork = vm.createSelectFork(vm.rpcUrl("mainnet"), blockNumber);

        claim = new Claim(merkleRoot, treasury, ctx, timeout);
        vm.prank(treasury);
        ctx.transfer(address(claim), 50_000 ether);
    }

    function test_SetUpState() public view{
        assert(claim.root() == merkleRoot);
        assert(address(claim.rewardToken()) == address(ctx));
        assert(claim.timeout() == 4 weeks);
        assert(ctx.balanceOf(address(claim)) == 50_000 ether);
        assert(claim.treasury() == treasury);
    }

    function test_claim_Revert_WhenInvalidProof() public {
        vm.expectRevert(InvalidProof.selector);
        claim.claim(merkleProof2, account1, 50 ether);
    }

    function test_claim_Revert_WhenInvalidValue() public {
        vm.expectRevert(InvalidProof.selector);
        claim.claim(merkleProof1, account1, 250 ether);
    }

    function test_claim_Revert_WhenInvalidAccount() public {
        vm.expectRevert(InvalidProof.selector);
        claim.claim(merkleProof1, account2, 50 ether);
    }

    function test_claim() public {
        assertEq(claim.isClaimed(account1), false, "already claimed");
        assertEq(ctx.balanceOf(account1), 0, "Balance not 0");
        claim.claim(merkleProof1, account1, 100 ether);
        assertEq(ctx.balanceOf(account1), 100 ether, "Balance not 100 CTX");
        assertEq(ctx.balanceOf(address(claim)), (50_000 ether - 100 ether), "Claim contract balance didn't change");
        assertEq(claim.isClaimed(account1), true, "isClaimed should be true");
    }

    //reset epochs, only claim after epoch

    // function test_claimFrom() public {
    //     ctx.transfer(address(claim), 10_000 ether);
    //     assert(claim.isClaimed(1) == false);
    //     assertEq(ctx.balanceOf(account2), 0);
    //     // user1.doClaim(claim, 1, account2, 50 ether, merkleProof2);
    //     assertEq(ctx.balanceOf(account2), 50 ether);
    //     assertEq(ctx.balanceOf(address(claim)), (10_000 ether - 50 ether));
    //     assertTrue(claim.isClaimed(1));
    // }

    // function testFail_alreadyClaimed() public {
    //     ctx.transfer(address(claim), 10_000 ether);
    //     claim.claim(0, account1, 50 ether, merkleProof1);
    //     // user1.doClaim(claim, 0, account1, 50 ether, merkleProof1);
    // }

    // function testFail_endAirdrop() public {
    //     ctx.transfer(address(claim), 10_000 ether);
    //     claim.endAirdrop();
    // }

    // function test_endAirdrop() public {
    //     assertEq(ctx.balanceOf(treasury), 0);
    //     ctx.transfer(address(claim), 10_000 ether);
    //     vm.warp(4 weeks + 1 seconds);
    //     claim.endAirdrop();
    //     assertEq(ctx.balanceOf(address(claim)), 0);
    //     assertEq(ctx.balanceOf(treasury), 10_000 ether);
    // }
}
