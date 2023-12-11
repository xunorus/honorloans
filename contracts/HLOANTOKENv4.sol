// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";

// SlaveContractERC20
// DEPLOYED ON MUMBAI   0xC3fB0e8A9E26dc59912bF45e52327Be4D88625e7
// DEPLOYED EN SEPOLIA 0xf65553B90a16a94eb59e93b869b3dA47f23F59F6

contract HLOANTOKENV4 is ERC20, AccessControl, ERC20Permit {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant DAO_ROLE = keccak256("DAO_ROLE");
    uint256 public mintTimestamp;

  constructor() ERC20("HONORLOANtoken", "HLT") ERC20Permit("HONORLOANtoken")  {
        // _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
        _grantRole(DAO_ROLE, msg.sender);
        mintTimestamp = block.timestamp;
    }

  uint public counter ; 
  bool public isTrue = true;

    function getDaysSinceMinted() public view returns (uint256) {
        uint256 currentTime = block.timestamp;
        uint256 timeDifference = currentTime - mintTimestamp;
        uint256 daysSinceMinted = timeDifference / 1 days; // 1 days is equivalent to 86400 seconds
        return daysSinceMinted;// *100this is the credit limit(100 per day)
    }

  function GRANTMINTERTROLE(address to) public onlyRole(DAO_ROLE){
        _grantRole(MINTER_ROLE, to);
  }

function revokeMINTERTROLE(address to) public{
        _revokeRole(MINTER_ROLE, to);
}

//  ERC20 SPECIFIC
    // function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE)  {
        // PUBLIC: PARA HACER PRUEBAS
    function xmint(address to, uint256 amount) public  {
        _mint(to, amount);
    }

  function INFINITEallowanceLOCAL (address spender )  public returns(bool){// REAL ammount of DAO members
            return approve( spender,  0x8000000000000000000000000000000000000000000000000000000000000000);
    }
   

}