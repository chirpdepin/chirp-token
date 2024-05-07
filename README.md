# Chirp Token contract

The Chirp Token contract implements the CHIRP coin, which is minted according to a predefined schedule.

## Deploying contract

```sh
sui client publish --gas-budget 1000000000
```

## Running tests

```sh
sui move test --gas-limit 1000000000
```

## Minting coins

Replace `$PACKAGE_ID` with your contract's package ID and `$TREASURY_ID` with the ID of the shared treasury.

```sh
sui client call --package $PACKAGE_ID --module chirp -- function mint --args $TREASURY_ID 0x6 --gas-budget 1000000000
```
