// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20FlashMint.sol";

contract TROQ is ERC20, ERC20Burnable, Pausable, AccessControl, ERC20FlashMint {



// ---------------------------------------

// GLOBAL MODIFIABLE VARIABLES
// IERC20 token = IERC20(0xd9145CCE52D386f254917e481eB44e9943F39138);

// function createValue(uint amount, address receiver)  public{
//     //need here add the method payment using my token erc20
//     // token.transferFrom(msg.sender, address(this), amount);
//     token.transferFrom(msg.sender, address(receiver), amount);
// }
 

// --------------------------------------------------
// EVENTS
    // event Created(address indexed to, uint256 indexed tokenId);
    // event Burned(address indexed to, uint256 indexed tokenId);

// ---------------------------------------
// ROLES

    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    constructor() ERC20("TROQ", "TROQ") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
    }

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) {
        _mint(to, amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount)
        internal
        whenNotPaused
        override
    {
        super._beforeTokenTransfer(from, to, amount);
    }
}