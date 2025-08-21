The purpose of these animations is to  simulatneously visualize individual  spins and bulk magnetization vectors in NMR phenomena. The visualizations are based on the 'uniform model' of spin distributions rather than the much more common 'alignment model', as explained in these papers:

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

Here are some [movies](https://drive.google.com/drive/folders/1Ni6xqJajgEw1TNGQrfSQUiMYROcS5pJj) made by the code.

Updated Aug 21, 2025
