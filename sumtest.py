l4lc = 20265.6
l4ls = 30937.996
l4ln = 40104.4
# l4lt = round((l4lc, l4ls, l4ln.sum()), -3),
l4lt = f"${int(round((l4lc + l4ls + l4ln), -3)):,d}"

print(type(l4ls))
print(l4lt)