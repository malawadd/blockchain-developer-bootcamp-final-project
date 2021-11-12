// SPDX-License-Identifier: MIT

pragma solidity 0.8.0;
/// [MIT License]
/// @title NFTGAME
/// @notice smart contract for a simple NFT game

/// @notice inhert NFT (ERC721) contract from openzeppelin.
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @notice Helper functions OpenZeppelin provides.
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

/// @notice Helper function  to encode in Base64
import "./libraries/Base64.sol";

/// @notice using chainlink keepers
import "@chainlink/contracts/src/v0.8/interfaces/KeeperCompatibleInterface.sol";

/// @notice Abstract Wars NFTGAME contract inherits from ERC721, which is the standard NFT contract!
contract NFTGAME is ERC721, Ownable, KeeperCompatibleInterface {
    /**
     * @notice hold all character's attributes in a struct.
     * @param characterIndex The index of the character
     * @param name  The name of the character
     * @param imageURI The image of the character
     * @param hp The current health points of the character
     * @param maxHp The maximum health points of the character
     * @param attackDamage The attack Damaga of the character
     */
    struct CharacterAttributes {
        uint256 characterIndex;
        string name;
        string imageURI;
        uint256 hp;
        uint256 maxHp;
        uint256 attackDamage;
    }

    /**
     * @dev The tokenId is the NFTs unique identifier, it's just a number that goes
                0, 1, 2, 3, etc.
     */
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    /**
     * @dev An array that helps hold the default data for the charactes 
            this will be helpful when minting new characters in order to 
            know thier attributes 
     */

    CharacterAttributes[] defaultCharacters;

    /// @notice  create a mapping from the nft's tokenId => that NFTs attributes.
    mapping(uint256 => CharacterAttributes) public nftHolderAttributes;

    /**
     * @notice A mapping from an address => the NFTs tokenId. provides a simple 
               way to store the owner of the NFT and reference it later
     */
    mapping(address => uint256) public nftHolders;

    /**
     * @notice hold all boss's attributes in a struct.
     * @param name  The name of the boss
     * @param imageURI The image of the boss
     * @param hp The current health points of the boss
     * @param maxHp The maximum health points of the boss
     * @param attackDamage The attack Damaga of the boss
     */
    struct BigBoss {
        string name;
        string imageURI;
        uint256 hp;
        uint256 maxHp;
        uint256 attackDamage;
    }

    BigBoss public bigBoss;

    /// @notice keepers Registry address

    address public keepersRegistry = 0x4Cb093f226983713164A62138C3F718A5b595F73;

    /// @notice only keepers modifer .
    modifier onlyKeepers() {
        require(
            msg.sender == keepersRegistry,
            "Ownable: caller is not keepers registry"
        );
        _;
    }

    /**
     * @notice an event for minted NFTS.
     * @param sender  the NFT owner
     * @param tokenId the NFT Id
     * @param characterIndex index of the minted character .
     */

    event CharacterNFTMinted(
        address sender,
        uint256 tokenId,
        uint256 characterIndex
    );

    /// @notice an event that fires after a player attack the boss
    event AttackComplete(uint256 newBossHp, uint256 newPlayerHp);

    /// @notice an event that fires after a owner restore Boss Health
    event RestoreHealth(uint256 oldBossHp, uint256 newBossHp);

    /**
     * @notice this is a constructor that contains all characters/boss attr.
     * @dev characters attr. are an array, because we have many of them
            but boss isnt as there is only a single boss.
     * @notice the NFT token name is declared here. 
     */
    constructor(
        string[] memory characterNames,
        string[] memory characterImageURIs,
        uint256[] memory characterHp,
        uint256[] memory characterAttackDmg,
        string memory bossName,
        string memory bossImageURI,
        uint256 bossHp,
        uint256 bossAttackDamage
    ) ERC721("Abstracts", "ABT") {
        /// @notice Initialize the boss. Save it to our global "bigBoss" state variable.
        bigBoss = BigBoss({
            name: bossName,
            imageURI: bossImageURI,
            hp: bossHp,
            maxHp: bossHp,
            attackDamage: bossAttackDamage
        });
        // console.log(
        //     "Done initializing boss %s w/ HP %s, img %s",
        //     bigBoss.name,
        //     bigBoss.hp,
        //     bigBoss.imageURI
        // );

        /**
        * @notice Loop through all the characters, and save their attributes.'s values 
                  in our contract so  we can use them later when we mint our NFTs.   
        */
        for (uint256 i = 0; i < characterNames.length; i += 1) {
            defaultCharacters.push(
                CharacterAttributes({
                    characterIndex: i,
                    name: characterNames[i],
                    imageURI: characterImageURIs[i],
                    hp: characterHp[i],
                    maxHp: characterHp[i],
                    attackDamage: characterAttackDmg[i]
                })
            );
            // CharacterAttributes memory c = defaultCharacters[i];

            // console.log(
            //     "Done initializing %s w/ HP %s, img %s",
            //     c.name,
            //     c.hp,
            //     c.imageURI
            // );
        }

        /**
        * @dev tokenIds is incremented here so that the first NFT has an ID of 1
               instead of 0   
        */
        _tokenIds.increment();
    }

    // Users would be able to hit this function and get their NFT based on the
    // characterId they send in!

    /**
    * @notice a Character minting function
    * @dev Users would be able to hit this function and get their NFT based on the
           characterId they send in!
    * @param _characterIndex  character Id 
    */
    function mintCharacterNFT(uint256 _characterIndex) external {
        //@notice Get current tokenId (starts at 1 since we incremented in the constructor).
        uint256 newItemId = _tokenIds.current();
        ///@notice The magical function from the ERC721 contract ! Assigns the tokenId to the caller's wallet address.
        _safeMint(msg.sender, newItemId);

        ///@notice  map the tokenId => their character attributes
        nftHolderAttributes[newItemId] = CharacterAttributes({
            characterIndex: _characterIndex,
            name: defaultCharacters[_characterIndex].name,
            imageURI: defaultCharacters[_characterIndex].imageURI,
            hp: defaultCharacters[_characterIndex].hp,
            maxHp: defaultCharacters[_characterIndex].hp,
            attackDamage: defaultCharacters[_characterIndex].attackDamage
        });

        // console.log(
        //     "Minted NFT w/ tokenId %s and characterIndex %s",
        //     newItemId,
        //     _characterIndex
        // );

        ///@notice Keep an easy way to see who owns what NFT.
        nftHolders[msg.sender] = newItemId;

        ///@notice Increment the tokenId for the next person that uses it
        _tokenIds.increment();

        // emit event
        emit CharacterNFTMinted(msg.sender, newItemId, _characterIndex);
    }

    /**
     * @notice Standard tokenURI function
     * @dev this function basically attach nftHolderAttributes to the tokenURI by overriding it
     * @param _tokenId  expects a NFT data in JSON
     * @return NFT with Assigned Metadata
     */

    function tokenURI(uint256 _tokenId)
        public
        view
        override
        returns (string memory)
    {
        // /**
        //  * @notice retrieves this specific NFTs data by querying for it using it's _tokenId
        //  * @dev if I did tokenURI(256) it would return the JSON data related the 256th NFT (if it existed!).
        //  */
        CharacterAttributes memory charAttributes = nftHolderAttributes[
            _tokenId
        ];

        string memory strHp = Strings.toString(charAttributes.hp);
        string memory strMaxHp = Strings.toString(charAttributes.maxHp);
        string memory strAttackDamage = Strings.toString(
            charAttributes.attackDamage
        );

        // /**
        // * @notice takes all the data provided by tokenId and pack it dynamically here
        // * @dev abi.encodePacked just combines strings. its done because we can
        //        change things like the NFTs HP or image later if we wanted and it'd
        //        update on the NFT itself! It's dynamic.
        // */
        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "',
                        charAttributes.name,
                        " -- NFT #: ",
                        Strings.toString(_tokenId),
                        '", "description": "This is an NFT that lets people play in the game Abstract attacks!", "image": "',
                        charAttributes.imageURI,
                        '", "attributes": [ { "trait_type": "Health Points", "value": ',
                        strHp,
                        ', "max_value":',
                        strMaxHp,
                        '}, { "trait_type": "Attack Damage", "value": ',
                        strAttackDamage,
                        "} ]}"
                    )
                )
            )
        );

        //
        //  * @notice encode the formatted json file into base64
        //  * @dev this is done because it makes it readable by browsers
        //

        string memory output = string(
            abi.encodePacked("data:application/json;base64,", json)
        );

        return output;
    }

    /**
     * @notice function that allow players nft to attack boss nft
     */
    function attackBoss() public {
        //  Get the state of the player's NFT.
        uint256 nftTokenIdOfPlayer = nftHolders[msg.sender];
        CharacterAttributes storage player = nftHolderAttributes[
            nftTokenIdOfPlayer
        ];
        // console.log(
        //     "\nPlayer w/ character %s about to attack. Has %s HP and %s AD",
        //     player.name,
        //     player.hp,
        //     player.attackDamage
        // );
        // console.log(
        //     "Boss %s has %s HP and %s AD",
        //     bigBoss.name,
        //     bigBoss.hp,
        //     bigBoss.attackDamage
        // );
        ///@notice Make sure the player has more than 0 HP.
        require(player.hp > 0, "Error: character must have HP to attack boss.");

        ///@notice Make sure the boss has more than 0 HP.
        require(bigBoss.hp > 0, "Error: boss must have HP to attack boss.");

        /**
        * @notice Allow player to attack boss.
        * @dev hp is uint which cant be negative , this why it's assigned to 0,
               in case it was going to be negative 
        */
        if (bigBoss.hp < player.attackDamage) {
            bigBoss.hp = 0;
        } else {
            bigBoss.hp = bigBoss.hp - player.attackDamage;
        }
        ///@notice Allow boss to attack player.
        if (player.hp < bigBoss.attackDamage) {
            player.hp = 0;
        } else {
            player.hp = player.hp - bigBoss.attackDamage;
        }

        // // Console for ease.
        // console.log("Player attacked boss. New boss hp: %s", bigBoss.hp);
        // console.log("Boss attacked player. New player hp: %s\n", player.hp);

        ///@notice emit the new boss and player health points
        emit AttackComplete(bigBoss.hp, player.hp);
    }

    /**
     * @notice check if a user has a character NFT we've given them
     * @dev this function mainly serves the webapp , as we need to be able to retrieve player's NFT
     * @return  retrieve the NFT's attributes if the NFT exists
     */

    function checkIfUserHasNFT()
        public
        view
        returns (CharacterAttributes memory)
    {
        // Get the tokenId of the user's character NFT
        uint256 userNftTokenId = nftHolders[msg.sender];

        /**
        * @notice If the user has a tokenId in the map, return their character.
        * @dev we do userNftTokenId > 0, because there's no way to check if 
               a key in a map exists , No matter what key we look for, 
               there will be a default value of 0. Hence nft tokenId start with 1
        */
        if (userNftTokenId > 0) {
            return nftHolderAttributes[userNftTokenId];
        }
        ///@notice Else, return an empty character.
        else {
            CharacterAttributes memory emptyStruct;
            return emptyStruct;
        }
    }

    /**
     * @notice  function that Retrieve all default characters.
     * @dev this function will mainly be useful in our character select screen
     * @return   all default characters.
     */

    function getAllDefaultCharacters()
        public
        view
        returns (CharacterAttributes[] memory)
    {
        return defaultCharacters;
    }

    /**
     * @notice  Retrieve the boss
     */

    function getBigBoss() public view returns (BigBoss memory) {
        return bigBoss;
    }

    /**
     * @notice  restore the boss health
     */

    function RestoreBossHealth() public onlyOwner {
        uint256 oldhealth = bigBoss.hp;
        bigBoss.hp = bigBoss.maxHp;
        emit RestoreHealth(oldhealth, bigBoss.hp);
    }

    /**
     * @notice  keeper implemntaion to restore boss health
     */

    function checkUpkeep(
        bytes calldata /* checkData */
    )
        external
        view
        override
        returns (
            bool upkeepNeeded,
            bytes memory /* performData */
        )
    {
        upkeepNeeded = bigBoss.hp <= 0;
    }

    function performUpkeep(
        bytes calldata /* performData */
    ) external override onlyKeepers {
        uint256 oldhealth = bigBoss.hp;
        bigBoss.hp = bigBoss.maxHp;
        emit RestoreHealth(oldhealth, bigBoss.hp);
    }
}
