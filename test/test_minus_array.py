brand_ids=['zu59dqx9zinvqlsxgevkfkpk','krksluwds5vszc0qkz0o52au','y34vrge7t4phikdl9qeuh10y']
whitelist_ids=['zu59dqx9zinvqlsxgevkfkpk'] 

result = [id for id in brand_ids if id not in whitelist_ids]

# brand_ids=brand_ids-whitelist_ids
print(f"This is result {result}")