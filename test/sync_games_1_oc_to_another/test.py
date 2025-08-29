import re
import json
from cuid2 import cuid_wrapper

cuid_generator: Callable[[], str] = cuid_wrapper()
my_cuid: str = cuid_generator()

print(f"this is my")


source_sql = 'data.sql'

# Read the file content into a variable
with open(source_sql, 'r') as file:
    sql_content = file.read()

# Define the regex pattern
pattern = r"VALUES\('[^']+'"

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

# Print or use the matches
# print(json.dumps(matches, indent=2))
