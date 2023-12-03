total = 0
total_ribbon = 0
with open("day2.txt", "r") as f:
    lines = f.readlines()
    for dim in lines:
        parts = dim.split("x")
        l, w, h = int(parts[0]), int(parts[1]), int(parts[2])
        s1 = l * w
        s2 = w * h
        s3 = l * h
        small = min(s1, s2, s3)
        total += (s1 + s2 + s3) * 2 + small

        ribbon = l * w * h
        if small == s1:
            # l w
            ribbon += (l + w) * 2
        elif small == s2:
            ribbon += (w + h) * 2
        else:
            ribbon += (l + h) * 2
        total_ribbon += ribbon
            
print(total)
print(total_ribbon)
