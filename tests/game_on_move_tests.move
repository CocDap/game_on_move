
#[test_only]
module game_on_move::hero_tests;

#[test]
fun game_test() {
    use sui::test_scenario;
    use sui::coin::{Self};
    use game_on_move::hero::{new_game, GameInfo, acquire_hero, GameAdmin, send_boar, Boar, Hero, slay, take_payment};

    let admin = @0xAD014;
    let player = @0x0;

    let mut scenario_val = test_scenario::begin(admin);
    let scenario = &mut scenario_val;
    // Run the create new game 
    test_scenario::next_tx(scenario, admin);
    {
        new_game(test_scenario::ctx(scenario));
    };
    // Tạo Hero cùng với Sword
    test_scenario::next_tx(scenario, player);
    {
        let mut game = test_scenario::take_shared<GameInfo>(scenario);
        let coin = coin::mint_for_testing(500, test_scenario::ctx(scenario));
        acquire_hero(&mut game, coin, test_scenario::ctx(scenario));
        test_scenario::return_shared(game);
    };
    // Admin tạo boar cho Player 
    test_scenario::next_tx(scenario, admin);
    {
        let game = test_scenario::take_shared<GameInfo>(scenario);
        let game_ref = &game;
        let mut admin_cap = test_scenario::take_from_sender<GameAdmin>(scenario);
        send_boar(game_ref, &mut admin_cap, 10, 10, player, test_scenario::ctx(scenario));
        test_scenario::return_to_sender(scenario, admin_cap);
        test_scenario::return_shared(game);
    };
    // Player slays the boar!
    test_scenario::next_tx(scenario, player);
    {
        let game = test_scenario::take_shared<GameInfo>(scenario);
        let game_ref = &game;
        let mut hero = test_scenario::take_from_sender<Hero>(scenario);
        std::debug::print(&b"Before slaying boar, our hero is:".to_string());
        std::debug::print(&hero);
        let boar = test_scenario::take_from_sender<Boar>(scenario);
        slay(game_ref, &mut hero, boar, test_scenario::ctx(scenario));
        test_scenario::return_to_sender(scenario, hero);
        test_scenario::return_shared(game);
    };

    test_scenario::next_tx(scenario, player);
    {
        let hero = test_scenario::take_from_sender<Hero>(scenario);
        std::debug::print(&b"After slaying boar, our updated hero is:".to_string());
        std::debug::print(&hero);
        test_scenario::return_to_sender(scenario, hero);
    };

    // Take Payment Checking 

    test_scenario::next_tx(scenario, admin);
    {
        let game = test_scenario::take_shared<GameInfo>(scenario);
        std::debug::print(&b"Before taking payment:".to_string());
        std::debug::print(&game);
        test_scenario::return_shared(game);
    };

    test_scenario::next_tx(scenario, admin);
    {
        let mut game = test_scenario::take_shared<GameInfo>(scenario);
        let admin_game = test_scenario::take_from_sender<GameAdmin>(scenario);
        take_payment(&admin_game, &mut game, test_scenario::ctx(scenario));
        test_scenario::return_to_sender(scenario, admin_game);
        test_scenario::return_shared(game);

    };


    test_scenario::next_tx(scenario, admin);
    {
        let game = test_scenario::take_shared<GameInfo>(scenario);
        
        std::debug::print(&b"After taking payment:".to_string());
        std::debug::print(&game);
        test_scenario::return_shared(game);
    };



    test_scenario::end(scenario_val);
}
