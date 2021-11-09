import React, { useEffect, useState } from 'react';
import SelectCharacter from './Components/SelectCharacter';
import { CONTRACT_ADDRESS, transformCharacterData  } from './constants';
import NFTGAME from './utils/MyEpicGame.json';
import { ethers } from 'ethers';
import './App.css';
import { transform } from 'typescript';
import Arena from './Components/Arena';
import LoadingIndicator from './Components/LoadingIndicator';
import consensysLogo from './assets/consensys-logo.svg'

const TWITTER_HANDLE = 'consensysacad'
const CONSENSYS_LINK = `https://consensys.net/academy/`

const App = () => {

   /*
   * Just a state variable we use to store our user's public wallet.
   */

   const [currentAccount, setCurrentAccount] = useState(null);

   const [characterNFT, setCharacterNFT] = useState(null);

   // loading state 

   const [isLoading, setIsLoading] = useState(false);

   
  /*
   * Start by creating a new action that we will run on component load
   */
  // Actions

  const checkIfWalletIsConnected = async () => {
    try {    

    /*
     * First make sure we have access to window.ethereum
     */

    const { ethereum } = window;

    if (!ethereum) {
      console.log('Make sure you have MetaMask!');

      setIsLoading(false);
      return;
    } else {
      console.log('We have the ethereum object', ethereum);

      
        /*
         * Check if we're authorized to access the user's wallet
         */

        const accounts = await ethereum.request({method: 'eth_accounts'});

         /*
         * User can have multiple authorized accounts, we grab the first one if its there!
         */
         if (accounts.length !== 0) {
          const account = accounts[0];
          console.log('Found an authorized account:', account);
          setCurrentAccount(account);
        } else {
          console.log('No authorized account found');
        }
      }
    } catch (error) {
      console.log(error);
    }

    setIsLoading(false);

  };

  // Render Methods
const renderContent = () => {

  if(isLoading){
    return <LoadingIndicator/>
  }
  /*
   * Scenario #1
   */
  if (!currentAccount) {
    return (
      <div className="connect-wallet-container">
      <img
        src="https://i.gifer.com/embedded/download/3OFpJ.gif"
        alt="luffy vs SilorMoon Gif"
      />
      {/* 
      * Button that we will use to trigger wallet connect
       * Don't forget to add the onClick event to call your method!
      */}
      <button
      className='cta-button connect wallet button'
      onClick={connectWalletAction}
      > connect Wallet to get started </button>
    </div>
    );
    /*
     * Scenario #2
     */
  } else if (currentAccount && !characterNFT) {
    return <SelectCharacter setCharacterNFT={setCharacterNFT} />;
  }
  
  /*
     * Scenario #3
  * If there is a connected wallet and characterNFT, it's time to battle!
     */
    else if ( currentAccount && characterNFT){
      return <Arena characterNFT={characterNFT} setCharacterNFT={setCharacterNFT} />
    }




};



  //  connect your wallet method

  const connectWalletAction = async () => {
    try {
      const {ethereum} = window;
      if (!ethereum) {
        alert('Get MetaMask');
        return;
      }
      //  request access to account 

      const accounts = await ethereum.request({
        method: 'eth_requestAccounts',
      });

      //Boom! This should print out public address once we authorize Metamask.

      console.log('connected', accounts[0]);
      setCurrentAccount(accounts[0]);
    } catch(error) {
      console.log(error);
    }
  };

  /*
   * This runs our function when the page loads.
   */

  useEffect(() => {
    setIsLoading(true);
    checkIfWalletIsConnected();
  }, [])

  useEffect(() => {

    //this is the function we will call to interact with our contract 

    const fetchNFTMetadata  = async() => {
      console.log('Checking for Character NFT on address:', currentAccount);

      const provider = new ethers.providers.Web3Provider(window.ethereum);
      const signer = provider.getSigner();
      const gameContract = new ethers.Contract(
        CONTRACT_ADDRESS,
        NFTGAME.abi,
        signer
      );

      const txn = await gameContract.checkIfUserHasNFT();
      console.log(txn);
      if (txn.name) {
        console.log('User has character  NFT');
        setCharacterNFT(transformCharacterData(txn));
      } else {
        console.log('No character NFT found');
      }

      // done loeading
      setIsLoading(false);
    };

    // We only want to run this, if we have a connected wallet

    if (currentAccount) {
      console.log('CurrentAccount:', currentAccount);
    fetchNFTMetadata();
    }
  }, [currentAccount]);

  return (
    <div className="App">
      <div className="container">
        <div className="header-container">
          <p className="header gradient-text">⚔️ Abstract Attacks ⚔️</p>
          <p className="sub-text">Now, only on Rinkeby testnet </p>
          {renderContent()}
        </div>
        <div className="footer-container">
          {/* <a className="footer-text">{`Final Project for consensys Academy Bootcamp 2021`}</a> */}
          <img alt="twitter Logo" className="twitter-logo" src={consensysLogo} />
          <a
            className="footer-text"
            href={CONSENSYS_LINK}
            target="_blank"
            rel="noreferrer"
          >{`Final Project for consensys Academy Bootcamp 2021`}</a>
        </div>
        
      </div>
    </div>
  );
};

export default App;
