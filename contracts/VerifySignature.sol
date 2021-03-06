// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VerifySignature {

    function recover(
        bytes32 messageHash, 
        uint8 v, 
        bytes32 r, 
        bytes32 s
    ) public pure returns (address) {
        return ecrecover(messageHash, v, r, s);
    }
    
    function verifyRelease(
        address _signer,
        address _owner,
        bytes32 _provenance,
        bytes memory signature
    ) public pure returns (bool) {
        bytes32 payloadHash = keccak256(abi.encodePacked(_owner, _provenance));
        bytes32 messageHash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", payloadHash));
        return recoverSigner(messageHash, signature) == _signer;
    }
    
    function verifyMinter(
        address _signer,
        address _to,
        uint32 _id,
        bool _isBase,
        bytes memory signature
    ) public pure returns (bool) {
        bytes32 payloadHash = keccak256(abi.encodePacked(_to, _id, _isBase));
        bytes32 messageHash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", payloadHash));
        return recoverSigner(messageHash, signature) == _signer;
    }
    
    function verifyF(
        address _signer,
        address _to,
        uint32 _id,
        bytes memory signature
    ) public pure returns (bool) {
        bytes32 payloadHash = keccak256(abi.encodePacked(_to, _id));
        bytes32 messageHash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", payloadHash));
        return recoverSigner(messageHash, signature) == _signer;
    }

    function recoverSigner(bytes32 _ethSignedMessageHash, bytes memory _signature)
        public
        pure
        returns (address)
    {
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);

        return ecrecover(_ethSignedMessageHash, v, r, s);
    }

    function splitSignature(bytes memory sig)
        public
        pure
        returns (
            bytes32 r,
            bytes32 s,
            uint8 v
        )
    {
        require(sig.length == 65, "invalid signature length");

        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }
    }
}
