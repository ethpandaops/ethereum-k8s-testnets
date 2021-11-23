## Nodeport ranges

The default open range is from 30000-32767

Start | Client deployment
----- | -----
30100 | geth-bootnode
30120 | geth-signer
30130 | geth-archive
30140 | geth
30300 | nethermind
30400 | besu
31080 | lighthouse-bootnode
31100 | lighthouse-beacon
31200 | lodestar-beacon
31300 | nimbus
31400 | teku-beacon
31500 | prysm-beacon



## Validator ranges

Total validators in genesis: `100000`

### Key allocation per clients

From  | To     | Client
----- | ----   |------
    0 |  24000 | Lighthouse         x  6
24000 |  48000 | Lodestar           x  6
48000 |  72000 | Prysm              x  6
72000 |  96000 | Nimbus             x  6
96000 | 100000 | Teku               x  1
