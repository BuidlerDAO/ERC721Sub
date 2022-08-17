// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./ERC/ERC1617.sol";

contract GameItem is ERC721URIStorage, ERC1617 {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    constructor() ERC721("ERC1617", "1617") ERC1617(0.01 ether, 7 days) {}

    function awardItem(address player, string memory tokenURI)
        public
        payable
        returns (uint256)
    {
        uint256 newItemId = _tokenIds.current();
        _mint(player, newItemId);
        _setTokenURI(newItemId, tokenURI);
        _tokenSubscribeExtend(newItemId, 7 days);

        _tokenIds.increment();
        return newItemId;
    }

    function SomeFunctionNeedSubscribeTokenToCall(uint _tokenID)
        public
        onlySubscribeToken(_tokenID)
    {
        // ...
    }
}
