// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interface/IERC20.sol";

contract MyContract{
    IMyToken public cbdcToken;
    IMyToken public physicalCurrency;
    address public centralBank;
    uint256 public constant MAX_SUPPLY = 1_000_000_000 * 10**18; // cbn should have a max supply of 1 Billion tokens
    uint256 public totalMinted;

    

    constructor(address _digitalAddress, address _physicalAddress) {
        cbdcToken =  IMyToken(_digitalAddress);
        physicalCurrency=  IMyToken( _physicalAddress);
        centralBank=msg.sender;
    }
    
    struct Recorde{
        address bankAdress;
        uint PhysicalCurrencySwaped;
        uint CbdcTokenAllocated;
    }

    struct CommercialCustomer{
        uint PhysicalCurrencySwaped;
        uint CbdcTokenAllocated;
    }

    mapping (address=>bool) public  commercialBank;
    mapping (uint => Recorde) public banksRecord;
    mapping (address => CommercialCustomer) public commercialCustomerRecord;

    uint public totalCommercialbanks;

    
    
    // modifers 

    modifier  OnlyCentralBank(){
        require(centralBank == msg.sender, "Only central bank can mint digital currency");
        _;
    }

    modifier OnlyComercialBanks(){
        require(commercialBank[msg.sender], "Only comercial banks are allow to transact here");
        _;
    }


    // errors

    error AmountIsZero();
    error ExceedsMaxSupply();

    function getBalance() public view returns (uint256) {
        return cbdcToken.balanceOf(address(this));
    }
     
    //  central bank minting the currency 
     function mintDigitalCurrency(uint256 _amountToMint, address _minter) public OnlyCentralBank {
        if (_amountToMint <= 0) revert AmountIsZero();
        if (totalMinted + _amountToMint > MAX_SUPPLY) revert ExceedsMaxSupply();
        totalMinted += _amountToMint;
        cbdcToken.addMinter(_minter);
        cbdcToken.mint(_minter, _amountToMint);
     }

    //  commercial banks exchanging physical currency with digital assets
     function exchangePhsical_cbdcToken(uint256 _amount) external  OnlyComercialBanks{
        require(_amount > 0, "can't swap Zero Physical currency");
        require(cbdcToken.balanceOf(address(this)) > _amount, "Fedral reseve is out of assets");
        
         // Bank sends physical currency to contract
        require(
            physicalCurrency.allowance(msg.sender, address(this)) >= _amount,
            "Insufficient physical currency allowance"
        );
       
        bool successPhysical = physicalCurrency.transferFrom(
            msg.sender, 
            address(this), 
            _amount
        );
        require(successPhysical, "Physical currency transfer failed");

        // contract i.e the cbn sends cbdc to comercial banks
        bool successCBDC = cbdcToken.transfer(msg.sender, _amount);

        require(successCBDC, "CBDC transfer failed");
        cbdcToken.transfer(msg.sender, _amount);
         totalCommercialbanks ++;
         
         banksRecord[totalCommercialbanks]=Recorde({
            bankAdress:msg.sender,
            PhysicalCurrencySwaped:_amount,
            CbdcTokenAllocated:_amount
         });


     }


     //  distribute to retailers
       function retailersPhysicalCashToCBDCToken(uint256 _amount, uint _bankID) external {
            require(_amount > 0, "can't swap Zero Physical currency");
             require(_bankID <= totalCommercialbanks, "bank does not exist");

             address _bankAddress=banksRecord[_bankID]. bankAdress;
             require(cbdcToken.balanceOf(_bankAddress) >= _amount, "Bank is out of cash");
             require(physicalCurrency.balanceOf(msg.sender) >= _amount, "Insufficient phsical cash for swap");
              require(
                 physicalCurrency.allowance(msg.sender, _bankAddress) >= _amount,
                 "Insufficient physical currency allowance"
                  );
             // Transfer physical currency from retailer to bank
                bool successPhysical = physicalCurrency.transferFrom(
                    msg.sender,
                    _bankAddress,
                    _amount
                );
               require(successPhysical, "Physical currency transfer failed");
        
                // Transfer CBDC tokens from bank to retailer
                  bool successCBDC = cbdcToken.transfer(msg.sender, _amount);
                  require(successCBDC, "CBDC transfer failed");
                  commercialCustomerRecord[msg.sender]=CommercialCustomer({
                          PhysicalCurrencySwaped:_amount,
                          CbdcTokenAllocated:_amount
                  });
       }


        // adding banks to the list of verified commercial bamks
       function addCommercialBank(address _bank) external OnlyCentralBank {
            commercialBank[_bank]=true;
        }


}