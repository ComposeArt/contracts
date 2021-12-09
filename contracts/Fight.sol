// SPDX-License-Identifier: CC-BY-4.0

pragma solidity >= 0.8.0;

contract Fight {

    address controller;
    bool[169] elementsMatrix;
    uint constant BOUTS = 10;

    struct Fighter {
        uint32 specialElement;
        uint32 specialDefense;
        uint32 specialAttack;
        uint32 element;
        uint32 defense;
        uint32 attack;
    }

    constructor (uint256 _elementsMatrix) {
        controller = msg.sender;

        for(uint i=0;i<169;i++) {
            elementsMatrix[i] = ((_elementsMatrix >> i) & 1) == 1;
        }
    }

    function elementIsStrong(uint8 _eo, uint8 _et) public view returns (bool) {
        return elementsMatrix[_eo * 13 + _et];
    }

    function elementIsWeak(uint8 _eo, uint8 _et) public view returns (bool) {
        return elementsMatrix[_et * 13 + _eo];
    }

    function fight(uint32 _fighterOne, uint32 _fighterTwo) public view returns (uint32, uint32, uint128) {
        Fighter memory fighterOne;
        fighterOne.specialElement = _fighterOne & 15;
        fighterOne.specialDefense = (_fighterOne >> 4) & 15;
        fighterOne.specialAttack = (_fighterOne >> 8) & 15;
        fighterOne.element = (_fighterOne >> 12) & 15;
        fighterOne.defense = (_fighterOne >> 16) & 15;
        fighterOne.attack = (_fighterOne >> 20) & 15;

        Fighter memory fighterTwo;
        fighterTwo.specialElement = _fighterTwo & 15;
        fighterTwo.specialDefense = (_fighterTwo >> 4) & 15;
        fighterTwo.specialAttack = (_fighterTwo >> 8) & 15;
        fighterTwo.element = (_fighterTwo >> 12) & 15;
        fighterTwo.defense = (_fighterTwo >> 16) & 15;
        fighterTwo.attack = (_fighterTwo >> 20) & 15;
        
        uint256 randomNumber = uint256(keccak256(abi.encodePacked(block.timestamp, block.number, block.difficulty)));
        uint128 eventLog;
        bool pom = (fighterOne.specialDefense + fighterOne.specialAttack + fighterOne.defense + fighterOne.attack) <= (fighterTwo.specialDefense + fighterTwo.specialAttack + fighterTwo.defense + fighterTwo.attack);

        for (uint b=0;b<BOUTS;b++) {
            if (pom) {
                (fighterTwo.defense, fighterTwo.specialDefense, eventLog, randomNumber) = attack(fighterOne.attack, fighterOne.specialAttack, fighterTwo.defense, fighterTwo.specialDefense, eventLog, randomNumber);
            } else {
                (fighterOne.defense, fighterOne.specialDefense, eventLog, randomNumber) = attack(fighterTwo.attack, fighterTwo.specialAttack, fighterOne.defense, fighterOne.specialDefense, eventLog, randomNumber);
            }
            if (fighterOne.defense == 0 || fighterTwo.defense == 0)
                break;
            pom = !pom;
        }

        return ((fighterOne.attack << 20) + (fighterOne.defense << 16) + (fighterOne.element << 12) + (fighterOne.specialAttack << 8) + (fighterOne.specialDefense << 4) + fighterOne.specialElement, (fighterTwo.attack << 20) + (fighterTwo.defense << 16) + (fighterTwo.element << 12) + (fighterTwo.specialAttack << 8) + (fighterTwo.specialDefense << 4) + fighterTwo.specialElement, eventLog);
    }

    function attack(uint32 _a, uint32 _sa, uint32 _d, uint32 _sd, uint128 _el, uint256 _r) internal view returns(uint32, uint32, uint128, uint256) {
        uint32 e;
        if (_sd > 0) {
            e = uint32(_r % _sa);
            if (e > _sd)
                _sd = 0;
            else
                _sd = _sd - e;
        } else {
            e = uint32(_r % _a);
            if (e > _d)
                _d = 0;
            else
                _d = _d - e;
        }
        _el = (_el << 4) + e;
        return (_d, _sd, _el, uint256(keccak256(abi.encodePacked(block.timestamp, block.number, _r))));
    }
}