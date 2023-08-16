// This file is MIT Licensed.
// SPDX-License-Identifier: MIT
// Copyright 2017 Christian Reitwiessner
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
pragma solidity ^0.8.0;

import "./pairing.sol";

contract DivBalanceVerifier {
    using Pairing for *;
    struct VerifyingKey {
        Pairing.G1Point alpha;
        Pairing.G2Point beta;
        Pairing.G2Point gamma;
        Pairing.G2Point delta;
        Pairing.G1Point[] gamma_abc;
    }
    function verifyingKey() pure internal returns (VerifyingKey memory vk) {
        vk.alpha = Pairing.G1Point(uint256(0x2a143ae0732707bafc331d604ba3955e86f81cd9c19de8ade77495c7998febec), uint256(0x2528726215c151735f8be083d56698aa7425ece5bb69b4cc2cb7d23b6f93b869));
        vk.beta = Pairing.G2Point([uint256(0x1e5aa6508c0915d8dd6d32efad609acc491f720391cf8d2f7fcceb6efddf890a), uint256(0x19607a169b689af6591380164301d7a6331314f7ee19471be88909636602d956)], [uint256(0x2d43306bcc949320cfe22d7f3efca9a18d8e1185d2aecb2a374a4ae675f8b572), uint256(0x0d8b318f572fe1b6fa0b56da93c2938b3774143c82c3aa2968ca80de1b6066d8)]);
        vk.gamma = Pairing.G2Point([uint256(0x2fd5fe05f7ac9e5b1439485b19f075eabd0f753521dc94a7d94e235f8bcf1a45), uint256(0x301c04670ad97b98f9687570a40dae7030dbf919e0e867f52b6c8d0d8fcd80db)], [uint256(0x10f2201c24cb9fdce9057a676ea0ce0b822731cd4adb17409ea6dd8743c1b6ed), uint256(0x048ddb00a6d8064ee0fcab54b914d2c125867540b29528f35160ced65549fc0f)]);
        vk.delta = Pairing.G2Point([uint256(0x115bb9c5e6105ebebf098c4980f2b9dc87f814c9b4ce49439a0280e3ee43ef92), uint256(0x01ca45dc2925486b55a2b5d33048b525fab3763dcd2097be20884f219ee0625b)], [uint256(0x14dbf56417783fd3d57abab7f5aabba1c11f33ba36c79cbdd804389bd42f5f94), uint256(0x2059495cda4682cf24ce4b9109bd5f6636987790085618147d98f00d1342242a)]);
        vk.gamma_abc = new Pairing.G1Point[](8);
        vk.gamma_abc[0] = Pairing.G1Point(uint256(0x2b7c6ed4714c898616f3591c0ea9358501c359ce9c53df25b4ecfa631d3b0db7), uint256(0x0dc2992e96acf36ec6d3a4bdeb94238e9c7393992cf5ef3f711e77c77970a1c5));
        vk.gamma_abc[1] = Pairing.G1Point(uint256(0x1883a81c5e0589391dc5862b3d9f10b9ec34ea9a30c51e68d9e6374a0ddb2569), uint256(0x0189d5c6e6efaf542145be075a17612e2e1093ef8fe0d72c1e2111cf0e7a2632));
        vk.gamma_abc[2] = Pairing.G1Point(uint256(0x130b27fb47ef8173814f8fbbb87581fe3bce7bbdc546fd40411bc8dc92a93815), uint256(0x0ba3f6206bef2978314b460613d929e9b976c0cad512ab453e65baeef83059c9));
        vk.gamma_abc[3] = Pairing.G1Point(uint256(0x17b8251eb0c48beb9c760eff40e049a138fe30f244f7e1b0611e3405c0244370), uint256(0x025594bd3616dfcce6a1535713a2d94be613c0220cd60ac8a573a6f42ff3d185));
        vk.gamma_abc[4] = Pairing.G1Point(uint256(0x21b429dbfc21428563c3d61a5baff6ced622c79573403757ce66295edc8ad2ca), uint256(0x113b6627d1473c30555712f49f2a2010a0c34079f3e0d3a844e5cc76139173d7));
        vk.gamma_abc[5] = Pairing.G1Point(uint256(0x11e1fba18f13a0e345aab82cebce9230773350e02b6abbd2d3f9b5c808db6404), uint256(0x187c2a1e6ad0f0cbfd5fe5654f9afc7a4ad8e7140bd998ec88365ce64bf07cff));
        vk.gamma_abc[6] = Pairing.G1Point(uint256(0x0b8200cc5c96925c202142f76c7a3ddd4b470295e43faaf7dc03ba94b5c5f4a3), uint256(0x28a15e90728634fdfc1fe447ef1340ba88ca28dca04927ce18d6a063c9eaf20a));
        vk.gamma_abc[7] = Pairing.G1Point(uint256(0x02607d4d93caca19781e078f937503b1d94c6f7c6e7675cc35ccea1c93b7599c), uint256(0x222d7b8d67048b48136809c78a91842cc8bf124a4bab33e2d180de2bb01688ba));
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
            Pairing.Proof memory proof, uint[7] memory input
        ) public view returns (bool r) {
        uint[] memory inputValues = new uint[](7);

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