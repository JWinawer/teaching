These animations were motivated by the desire to simulatneously visualize individual NMR spins and bulk magnetization vectors in basic NMR phenomena. They were motivated by a couple of papers suggesting that the usual "two-state" depictions (spin up / spin down) are misleading. The two articles are:

- Williamson MP. Drawing Single NMR Spins and Understanding Relaxation. Natural Product Communications. 2019;14(5). https://doi.org/10.1177/1934578X19849790
- Hanson, L.G. (2008), Is quantum mechanics necessary for understanding magnetic resonance?. Concepts Magn. Reson., 32A: 329-340. https://doi.org/10.1002/cmr.a.20123

To view a simple demo:

```matlab
fH = figure();
[params, units] = spinsDefaultParams();
animateSpins(params, fH);
```

For additional examples, see

```matlab
s_SpinsToBulkM.m
```
