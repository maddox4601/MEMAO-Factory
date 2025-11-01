// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// ---------------------------
/// 基础 ERC20 Token
/// ---------------------------
contract CustomToken is ERC20 {
    constructor(
        string memory name_,
        string memory symbol_,
        uint256 initialSupply_,
        address owner_
    ) ERC20(name_, symbol_) {
        _mint(owner_, initialSupply_ * 10 ** decimals());
    }
}

/// ---------------------------
/// Token 工厂合约
/// ---------------------------
contract TokenFactory is Ownable {
    /// 平台钱包（收取手续费用）
    address payable public platformWallet;

    /// 默认链上部署手续费（仅 userDeploy 生效）
    uint256 public defaultDeploymentFee = 0.01 ether;

    /// 记录用户发行的 Token 列表
    mapping(address => address[]) public userTokens;

    /// 事件：新 Token 创建
    event TokenCreated(
        address indexed tokenAddress,
        string name,
        string symbol,
        uint256 supply,
        address indexed creator
    );

    constructor(address payable _platformWallet) Ownable(msg.sender) {
        require(_platformWallet != address(0), "Invalid platform wallet");
        platformWallet = _platformWallet;
    }

    // -------------------------------------------------
    // 模式一：平台代部署 (Platform Deploy)
    // -------------------------------------------------
    /**
     * @dev 平台调用，用户链下用法币支付。
     * - onlyOwner: 仅限平台钱包调用
     * - Gas 由平台承担
     * - 不涉及链上收费
     */
    function platformDeploy(
        string memory name_,
        string memory symbol_,
        uint256 initialSupply_,
        address user_
    ) external onlyOwner returns (address) {
        require(user_ != address(0), "Invalid user address");

        CustomToken token = new CustomToken(name_, symbol_, initialSupply_, user_);

        userTokens[user_].push(address(token));

        emit TokenCreated(address(token), name_, symbol_, initialSupply_, user_);
        return address(token);
    }

    // -------------------------------------------------
    // 模式二：用户自助部署 (User Deploy)
    // -------------------------------------------------
    /**
     * @dev 用户自己部署，支付链上费用。
     * - 用户通过 msg.value 支付
     * - 部分/全部费用转给平台钱包
     */
    function userDeploy(
        string memory name_,
        string memory symbol_,
        uint256 initialSupply_
    ) external payable returns (address) {
        require(msg.value >= defaultDeploymentFee, "Insufficient fee");

        // 部署 Token，初始 Token 全部 mint 给用户
        CustomToken token = new CustomToken(name_, symbol_, initialSupply_, msg.sender);

        userTokens[msg.sender].push(address(token));

        // 平台收取部署费用 (这里简单写成全额给平台)
        (bool sent, ) = platformWallet.call{value: msg.value}("");
        require(sent, "Fee transfer failed");

        emit TokenCreated(address(token), name_, symbol_, initialSupply_, msg.sender);
        return address(token);
    }

    // -------------------------------------------------
    // 管理员操作
    // -------------------------------------------------

    /// 设置新的平台钱包
    function setPlatformWallet(address payable newWallet) external onlyOwner {
        require(newWallet != address(0), "Invalid wallet");
        platformWallet = newWallet;
    }

    /// 设置链上部署手续费
    function setDeploymentFee(uint256 newFee) external onlyOwner {
        defaultDeploymentFee = newFee;
    }

    /// 查询某用户发行的所有 Token
    function getUserTokens(address user) external view returns (address[] memory) {
        return userTokens[user];
    }
}