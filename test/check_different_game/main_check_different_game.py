# main.py
from env import *
from connect_to_postgres import connect_to_postgres 
from convert_game_code_to_game_id import convert_game_code_to_game_id
import time

def main_check_different_game(result_array,sb_current):
    try: 
        #is test?
        if test==True:
            print("This is a test run")
        #connect to db
        conn = connect_to_postgres(**db_config)
        print(f"This is postgres db to connect:{db_postgres_to_connect}")
        
        # get games from source_oc and sync to target oc: - enable if needed
        # get_games_from_oc_and_insert_to_target_oc(conn,source_OCs,target_OCs)
        print("check values")
        print(f"this is result_array {result_array}")
        print(f"this is sb_current {sb_current} ")
        if is_result_array_game_code:
            result_array=convert_game_code_to_game_id(result_array,conn)
        
        if is_sb_current_game_code:
            sb_current=convert_game_code_to_game_id(sb_current,conn)

        # --- Compare arrays ---
        not_exist_sb_current_array = [item for item in result_array if item not in sb_current]
        not_exist_result_array = [item for item in sb_current if item not in result_array]

        # --- Output the result ---
        # print("result_array:", result_array)
        print("not in sb_current:", not_exist_sb_current_array)
        print("not in result_array:", not_exist_result_array)
    except Exception as e:
        print(f"This is error during execution of main: {e}")

if __name__ == "__main__":
    main_check_different_game(result_array,sb_current)