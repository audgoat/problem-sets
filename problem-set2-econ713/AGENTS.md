# AGENTS.md

## Project goal
Implement the Huggett household problem in MATLAB for a fixed interest rate before adding equilibrium or stationary distribution code.

## Working preferences
- Prioritize clarity and correctness over speed.
- Use modular MATLAB files.
- Add comments explaining both economics and code logic.
- Keep notation close to macro lecture notes: a, a', y, V, g, c, beta, sigma, phi, Pi.
- Use value function iteration with piecewise linear interpolation for off-grid a' choices.
- Avoid unnecessary refactors or fancy MATLAB tricks.

## Output expectations
- Clean readable code
- Clear convergence diagnostics
- Nice policy plots
- Easy to extend later to stationary distribution and outer loop on r