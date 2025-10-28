// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
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

    //目标募集资金
    uint256 constant TARGET = 500 * 10 ** 18;

    //部署时间
    uint256 public deployTime;

    //限制时间
    uint256 internal  limit_time;

    //美元汇率
    int256 public price;

    AggregatorV3Interface private priceFeed;

    constructor(uint256 _limit_time){
        owner = msg.sender;
        priceFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        deployTime = block.timestamp;
        limit_time = _limit_time;
        price = getLatestPrice();
    }

    function fund() external payable{
        require(transTUsd(msg.value) >= minimumUSD, string(abi.encodePacked("Please provide a minimum donation of $", (minimumUSD / 10**18).toString())));

        if (funders[msg.sender] > 0) {
            funders[msg.sender] += uint256(msg.value);    
        } else {
            funders[msg.sender] = uint256(msg.value);
        }
        
    }

    function getLatestPrice() public view returns (int256) {
        (, int256 answer, , , ) = priceFeed.latestRoundData(); //该地址支持这个方法
        return answer;
    }

    //将筹资转为美元
    function transTUsd(uint256 _fund) public view returns(uint256){
        return _fund * uint256(price) / 10 ** 8;
    }

    //提现
    function getFund() external onlyOwner fundGoalReached outLimitTime{
        (bool success, ) = owner.call{value: address(this).balance}("");
        require(success, "Transfer failed.");
    }
    //筹资不达标，获取自己的筹资
    function reFund() external onlyFunder fundGoalNotReached outLimitTime{
        (bool success, ) = msg.sender.call{value: funders[msg.sender]}("");
        require(success, "Transfer failed.");
        funders[msg.sender] = 0;
    }
    
    //修改发起人
    function changeOwner(address _newOwner) external onlyOwner{
        owner = _newOwner;
    }

    //只允许ower
    modifier onlyOwner(){
        require(msg.sender == owner, "Only owner can call this function!");
        _;
    }
    //只允许funder
    modifier onlyFunder(){
        require(funders[msg.sender] > 0, "Only funder can call this function!");
        _;
    }
    //筹资达标
    modifier fundGoalReached(){
        require(transTUsd(address(this).balance) >= TARGET, "Fund goal has not been reached");
        _;
    }
    //筹资不达标
    modifier fundGoalNotReached(){
        require(transTUsd(address(this).balance) < TARGET, "Fund goal has been reached");
        _;
    }
    //在限制期外
    modifier outLimitTime(){
        require(block.timestamp >= (deployTime + limit_time), "Now is in limit time");
        _;
    }
}