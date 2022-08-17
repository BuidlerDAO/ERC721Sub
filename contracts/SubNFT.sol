// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./ERC/ERC1617.sol";

contract SubNFT is ERC721URIStorage, ERC1617, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    constructor() ERC721("ERC1617", "1617") ERC1617(0.01 ether, 7 days) {}

    /* 铸造可订阅功能的代币 */
    function mintAndSubscribe(address player, string memory tokenURI)
        public
        payable
        returns (uint256)
    {
        uint256 newItemId = _tokenIds.current();

        _mint(player, newItemId);
        _setTokenURI(newItemId, tokenURI);
        _tokenSubscribeExtend(player, newItemId, 7 days);

        _tokenIds.increment();
        return newItemId;
    }

    /* 修改订阅配置 */
    function changeSubscribeConfig(uint _time, uint _subscribePrice)
        public
        onlyOwner
    {
        _changeSubscribeConfig(_time, _subscribePrice);
    }

    /* 基于token为基准的，订阅即服务 */
    function someFunctionNeedSubscribeToService(uint _tokenID)
        public
        onlySubscribeByToken(_tokenID)
    {
        // some service module
    }

    /* 基于user为基准的，订阅即服务 */
    function someFunctionNeedSubscribeToService2() public onlySubscribeByUser {
        // some service module
    }
}
