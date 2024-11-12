import numpy as np
p={
    'A':0.5,
    'C':0.1,
    'D':0.1,
    'E':0.4,
    'F':0.1,
    'G':3,
    'H':0.1,
    'I':0.0,
    'K':0.4,
    'L':0.05,
    'M':0.1,
    'N':0.1,
    'P':0.1,
    'Q':0.1,
    'R':0.1,
    'S':1,
    'T':0.4,
    'V':0.1,
    'W':0.1,
    'Y':0.1
}
for k in range(50):
    print(''.join(np.random.choice(list(p.keys()),32,p=[i/sum(p.values()) for i in list(p.values())])))