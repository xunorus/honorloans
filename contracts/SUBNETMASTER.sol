// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

// SIN AUTOMATION EN TROK 0xc7a280CbF424d76cf42FcE9d739032E72658490D

// CON AUTOMATION
// deployed on fuji  

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";
import "./HLOANTOKEN.sol";
// import "./slaveERC20TROK-v4.sol";
import "./nativeMinter.sol";
import "@chainlink/contracts/src/v0.8/automation/AutomationCompatible.sol";

import "@openzeppelin/contracts/utils/Counters.sol";

contract SUBNETMASTER  is ERC721, AccessControl{

    HLOANTOKENV6 public erc20Contract;
    bytes32 public constant DAO_ROLE = keccak256("DAO_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    // uint256 public immutable interval;//chainlink
    uint256 public lastTimeStamp;
    
// CONSTRUCTOR
    constructor() ERC721("TROKmaster", "TROKM") {
        erc20Contract = new HLOANTOKENV6();
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(DAO_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
    }


 event Log(address indexed msgSender);

    function emitLog() public {
        emit Log(msg.sender);
    }

    // -----------------------------------
// CHAINLINK
// -----------------------------------
    // function checkUpkeep(bytes calldata /* checkData */) external view override returns (bool upkeepNeeded, bytes memory /* performData */) {
    //     upkeepNeeded = (block.timestamp - lastTimeStamp) > interval;      
    //      return (upkeepNeeded, "");  
    // }

    // function performUpkeep(bytes calldata /* performData */) external override  {        
    //     if ((block.timestamp - lastTimeStamp) > interval ) {
    //         lastTimeStamp = block.timestamp;
    //         // -----------------------------------
    //         // aqui llama la funciona magica!!!
    //             // updateAllNFTs();            
    //         // -----------------------------------
    //     }        
    // }

// --------------------------------------------------------------------
// TROK's NETWORK PERMISSIONS
// allows an address to participate in trok network
  function allowAddress(address addr) external   {
        IAllowList(address(0x0200000000000000000000000000000000000002)).setEnabled(addr);
        // IAllowList(address(0x0200000000000000000000000000000000000002)).setEnabled(addr);
    }

// bans an address to participate in trok network
  function revokeAddress(address addr) external   {
        IAllowList(address(0x0200000000000000000000000000000000000002)).setNone(addr);
        // IAllowList(address(0x0200000000000000000000000000000000000002)).setEnabled(addr);
    }

  function isAllowed(address addr) external  view  returns (uint256 role){
        // IAllowList(address(0x0200000000000000000000000000000000000002)).readAllowList(addr);
        // IAllowList(address(0x0200000000000000000000000000000000000002)).setEnabled(addr);
        return IAllowList(address(0x0200000000000000000000000000000000000002)).readAllowList(addr);
    }

// gives free gas for free transactinos!
// cada ve que el gas de cierta address, luego de una transaccion, es menor a x(<10000 ,x ej), le airdropea mas gas/
  function airdropTo(address addr, uint256 amount) external   {
        INativeMinter(address(0x0200000000000000000000000000000000000001)).mintNativeCoin(addr,amount);
    }


  // Read the status of [addr].
//   function readAllowList(address addr) external view returns (uint256 role);

// --------------------------------------------------------------------
// STRUCTS
  struct valueCreated{
        uint256  value;
    }


// --------------------------------------------------------------------
// MAPPINGS
    mapping(address => valueCreated) public minted;// para llevar una cuenta de cuanto crea/mintea cada participante y deducir el saldo

// --------------------------------------------------------------------
// EVENTS
    event MintedTo(address recipient, uint256 amount );

// --------------------------------------------------------------------
// FUNCTIONS
  


 function TRANSFERcustom(address from, address to, uint256 amount) public onlyRole(DAO_ROLE) {
        uint256 fromBalance = checkBalance(from);

        if (fromBalance >= amount) {
        // 1. IF USER HAS BALANCE JUSTPAY WITH HIS BALANCE
        erc20Contract.transferFrom(from, to, amount);

        } else if (fromBalance < amount) {
          
            // 2. IF USER DOESN HAVE ENOUGHT BALACE: 
            // MINT(LOAN) THE DIFERENCE, 
            // TRANSFER TO RECIPIENT, 
            // AND SEND AMOUNT FROM CREATOR TO RECIPIENT
            //observations: this method seems beter because we avoid resending minted from creator to recipient
            uint256 valueToMint = amount - fromBalance;
            erc20Contract.transferFrom(from, to, fromBalance);//send all balance to recipient 
            erc20Contract.xmint(to, valueToMint);//mint remaining and send it to recipient
            minted[from].value = valueToMint;// add mint info tokenId
            emit MintedTo(to, valueToMint );

        }
      

    }

    // TEST FUNCTIONS
    function MINTcustom(address to, uint256 amount) public onlyRole(DAO_ROLE) {

            erc20Contract.xmint(to, amount);//mint remaining and send it to recipient
            emit MintedTo(to,  amount );

    }


    // --------------------------------------------------------------------
    // OTHER FUNCTIONS
    function SET_SLAVECONTRACT (address _erc20Contract) public onlyRole(DAO_ROLE){
        erc20Contract = HLOANTOKENV6(_erc20Contract);
    }

    function confirmFirstContract() public view returns(bool) {
        bool x = erc20Contract.isTrue();
        return x;
    }

    function checkBalance(address _account) public  view returns (uint256 balance) {
        // return balanceOf[_account];
        return erc20Contract.balanceOf(_account);
    }

    function grantMINTERTROLE(address to) public onlyRole(DAO_ROLE){
        _grantRole(DAO_ROLE, to);
    }

    function revokeMINTERROLE(address to) public{
        _revokeRole(DAO_ROLE, to);
    }

    function grantDAOROLE(address to) public onlyRole(DAO_ROLE){
        _grantRole(DAO_ROLE, to);
    }

    function revokeDAOTROLE(address to) public{
        _revokeRole(DAO_ROLE, to);
    }

    function TESTviewContract() view public returns(address){// REAL ammount of DAO members
        return address( erc20Contract);
    }

    function TESTviewTHISContract() view public returns(address){// REAL ammount of DAO members
        return address(this);
    }

    function TESTviewAllowance(address from ) view public returns(uint256){// REAL ammount of DAO members
        return erc20Contract.allowance(from,  address( this));
    }

    
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

   function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}