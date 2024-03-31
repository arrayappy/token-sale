// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {ERC20} from "@openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract EliteToken is ERC20 ("Elite Token", "ELT"){
    constructor() {
        _mint(msg.sender, 100000 * (10**18));
    }
}
