/*
Requirements:
1. Minting new tokens: The platform should be able to create new tokens and distribute them to players as rewards. Only the owner can mint tokens.
2. Transferring tokens: Players should be able to transfer their tokens to others.
3. Redeeming tokens: Players should be able to redeem their tokens for items in the in-game store.
4. Checking token balance: Players should be able to check their token balance at any time.
5. Burning tokens: Anyone should be able to burn tokens, that they own, that are no longer needed.
*/// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract DegenToken is ERC20, Ownable {
    uint256 public constant REDEMPTION_RATE = 100; // This will specify how much an item is
    mapping(address => uint256) public stevenTokenOwned;

    // Struct to define an item with its redemption cost
    struct Item {
        uint256 costInTokens;
    }

    // Mapping of item names to their respective costs
    mapping(string => Item) public items;

    // Mapping to track user's owned items
    mapping(address => mapping(string => uint256)) public userItems;

    constructor() ERC20("Degen", "DGN") {
        _mint(msg.sender, 10 * (10 ** uint256(decimals())));
    
        // In-game store
        addItem("Item A", 100);
        addItem("Item B", 200);
        addItem("Item C", 300);
    }

    // Function to add a new item with its cost
    function addItem(string memory itemName, uint256 costInTokens) internal {
        items[itemName] = Item(costInTokens);
    }

    // Function to redeem an item by name
    function redeemStevenToken(string memory itemName, uint256 quantity) public {
        uint256 cost = items[itemName].costInTokens * quantity;
        require(balanceOf(msg.sender) >= cost, "Not enough tokens to redeem for this item");
        stevenTokenOwned[msg.sender] += quantity;
        _burn(msg.sender, cost);

        // Track user's ownership of the item
        userItems[msg.sender][itemName] += quantity;
    }

    // Function to check how many Steven Tokens a user owns
    function checkStevenTokenOwned(address user) public view returns (uint256) {
        return stevenTokenOwned[user];
    }

    // Function to check which items a user owns
    function checkUserItems(address user, string memory itemName) public view returns (uint256) {
        return userItems[user][itemName];
    }

    // Function to mint tokens (only owner can mint)
    function mintTokens(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    // Function to burn tokens that they no longer need
    function burnTokens(uint256 amount) public {
        require(balanceOf(msg.sender) >= amount, "Not enough tokens to burn");
        _burn(msg.sender, amount);
    }

    // Function for transferring tokens to different addresses 
    function transferTokens(address to, uint256 amount) public {
        require(to != address(0), "Invalid address");
        require(balanceOf(msg.sender) >= amount, "Not enough tokens to transfer");
        _transfer(msg.sender, to, amount);
    }
}
