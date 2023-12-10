# HONORLOANS

[demo]<https://honorloans.web.app>

HONOR LOANS is an experiment where currency issuance is backed by honourability of the members in a network of trust

## Installation
```
yarn 
yarn parcel src/index.html   --port 2122 --https 

```

# To compile demo (firebase)
```
yarn parcel src/index.html --dist-dir public  --public-url ./
firebase deploy
```
if errors
```
nvm install 18                                               
```
## Description
Let's say Bob needs to borrow 200usd, but he doesn’t want to ask for a credit in a bank. Maybe a friend (or someone in his  network of trust) can lend him that money without paying for interest.
So, his friend Alice , lends him the 200 bucks as he promises her to give it back in 90 days. 


With honorLoans Bob mints a new token called Bobcoin, for the amount of the loan and gives it to Alice. 
That's cool for three reasons:
1- they both have a remainder (in the form of an NFT) for the amount of the loan and the conditions they agreed for, a very useful thing to have as our memory is not flawless.


2- if she wishes, Alice can use  bobcoins at Bob’s store.
3- Bob can accept other participant’s coins to  progressively pay for this loan.


As Bob progressively pays his debt during this cycle, Bobcoins now become Alicecoins. 
Having liquidity, this newly minted Alicecoins, can be directly used as a form of payment between other honorLoans’s network of trust participants. 

The balance is dynamically reflected in each respective  NFT wallet that each participant holds


At the end of the cycle, if Bob didn't pay for the loan, he loses his honorability, being banned to create new loans and being banned from the network until he restores his honor.




## Tech
This project uses:



## Project status
Project built during CONSTALLATION hachathon

## Usage
1- Visit the app.  
2- Deposit or Ask for a Loan
3- Start Interacting

# Demo
- [ ] [DEMO](https://honorloans.web.app) 

## Support
Write me to @xunorus


## Credits
- Developed by Xunorus and a comunity of undisclosed and atemporal thinkers.


## Misc
[© Xunorus 2023](http://xunorus.com)