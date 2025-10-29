//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import {FundMe} from "./FundMe.sol";

contract FuncTokenERC20 is ERC20{
    FundMe fundMe;
    address private owner;

    constructor(address fundMeAddr) ERC20("FuncTokenERC20", "FT"){
        owner = msg.sender;
        fundMe = FundMe(fundMeAddr);
    }

    function mint(uint256 amountToMint) public{
        require(fundMe.funders(msg.sender) >= amountToMint, "You have not enough coin");
        require(fundMe.fundSuccess(), "Fund not success");
        _mint(msg.sender, amountToMint);
        fundMe.setFunderAmount(msg.sender, fundMe.funders(msg.sender) - amountToMint);
    }


}