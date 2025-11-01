// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {TokenFactory} from "../src/Factory.sol";
import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";

contract DeployFactory is Script {
    function run() external {
        // 从环境变量读取部署者私钥
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        // 平台钱包地址（收取部署手续费的地址）
        address payable platformWallet = payable(vm.envAddress("PLATFORM_WALLET"));

        // 启动广播
        vm.startBroadcast(deployerPrivateKey);

        // 部署 TokenFactory
        TokenFactory factory = new TokenFactory(platformWallet);

        // 停止广播
        vm.stopBroadcast();

        // 输出部署后的合约地址
        console.log("TokenFactory deployed at:", address(factory));
    }
}
