
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title Gaming Loot Box Fractionalization
 * @dev This contract allows users to fractionalize ownership of loot boxes (NFTs)
 * into ERC20 tokens, enabling shared ownership and trade.
 */
contract Project {
    struct LootBox {
        uint256 id;
        address owner;
        uint256 totalShares;
        uint256 sharePrice;
        mapping(address => uint256) sharesOwned;
    }

    uint256 public lootBoxCount;
    mapping(uint256 => LootBox) public lootBoxes;

    event LootBoxCreated(uint256 indexed id, address indexed owner, uint256 totalShares, uint256 sharePrice);
    event SharesPurchased(uint256 indexed id, address indexed buyer, uint256 shares);
    event LootBoxRedeemed(uint256 indexed id, address indexed owner);

    /**
     * @notice Create a new Loot Box with fractional shares
     * @param _totalShares Total shares available for purchase
     * @param _sharePrice Price per share in wei
     */
    function createLootBox(uint256 _totalShares, uint256 _sharePrice) external {
        require(_totalShares > 0, "Invalid total shares");
        require(_sharePrice > 0, "Invalid share price");

        lootBoxCount++;
        LootBox storage box = lootBoxes[lootBoxCount];
        box.id = lootBoxCount;
        box.owner = msg.sender;
        box.totalShares = _totalShares;
        box.sharePrice = _sharePrice;

        emit LootBoxCreated(lootBoxCount, msg.sender, _totalShares, _sharePrice);
    }

    /**
     * @notice Purchase shares of a specific loot box
     * @param _id Loot box ID
     * @param _shares Number of shares to buy
     */
    function buyShares(uint256 _id, uint256 _shares) external payable {
        LootBox storage box = lootBoxes[_id];
        require(box.id != 0, "Loot box not found");
        require(msg.value == box.sharePrice * _shares, "Incorrect payment");
        require(_shares <= box.totalShares, "Not enough shares left");

        box.sharesOwned[msg.sender] += _shares;
        box.totalShares -= _shares;

        emit SharesPurchased(_id, msg.sender, _shares);
    }

    /**
     * @notice Redeem loot box once all shares are sold
     * Only the original owner can redeem after all shares are distributed.
     */
    function redeemLootBox(uint256 _id) external {
        LootBox storage box = lootBoxes[_id];
        require(msg.sender == box.owner, "Not the owner");
        require(box.totalShares == 0, "All shares not sold");

        emit LootBoxRedeemed(_id, msg.sender);
    }
}
