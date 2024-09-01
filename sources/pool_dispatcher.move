module blhnsuicntrtctkn::pool_dispatcher {
    // === Imports ===
    use std::string::{String};
    use sui::bag::{Self, Bag};
    use sui::coin::{Coin};

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
    public(package) fun default(ctx: &mut TxContext): PoolDispatcher {
        let mut dispatcher = PoolDispatcher {
            id: object::new(ctx),
            pools: bag::new(ctx),
        };
        dispatcher.pools.add(KEEPERS.to_string(), @0xb933a40acfc93c76497594b61846a467852cbe69d05dcf5e6bdac854455244dc);
        dispatcher.pools.add(ECOSYSTEM_GROWTH_POOL.to_string(), @0xc3cf26f16dc0c7c77f0a6213c3e87adab3b8a97a0f5a840121a72200ebb62ca9);
        dispatcher.pools.add(STRATEGIC_SUPPORTERS.to_string(), @0x045d9efa0ac428d510f36dd9c7647e22cbff50a11652d3d008a87c1014491932);
        dispatcher.pools.add(TOKEN_TREASURY.to_string(), @0x8a7aee051362c9a7336ad1cd9eca9703294349a74e7bb9310c9784e223a67870);
        dispatcher.pools.add(TEAM.to_string(), @0xcb54d8e3160b554eea3a9493ec5bf5766263903e2ab3f5e6b8eb7470dce9f609);
        dispatcher.pools.add(ADVISORS.to_string(), @0x931391f8d0c321a5a23a68f566a28fed705ff3cb621b7f1967a0f16a9081fd0a);
        dispatcher.pools.add(LIQUIDITY.to_string(), @0x6b1d6f41388f9e0c6080b6823dc4ba672e32bfc4e68becc92c811d694352ec5f);
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
        dispatcher: &PoolDispatcher,
        name: String,
        obj: Coin<T>,
    ) {
        let pool: address = dispatcher.pools[name];
        transfer::public_transfer(obj, pool);
    }

    /// Returns true if the pool dispatcher contains a pool with the given name.
    public(package) fun contains(
        dispatcher: &PoolDispatcher,
        name: String,
    ): bool {
       dispatcher.pools.contains(name) 
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
}
