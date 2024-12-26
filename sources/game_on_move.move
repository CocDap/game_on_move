
/// Module: hero
module game_on_move::hero {
    /// -------------------------------------------------------------------------------
    /// -------------------------------ĐỊNH NGHĨA THƯ VIỆN CẦN DÙNG--------------------
    /// -------------------------------------------------------------------------------
    
    use sui::sui::SUI;
    use sui::balance::{Self, Balance};
    use sui::coin::{Self, Coin};

    /// -------------------------------------------------------------------------------
    /// -------------------------------ĐỊNH NGHĨA OBJECT-------------------------------
    /// -------------------------------------------------------------------------------
    
    // Tạo 1 object Sword

    public struct Sword has key, store {
        id: UID,
        // Sức mạnh phép thuật 
        magic: u64,
        // Sức mạnh của Sword trong game 
        strength: u64,
        game_id: ID

    }
    // Tạo 1 object Hero 

    public struct Hero has key, store {
        id: UID,
        // Hit point - Máu của Hero 
        hp: u64,
        // Điểm kinh nghiệm của hero 
        experience: u64,
        // Hero có Sword 
        sword: Option<Sword>,
        // Game id mà user đang chơi 
        game_id: ID,
    }

    // Tạo 1 object "Máu" -> Sử dụng để hồi HP 
    public struct Potion has key, store {
        id: UID,
        // Lượng hồi máu
        potency: u64,
        // Game id mà user đang chơi 
        game_id: ID

    }

    // Tạo 1 object Quái Boar

    public struct Boar has key {
        id: UID,
        // Máu của quái tối đa bao nhiêu 
        // HP =0 -> quái chết 
        hp: u64,
        // Sức mạnh của quái 
        strength: u64,
        // Game id 
        game_id: ID

    }

    // Tạo GameAdmin
    public struct GameInfo has key {
        id: UID,
        admin: address,
        payments: Balance<SUI>,
    }

    public struct GameAdmin has key {
        id: UID,
        boars_created: u64,
        potions_created: u64,
        game_id: ID

    }

    /// -------------------------------------------------------------------------------
    /// -------------------------------ĐỊNH NGHĨA EVENT--------------------------------
    /// -------------------------------------------------------------------------------
    

    public struct BoarSlainEvent has copy, drop {
        // player nào hạ gục boar
        slayer_address: address,
        // ID của hero mà user đang control 
        hero: ID,
        // ID của boar đã bị hạ gục
        boar: ID,
        game_id: ID

    }


    /// -------------------------------------------------------------------------------
    /// ----------------------ĐỊNH NGHĨA CÁC HẰNG SỐ ----------------------------------
    /// -------------------------------------------------------------------------------
    

    const MAX_HP: u64 = 1000;

    const MAX_MAGIC: u64 = 10;

    const MIN_SWORD_COST: u64 = 100;


    /// -------------------------------------------------------------------------------
    /// -------------------------------ĐỊNH NGHĨA LỖI----------------------------------
    /// -------------------------------------------------------------------------------
    
    const EBOAR_WON: u64 = 0;

    const EHERO_TIRED: u64 = 1;
    const ENOT_ADMIN: u64 = 2;

    const EINSUFFICIENT_FUNDS: u64 = 3; 

    const ENO_SWORD: u64 = 4;

    const EWRONG_GAME_PLAY: u64 = 5;

    /// -------------------------------------------------------------------------------
    /// -------------------------ENTRY FUNCTION TẠO GAME ------------------------------
    /// -------------------------------------------------------------------------------
    
    public entry fun new_game(ctx: &mut TxContext) {
        create(ctx);
    }
    
    /// -------------------------------------------------------------------------------
    /// -----------------HELPER FUNCTION CHO VIỆC TẠO GAME ADMIN VÀ GAME INFO----------
    /// -------------------------------------------------------------------------------
    fun create(ctx: &mut TxContext){
        let sender = tx_context::sender(ctx);
        let id = object::new(ctx);
        let game_id = object::uid_to_inner(&id);
    
        transfer::share_object(GameInfo { 
            id, 
            admin: sender,
            payments: balance::zero()
        });
    
        transfer::transfer(
            GameAdmin {
                id: object::new(ctx),
                boars_created: 0,
                potions_created: 0,
                game_id,
            }, 
            sender
        )
    
    }

    /// -------------------------------------------------------------------------------
    /// -------------------------ENTRY FUNCTION TẠO HERO VÀ SWORD ------------------------------
    /// -------------------------------------------------------------------------------
    
    public entry fun acquire_hero(game: &mut GameInfo, payment: Coin<SUI>, ctx: &mut TxContext) {
        let sword = create_sword(game, payment, ctx);
        let hero = create_hero(game, sword, ctx);
        transfer::transfer(hero, tx_context::sender(ctx))
    
    }
 
    /// -------------------------------------------------------------------------------
    /// ---------------------HELPER FUNCTION TẠO HERO VÀ SWORD-------------------------
    /// -------------------------------------------------------------------------------
 
    // Tạo Sword
    public fun create_sword(game: &mut GameInfo, payment: Coin<SUI>, ctx: &mut TxContext): Sword {
        // Lấy số lượng coin hiện tại mà user sở hữu 
        let value = coin::value(&payment);
    
        assert!(value >= MIN_SWORD_COST, EINSUFFICIENT_FUNDS);
    
        // pay coin cho admin 
        coin::put(&mut game.payments, payment);
    
        // Công thức tính magic 
        let magic =  (value - MIN_SWORD_COST)/ MIN_SWORD_COST;
        Sword {
            id: object::new(ctx),
            magic: std::u64::min(magic, MAX_MAGIC),
            strength: 1,
            game_id: object::id(game)
        }
    
    }
    
    // Tạo hero 
    public fun create_hero(game: &GameInfo, sword: Sword, ctx: &mut TxContext): Hero {
        // Kiểm tra có cùng game id hay không 
        assert!(object::id(game) == sword.game_id, EWRONG_GAME_PLAY);
        Hero {
            id: object::new(ctx),
            hp: 100,
            experience: 0,
            sword: option::some(sword),
            game_id: object::id(game),
        }
    }



}



