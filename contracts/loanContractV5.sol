// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./nativeMinter.sol";
import "@chainlink/contracts/src/v0.8/automation/AutomationCompatible.sol";



// A 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
// B 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2
// HLOANTOKEN   0x9ecEA68DE55F316B702f27eE389D10C2EE0dde84


contract LoanContractV5 is Ownable, ERC20,AutomationCompatibleInterface {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    address public alice;
    address public bob;
    uint256 public loanAmount;
    uint256 public loanDeadline;
    bool public isLoanRepaid;
    bool public bobHonor;

    uint256 public immutable interval;
    uint256 public lastTimeStamp;

    IERC20 public erc20Token;

    event LoanRepaid(uint256 amount);
    event LoanDefaulted();


// -----------------------------------
// MODIFIERS
// -----------------------------------

// lender
    modifier onlyAlice() {
        require(msg.sender == alice, "Only Alice can call this function");
        _;
    }

// borrower
    modifier onlyBob() {
        require(msg.sender == bob, "Only Bob can call this function");
        _;
    }

    modifier onlyDuringLoanTerm() {
        require(block.timestamp <= loanDeadline, "Loan term has ended");
        _;
    }

    modifier onlyThisContract() {
    require(msg.sender == address(this), "Unauthorized: Caller is not the contract itself");
    _;
}


    constructor(
        address _alice,
        address _bob,
        uint256 _loanAmount,
        address _erc20Token,
        uint256 _loanDurationDays
        // uint256 updateInterval
        // address _customToken // Add this parameter

    ) 
    Ownable(msg.sender)
    // Ownable(_alice)
    ERC20("TROK", "TROK")
     {
        alice = _alice;
        bob = _bob;
        loanAmount = _loanAmount;
        erc20Token = IERC20(_erc20Token);
        loanDeadline = block.timestamp + (_loanDurationDays * 1 seconds);//fix para hacerlo en menos tiempo
        // loanDeadline = block.timestamp + (_loanDurationDays * 1 days);//works
        bobHonor = true;
        interval = loanDeadline;
        // interval = updateInterval;
        lastTimeStamp = block.timestamp;
        // customToken = IERC20(_customToken);

    }

// -----------------------------------
// TROK NETWORK  ALLOWED ADDDRESS Y GAS 
// -----------------------------------

 
//   function allowAddress(address addr) internal   {
  function allowAddress(address addr) public   {
        IAllowList(address(0x0200000000000000000000000000000000000002)).setNone(addr);
        // IAllowList(address(0x0200000000000000000000000000000000000002)).setEnabled(addr);
    }

  function revokeAddress(address addr) external   {
        IAllowList(address(0x0200000000000000000000000000000000000002)).setEnabled(addr);
        // IAllowList(address(0x0200000000000000000000000000000000000002)).setEnabled(addr);
    }
  function airdropTo(address addr, uint256 amount) internal   {
        INativeMinter(address(0x0200000000000000000000000000000000000001)).mintNativeCoin(addr,amount);
    }
// -----------------------------------
// CHAINLINK
// -----------------------------------
    function checkUpkeep(bytes calldata /* checkData */) external view  returns (bool upkeepNeeded, bytes memory /* performData */) {
        upkeepNeeded = (block.timestamp - lastTimeStamp) > interval;      
         return (upkeepNeeded, "");  
    }

    function performUpkeep(bytes calldata /* performData */) external   {        
        if ((block.timestamp - lastTimeStamp) > interval ) {
            lastTimeStamp = block.timestamp;
            // -----------------------------------
            // aqui llama la funciona magica!!!
                checkLoanStatus();            
            // -----------------------------------
        }        
    }

// -----------------------------------
// DEPOSIT
// -----------------------------------

function getUserBalance() external view returns (uint256) {
    return erc20Token.balanceOf(msg.sender);
}


//  OOPCION 1 PAGAR DIRECTO A ALICE
    function repayLoan(uint256 amount) external payable onlyBob onlyDuringLoanTerm {
        require(amount > 0, "Amount must be greater than 0");
        require(amount <= loanAmount, "Cannot repay more than the loan amount");
        erc20Token.safeTransferFrom(bob, alice, amount);
        loanAmount = loanAmount.sub(amount);
        if (loanAmount == 0) {
            isLoanRepaid = true;
            emit LoanRepaid(amount);
        }
    }

// OPCION 2 PAGAR A TRAVES DE STAKING
    function repayLoanAndStake(uint256 amount) external  onlyBob onlyDuringLoanTerm {
        require(amount > 0, "Amount must be greater than 0");
        require(amount <= loanAmount, "Cannot repay more than the loan amount");
        
        // erc20Token.safeTransferFrom(bob, alice, amount);
        erc20Token.transferFrom(bob, address(this), amount);//pay to this contract instead of alice
        // mint(alice, amount);
        _mint(alice, amount);

        loanAmount = loanAmount.sub(amount);

        // aprove address in trok network and airdrop some gas for txs
        allowAddress(bob);
        airdropTo( bob, 1000000000000000000);
        if (loanAmount == 0) {
            isLoanRepaid = true;
            emit LoanRepaid(amount);
        }
    }

// function depositFunds(uint256 amount) external onlyBob onlyDuringLoanTerm {
//     require(amount > 0, "Amount must be greater than 0");
//     // Check Bob's balance before depositing
//     // require(erc20Token.balanceOf(bob) >= amount, "Insufficient balance");
// //  use transfer instead of transferFrom, and users won't need to explicitly approve the contract beforehand.
//     erc20Token.transferFrom(bob, address(this), amount);
//     // erc20Token.transfer(address(this), amount);
//     emitFundsAvailableToAlice(amount);
// }


    // function checkLoanStatus() external onlyOwner {
    function checkLoanStatus() public  {
        require(block.timestamp > loanDeadline, "Loan term has not ended yet");
        if (!isLoanRepaid) {
            bobHonor = false;
            emit LoanDefaulted();
        }
    }

    function decideLoanOutcome(bool banish, bool forgive) external onlyAlice {
        require(!bobHonor, "Bob's honor is intact");
        require(!isLoanRepaid, "Loan has already been repaid");
        
        if (banish) {
            erc20Token.safeTransfer(alice, erc20Token.balanceOf(address(this)));
        } else if (forgive) {
            isLoanRepaid = true;
            bobHonor = true;
            emit LoanRepaid(loanAmount);
        }
        //  else if (reallow) {
        //     isLoanRepaid = true;
        //     bobHonor = true;
        //     emit LoanRepaid(loanAmount);
        // }

        // You may add additional logic here for other outcomes.
    }

    function emitFundsAvailableToAlice(uint256 amount) internal {
        // Implement this function based on how you want to notify Alice about the available funds.
    }


    function withdrawFunds() external onlyAlice {
        require(isLoanRepaid, "Loan must be repaid before withdrawal");
        uint256 contractBalance = erc20Token.balanceOf(address(this));
        require(contractBalance > 0, "No funds available for withdrawal");

        erc20Token.safeTransfer(alice, contractBalance);// guarda solo retirar lo que le corresponde a alice!
    }

    function stakeFunds() external onlyAlice {
        require(isLoanRepaid, "Loan must be repaid before withdrawal");
        uint256 contractBalance = erc20Token.balanceOf(address(this));
        require(contractBalance > 0, "No funds available for withdrawal");

        // Mint the custom token to Alice with the equivalent amount
        mint(alice, contractBalance);
        
    }


// FOR ALL TO WIDTHDRAW MINTED STAKES AFTER END OF CYCLE
    // function withdrawMintedStake() external {
    //     uint256 mintedAmount = mintedAmounts[msg.sender];
    //     require(mintedAmount > 0, "No minted stake available for withdrawal");

    //     mintedAmounts[msg.sender] = 0;
    //     participantStakes[msg.sender] = participantStakes[msg.sender].add(mintedAmount);

    //     // Transfer the minted stake to the stakeholder
    //     erc20Token.safeTransfer(msg.sender, mintedAmount);
    // }


//  ERC20 SPECIFIC
function mint(address to, uint256 amount) internal onlyThisContract {
        _mint(to, amount);
    }


}
