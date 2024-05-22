module blhnsuicntrtctkn::pool_dispatcher {
    // === Imports ===
    use sui::bag::{Self, Bag};

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
        dispatcher.pools.add(b"keepers",@0x02ab60f0e82d58cbd047dd27d9e09d08a9b41d8d08f2f08bd0f25424d08c7f77);
        dispatcher.pools.add(b"ecosystem_growth_pool", @0x021e2fcdb57234a42a588654bc2b31fa1a53896cdc11b81d9332a5287cd0f248);
        dispatcher.pools.add(b"strategic_supporters", @0x6bf9e238beb4391690ec02ce41cb480f91a78178819574bf6e9882cc238920d3);
        dispatcher.pools.add(b"token_treasury", @0xc196c590ff20d63d17271c8dcceafc3432a47f629292fa9f552f5c8c4ea92b4b);
        dispatcher.pools.add(b"team", @0xd841709b605bafdcb27d544b0a76e35cd3e904a6b6f5b4347e836c1dd24f6306);
        dispatcher.pools.add(b"advisors", @0x573a0841ab7c22c1e5c714c4e5ab1c440546c8c36c2b94eba62665c5f75237d6);
        dispatcher.pools.add(b"liquidity", @0x9575fc19fedcd62a406385dcc7607c567d91a6df94e2eea9a941051bbb6ce65e);
        return dispatcher
    }

    /// Set the address of an address pool.
    public(package) fun set_address_pool(
        dispatcher: &mut PoolDispatcher,
        name: vector<u8>,
        address: address,
    ) { 
        let pool: &mut address = &mut dispatcher.pools[name];
        *pool = address;
    }

    /// Transfer an object to a pool.
    public(package) fun transfer<T: key + store>(
        dispatcher: &PoolDispatcher,
        name: vector<u8>,
        obj: T,
    ) {
        let pool: address = dispatcher.pools[name];
        transfer::public_transfer(obj, pool);
    }

    #[test_only]
    public fun add_address_pool(
        dispatcher: &mut PoolDispatcher,
        name: vector<u8>,
        address: address,
    ) {
        dispatcher.pools.add(name, address);
    }

    #[test_only]
    public fun get_address_pool(
        dispatcher: &PoolDispatcher,
        name: vector<u8>
    ): address {
        dispatcher.pools[name]
    }
}
