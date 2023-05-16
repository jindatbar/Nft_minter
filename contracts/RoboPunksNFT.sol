// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import '@openzeppelin/contracts/token/ERC721/ERC721.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/Strings.sol';
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract RoboPunksNFT is ERC721, Ownable {
    using SafeMath for uint256;
    
    uint256 public constant MINT_PRICE = 0.1 ether;
    uint256 public constant MAX_SUPPLY = 10000;
    uint256 public constant MAX_PER_WALLET = 3;
    
    bool public isPublicMintEnabled;
    string internal baseTokenUri;
    address payable public withdrawWallet;
    mapping(address => uint256) public walletMints;
    
    constructor() payable ERC721('RoboPunks', 'RP') {
        withdrawWallet = payable(msg.sender);
    }
    
    function setIsPublicMintEnabled(bool isPublicMintEnabled_) external onlyOwner {
        isPublicMintEnabled = isPublicMintEnabled_;
    }
    
    function setBaseTokenUri(string calldata baseTokenUri_) external onlyOwner {
        baseTokenUri = baseTokenUri_;
    }
    
    function tokenURI(uint256 tokenId_) public view override returns (string memory) {
        require(_exists(tokenId_), 'Token does not exist!');
        return string(abi.encodePacked(baseTokenUri, Strings.toString(tokenId_), ".json"));
    }
    
    function withdraw() external onlyOwner {
        (bool success, ) = withdrawWallet.call{value: address(this).balance } ('');
        require(success, 'withdraw failed');
    }
    
    function mint(uint256 quantity) public payable {
        require(isPublicMintEnabled, 'Minting not enabled');
        require(quantity > 0 && quantity <= MAX_PER_WALLET, 'Invalid quantity');
        require(msg.value == quantity.mul(MINT_PRICE), 'Incorrect mint value');
        require(totalSupply().add(quantity) <= MAX_SUPPLY, 'Exceeds maximum supply of RoboPunks');
        require(walletMints[msg.sender].add(quantity) <= MAX_PER_WALLET, 'Exceeds maximum per wallet');
        
        for (uint256 i = 0; i < quantity; i++) {
            uint256 newTokenId = totalSupply().add(1);
            totalSupply().add(1);
            _safeMint(msg.sender, newTokenId);
            walletMints[msg.sender].add(1);
        }
    }
}
