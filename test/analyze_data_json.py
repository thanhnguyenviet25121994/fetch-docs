import json

source_mkt='mkt-data.json'
source_prod='prod-data.json'


# Load the JSON file mkt
with open(source_mkt, 'r') as file:
    data_mkt = json.load(file)

# Loop through and print name + value
env_mkt=[]
for item in data_mkt:
    #print(f"{item['name']}:{item['value']}")
    env_mkt.append(item['name'])
    #print("-------------")
    #print("-------------")



# Load the JSON file prod
with open(source_prod, 'r') as file:
    data_prod = json.load(file)

# Loop through and print name + value
env_prod=[]
for item in data_prod:
    #print(f"{item['name']}{item['value']}")
    env_prod.append(item['name'])
    #print("++++++++++")
    #print("++++++++++")





# check different item
#mkt-asia
result_array=env_mkt

#prod-asia
sb_current = env_prod

# --- Compare arrays ---
not_exist_sb_current_array = [item for item in result_array if item not in sb_current]
not_exist_result_array = [item for item in sb_current if item not in result_array]

# --- Output the result ---
# #print("result_array:", result_array)
#print("env not in prod:", not_exist_sb_current_array)
#print("env not in mkt:", not_exist_result_array)





#######
#print(f"env mkt: {env_mkt}")
#print(f"env prod: {env_prod}")

# Print total number of items mkt
#print(f"Total items mkt: {len(data_mkt)}")
# Print total number of items prod
#print(f"Total items prod: {len(data_prod)}")

#print("^^^^^^^^^^^^^^^^^^")
#print("^^^^^^^^^^^^^^^^^^")
#print("^^^^^^^^^^^^^^^^^^")
#print("env not in prod:", not_exist_sb_current_array)
#print("env not in mkt:", not_exist_result_array)

#print("")
#print("")
#print("")
#print("$$$$$$$$$$$$$$$$$$")
#print("$$$$$$$$$$$$$$$$$$")
#print("$$$$$$$$$$$$$$$$$$")
####Check value on env prod
for item in data_prod:
    if item['name'] in not_exist_result_array:
        # print(f"item not exist in mkt")
        print(f"{item['name']} - {item['value']}")
        # print("++++++++++")
        # print("++++++++++")