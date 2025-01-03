// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

// 基金智能合约
// 1、创建一个募资方法
// 2、存储投资人并查询投资人的方法
// 3、在锁定期内，达到目标值，借款人可以提款
// 4、在锁定期内，未达到目标值，投资人可以退款

contract FundMe {
    /**
     *  关于原生通证不同单位换算
     *  10^9 Wei = 1 GWei
     *  10^6 Gwei = 1 Finney
     *  10^3 Finney = 1 Ether
     *
     */

    // 喂价接口
    AggregatorV3Interface internal dataFeed;

    // 定义一个HashMap：储存投资人钱包地址及对应投资金额
    mapping(address => uint256) public fundersToAmount;

    // 定义最小投资金额为：10 USD
    uint256 constant MIN_VALUE = 10 * 10**18;

    // 账户余额不能低于阈值: 100 USD
    uint256 constant TARGET = 100 * 10**18;

    // 定义合约拥有者
    address public owner;

    /**
     * Network: Sepolia TestNet
     * Aggregator: ETH / USD
     * Address: 0x694AA1769357215DE4FAC081bf1f309aDC325306
     */
    constructor() {
        // 初始化测试网喂价服务合约地址
        dataFeed = AggregatorV3Interface(
            0x694AA1769357215DE4FAC081bf1f309aDC325306
        );

        // 当前合约部署者
        owner = msg.sender;
    }

    // payable 关键字 标记该方法可接收链上原生通证，比如以太坊连上的以太币ETH
    function fund() external payable {
        require(convertEthToUsd(msg.value) >= MIN_VALUE, "Send more ETH");
        // msg.sender 当前智能合约方法的调用者
        // msg.value 当前智能合约方法调用收到的金额
        fundersToAmount[msg.sender] = msg.value;
    }

    /**
     * Returns the latest answer.
     */
    function getChainlinkDataFeedLatestAnswer() public view returns (int256) {
        // prettier-ignore
        (
            /* uint80 roundID */,
            int answer,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = dataFeed.latestRoundData();
        return answer;
    }

    /**
     * ETH 转 USD
     *
     */
    function convertEthToUsd(uint256 ethAmount)
        internal
        view
        returns (uint256)
    {
        uint256 ethPrice = uint256(getChainlinkDataFeedLatestAnswer());
        return (ethPrice * ethAmount) / (10**8);
    }

    /**
     * 转让合约所有权，变更合约拥有者
     */
    function transferOwnerShip(address newOwner) public {
        require(msg.sender == owner, "Only the contract owner can call");
        owner = newOwner;
    }

    /**
     * 提款函数
     */
    function fetchFund() external {
        // 校验当前钱包余额是否充足
        require(
            convertEthToUsd(address(this).balance) >= TARGET,
            "Insufficient wallet balance"
        );
        require(msg.sender == owner, "Only the contract owner can call");

        payable(msg.sender).transfer(address(this).balance);
    }
}
