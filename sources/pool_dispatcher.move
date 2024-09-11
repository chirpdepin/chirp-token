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
        dispatcher.pools.add(KEEPERS.to_string(), @0x5178c7c4cf934a58422b6cf9526fc59671f246d5a27f63db60474e187158de75);
        dispatcher.pools.add(ECOSYSTEM_GROWTH_POOL.to_string(), @0x1edc6ce4230130ace71a2280bcfe43ba161bf9754080fe224aff0f3849d7c30b);
        dispatcher.pools.add(STRATEGIC_SUPPORTERS.to_string(), @0xead69d610b981d13f2f3d7a964cc6b94f2d52cfa8b5ac138c38f2c466543b4f2);
        dispatcher.pools.add(TOKEN_TREASURY.to_string(), @0xded0cfc31d035545273f4cb9dd0648c52575062c9a4e37432c6ca3d5579f7a83);
        dispatcher.pools.add(TEAM.to_string(), @0xb67d8af06fe17d01db643428947baa6f976975254feedb5db9370f9fbd1dc233);
        dispatcher.pools.add(ADVISORS.to_string(), @0x0b8c9b59d4f07b6d2a2c3e1c7b9692b8c4ff49c4618c958e4e19bf415728a963);
        dispatcher.pools.add(LIQUIDITY.to_string(), @0xc85c58c6669e2139524bb214942d5d3cd252c81692ad58d246bf7831e16b68d7);
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
