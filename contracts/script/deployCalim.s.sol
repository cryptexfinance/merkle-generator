// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import "../src/Claim.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ClaimScript is Script {
    Claim public claim;
    ERC20 ctx = ERC20(0x321C2fE4446C7c963dc41Dd58879AF648838f98D);
    address treasury = 0xa54074b2cc0e96a43048d4a68472F7F046aC0DA8;
    bytes32 merkleRoot =
        0xf20bb2a7174235c4d136fadf01cd41994ead61d76801bedd511b4372cca4ae6f;
    uint256 epochDuration = 13 weeks;

    function run() public {
        vm.startBroadcast();
        claim = new Claim(merkleRoot, treasury, ctx, epochDuration);
        vm.stopBroadcast();
    }
}
