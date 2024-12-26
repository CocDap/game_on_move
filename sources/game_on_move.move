
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

    
    
}



