const NFTGAME = artifacts.require("NFTGAME");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("NFTGAME", function ( accounts ) {
  const [mohammed, layla, coogan] = accounts;

  beforeEach(async () => {
    game = await NFTGAME.deployed();
  });

  describe("characters & boss", async ()=>{
    beforeEach(async () => {
      game = await NFTGAME.deployed();
    });

    it("should have three defalut characters" , async function(){

      const defaultCharacters = await game.getAllDefaultCharacters()
      // console.log(defaultCharacters)
  
      return assert.lengthOf(defaultCharacters,3,`expected three default characters`)
  
    });

    
    it("should have one boss character" , async function(){

      const bossCharacters = await game.getBigBoss()
      // console.log(bossCharacters)

      return assert.equal(bossCharacters.name,"Empror",`expected only one Boss`)

    });

  } );

  describe("minting a character", async ()=>{
    beforeEach(async () => {
      game = await NFTGAME.deployed();
    });

    it("should check if player do not have an NFT in thier account" , async function(){

      const nft = await game.checkIfUserHasNFT({from: layla})
      // console.log(nft)
  
      return assert.isEmpty(nft.name,"user have an NFT in thier account")
  
    })

    it("should allow player to mint a character  ", async function () {
     
      let eventEmitted = false; 
      const mint = await game.mintCharacterNFT(0, {from: mohammed})
   
      if(mint.logs[1].event == "CharacterNFTMinted"){
       eventEmitted = true
      }
       
       const minted = await game.checkIfUserHasNFT({from: mohammed})
   
       // console.log(mint)
       // console.log(minted)
       return assert.equal(eventEmitted,
         true,
         "minting a character should emit an event ")
     });

     it("should check if player have an NFT in thier account ", async function () {
     
      const mint = await game.mintCharacterNFT(0, {from: layla})
      const nft = await game.checkIfUserHasNFT({from: layla})


      // console.log(nft)
  
      return assert.isNotEmpty(nft.name,"user have an NFT in thier account")

     });
  
        //  console.log(attack)
    
        // return assert.isNotEmpty(nft.name,"user have an NFT in thier account")
  
       });

       describe("Functionallity", async ()=>{
        beforeEach(async () => {
          game = await NFTGAME.deployed();
        });
    
         it("should check player can attack Boss ", async function () {
  
          let eventEmitted = false; 
          const mint = await game.mintCharacterNFT(0, {from: mohammed})
          const attackBoss = await game.attackBoss({from: mohammed})
          if(attackBoss.logs[0].event == "AttackComplete"){
            eventEmitted = true
           }
          //  console.log(attackBoss)
           return assert.equal(eventEmitted,
            true,
            "Attacking the boss should emit an event ")
        });

        it("should restore Boss hp ", async function () {
  
          let eventEmitted = false; 
          const p1 = await game.mintCharacterNFT(1, {from: mohammed})
          const p2 = await game.mintCharacterNFT(1, {from: layla})
          const p3 = await game.mintCharacterNFT(1, {from: coogan})
          const attackBoss1 = await game.attackBoss({from: mohammed})
          const attackBoss2 = await game.attackBoss({from: layla})
          const attackBoss3 = await game.attackBoss({from: coogan})
          const restoreHealth = await game.RestoreBossHealth({from: mohammed})

          if(restoreHealth.logs[0].event == "RestoreHealth"){
            eventEmitted = true
           }
            console.log(restoreHealth)
           return assert.equal(eventEmitted,
            true,
            "Restoring the boss healthe should emit an event ")
        });

  } );

  
});

