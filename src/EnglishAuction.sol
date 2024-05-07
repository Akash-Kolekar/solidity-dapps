// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

interface IERC721 {
    function transferFrom(address _from, address _to, uint256 _nftId) external;
}

contract EnglishAuction {
    error EnglishAuction__StartingPriceGreaterThanIncreasedPrice();

    uint32 private constant DURATION = 7 days;

    address payable public immutable seller;

    uint256 private immutable startAt;
    uint32 public endAt;
    uint256 private immutable startingPrice;
    uint256 private immutable increasedPrice;

    IERC721 public immutable nft;
    uint256 public immutable nftId;

    constructor(uint256 _startingPrice, uint256 _increasedPrice, IERC721 _nft, uint256 _nftId) {
        seller = payable(msg.sender);
        startAt = block.timestamp;
        endAt = uint32(block.timestamp + DURATION);
        startingPrice = _startingPrice;
        increasedPrice = _increasedPrice;

        if (_startingPrice >= increasedPrice * DURATION) {
            revert EnglishAuction__StartingPriceGreaterThanIncreasedPrice();
        }

        nft = _nft;
        nftId = _nftId;
    }

    function getPrice() public view returns (uint256) {
        uint256 timeElapsed = block.timestamp - startAt;
        uint256 increased = increasedPrice * timeElapsed;

        return startingPrice + increased;
    }

    function buy() external payable {
        require(block.timestamp < endAt, "auction expired");

        uint256 price = getPrice();
        require(msg.value >= price, "ETH < price");

        nft.transferFrom(seller, msg.sender, nftId);
        uint256 refund = msg.value - price;

        if (refund > 0) {
            payable(msg.sender).transfer(refund);
        }
    }
}
