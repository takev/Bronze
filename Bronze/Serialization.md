= Serialization


c0                                              Int value -64
..
ff                                              Int value -1
00                                              Int value 0
..
7f                                              Int value 127

80                                              nil
81 VVVV                                         Int encoded little endian in two bytes
82 VVVV VVVV                                    Int encoded little endian in four bytes
83 VVVV VVVV VVVV VVVV                          Int encoded little endian in eight bytes
84 LL   VV*                                     BigInt encoded little endian in L bytes.
84 LLLL VV*                                     BigInt encoded little endian in L bytes.
85 VVVV VVVV                                    Float32
86 VVVV VVVV VVVV VVVV                          Float64
87 VVVV VVVV                                    Decimal32
88 VVVV VVVV VVVV VVVV                          Decimal64
89                                              true
8a                                              false
8c VVVV VVVV VVVV VVVV                          Timestamp nanoseconds since 2000-01-01 00:00:00.000000000
8d                                              Float 0.0
8e
8f

90                                              Empty array
91 <object>                                     Array with one object
92 <object> <object>                            Array with two objects
93 <object> <object> <object>                   Array with tree objects
94 LL   <object>*                               Array with L objects.
95 LLLL <object>*                               Array with L objects.
96 LLLL LLLL <object>*                          Array with L objects.
97 LLLL LLLL LLLL LLLL <object>*                Array with L objects.
98                                              Empty dictionary
99 <key-value>                                  Dictionary with one key-value
9a <key-value> <key-value>                      Dictionary with two key-value
9b <key-value> <key-value> <key-value>          Dictionary with tree key-value
9c LL   <key-value>*                            Dictionary with L key-value.
9d LLLL <key-value>*                            Dictionary with L key-value.
9e LLLL LLLL <key-value>*                       Dictionary with L key-value.
9f LLLL LLLL LLLL LLLL <key-value>*             Dictionary with L key-value.

a0 <name>                                       object of class <name>
a1 <name> <key-value>                           object of class <name> initialized with one attribute
a2 <name> <key-value> <key-value>               object of class <name> initialized with two attribute
a3 <name> <key-value> <key-value> <key-value>   object of class <name> initialized with three attribute
a4 LL   <name> <key-value>*                     object of class <name> initialized with L attributes.
a5 LLLL <name> <key-value>*                     object of class <name> initialized with L attributes.
a6 LLLL LLLL <name> <key-value>*                object of class <name> initialized with L attributes.
a7 LLLL LLLL LLLL LLLL <name> <key-value>*      object of class <name> initialized with L attributes.

a8                                        
a9 
aa
ab
ac TT LLLL LLLL <hash> <object>                 
ad TT LLLL LLLL LLLL LLLL <hash> <object>       Hashed object
ar TT LLLL LLLL <nonce> <counter> <object>      Encrypted object L in bytes
af TT LLLL LLLL LLLL LLLL <nonce> <counter> <object>

b0                                              0 byte binary data
b1 VV                                           1 byte binary data
b2 VVVV                                         2 byte binary data 
b3 VVVV VV                                      3 byte binary data
b4 LL   VV*                                     L byte binary data
b5 LLLL VV*                                     L byte binary data 
b6 LLLL LLLL VV*                                L byte binary data
b7 LLLL LLLL LLLL LLLL VV*                      L byte binary data
b8                                              0 byte UTF-8 encoded string (without trailing zero)
b9 VV                                           1 byte UTF-8 encoded string (without trailing zero)
ba VVVV                                         2 byte UTF-8 encoded string (without trailing zero) 
bb VVVV VV                                      3 byte UTF-8 encoded string (without trailing zero)
bc LL   VV*                                     L byte UTF-8 encoded string (without trailing zero)
bd LLLL VV*                                     L byte UTF-8 encoded string (without trailing zero) 
be LLLL LLLL VV*                                L byte UTF-8 encoded string (without trailing zero)
bf LLLL LLLL LLLL LLLL VV*                      L byte UTF-8 encoded string (without trailing zero)

