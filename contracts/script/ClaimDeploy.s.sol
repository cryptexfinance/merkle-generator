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
        0xec14f6f339cb57f9487917cbc578a8f05ec78d0b2c54b94ecc0e600b7b540042; //TODO: Change to real merkle
    uint256 epochDuration = 4 weeks;

    function run() public {
        vm.startBroadcast();
        claim = new Claim(merkleRoot, treasury, ctx, epochDuration);
        vm.stopBroadcast();
    }
}
