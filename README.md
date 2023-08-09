# Web3-Native Credit Bureau
A decentralized cross-chain credit bureau designed to allow whitelisted protocols to submit credit reports for addresses and retrieve credit histories across multiple chains for better underwriting.

## Features 🌟
- Whitelisting of addresses to control report submissions.
- Support for multiple types of credit lines, including uncollateralized, collateralized, and overcollateralized.
- Duration categorization into fixed and revolving.
- Cross-chain functionality supported by Axelar.
- Viewable credit summaries, including the length of credit history, total open credit lines, and more.

## Prerequisites 🛠
- Solidity ^0.8.19
- [HardHat](https://github.com/NomicFoundation/hardhat)
- [Axelar](https://www.axelar.network/) setup for cross-chain communication.

## Smart Contracts 📜
- `CreditBureau`: Main contract responsible for handling credit reports and summaries.
- `SatelliteCreditBureau`: Helper contract for easier access to Axelar's cross-chain calls.

## Usage 💡
- Whitelist addresses using the `toggleWhitelist` function.
- Submit credit reports for addresses via the `submitCreditReport` function.
- View credit summaries using the `viewCreditSummary` function.
- To make cross-chain calls, use helper contract's `submitCreditReport` method and ensure Axelar data like destination chain and address are correct.

## Contributing 🤝
We welcome contributions from the community! This is a public goods project made for the whole web3 community to expand and implement. Contrarily to tradfi credit bureau that are private, centralised and pay-per-view, we are aiming at a collaborative apporach able to create a stronger, more fair and transparent ecosystem.

## License ⚖️
This project is licensed under the GPLv3 License. See the [LICENSE](LICENSE) file for details.
