// This file is MIT Licensed.
// SPDX-License-Identifier: MIT
// Copyright 2017 Christian Reitwiessner
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
pragma solidity ^0.8.0;

import "./pairing.sol";

contract BalanceVerifier {
    using Pairing for *;

    struct VerifyingKey {
        Pairing.G1Point alpha;
        Pairing.G2Point beta;
        Pairing.G2Point gamma;
        Pairing.G2Point delta;
        Pairing.G1Point[] gamma_abc;
    }

    function verifyingKey() pure internal returns (VerifyingKey memory vk) {
        vk.alpha = Pairing.G1Point(uint256(0x21cc2efea3ff4d43ff761ab2da50bdee573c92f572db276acd32f2b80e9125e1), uint256(0x04135e99867b910cd9555bde25b0b787c7aa9e0fe8ab8e7461e2989b59bb89fc));
        vk.beta = Pairing.G2Point([uint256(0x10ce2783a2dafd2e7c5de4825ddaacc0b6f9a07158e8fb26aa1ea165381afd03), uint256(0x165d8f753d78d94746dcbd6789d531e8003cb018b3fb77e59723e98bc29b586d)], [uint256(0x015793082049e4ec177b8db9cac6f1885437526aca24368afa6207325bbb9cdc), uint256(0x24a8342cff30fb16dc209463eabf3d611c6224becd22e34e2f6cf088de18c40b)]);
        vk.gamma = Pairing.G2Point([uint256(0x22ed4868e2e3acc59d1d6f4dc522510bade3e0f9b31d8c1ef906956a07531ad5), uint256(0x0335b1446251373d4d827adb189ebb92f10cb135678265cb76fbc1b5425c8cd5)], [uint256(0x2837d2a592b59052d7ceeaf5ba2bbad31d5f8fb8ddc85c3f225f93904827f76a), uint256(0x07b2b1d5716eb59838d404d7ad847ca71689d82948e8f2251a40b96fbf375184)]);
        vk.delta = Pairing.G2Point([uint256(0x1e0e252876779c499e0582eeefca59922f2e616a6c06b584b4520738dc622473), uint256(0x16c750c4af2f82626b26c7a46cfc9e2051159595d890a571a9c97ef1b0817649)], [uint256(0x247abac455e077292a50a83578737a65d5b24c112ac07b7a5ea18c070089c94f), uint256(0x1a3ea8a111aa1833b2488efad73afdfd29f23c0691188ffae8375699e0ae408b)]);
        vk.gamma_abc = new Pairing.G1Point[](4);
        vk.gamma_abc[0] = Pairing.G1Point(uint256(0x0b001cb19edaf1507305cae7a8d78dbb5ff1e16a544aa7e9468605f02e42b9ef), uint256(0x0e9bd33dcacddca895aea1449d4fb420e21af15a1a06e7fa877a694e8e87e55f));
        vk.gamma_abc[1] = Pairing.G1Point(uint256(0x2af6d81e8f2975da2416394a26dcae843955d8b7c0e1c6e2910101e5a6082c37), uint256(0x14cd5feb6adcb62c6690b82d0b724ddf7d911cd9b718c29d57928c0279f96600));
        vk.gamma_abc[2] = Pairing.G1Point(uint256(0x177dedc7bf5134d84665412ccc27a86fec621b2c4b15b78c31fbbcb7cd35bc25), uint256(0x1e796bb1c4ccce49c906d1b59b6fe894e3c7cd1889b1ba61df372c44f9a051ff));
        vk.gamma_abc[3] = Pairing.G1Point(uint256(0x17f4905be707bddbfc4da894f4b33d08273bed00477783f7233800ad6dcfba93), uint256(0x22e6223d3d456edc820fd941735f26ab9b73c37a9386d8e6359c70118981e86a));
    }
    function verify(uint[] memory input, Pairing.Proof memory proof) internal view returns (uint) {
        uint256 snark_scalar_field = 21888242871839275222246405745257275088548364400416034343698204186575808495617;
        VerifyingKey memory vk = verifyingKey();
        require(input.length + 1 == vk.gamma_abc.length);
        // Compute the linear combination vk_x
        Pairing.G1Point memory vk_x = Pairing.G1Point(0, 0);
        for (uint i = 0; i < input.length; i++) {
            require(input[i] < snark_scalar_field);
            vk_x = Pairing.addition(vk_x, Pairing.scalar_mul(vk.gamma_abc[i + 1], input[i]));
        }
        vk_x = Pairing.addition(vk_x, vk.gamma_abc[0]);
        if(!Pairing.pairingProd4(
             proof.a, proof.b,
             Pairing.negate(vk_x), vk.gamma,
             Pairing.negate(proof.c), vk.delta,
             Pairing.negate(vk.alpha), vk.beta)) return 1;
        return 0;
    }
    function verifyTx(
            Pairing.Proof memory proof, uint[3] memory input
        ) public view returns (bool r) {
        uint[] memory inputValues = new uint[](3);

        for(uint i = 0; i < input.length; i++){
            inputValues[i] = input[i];
        }
        if (verify(inputValues, proof) == 0) {
            return true;
        } else {
            return false;
        }
    }
}