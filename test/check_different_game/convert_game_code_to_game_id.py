from connect_to_postgres import query_postgresdb
import json
from env import *


def get_game_id(conn,game_code):
    try: 
        query = """
            SELECT id
            FROM public.games
            where code=%s;
        """
        game_code=str(game_code)
        record_result=query_postgresdb(conn,query,(game_code,),True)

        if record_result:
            for record in record_result:
                my_array=list(record)
                game_id=my_array[0]
        print(f"This is game_id {game_id} for game code: {game_code}")
        return game_id
    except Exception as e:
        print(f"This is error {e}")
        print(f"get game_id failed for game code {game_code}")
        conn.rollback()  
        



def convert_game_code_to_game_id(game_code_array, conn):
    try:
        n=1
        game_id_array=[]
        for game_code in game_code_array:
            # #test
            if n>1 and test==True:
                break
            # #test
            game_id=get_game_id(conn,game_code)
            print(f"this is game_id {game_id }for game_code {game_code}")
            game_id_array.append(game_id)
            # #update_new_betsetting_for_game
            n=n+1
            print('------------')
            print('------------')
            print('------------')
        print(f"This is number of game updated: {n-1}")
        print(f"This is game_id_array: {game_id_array}")
        return game_id_array
    except Exception as e:
        print(f"An error occurred: {e}")
        return None

    
