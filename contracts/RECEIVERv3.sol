// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;
// RECEIVER(sepolia-mumbai)
//  implementa ccipReceiver y ejecuta la funcion xmint en el HLOANTOKENv4

import {CCIPReceiver} from "@chainlink/contracts-ccip/src/v0.8/ccip/applications/CCIPReceiver.sol";
import {Client} from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";
import {HLOANTOKENV4} from "./HLOANTOKENv4.sol";



// DEPLOYED EN SEPOLIA 0x44126fbd93795ade762a86456d325c9e02fd8525
// 0x03AB19CF7F795B8a494DE0e76FE99e314f964F46
// router de sepolia 0x0bf3de8c5d3e8a2b34d2beeb17abfcebaf363a59
// ERC address en  sepolia  0xf65553B90a16a94eb59e93b869b3dA47f23F59F6

// DEPLOYED EN MUMBAI 
// router de mumbai 0x1035cabc275068e0f4b745a29cedf38e13af41b1
// ERC address en  mumbai  0xC3fB0e8A9E26dc59912bF45e52327Be4D88625e7
contract RECEIVERv3 is CCIPReceiver {
    HLOANTOKENV4 erc;
 
    event MintCallSuccessfull();
 
    constructor(address router, address ercAddress) CCIPReceiver(router) {
        // nft = tokenerc20(nftAddress);
        erc = HLOANTOKENV4(ercAddress);
    }
 
    function _ccipReceive(Client.Any2EVMMessage memory message) internal override {
        (bool success, ) = address(erc).call(message.data);
        require(success);
        emit MintCallSuccessfull();
    }
 
}