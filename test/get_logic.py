source_array=['http://service-marketing-2/logic-wealthy-frog-vs5wfrog-cloned.revenge-games.staging','http://service-marketing-2/logic-5-lions-reborn-vsways5lionsr-cloned.revenge-games.staging','http://service-marketing-2/logic-clover-gold-vs20mustanggld2-cloned.revenge-games.staging','http://service-marketing-2/logic-3-buzzing-wilds-vs20wildparty-cloned.revenge-games.staging','http://service-marketing-2/logic-5-lions-gold-clone.revenge-games.staging','http://service-marketing-2/logic-pandas-fortune-vs25pandagold-cloned.revenge-games.staging','http://service-marketing-2/logic-5-lions-megaways-vswayslions-cloned.revenge-games.staging']

goal_array=[]
for item in source_array:
    logic=item.split(".")[0]
    # print(logic)
    logic=logic.split("http://service-marketing-2/")[1]
    print(logic)
    goal_array.append(logic)
# print(f"final result:")
# print(goal_array)

# goal_array=['logic-frkn-bananas-clonedhs','logic-hand-of-anubis-clonedhs','logic-rotten-clonedhs','logic-stormforged-clonedhs','logic-le-viking-clonedhs']
result=""
for item in goal_array:
    result=result+item+","
print(f"final result:")
print(result)