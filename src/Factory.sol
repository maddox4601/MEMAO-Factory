// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// ---------------------------
/// Basic ERC20 Token
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
/// Token Factory Contract
/// ---------------------------
contract TokenFactory is Ownable {
    /// Platform wallet (receives service fee)
    address payable public platformWallet;

    /// Default on-chain deployment fee (applies only to userDeploy)
    uint256 public defaultDeploymentFee = 0.01 ether;

    /// Records the list of tokens issued by each user
    mapping(address => address[]) public userTokens;

    /// Event: New Token Created
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
    // Mode 1: Platform Deployment (Platform Deploy)
    // -------------------------------------------------
    /**
     * @dev Called by platform; user pays off-chain (fiat).
     * - onlyOwner: can only be called by the platform wallet
     * - Gas is paid by the platform
     * - No on-chain fee involved
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
    // Mode 2: User Self-Deployment (User Deploy)
    // -------------------------------------------------
    /**
     * @dev User deploys token and pays on-chain fees.
     * - User pays via msg.value
     * - Part/all deployment fee sent to platform wallet
     */
    function userDeploy(
        string memory name_,
        string memory symbol_,
        uint256 initialSupply_
    ) external payable returns (address) {
        require(msg.value >= defaultDeploymentFee, "Insufficient fee");

        // Deploy token; all initial tokens minted to user
        CustomToken token = new CustomToken(name_, symbol_, initialSupply_, msg.sender);

        userTokens[msg.sender].push(address(token));

        // Transfer deployment fee to platform (currently full amount)
        (bool sent, ) = platformWallet.call{value: msg.value}("");
        require(sent, "Fee transfer failed");

        emit TokenCreated(address(token), name_, symbol_, initialSupply_, msg.sender);
        return address(token);
    }

    // -------------------------------------------------
    // Admin Operations
    // -------------------------------------------------

    /// Set new platform wallet
    function setPlatformWallet(address payable newWallet) external onlyOwner {
        require(newWallet != address(0), "Invalid wallet");
        platformWallet = newWallet;
    }

    /// Set deployment fee
    function setDeploymentFee(uint256 newFee) external onlyOwner {
        defaultDeploymentFee = newFee;
    }

    /// Query all tokens deployed by a user
    function getUserTokens(address user) external view returns (address[] memory) {
        return userTokens[user];
    }
}
