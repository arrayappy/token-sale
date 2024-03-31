// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Script, console2} from "forge-std/Script.sol";
import {EliteToken} from "../src/MyToken.sol";
import {TokenSale} from "../src/TokenSale.sol";

contract DeployScript is Script {
    EliteToken public token;
    TokenSale public sale;
    function run() public {
        vm.startBroadcast();
        token = new EliteToken();
        sale = new TokenSale(address(token));
        token.transfer(address(sale), 10000); // 10000 tokens for presale + publicsale use
        vm.stopBroadcast();
    }
}
