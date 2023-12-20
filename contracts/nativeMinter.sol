// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./allowListInterface.sol";
// import "./IAllowList.sol";
// ContractNativeMinter adheres to the following Solidity interface at 0x0200000000000000000000000000000000000001 
interface INativeMinter is IAllowList {
  // Mint [amount] number of native coins and send to [addr]
  function mintNativeCoin(address addr, uint256 amount) external;
}

