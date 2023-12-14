// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;
 
import {LinkTokenInterface} from "@chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol";
import {IRouterClient} from "@chainlink/contracts-ccip/src/v0.8/ccip/interfaces/IRouterClient.sol";
import {Client} from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";
import {Withdraw} from "./withdraw.sol";
//  DEPLOY EN FUJI  


interface ERC20 {
    function balanceOf(address account) external view returns (uint256);
}

contract SENDERnft is Withdraw {
    enum PayFeesIn {
        Native,//0 (avax)
        LINK//1
    }
 
    address immutable i_router;
    address immutable i_link;
 
    event MessageSent(bytes32 messageId);
 
    constructor(address router, address link) {
        i_router = router;
        i_link = link;
        LinkTokenInterface(i_link).approve(i_router, type(uint256).max);
    }
 
    receive() external payable {}
 
 function linkBalance() external view returns (uint256) {
    // 0x0b9d5D9136855f6FEc3c0993feE6E9CE8a297846// link en fuji testnet
    // address tokenAddress, 
        ERC20 token = ERC20(i_link);
        return token.balanceOf(address(this));
    }

    function mint(
        uint64 destinationChainSelector,
        address receiver,
        PayFeesIn payFeesIn,
        address nftRecipientAddress
    ) external {
        Client.EVM2AnyMessage memory message = Client.EVM2AnyMessage({
            receiver: abi.encode(receiver),
            data: abi.encodeWithSignature("safeMint(address)", nftRecipientAddress),//NEW
            // data: abi.encodeWithSignature("safeMint(address)", msg.sender),//AQUI
            tokenAmounts: new Client.EVMTokenAmount[](0),
            extraArgs: "",
            feeToken: payFeesIn == PayFeesIn.LINK ? i_link : address(0)
        });
        
 
            //VALIDACIONES...
        uint256 fee = IRouterClient(i_router).getFee(
            destinationChainSelector,
            message
        );
 
        bytes32 messageId;
 
        if (payFeesIn == PayFeesIn.LINK) {
            messageId = IRouterClient(i_router).ccipSend(
                destinationChainSelector,
                message
            );
        } else {
            messageId = IRouterClient(i_router).ccipSend{value: fee}(
                destinationChainSelector,
                message
            );
        }
 
        emit MessageSent(messageId);
    }
}