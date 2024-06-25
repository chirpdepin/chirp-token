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
        dispatcher.pools.add(KEEPERS.to_string(), @0xbe5e7cd649c93c432e8f0b761d4640e03d6a6db37e04c4c70b87b37596adfc55);
        dispatcher.pools.add(ECOSYSTEM_GROWTH_POOL.to_string(), @0x1edc6ce4230130ace71a2280bcfe43ba161bf9754080fe224aff0f3849d7c30b);
        dispatcher.pools.add(STRATEGIC_SUPPORTERS.to_string(), @0x3000c7fbfb1c83abf8cd86f3a637bba37a720d60812d7d5b0ec497f553d50830);
        dispatcher.pools.add(TOKEN_TREASURY.to_string(), @0xded0cfc31d035545273f4cb9dd0648c52575062c9a4e37432c6ca3d5579f7a83);
        dispatcher.pools.add(TEAM.to_string(), @0xb67d8af06fe17d01db643428947baa6f976975254feedb5db9370f9fbd1dc233);
        dispatcher.pools.add(ADVISORS.to_string(), @0x7e8bd38d38b137eda219c11d2f17a5f59a5d9a974d6dac8ce280a36f3f87fb17);
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
