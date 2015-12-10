ctmlejl: an interface to julia package TargetedLearning.jl


--------------------------

This package built a interfact to julia package TargetedLearning (https://lendle.github.io/TargetedLearning.jl/) based on rjulia project (https://github.com/armgong/RJulia).

For details of Targeted Learning, see the book Van der Laan, Mark J., and Sherri Rose. Targeted learning: causal inference for observational and experimental data. Springer Science & Business Media, 2011., or https://lendle.github.io/TargetedLearning.jl/


--------------------------
### Installation julia

Before using this package, ensure you have julia (v0.4.x.) installed. If not, you can download latest version of julia in http://julialang.org/downloads/

For mac users, use symbolic link so you can simply call julia in terminal (else rjulia package can not be installed):

```
ln -s /Applications/Julia-0.4.1.app/Contents/Resources/julia/bin/julia /usr/local/bin/julia

```

Finally, simply open julia by type `julia` in terminal. In julia, you need install several packages:

```
Pkg.add("GLM")
Pkg.clone("https://github.com/lendle/TargetedLearning.jl.git")
```


### Installation

Install devtools package:

```
install.packages("devtools")
```

Install rjulia package from github:
```
devtools::install_github("armgong/rjulia", ref="master")
```


Install ctmlejl package from github:
```
devtools::install_github("jucheng1992/ctmlejl")
```