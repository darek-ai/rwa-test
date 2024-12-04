// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

// 智能合约
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

    // 定义一个HashMap：储存投资人钱包地址及对应投资金额
    mapping(address => uint256) public fundersToAmount;

    // payable 关键字 标记该方法可接收链上原生通证，比如以太坊连上的以太币ETH
    function fund() external payable {
        // msg.sender 当前智能合约方法的调用者
        // msg.value 当前智能合约方法调用收到的金额
        fundersToAmount[msg.sender] = msg.value;
    }
}
