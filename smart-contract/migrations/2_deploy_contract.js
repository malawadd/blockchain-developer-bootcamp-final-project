var gameContract = artifacts.require("./NFTGAME.sol");

module.exports =async function(deployer) {


  await deployer.deploy(gameContract, 
    ["Knight Castle", "Sleeping Beauty", "Flying Wisdom"],       // Names
        ["https://bafybeidunlbwgi76hqxigu3uedpczvzywlbwnptvwugsi6kqssaal6q7qa.ipfs.dweb.link/index2.png ", // Images
        "https://bafybeic7fd5l4zybrjzfmzsrsz6fs7izayytb53qmm7oyooof7smmc5sty.ipfs.dweb.link/index3.png", 
        "https://bafybeihikzan7xselev5g3so7i372bibvhskxamwjbpnihoyxkd7ftxfay.ipfs.dweb.link/index4.png"],
        [500, 20, 3000],                    // HP values
        [1000, 2500, 25],
        "Empror", // Boss name
        "https://bafybeiaqw2lamaw6hrb65zbonw6m5ybddsizxg2x2knyka25xsvbdife3m.ipfs.dweb.link/index.png", // Boss image
         10000, // Boss hp
           50 // Boss attack damage 
)};


