// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IEIP1617.sol";

contract ERC1617 is EIP1617 {
    /* 基于token进行时间定义 */
    mapping(uint => uint) private subscribeTokens;
    /* 基于user进行时间定义 */
    mapping(address => uint) private userMostExprieTokenIDs;

    /* 基本配置项，延长时间与价格 */
    struct SubscribeConfig {
        uint time;
        uint price;
    }

    SubscribeConfig private subscribeConfig;

    /* 配置初始化 */
    constructor(uint _time, uint _subscribePrice) {
        subscribeConfig.time = _time;
        subscribeConfig.price = _subscribePrice;
    }

    /* 延长toke订阅时长 */
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

    /* 销毁token时长 */
    function tokenSubscribeRevoke(uint _tokenID) external override {
        _tokenSubscribeRevoke(_tokenID);
    }

    /* token是否过期 */
    function isTokenExpire(uint _tokenID)
        external
        view
        override
        returns (bool)
    {
        return _isTokenExpire(_tokenID);
    }

    /* user是否过期-基于用户持有的token中的最长订阅时长 */
    function isUserExpire(address _player) external override returns (bool) {
        uint _tokenID = userMostExprieTokenIDs[_player];
        bool isExpire = _isTokenExpire(_tokenID);
        return isExpire;
    }

    /* 查询token过期时间 */
    function queryTokenExpire(uint _tokenID)
        external
        view
        override
        returns (uint)
    {
        return _queryTokenExpire(_tokenID);
    }

    /* 查询用户过期时间-基于用户持有的token中的最长订阅时长 */
    function queryUserExpire(address _player)
        external
        view
        override
        returns (uint)
    {
        uint _tokenID = userMostExprieTokenIDs[_player];
        return _queryTokenExpire(_tokenID);
    }

    /* 内置方法 */
    function _isTokenExpire(uint _tokenID) internal view returns (bool) {
        bool isExpire = subscribeTokens[_tokenID] >= block.timestamp
            ? true
            : false;
        return isExpire;
    }

    /* 内置方法 */
    function _queryTokenExpire(uint _tokenID) internal view returns (uint) {
        return subscribeTokens[_tokenID];
    }

    /* 内置方法 */
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

    /* 内置方法 */
    function _tokenSubscribeRevoke(uint _tokenID) internal {
        subscribeTokens[_tokenID] = block.timestamp;
    }

    /* 内置方法 */
    function _changeSubscribeConfig(uint _time, uint _subscribePrice) internal {
        subscribeConfig.time = _time;
        subscribeConfig.price = _subscribePrice;
    }

    /* 内置方法-触发过期事件 */
    function _beforeOnlySubscribeService(uint _tokenID) internal {
        if (_isTokenExpire(_tokenID) == false) emit TokenIsExpire(_tokenID);
    }

    /* 以user作为订阅服务提供依据 */
    modifier onlySubscribeByUser() {
        uint mostExprieTokenID = userMostExprieTokenIDs[msg.sender];
        bool isExpire = _isTokenExpire(mostExprieTokenID);

        _beforeOnlySubscribeService(mostExprieTokenID);
        require(isExpire);
        _;
    }
}
