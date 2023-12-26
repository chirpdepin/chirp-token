module blhnsuicntrtctkn::chirp {
    use std::option;
    use sui::coin::{Self, TreasuryCap};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};

    /// Error code for minting more tokens than allowed
    const EMintLimitReached: u64 = 2;

    struct CHIRP has drop {}

    #[allow(unused_function)]
    /// Module initializer is called once on module publish. A treasury
    /// cap is sent to the publisher, who then controls minting
    fun init(witness: CHIRP, ctx: &mut TxContext) {
        let (treasury, metadata) = coin::create_currency(witness, 10, b"CHIRP", b"Chirp Token", b"Chirp token description", option::none(), ctx);
        transfer::public_freeze_object(metadata);
        transfer::public_transfer(treasury, tx_context::sender(ctx))
    }

    /// Mint tokens to the recipient
    public entry fun mint(treasury_cap: &mut TreasuryCap<CHIRP>, amount: u64, recipient: address, ctx: &mut TxContext) {
        assert!(amount <= (3000000000000000000u64 - coin::total_supply(treasury_cap)), EMintLimitReached);
        coin::mint_and_transfer(treasury_cap, amount, recipient, ctx)
    }

    #[test_only]
    /// Wrapper of module initializer for testing
    public fun test_init(ctx: &mut TxContext) {
        init(CHIRP{}, ctx)
    }
}
