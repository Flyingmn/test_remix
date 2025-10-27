// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/utils/Strings.sol"; // 或直接使用内置 strings


/*
1. 接受转账，设置最小转账额度，单位美金
2. 统计转账人信息
3. 限制期满达标发起人可以提现
4. 限制期满未达标可以撤资
*/
contract FundMe{
    
    using Strings for uint256; // 扩展 uint256 类型

    address public owner;
    mapping(address => uint256) public funders;
    uint256 public minimumUSD = 50 * 10 ** 18;

    AggregatorV3Interface private priceFeed;

    constructor(){
        owner = msg.sender;
         priceFeed = AggregatorV3Interface(0x627D9d6c29D2C2B3DeAAb40263af2a474F49b130);
    }

    function fund() external payable{
        require(transTUsd(msg.value) >= minimumUSD, string(abi.encodePacked("Please provide a minimum donation of $", (minimumUSD / 10**18).toString())));

        funders[msg.sender] = uint256(msg.value);
    }

    function getLatestPrice() public view returns (int256) {
        (, int256 answer, , , ) = priceFeed.latestRoundData(); //该地址支持这个方法
        return answer;
    }

    //将筹资转为美元
    function transTUsd(uint256 _fund) public view returns(uint256){
        return _fund * uint256(getLatestPrice());
    }
}