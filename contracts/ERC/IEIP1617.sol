// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface EIP1617{
    event TokenIsExpire(uint indexed tokenId);

    function tokenSubscribeExtend(uint _tokenID, uint _time) external payable;

    function tokenSubscribeRevoke(uint _tokenID) external;

    function isTokenExpire(uint _tokenID) external returns (bool);

    function queryTokenExpire(uint _tokenID) external returns(uint);
}