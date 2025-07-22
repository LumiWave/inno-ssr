<p align="center">
  <img src="https://innofile.blob.core.windows.net/common/SSR Token_Black_Round_512.png">
</p>

Welcome to SSR Token
===============
SSR is the official token of **Samurai Shodown R**, a Web3 reboot of SNK’s legendary fighting game IP, operated by LumiWave.  
The token powers in-game experiences and unlocks Web3 functionalities across the SSR ecosystem built on the **Sui mainnet**.

About SSR Token
---------------------

SSR  
<br>
- **Swords** clash in _Samurai Shodown R_: a return of honor and action in a new era.

Shodown  
<br>
- Web3-native _Showdown_: enabling on-chain battles, progression, and ownership.

Reboot  
<br>
- Classic IP meets _Rebooted Ecosystem_: seamlessly bridging game and chain.

SSR provides the following features and use cases:
<br>
* Fungible Token on Sui Mainnet  
* Used in-game for upgrades, rewards, and events  
* Redeemable in Web3 dashboards, DeFi protocols, and NFT utilities  
<br><br>

Catchphrase:
<br>
_Honor Reignited. Battle Rebooted. SSR — your sword in the Web3 frontier._
<br><br>

SSR represents our belief in merging legendary gameplay with transparent, on-chain innovation — all while keeping the player at the center.

---

Contract Information
---------------------

- **Network**: Sui Mainnet  
- **Token Symbol**: `$SSR`  
- **Decimals**: 9  
- **Object ID**:  
  `0x79f0b9a0862120619e0ed79690c81be28032b63b2b4fb19226dc81f40fa60d03::SSR::SSR`  
- **Token Type**: SUI-based fungible token  
- **Issuer**: LumiWave  

[View on SuiScan](https://suiscan.xyz/mainnet/coin/0x79f0b9a0862120619e0ed79690c81be28032b63b2b4fb19226dc81f40fa60d03::SSR::SSR/txs)

---

Sample Integration
---------------------

```ts
// SSR balance check (TypeScript pseudocode)
const SSR_COIN_TYPE = '0x79f0b9a0862120619e0ed79690c81be28032b63b2b4fb19226dc81f40fa60d03::SSR::SSR'

const coins = await suiClient.getCoins({
  owner: walletAddress,
  coinType: SSR_COIN_TYPE,
})

const totalSSR = coins.data.reduce((acc, coin) => acc + Number(coin.balance), 0)
