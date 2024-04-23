/// This module implements the default minting schedule of CHIRP token
module blhnsuicntrtctkn::schedule {
    // === Imports ===
    use blhnsuicntrtctkn::treasury::{Self, ScheduleEntry};

    // === Constants ===
    const KEEPERS_POOL: address = @0x02ab60f0e82d58cbd047dd27d9e09d08a9b41d8d08f2f08bd0f25424d08c7f77;
    const KEEPERS_GROWTH_POOL: address = @0x021e2fcdb57234a42a588654bc2b31fa1a53896cdc11b81d9332a5287cd0f248;
    const INVESTORS_POOL: address = @0x6bf9e238beb4391690ec02ce41cb480f91a78178819574bf6e9882cc238920d3;
    const TOKEN_TREASURY_POOL: address = @0xc196c590ff20d63d17271c8dcceafc3432a47f629292fa9f552f5c8c4ea92b4b;
    const CHIRP_TEAM_POOL: address = @0xd841709b605bafdcb27d544b0a76e35cd3e904a6b6f5b4347e836c1dd24f6306;
    const STRATEGIC_ADVISORS_POOL: address = @0x573a0841ab7c22c1e5c714c4e5ab1c440546c8c36c2b94eba62665c5f75237d6;
    const LIQUIDITY_POOL: address = @0x9575fc19fedcd62a406385dcc7607c567d91a6df94e2eea9a941051bbb6ce65e;

    // === Functions ===
    /// Returns the default minting schedule token
    public(package) fun default<T>(): vector<ScheduleEntry<T>> {
        vector[
            treasury::create_entry(vector[INVESTORS_POOL, TOKEN_TREASURY_POOL, LIQUIDITY_POOL], vector[9_600_000_0000000000, 4_500_000_0000000000, 15_000_000_0000000000], 1, 172800000, option::none()),
            // TODO: other entries
        ]
    }

    #[test_only] public fun chirp_team_pool(): address { CHIRP_TEAM_POOL }
    #[test_only] public fun investors_pool(): address { INVESTORS_POOL }
    #[test_only] public fun keepers_growth_pool(): address { KEEPERS_GROWTH_POOL }
    #[test_only] public fun keepers_pool(): address { KEEPERS_POOL }
    #[test_only] public fun liquidity_pool(): address { LIQUIDITY_POOL }
    #[test_only] public fun strategic_advisors_pool(): address { STRATEGIC_ADVISORS_POOL }
    #[test_only] public fun treasury_pool(): address { TOKEN_TREASURY_POOL }
} 
