## forward sbox
### Implement the Forward S-Box, a lookup table used in the Rijneal Cypher, which the Advanced Encryption Standard (AES) cryptographic algorithm was based on. This will be done in Verilog, a hardware description language.

The job of this forward s box is to act like a hash table (lookup table). We give it a single byte which is 8 bits and we expect to get an output that is also a single byte. 