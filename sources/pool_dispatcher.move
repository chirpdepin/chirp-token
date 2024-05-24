module blhnsuicntrtctkn::pool_dispatcher {
    // === Imports ===
    use std::string::{String};
    use sui::bag::{Self, Bag};
    use sui::balance::{Self, Balance};
    use sui::coin::{Self, Coin};

    // === Constants ===
    const STRATEGIC_SUPPORTERS: vector<u8> = b"strategic_supporters";
    const KEEPERS: vector<u8> = b"keepers";
    const ECOSYSTEM_GROWTH_POOL: vector<u8> = b"ecosystem_growth_pool";
    const ADVISORS: vector<u8> = b"advisors";
    const TEAM: vector<u8> = b"team";
    const TOKEN_TREASURY: vector<u8> = b"token_treasury";
    const LIQUIDITY: vector<u8> = b"liquidity";

    // === Structs ===

    /// Manages token pools.
    public struct PoolDispatcher has key, store {
        /// The unique identifier of the pool dispatcher.
        id: UID,
        /// The pools managed by the dispatcher.
        pools: Bag,
    }

    // === Public package functions ===

    /// Creates a new pool dispatcher.
    public(package) fun default<T>(ctx: &mut TxContext): PoolDispatcher {
        let mut dispatcher = PoolDispatcher {
            id: object::new(ctx),
            pools: bag::new(ctx),
        };
        dispatcher.pools.add(KEEPERS.to_string(), balance::zero<T>());
        dispatcher.pools.add(ECOSYSTEM_GROWTH_POOL.to_string(), @0x021e2fcdb57234a42a588654bc2b31fa1a53896cdc11b81d9332a5287cd0f248);
        dispatcher.pools.add(STRATEGIC_SUPPORTERS.to_string(), @0x6bf9e238beb4391690ec02ce41cb480f91a78178819574bf6e9882cc238920d3);
        dispatcher.pools.add(TOKEN_TREASURY.to_string(), @0xc196c590ff20d63d17271c8dcceafc3432a47f629292fa9f552f5c8c4ea92b4b);
        dispatcher.pools.add(TEAM.to_string(), @0xd841709b605bafdcb27d544b0a76e35cd3e904a6b6f5b4347e836c1dd24f6306);
        dispatcher.pools.add(ADVISORS.to_string(), @0x573a0841ab7c22c1e5c714c4e5ab1c440546c8c36c2b94eba62665c5f75237d6);
        dispatcher.pools.add(LIQUIDITY.to_string(), @0x9575fc19fedcd62a406385dcc7607c567d91a6df94e2eea9a941051bbb6ce65e);
        return dispatcher
    }

    /// Set the address of an address pool.
    public(package) fun set_address_pool(
        dispatcher: &mut PoolDispatcher,
        name: String,
        address: address,
    ) { 
        let pool: &mut address = &mut dispatcher.pools[name];
        *pool = address;
    }

    /// Transfer the coin to a pool.
    public(package) fun transfer<T>(
        dispatcher: &mut PoolDispatcher,
        name: String,
        obj: Coin<T>,
    ) {
        if (name == KEEPERS.to_string()) {
            let pool: &mut Balance<T> = &mut dispatcher.pools[name];
            coin::put(pool, obj);
        } else {
            let pool: address = dispatcher.pools[name];
            transfer::public_transfer(obj, pool);
        }
    }

    /// Returns true if the pool dispatcher contains a pool with the given name.
    public(package) fun contains(
        dispatcher: &PoolDispatcher,
        name: String,
    ): bool {
       dispatcher.pools.contains(name) 
    }

    /// Take the coin from the keepers pool.
    public(package) fun take_from_keepers_pool<T>(
        dispatcher: &mut PoolDispatcher,
        amount: u64,
        ctx: &mut TxContext,
    ):Coin<T>{
        coin::take(&mut dispatcher.pools[KEEPERS.to_string()], amount, ctx)
    }

    #[test_only]
    public(package) fun add_address_pool(
        dispatcher: &mut PoolDispatcher,
        name: String,
        address: address,
    ) {
        dispatcher.pools.add(name, address);
    }

    #[test_only]
    public(package) fun get_address_pool(
        dispatcher: &PoolDispatcher,
        name: String,
    ): address {
        dispatcher.pools[name]
    }

    #[test_only]
    public(package) fun get_pool_balance<T>(
        dispatcher: &PoolDispatcher,
        name: String,
    ): u64 {
        let pool: &Balance<T> = &dispatcher.pools[name];
        pool.value()
    }
}
