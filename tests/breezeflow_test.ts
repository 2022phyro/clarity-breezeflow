import {
  Clarinet,
  Tx,
  Chain,
  Account,
  types
} from 'https://deno.land/x/clarinet@v1.0.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
  name: "Ensure can submit weather data as contract owner",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const deployer = accounts.get("deployer")!;
    const testLocation = "New York";
    
    let block = chain.mineBlock([
      Tx.contractCall(
        "breezeflow",
        "submit-weather-data",
        [
          types.ascii(testLocation),
          types.int(25),
          types.uint(60),
          types.uint(10)
        ],
        deployer.address
      )
    ]);
    
    assertEquals(block.receipts.length, 1);
    assertEquals(block.height, 2);
    assertEquals(block.receipts[0].result.expectOk(), true);
  }
});

Clarinet.test({
  name: "Ensure non-owner cannot submit weather data",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const user = accounts.get("wallet_1")!;
    const testLocation = "New York";
    
    let block = chain.mineBlock([
      Tx.contractCall(
        "breezeflow",
        "submit-weather-data",
        [
          types.ascii(testLocation),
          types.int(25),
          types.uint(60),
          types.uint(10)
        ],
        user.address
      )
    ]);
    
    assertEquals(block.receipts[0].result.expectErr(), "u100");
  }
});

Clarinet.test({
  name: "Ensure can submit valid activity rating",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const user = accounts.get("wallet_1")!;
    
    let block = chain.mineBlock([
      Tx.contractCall(
        "breezeflow",
        "submit-rating",
        [
          types.ascii("hiking"),
          types.uint(5)
        ],
        user.address
      )
    ]);
    
    assertEquals(block.receipts[0].result.expectOk(), true);
  }
});
