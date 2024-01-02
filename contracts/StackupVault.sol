pragma solidity ^0.8.13;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {sToken} from "./sToken.sol";
contract StackupVault {
    // mapping of token address to underlying tokens and claim tokens
    mapping(address => IERC20) public tokens;
    mapping(address => sToken) public claimTokens;
    constructor(address uniAddr, address linkAddr) {
        // initialize mapping of underlying token address => claim tokens
        claimTokens[uniAddr] = new sToken("Claim Uni", "sUNI");
        claimTokens[linkAddr] = new sToken("Claim Link", "sLINK");
        // initialize mapping of underlying token address => underlying tokens
        tokens[uniAddr] = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F); // UNI token address
        tokens[linkAddr] = IERC20(0x514910771AF9Ca656af840dff83E8264EcF986CA); // LINK token address
    }
    function deposit(address tokenAddr, uint256 amount) external {
        // transfer underlying tokens from user to vault, assume that user has already approved vault to transfer underlying tokens
        IERC20(tokenAddr).transferFrom(msg.sender, address(this), amount);
        // mint sTokens
        sToken sTokenContract = claimTokens[tokenAddr];
        require(address(sTokenContract) != address(0), "Invalid token address");
        sTokenContract.mint(msg.sender, amount);
    }
    function withdraw(address tokenAddr, uint256 amount) external {
        // burn sTokens
        sToken sTokenContract = claimTokens[tokenAddr];
        require(address(sTokenContract) != address(0), "Invalid token address");
        sTokenContract.burn(msg.sender, amount);
        // transfer underlying tokens from vault to user
        IERC20(tokenAddr).transfer(msg.sender, amount);
    }
}