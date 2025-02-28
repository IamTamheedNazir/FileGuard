// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract FileGuard is Ownable, ReentrancyGuard {
    // ========== ENUMS & STRUCTS ==========

    enum SubscriptionTier { Free, Basic, Pro, Business }
    enum BillingCycle { Monthly, Quarterly, Yearly }

    struct User {
        SubscriptionTier tier;
        BillingCycle cycle;
        uint256 storageLimit;
        uint256 storageUsed;
        uint256 subscriptionExpiry;
        address paymentAddress;
    }

    struct File {
        address owner;
        string fileHash;
        uint256 size;
        uint256 uploadTime;
        mapping(address => bool) accessList;
        mapping(address => string) encryptionKeys;
    }

    // ========== STATE VARIABLES ==========

    AggregatorV3Interface internal filUsdPriceFeed;

    mapping(address => User) public users;
    mapping(string => File) public files;
    mapping(SubscriptionTier => mapping(BillingCycle => uint256)) public tierPricesUSD;
    mapping(SubscriptionTier => uint256) public tierStorageLimits;

    // ========== EVENTS ==========

    event SubscriptionUpdated(address indexed user, SubscriptionTier tier, BillingCycle cycle);
    event FileUploaded(address indexed user, string fileHash);
    event FileShared(string fileHash, address recipient);

    // ========== CONSTRUCTOR ==========

    constructor(address _priceFeedAddress, address _initialOwner) 
        Ownable(_initialOwner) // Pass the initial owner to the Ownable constructor
    {
        filUsdPriceFeed = AggregatorV3Interface(_priceFeedAddress);
        _configurePricing();
        _configureStorageLimits();
    }

    // ========== CONFIGURATION ==========

    function _configurePricing() internal {
        // Prices in USD cents (e.g., $5 = 500)
        tierPricesUSD[SubscriptionTier.Basic][BillingCycle.Monthly] = 500;
        tierPricesUSD[SubscriptionTier.Basic][BillingCycle.Quarterly] = 1300;
        tierPricesUSD[SubscriptionTier.Basic][BillingCycle.Yearly] = 5000;

        tierPricesUSD[SubscriptionTier.Pro][BillingCycle.Monthly] = 1000;
        tierPricesUSD[SubscriptionTier.Pro][BillingCycle.Quarterly] = 2700;
        tierPricesUSD[SubscriptionTier.Pro][BillingCycle.Yearly] = 10000;

        tierPricesUSD[SubscriptionTier.Business][BillingCycle.Monthly] = 2000;
        tierPricesUSD[SubscriptionTier.Business][BillingCycle.Quarterly] = 5400;
        tierPricesUSD[SubscriptionTier.Business][BillingCycle.Yearly] = 20000;
    }

    function _configureStorageLimits() internal {
        tierStorageLimits[SubscriptionTier.Free] = 5 * 1024**3;     // 5GB
        tierStorageLimits[SubscriptionTier.Basic] = 50 * 1024**3;   // 50GB
        tierStorageLimits[SubscriptionTier.Pro] = 200 * 1024**3;    // 200GB
        tierStorageLimits[SubscriptionTier.Business] = 1024 * 1024**3; // 1TB
    }

    // ========== CORE FUNCTIONS ==========

    function subscribeToPlan(
        SubscriptionTier _tier,
        BillingCycle _cycle
    ) external payable nonReentrant {
        require(_tier != SubscriptionTier.Free, "Use startFreeTrial()");
        User storage user = users[msg.sender];
        require(user.subscriptionExpiry < block.timestamp, "Active subscription");

        // Get price in FIL
        uint256 usdPrice = tierPricesUSD[_tier][_cycle];
        uint256 filUsdPrice = _getFilUsdPrice();
        uint256 requiredFil = (usdPrice * 1e18) / filUsdPrice;

        require(msg.value >= requiredFil, "Insufficient FIL");

        // Set subscription duration
        uint256 duration = _cycle == BillingCycle.Monthly ? 30 days :
                          _cycle == BillingCycle.Quarterly ? 90 days : 365 days;

        users[msg.sender] = User({
            tier: _tier,
            cycle: _cycle,
            storageLimit: tierStorageLimits[_tier],
            storageUsed: 0,
            subscriptionExpiry: block.timestamp + duration,
            paymentAddress: msg.sender
        });

        // Refund excess
        if (msg.value > requiredFil) {
            payable(msg.sender).transfer(msg.value - requiredFil);
        }

        emit SubscriptionUpdated(msg.sender, _tier, _cycle);
    }

    function uploadFile(string memory _fileHash, uint256 _size) external {
        User storage user = users[msg.sender];
        require(user.subscriptionExpiry >= block.timestamp, "Subscription expired");
        require(user.storageUsed + _size <= user.storageLimit, "Storage limit");

        files[_fileHash].owner = msg.sender;
        files[_fileHash].size = _size;
        files[_fileHash].uploadTime = block.timestamp;

        user.storageUsed += _size;
        emit FileUploaded(msg.sender, _fileHash);
    }

    function shareFile(string memory _fileHash, address _recipient, string memory _encryptedKey) external {
        require(files[_fileHash].owner == msg.sender, "Not owner");
        files[_fileHash].accessList[_recipient] = true;
        files[_fileHash].encryptionKeys[_recipient] = _encryptedKey;
        emit FileShared(_fileHash, _recipient);
    }

    // ========== HELPER FUNCTIONS ==========

    function _getFilUsdPrice() internal view returns (uint256) {
        (, int256 price, , , ) = filUsdPriceFeed.latestRoundData();
        return uint256(price); // Price in USD with 8 decimals
    }

    function withdrawFunds() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    // ========== FREE TIER ==========

    function startFreeTrial() external {
        require(users[msg.sender].subscriptionExpiry == 0, "Already registered");
        users[msg.sender] = User({
            tier: SubscriptionTier.Free,
            cycle: BillingCycle.Monthly,
            storageLimit: tierStorageLimits[SubscriptionTier.Free],
            storageUsed: 0,
            subscriptionExpiry: block.timestamp + 30 days,
            paymentAddress: address(0)
        });
    }
}