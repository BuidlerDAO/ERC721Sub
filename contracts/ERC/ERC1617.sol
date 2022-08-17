// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IEIP1617.sol";

contract ERC1617 is EIP1617 {
    mapping(uint => uint) private subscribeTokens;

    struct SubscribeConfig {
        uint time;
        uint price;
    }

    SubscribeConfig private subscribeConfig;

    constructor(uint _time, uint _subscribePrice) {
        subscribeConfig.time = _time;
        subscribeConfig.price = _subscribePrice;
    }

    function tokenSubscribeExtend(uint _tokenID, uint _time)
        external
        payable
        override
    {
        uint subscribeNeedPay = (_time / subscribeConfig.time) *
            subscribeConfig.price;
        require(msg.value >= subscribeNeedPay);
        _tokenSubscribeExtend(_tokenID, _time);
    }

    function tokenSubscribeRevoke(uint _tokenID) external override {
        _tokenSubscribeRevoke(_tokenID);
    }

    function isTokenExpire(uint _tokenID)
        external
        view
        override
        returns (bool)
    {
        return _isTokenExpire(_tokenID);
    }

    function queryTokenExpire(uint _tokenID)
        external
        view
        override
        returns (uint)
    {
        return _queryTokenExpire(_tokenID);
    }

    function _isTokenExpire(uint _tokenID) internal view returns (bool) {
        bool isExpire = subscribeTokens[_tokenID] >= block.timestamp
            ? true
            : false;
        return isExpire;
    }

    function _queryTokenExpire(uint _tokenID) internal view returns (uint) {
        return subscribeTokens[_tokenID];
    }

    function _tokenSubscribeExtend(uint _tokenID, uint _time) internal {
        uint remainingTime = subscribeTokens[_tokenID] - block.timestamp;
        if (remainingTime >= 0) {
            subscribeTokens[_tokenID] += _time;
        } else {
            subscribeTokens[_tokenID] = block.timestamp + _time;
        }
    }

    function _tokenSubscribeRevoke(uint _tokenID) internal {
        subscribeTokens[_tokenID] = block.timestamp;
    }

    function _beforeSubscribeToken(uint _tokenID) internal {
        if (_isTokenExpire(_tokenID) == false) emit TokenIsExpire(_tokenID);
    }

    modifier onlySubscribeToken(uint _tokenID) {
        _beforeSubscribeToken(_tokenID);
        require(_isTokenExpire(_tokenID));
        _;
    }
}
