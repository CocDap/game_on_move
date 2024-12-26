
/// Module: hero
module game_on_move::hero {
    /// -------------------------------------------------------------------------------
    /// -------------------------------ĐỊNH NGHĨA THƯ VIỆN CẦN DÙNG--------------------
    /// -------------------------------------------------------------------------------
    
    use sui::sui::SUI;
    use sui::balance::{Self, Balance};
    use sui::coin::{Self, Coin};
    use sui::event;

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

    /// -------------------------------------------------------------------------------
    /// -------------------------ENTRY FUNCTION ADMIN TẠO BOAR ---------------------
    /// -------------------------------------------------------------------------------
    
    
    // Admin tạo boar cho player 
    public entry fun send_boar(
        game: &GameInfo,
        admin: &mut GameAdmin,
        hp: u64,
        strength: u64,
        player: address,
        ctx: &mut TxContext
    ) {
        assert!(object::id(game) == admin.game_id, EWRONG_GAME_PLAY);
    
        admin.boars_created = admin.boars_created + 1;
        // send boars to the designated player
        transfer::transfer(
            Boar { id: object::new(ctx), hp, strength, game_id: object::id(game) },
            player
        )
    }


    /// -------------------------------------------------------------------------------
    /// --------------ENTRY FUNCTION LIÊN QUAN TỚI HÀNH ĐỘNG CỦA HERO------------------
    /// -------------------------------------------------------------------------------
    
    // Hàm đánh quái 
    public entry fun slay(game: &GameInfo, hero: &mut Hero, boar: Boar, ctx: &TxContext){
    
        // Kiểm tra game ID của hero 
        assert!(object::id(game) == hero.game_id, EWRONG_GAME_PLAY);
        // Kiểm tra game ID của Boar
        assert!(object::id(game) == boar.game_id, EWRONG_GAME_PLAY);
    
        // Destructure boar object 
        let Boar {id: boar_id, strength: boar_strength, hp, game_id: _} = boar;
        let hero_strength = hero_strength(hero);
    
        assert!(hero_strength !=0, EHERO_TIRED);
    
        let mut boar_hp = hp;
    
        let mut hero_hp = hero.hp;
    
        // Tấn công boar cho đến khi HP của Boar còn 0 
        while (boar_hp > hero_strength) {
            // đầu tiên hero attack trước 
            boar_hp = boar_hp - hero_strength; 
            // sau đó boar attack 
            assert!(hero_hp >= boar_strength, EBOAR_WON);
    
            hero_hp = hero_hp - boar_strength;
    
        };
    
        // lưu lại HP của Hero sau khi tấn công boar
    
        hero.hp = hero_hp;
        // Nhận kinh nghiệm bằng lượng HP của boar sau khi đánh bại 
        hero.experience = hero.experience + hp;
        
        // Tăng sức mạnh của Sword lên 1 đơn vị 
    
        if (option::is_some(&hero.sword)) {
            level_up_sword(option::borrow_mut(&mut hero.sword), 1)
        };
        event::emit(BoarSlainEvent {
            slayer_address: tx_context::sender(ctx),
            hero: object::uid_to_inner(&hero.id),
            boar: object::uid_to_inner(&boar_id),
            game_id: object::id(game)
        });
    
        object::delete(boar_id);
    
    }
    
    /// -------------------------------------------------------------------------------
    /// ---------------------HELPER FUNCTION CHO HÀM SLAY(ĐÁNH QUÁI)-------------------
    /// -------------------------------------------------------------------------------
    
    // Sức mạnh của Sword khi tấn công 
    public fun sword_strength(sword: &Sword): u64 {
        sword.magic + sword.strength
    }
    
    // Sức mạnh của Hero khi tấn công 
    public fun hero_strength(hero: &Hero): u64 {
        // Nếu hero có HP = 0 thì không thể attack 
    
        if (hero.hp == 0) {
            return 0
        };
        // Nếu hero có sử dụng Sword -> lấy sức mạnh của Sword 
        let  sword_strength  = if (option::is_some(&hero.sword)) {
            sword_strength(option::borrow(&hero.sword))
        }
        else {
            0
        };
    
        // Sức mạnh của hero 
        (hero.experience * hero.hp) + sword_strength
    }
    
    // Tăng cấp cho Sword 
    public fun level_up_sword(sword: &mut Sword, amount: u64) {
        sword.strength =  sword.strength + amount;
    }


    /// -------------------------------------------------------------------------------
    /// -------------------------ENTRY FUNCTION ADMIN TẠO POTION---------------------
    /// -------------------------------------------------------------------------------
    
    // Admin tạo potion (bình máu) cho player 
    public entry fun send_potion(
        game: &GameInfo,
        potency: u64,
        player: address,
        admin: &mut GameAdmin,
        ctx: &mut TxContext
    ) {
        assert!(object::id(game) == admin.game_id, EWRONG_GAME_PLAY);
        admin.potions_created = admin.potions_created + 1;
        // send potion to the designated player
        transfer::transfer(
            Potion { id: object::new(ctx), potency, game_id: object::id(game) },
            player
        )
    }

    /// -------------------------------------------------------------------------------
    /// -------------------------ENTRY FUNCTION LIÊN QUAN TỚI TRANG BỊ-----------------
    /// -------------------------------------------------------------------------------
    
    
    /// Phục hồi máu cho hero 
    public fun heal(hero: &mut Hero, potion: Potion) {
        assert!(hero.game_id == potion.game_id, EWRONG_GAME_PLAY);
        let Potion { id, potency, game_id: _ } = potion;
        object::delete(id);
        let new_hp = hero.hp + potency;
        // maximum HP của hero là 1000
        hero.hp = std::u64::min(new_hp, MAX_HP)
    }
    
    /// Trang bị New Sword cho Hero và return old sword 
    public fun equip_sword(hero: &mut Hero, new_sword: Sword): Option<Sword> {
        option::swap_or_fill(&mut hero.sword, new_sword)
    }
    
    /// Tháo Sword ra khỏi trang bị của Hero 
    public fun remove_sword(hero: &mut Hero): Sword {
        assert!(option::is_some(&hero.sword), ENO_SWORD);
        option::extract(&mut hero.sword)
    }

}



