#!/usr/bin/env python

import numpy as np
import zfit


obs = zfit.Space('x', -10, 10)

# create the model
mu    = zfit.Parameter("mu"   , 2.4, -1, 5)
sigma = zfit.Parameter("sigma", 1.3,  0, 5)
gauss = zfit.pdf.Gauss(obs=obs, mu=mu, sigma=sigma)

# load the data
data_np = np.random.normal(size=10_000)
data = zfit.Data(obs=obs, data=data_np)
# or sample from model
data = gauss.sample(10_000)

# build the loss
nll = zfit.loss.UnbinnedNLL(model=gauss, data=data)

# minimize (20+ interchangeable minimizers available!)
minimizer = zfit.minimize.Minuit()
result = minimizer.minimize(nll).update_params()

# calculate errors
sym_errors = result.hesse()
asym_errors = result.errors()

print("\nSymmetric errors:\n", sym_errors)
print("\nAsymmetric errors:\n", asym_errors)
