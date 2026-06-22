# Stage 3 Project Summary: System Identification and Data-Driven Modeling

## Overview

This document summarizes the main activities carried out in Stage 3 of the project, covering several system identification and modeling approaches such as **SINDy**, **ERA**, **OKID**, **Koopman-based methods**, and data-driven analysis for mechanical and dynamical systems. The goal of this stage is to identify governing dynamics from measured data and evaluate how well different methods can reconstruct behavior.

## Scope of the Stage 3 Projects

The Stage 3 folder includes several different directions of investigation, including:
- **SINDy-based modeling** for nonlinear dynamics and reduced-order system discovery
- **ERA/OKID-based identification** for linear system estimation
- **Koopman and EDMD-related methods** for lifted-state modeling
- **Data analysis and preprocessing studies** for vibration and control datasets
- **Benchmark and synthetic examples** used to compare model quality under controlled settings

## General Observation

Across these projects, the obtained model fits are often not uniformly high. In many cases, the results are limited by the nature of the available data rather than by the modeling method itself.

### Common Data-Related Challenges

Several projects show reduced evaluation quality because of issues such as:
- **Noisy or incomplete measurements**
- **Insufficiently informative input-output signals**
- **Unclear data labeling or inconsistent sampling**
- **Lack of proper excitation signals** for identification methods that require specific input conditions
- **Mismatch between assumed model assumptions and the actual dataset characteristics**
- **Need for stronger preprocessing** (filtering, smoothing, normalization, derivative estimation, and scaling)

## Interpretation of Results

This means that some projects may appear to perform poorly even when the identification method itself is reasonable. In practice, the quality of the learned model depends strongly on whether the dataset contains enough information to recover the underlying dynamics.

For example:
- **Synthetic or well-conditioned datasets** typically give better reconstruction quality.
- **Realistic or noisy datasets** often yield lower evaluation scores, even if the learned system structure is meaningful.
- **Methods that rely on derivatives or impulse-like behavior** are especially sensitive to data quality and preprocessing choices.

## Conclusion

Overall, Stage 3 demonstrates that system identification is highly dependent on both the chosen algorithm and the quality of the dataset. Some projects do not show high evaluation scores due to data limitations, preprocessing difficulties, or mismatch between the method and the available measurements. Therefore, the results should be interpreted not only in terms of numerical fit, but also in terms of the suitability of the data for the chosen identification framework.
