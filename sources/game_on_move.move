
/// Module: hero
module game_on_move::hero {
    /// -------------------------------------------------------------------------------
    /// -------------------------------ĐỊNH NGHĨA THƯ VIỆN CẦN DÙNG--------------------
    /// -------------------------------------------------------------------------------
    
    use sui::sui::SUI;
    use sui::balance::{Self, Balance};


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
    

}



