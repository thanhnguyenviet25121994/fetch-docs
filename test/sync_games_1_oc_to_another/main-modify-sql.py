import re
import json
from cuid2 import cuid_wrapper
from env import *
from read_and_update_data_sql_file import find_data_with_pattern,replace_value_in_sql_file

def main():
    print("Running main")

    #load file data.sql
    source_sql = 'data.sql'

    #read file content and find 
    matches=find_data_with_pattern(source_sql,pattern_available_game_id)

    #update the value in the data.sql file
    n=0
    for match in matches:
        # #test
        # if n>3:
        #     break
        # #test
        cuid_generator: Callable[[], str] = cuid_wrapper()
        my_cuid: str = cuid_generator()
        print(f"This is old match:{match}")
        print(f"This is new cuid about to be updated:{my_cuid}")
        replace_value_in_sql_file(source_sql, match, my_cuid)
        n=n+1
        print("+++++++++++++")
        print("+++++++++++++")
        print("+++++++++++++")

if __name__ == "__main__":
    main()