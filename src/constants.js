const CONTRACT_ADDRESS = '0x8D923ED4368Ad414bEa4Ad96d9ab548D6cc32a18';

const transformCharacterData = (characterData) => {
    return {
        name: characterData.name,
    imageURI: characterData.imageURI,
    hp: characterData.hp.toNumber(),
    maxHp: characterData.maxHp.toNumber(),
    attackDamage: characterData.attackDamage.toNumber(),
    };
};

export { CONTRACT_ADDRESS , transformCharacterData};