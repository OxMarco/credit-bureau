const { assert } = require("chai");
const { ethers, BigNumber, parseEther } = require("hardhat");
const {
  createNetwork,
  relay,
  bigNumberToNumber,
} = require("@axelar-network/axelar-local-dev");

describe("Unit tests", function () {
  let eth, avalanche;
  let creditBureau, satelliteCreditBureau;

  before(async function () {
    // Initialize an Ethereum network
    eth = await createNetwork({ name: "Ethereum" });

    // Deploy the credit bureau contract on Ethereum
    creditBureau = await ethers.deployContract("CreditBureau", [
      eth.gateway.address,
      eth.gasService.address,
    ]);

    // Initialize an Avalanche network
    avalanche = await createNetwork({name: "Avalanche"});

    // Deploy the satellite bureau contract on Avalanche
    satelliteCreditBureau = await ethers.deployContract(
      "SatelliteCreditBureau",
      [avalanche.gateway.address, avalanche.gasService.address],
    );
  });

  it("Submit local credit report", async function () {
    const [deployer, user, reporter] = await ethers.getSigners();
    await creditBureau.toggleWhitelist(reporter.address);

    // Send the report
    const reportData = createReport(reporter);
    await creditBureau
      .connect(reporter)
      .submitCreditReport(reportData, user.address);

    // perform some basic checks
    const report = await creditBureau.creditHistory(user.address, 0);
    runAsserts(report, reportData, reporter.address);
  });

  it("Submit cross-chain credit report", async function () {
    const [deployer, user, reporter] = await ethers.getSigners();
    await creditBureau.toggleWhitelist(reporter.address);

    const reportData = createReport(reporter);
    await satelliteCreditBureau.submitCreditReport("Ethereum", creditBureau.address, reportData, user.address, {value: ethers.parseEther("0.1")});

    const report = await creditBureau.creditHistory(user.address, 0);
    runAsserts(report, reportData, reporter.address);
  });

  function runAsserts(report, reportData, reporterAddress) {
    assert(
      report.creditProvider === reportData.creditProvider,
      "Mismatch in creditProvider",
    );
    assert(report.reporter == reporterAddress, "Mismatch in reporter");
    assert(report.review == reportData.review, "Mismatch in review");
    assert(report.status == reportData.status, "Mismatch in status");
    assert(
      report.credit.collateral == reportData.credit.collateral,
      "Mismatch in collateral",
    );
    assert(
      report.credit.creditType == reportData.credit.creditType,
      "Mismatch in creditType",
    );
    assert(
      report.credit.fromDate == reportData.credit.fromDate,
      "Mismatch in fromDate",
    );
    assert(
      report.credit.toDate == reportData.credit.toDate,
      "Mismatch in toDate",
    );
    assert(
      report.credit.amount == reportData.credit.amount,
      "Mismatch in amount",
    );
    assert(report.credit.token == reportData.credit.token, "Mismatch in token");
    assert(
      ethers.toUtf8String(report.data) === ethers.toUtf8String(reportData.data),
      "Mismatch in data",
    );
  }

  function createReport() {
    const randomAddress = ethers.Wallet.createRandom().address;
    const randomReview = randomNumber(0, 2); // Assuming 0, 1, 2 are the valid enum values
    const randomStatus = randomNumber(0, 3); // Assuming 0, 1, 2, 3 are the valid enum values
    const randomCollateral = randomNumber(0, 2); // Assuming 0, 1, 2 are the valid enum values
    const randomCreditType = randomNumber(0, 1); // Assuming 0, 1 are the valid enum values

    // Construct the Report data with random parameters
    const reportData = {
      creditProvider: "Credit Protocol",
      reporter: "0x0000000000000000000000000000000000000000", // Filled by the smart contract
      review: randomReview,
      status: randomStatus,
      credit: {
        collateral: randomCollateral,
        creditType: randomCreditType,
        fromDate: Date.now() - randomNumber(1, 60) * 24 * 60 * 60 * 1000, // Up to 60 days ago
        toDate: Date.now(),
        amount: randomNumber(1, 1000000000) * 1000000,
        token: randomAddress,
        chain: 0, // Filled by the smart contract
      },
      timestamp: 0, // Filled by the smart contract
      data: ethers.toUtf8Bytes("Randomized report data"),
    };

    return reportData;
  }

  function randomNumber(min, max) {
    return Math.floor(Math.random() * (max - min + 1)) + min;
  }
});
