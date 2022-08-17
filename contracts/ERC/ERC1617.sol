// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IEIP1617.sol";

contract ERC1617 is EIP1617 {
    /* 基于token进行时间定义 */
    mapping(uint => uint) private subscribeTokens;
    /* 基于user进行时间定义 */
    mapping(address => uint) private userMostExprieTokenIDs;

    struct SubscribeConfig {
        uint time;
        uint price;
    }

    SubscribeConfig private subscribeConfig;

    constructor(uint _time, uint _subscribePrice) {
        subscribeConfig.time = _time;
        subscribeConfig.price = _subscribePrice;
    }

    function tokenSubscribeExtend(
        address _player,
        uint _tokenID,
        uint _time
    ) external payable override {
        uint subscribeNeedPay = (_time / subscribeConfig.time) *
            subscribeConfig.price;
        require(msg.value >= subscribeNeedPay);
        _tokenSubscribeExtend(_player, _tokenID, _time);
    }

    function tokenSubscribeRevoke(address _player, uint _tokenID)
        external
        override
    {
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

    function isUserExpire(address _player)
        external
        view
        override
        returns (bool)
    {
        uint userMostExprieTokenID = userMostExprieTokenIDs[_player];
        uint isExpire = isTokenExpire(userMostExprieTokenID);
        return isExpire;
    }

    function queryTokenExpire(uint _tokenID)
        external
        view
        override
        returns (uint)
    {
        return _queryTokenExpire(_tokenID);
    }

    function queryUserExpire(address _player)
        external
        view
        override
        returns (uint)
    {
        uint _tokenID = userMostExprieTokenIDs[_player];
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

    function _tokenSubscribeExtend(
        address _player,
        uint _tokenID,
        uint _time
    ) internal {
        uint tokenRemainingTime = subscribeTokens[_tokenID] - block.timestamp;
        tokenRemainingTime >= 0
            ? subscribeTokens[_tokenID] += _time
            : subscribeTokens[_tokenID] = block.timestamp + _time;

        uint userMostExprie = userMostExprieTokenIDs[_player];

        /* 无代币 或 之前的代币时长<=新延时的代币时长，则更新userMostExprieTokenIDs */
        if (userMostExprie == 0 || userMostExprie < tokenRemainingTime) {
            userMostExprieTokenIDs[_player] = _tokenID;
        }
    }

    function _tokenSubscribeRevoke(uint _tokenID) internal {
        subscribeTokens[_tokenID] = block.timestamp;
    }

    function _changeSubscribeConfig(uint _time, uint _subscribePrice) internal {
        subscribeConfig.time = _time;
        subscribeConfig.price = _subscribePrice;
    }

    function _beforeOnlySubscribeService(uint _tokenID) internal {
        if (_isTokenExpire(_tokenID) == false) emit TokenIsExpire(_tokenID);
    }

    /* 以tokenID作为服务提供依据 */
    modifier onlySubscribeByToken(uint _tokenID) {
        _beforeOnlySubscribeService(_tokenID);
        require(_isTokenExpire(_tokenID));
        _;
    }

    /* 以msg.sender作为服务提供依据 */
    modifier onlySubscribeByUser() {
        uint mostExprieTokenID = userMostExprieTokenIDs[msg.sender];
        bool isExpire = _isTokenExpire(mostExprieTokenID);

        _beforeOnlySubscribeService(_tokenID);
        require(isExpire);
        _;
    }
}
