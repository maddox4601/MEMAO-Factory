// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {TokenFactory} from "../src/Factory.sol";
import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";

contract DeployFactory is Script {
    function run(address platformWallet) external {
        // Read platform wallet address from command-line argument
        // Private key is passed via the --private-key parameter
        
        // Start broadcast (private key passed via --private-key)
        vm.startBroadcast();

        // Deploy TokenFactory
        TokenFactory factory = new TokenFactory(payable(platformWallet));

        // Stop broadcast
        vm.stopBroadcast();

        // Output deployed contract address
        console.log("TokenFactory deployed at:", address(factory));
        console.log("Platform wallet set to:", platformWallet);
    }
}
