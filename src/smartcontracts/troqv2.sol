// SPDX-License-Identifier: MIT
pragma solidity ^0.8;
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";

// DEPLOYED ON SEPOLIA SCROLL:
// MASTERTROQV2 0xCDf739d380b57EFB25717eE9F7b4292b36D2c075
// https://sepolia.scroll.io/bridge

// SlaveContractERC20 at 0x691E71Ff60cF56d4f6417b203b25A683afE9a9B6
// https://sepolia.scrollscan.com/address/0x691E71Ff60cF56d4f6417b203b25A683afE9a9B6
// MasterContract at 0x4bF546fC1A24F24c1F88e315B0ED96BF853C3D1a
// https://sepolia.scrollscan.com/address/0x4bF546fC1A24F24c1F88e315B0ED96BF853C3D1a

// 1. deploy both contracts
// 2. copy slave erc20 contract address and set it in master's contract SETSLAVEECONTRACT FUNCTION
// 3. copy master erc contract address and set it in GRANTMINTERTROLE (???)

// HOW IT WORKS? (FOR PAYMENTS)
     // 1. IF USER HAS BALANCE JUSTPAY WITH HIS BALANCE
    // 2. IF USER DOESN HAVE ENOUGHT BALACE: MINT THE DIFERENCE, TRANSFER TO RECIPIENT, AND SEND AMOUNT FROM CREATOR TO RECIPIENT
    // 3. IF USER HAS EXACTLY THE AMOUNT, JUST SEND IT(redundant?)


contract TROQERC20V2 is ERC20, AccessControl, ERC20Permit {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant DAO_ROLE = keccak256("DAO_ROLE");
    uint256 public mintTimestamp;

  constructor() ERC20("TROQtoken", "TROQ") ERC20Permit("TROQtoken")  {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
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
    function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE)  {
        _mint(to, amount);
    }

  function INFINITEallowanceLOCAL (address spender )  public returns(bool){// REAL ammount of DAO members
            return approve( spender,  0x8000000000000000000000000000000000000000000000000000000000000000);
    }
   

}









contract MASTERTROQV2  is ERC721, AccessControl{

    bytes32 public constant DAO_ROLE = keccak256("DAO_ROLE");
  // deployed in goerli: 0x9Ac5A24178Ade9Bb101daCA172Ac03984F5c5246
    constructor() ERC721("TROQmaster", "TROQM") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(DAO_ROLE, msg.sender);
    }

  TROQERC20V2 erc20Contract;
  
    // --------------------------------------------------
    // MAPPINGS AND ARRAYS STRUCTS


  struct valueCreated{
        uint256  value;
        // address  userAddress;
    }

    mapping(address => valueCreated) public minted;// para llevar una cuenta de cuanto crea/mintea cada participante y deducir el saldo
    // mapping(uint256 => UP) public universalPass;


  function SETSLAVECONTRACT (address _erc20Contract) public onlyRole(DAO_ROLE){
    erc20Contract = TROQERC20V2(_erc20Contract);
  }

  function confirmFirstContract() public view returns(bool) {
      bool x = erc20Contract.isTrue();
      return x;
  }



//  ERC20 CUSTOM ERC20 TRASNFER
function checkBalance(address _account) public  view returns (uint256 balance) {
        // return balanceOf[_account];
        return erc20Contract.balanceOf(_account);
    }



 function customTransfer(address from, address to, uint256 amount) public onlyRole(DAO_ROLE) {
        
        //1A. CHECK FROM BALANCE
        uint256 fromBalance = checkBalance(from);

        if (fromBalance > amount) {
        // 1. IF USER HAS BALANCE JUSTPAY WITH HIS BALANCE
        erc20Contract.transferFrom(from, to, amount);

        } else if (fromBalance < amount) {
          
            // 2. IF USER DOESN HAVE ENOUGHT BALACE: MINT THE DIFERENCE, TRANSFER TO RECIPIENT, AND SEND AMOUNT FROM CREATOR TO RECIPIENT
            //observations: this method seems beter because we avoid resending minted from creator to recipient

            uint256 valueToMint = amount - fromBalance;
            erc20Contract.transferFrom(from, to, fromBalance);//send all balance to recipient 
            erc20Contract.mint(to, valueToMint);//mint remaining and send it to recipient
            minted[from].value = valueToMint;// add mint info tokenId

        } else if (fromBalance == amount) {
            // 3. IF USER HAS EXACTLY THE AMOUNT, JUST SEND IT
            erc20Contract.transferFrom(from, to, amount);

        }

    }

     // --------------------------------------------
    // DAO FUNCTIONS


    function GRANTDAOTROLE(address to) public onlyRole(DAO_ROLE){
        _grantRole(DAO_ROLE, to);
    }

    function revokeDAOTROLE(address to) public{
        _revokeRole(DAO_ROLE, to);
    }


     // --------------------------------------------
    // TEST FUNCTIONS
    function TESTviewContract() view public returns(address){// REAL ammount of DAO members
        return address( erc20Contract);
    }

    function TESTviewTHISContract() view public returns(address){// REAL ammount of DAO members
        return address(this);
    }

    function TESTviewAllowance(address from ) view public returns(uint256){// REAL ammount of DAO members
        return erc20Contract.allowance(from,  address( this));
    }

    
    // --------------------------------------------
    // SIGNATURE VERIFICATION
    // funciona con signCOMPLETE.html
//   convierto el hash a eth signed dentro del contrato y la firma, y devuelve el firmante
 function recoverSigner(bytes32 _Hash, bytes memory _signature) public pure returns (address) {
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);
        bytes32 _ethSignedMessageHash = convertToEthSignedMessageHash(_Hash);
        return ecrecover(_ethSignedMessageHash, v, r, s);
    }

  
  
    function convertToEthSignedMessageHash(bytes32 _messageHash) internal pure returns (bytes32) {
        return keccak256( abi.encodePacked("\x19Ethereum Signed Message:\n32", _messageHash) ); 
    }

    function splitSignature(bytes memory sig) internal pure returns ( bytes32 r, bytes32 s, uint8 v ) {
            require(sig.length == 65, "invalid signature length");
            assembly {
                r := mload(add(sig, 32))
                s := mload(add(sig, 64))
                v := byte(0, mload(add(sig, 96)))
            }
        }

     // ---------------------------------------
    // The following functions are overrides required by Solidity.
   function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}