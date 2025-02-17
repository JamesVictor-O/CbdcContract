 // SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

   interface IMyToken is IERC20 {
        // Custom functions
        function mint(address to, uint256 amount) external;
        function addMinter(address minter) external;
        function minters(address minter) external view returns (bool);
    }