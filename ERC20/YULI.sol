// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.22;

import {ERC20} from "@openzeppelin/contracts@5.1.0/token/ERC20/ERC20.sol";
import {ERC20Burnable} from "@openzeppelin/contracts@5.1.0/token/ERC20/extensions/ERC20Burnable.sol";
import {Ownable} from "@openzeppelin/contracts@5.1.0/access/Ownable.sol";

contract YuliToken is ERC20, ERC20Burnable, Ownable {
    constructor(address initialOwner)
        ERC20("YULI", "YULI")
        Ownable(initialOwner)
    {
        _mint(msg.sender, 8000000000 * 10 ** decimals());
    }
}

