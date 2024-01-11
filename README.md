# Chirp Token contract

Contract on the SUI blockchain permits administrators to mint CHIRP tokens within a fixed maximum limit.
It aligns with SUI wallet and exchange interfaces and includes a non-burnable token policy.
The primary role of the contract is to manage the issuance of tokens, adhering to the set supply cap.

## Starting localnet node

```sh
RUST_LOG="off,sui_node=info" sui-test-validator
```


## Getting test coins

```sh
curl -L -X POST 'http://127.0.0.1:9123/gas' -H 'Content-Type: application/json' -d "{\"FixedAmountRequest\": {\"recipient\": \"$(sui client active-address)\"}}"
```


## Deploying contract

```sh
sui client publish --gas-budget 30000000
```

## Running tests

```sh
sui move test
```

## Minting coins

Replace `$PACKAGE_ID` and `$TREASURY_CAP` with your contract's package ID and treasury cap.

```sh
sui client call --package $PACKAGE_ID --module chirp --function mint --args $TREASURE_CAP 4000 $(sui client active-address) --gas-budget 20000000
```

## Sending coins to others

Replace `$COIN_ID` and `$RECIPIENT` with your coin ID and recipient address.

```sh
sui client pay --input-coins $COIN_ID --gas-budget 3000000 --recipients $RECIPIENT --amounts 10000000000
```
