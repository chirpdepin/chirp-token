module blhnsuicntrtctkn::depositary {
    use sui::balance::{Self, Balance};
    use sui::coin::{Self, Coin, TreasuryCap};
    use sui::linked_table::{Self, LinkedTable};

    use blhnsuicntrtctkn::chirp::CHIRP;

    public struct ClaimedChirp has key {
        id: UID,
        claimed_amount: u64,
    }

    public struct ClaimingPool has key, store {
        id: UID,
        liquidity: Balance<CHIRP>,
        all_staked_chirp: u128,
        claimed_chirp_holders: LinkedTable<address, vector<u64>>,
    }

    public fun create_claiming_pool(_cap: &TreasuryCap<CHIRP>, ctx: &mut TxContext) {
        let staking_pool = ClaimingPool{
            id: object::new(ctx),
            liquidity: balance::zero<CHIRP>(),
            all_staked_chirp: 0,
            claimed_chirp_holders: linked_table::new<address, vector<u64>>(ctx)
        };
        transfer::share_object(staking_pool);
    }

    public fun hold(cp: &mut ClaimingPool, chirp: Coin<CHIRP>, recivier: address, ctx: &mut TxContext) {
        // linked_table

        let chirp_amount = coin::value(&chirp);
        let balance = coin::into_balance(chirp);
        balance::join(&mut cp.liquidity, balance);
        let v = vector::empty<u64>();
        
        linked_table::push_back(&mut cp.claimed_chirp_holders, tx_context::sender(ctx), v);
    }

    
    // fun claim(claimed_chirp: ClaimedChirp, claiming_pool: &mut ClaimingPool, ctx: &mut TxContext): Coin<CHIRP> {
    //     let coin_balance = balance::split<CHIRP>(&mut claiming_pool.liquidity, claimed_chirp.claimed_amount);
    //     let chirp = coin::from_balance<CHIRP>(coin_balance, ctx);

    //     burn(claimed_chirp, claiming_pool);

    //     linked_table::remove(&mut claiming_pool.claimed_chirp_holders, tx_context::sender(ctx));

    //     chirp
    // }

}
