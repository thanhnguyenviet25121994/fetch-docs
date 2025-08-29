import re

def find_data_with_pattern(source_sql,pattern):
    func_name='find_data_with_pattern'
    try: 
        # Read the file content into a variable
        with open(source_sql, 'r') as file:
            sql_content = file.read()

        # Find all matches
        matches = re.findall(pattern, sql_content)

        final_matches=[]
        if matches:
            for match in matches:
                print("this is match:")
                match=match.replace("VALUES('","")
                match=match.replace("'","")
                print(match)
                final_matches.append(match)
                print("---------")
                print("---------")
                print("---------")
        return final_matches
    except Exception as e:
        print(f"There is an error white executing: {func_name}: {e}")
        return None
        


def replace_value_in_sql_file(file_path, target_value, new_value):
    func_name='replace_value_in_sql_file'
    try: 
        # Read the file content
        with open(file_path, 'r') as file:
            content = file.read()

        # Replace occurrences
        updated_content = content.replace(target_value, new_value)

        # Write back the updated content
        with open(file_path, 'w') as file:
            file.write(updated_content)
        print(f"Update successsfully new value {new_value}, old value is {target_value}")
    except Exception as e:
        print(f"There is an error white executing: {func_name}: {e}")