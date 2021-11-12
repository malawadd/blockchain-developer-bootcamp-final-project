const CONTRACT_ADDRESS = '0x590f0295200f7cb43A55d87f08c3D1A8f828186d';

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