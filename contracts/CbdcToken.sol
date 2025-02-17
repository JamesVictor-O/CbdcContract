// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./interface/IERC20.sol";

contract MyToken is ERC20,IMyToken {
    mapping(address => bool) public minters;
    address public owner;

    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
        owner=msg.sender;
        _mint(msg.sender, 1000 * 10**18);
    }

    modifier onlyOwner() {
            require(msg.sender == owner, "Only the owner can call this");
        _;
    }

    modifier onlyMinter() {
        require(minters[msg.sender], "Not a minter");
        _;
    }

    //  Function to add a minter (onlyOwner can call)
    function addMinter(address minter) public onlyOwner {
        minters[minter] = true;
    }

    // Mint function that allows approved minters
    function mint(address to, uint256 amount) public onlyMinter{
        _mint(to, amount);
    }
}
