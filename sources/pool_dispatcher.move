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
        dispatcher.pools.add(KEEPERS.to_string(), @0xcee9afe2a96a13661f9384c208dbadadb4ef57641380f175ebc09a3b97a056fc);
        dispatcher.pools.add(ECOSYSTEM_GROWTH_POOL.to_string(), @0x951efeb9d12c3b4706a2d6b96ebbffec62f404ef6c7e3e3e69d20c913611b14f);
        dispatcher.pools.add(STRATEGIC_SUPPORTERS.to_string(), @0x1eb51dca50b87b31797a9f7f563dcc4c80d9375fcece1ad1d204b95c14fa8161);
        dispatcher.pools.add(TOKEN_TREASURY.to_string(), @0xf68173898ffe80d026f641ae91ced35fd5ce375d8a1d3409f8448d11d4d7e39c);
        dispatcher.pools.add(TEAM.to_string(), @0x3d523904e821bcda1d1b2cded9b717e695d321fb4fc16ccc093fdbe1979b36bd);
        dispatcher.pools.add(ADVISORS.to_string(), @0xfe9d6eb8882ca6be88e15d005353c3458cb6e2487e723379f05ea2a71b4dee3c);
        dispatcher.pools.add(LIQUIDITY.to_string(), @0xf33c25a073ea934ed58371e86047b5a732f86f606770e837ec0758ac6b60d391);
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
