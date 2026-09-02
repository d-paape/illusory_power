# Illusory Power for Imaginary Interactions

An interactive Shiny app that demonstrates a subtle but common statistical mistake in experiments with a 2×2 design.

**Live app:** https://dpaape.shinyapps.io/ipower/

## The problem

Say you run an experiment with two factors (e.g. sentence context: constraining vs. unconstraining; word type: expected vs. unexpected) and predict a statistical *interaction* — that one factor's effect depends on the level of the other.

The correct way to test this is to fit a model with an interaction term and check whether *that* term is significant. A common but invalid shortcut is to instead split the data by one factor and test the other factor's effect separately in each half, then claim an interaction if one half is significant and the other isn't.

This shortcut is wrong: "significant" vs. "not significant" is not itself a significant difference (Gelman & Stern, 2006). The app lets you interactively see how often this mistake manufactures a false "interaction" out of pure noise — and how much worse it gets when combined with HARKing (hypothesizing after results are known).

## What it shows

- Sliders for the true effect sizes, sample size, and noise (standard deviation) let you simulate many experiments and see the distribution of:
  - statistical power for each of the two nested effects
  - power for the real interaction
  - the inflated "power" for the spurious, incorrectly-tested interaction (with and without HARKing)
- A 3D plot shows the relationship between real power and this illusory power — it forms a saddle shape, and the false-positive rate is worst exactly when power is high for one nested effect and low for the other.

## Background

Built alongside a poster (Paape & Vasishth, AMLaP 2019) making the same argument. The underlying calculation uses R's `power.t.test`.

## Files

- `ui.R` / `server.R` — Shiny app source
