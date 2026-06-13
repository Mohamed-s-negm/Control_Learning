# Eigenrealization Algorithm (ERA) and Observer Kalman Filter Identification (OKID) - System Identification Study

## Overview

This section documents a comprehensive experimental study on system identification using data-driven methods applied to mechanical systems. The primary techniques employed are the **Eigenrealization Algorithm (ERA)** and **Observer Kalman Filter Identification (OKID)**, two complementary approaches commonly utilized for linear system identification from input-output data.

## Experimental Methodology

### Data Sources

Experimental data were obtained from multiple mechanical systems to evaluate the effectiveness of ERA and OKID methods. The majority of test cases utilized benchmark datasets sourced from the **DAISY (Database for the Identification of Systems)** repository, available at: https://homes.esat.kuleuven.be/~smc/daisy/daisydata.html

These datasets comprise real-world experimental measurements from various mechanical and structural systems, providing a robust foundation for testing system identification algorithms under realistic conditions.

### Implementation

Two primary implementation files support the identification analysis:
- **OKID.m** - Observer Kalman Filter Identification implementation
- **ERA.m** - Eigenrealization Algorithm implementation

These functions serve as the core computational tools for processing experimental data and generating identified system models.

## Results and Findings

### Performance Analysis

The identification results demonstrated considerable variation across different mechanical systems. In most cases involving real experimental data, the achieved model fits were suboptimal due to fundamental limitations inherent to both the data characteristics and the identification methods:

**Key Limitations:**
- **Data Incompatibility**: Real experimental datasets from mechanical systems typically do not constitute impulse response data, which is the ideal input format for OKID and ERA methods
- **Method Constraints**: Both OKID and ERA are fundamentally designed for impulse response identification; non-ideal data characteristics limit their applicability and accuracy
- **Physical Uncertainties**: Real-world measurements contain noise, unmodeled dynamics, and parameter variations that degrade identification fidelity

### Benchmark Results

Among all tested cases using real experimental data, the most satisfactory results were obtained for:
- **Dryer System (dryer_ERAOKID.m)**: Model fit of approximately 57%
- **Flutter Structure (flutter_ERAOKID.m)**: Model fit of approximately 73%

### Validation with Synthetic Systems

To validate the effectiveness of the ERA methodology under controlled conditions, two additional systems were analyzed:
- **Random System (Random_ERA_sys.m)**: A synthetically generated system with known characteristics
- **Custom System**: A user-defined system with well-defined properties

For these systems, ERA demonstrated significantly improved performance compared to real experimental data. This improvement is attributed to the availability of exact impulse response data, which eliminates the data incompatibility issues encountered with real-world measurements. These cases effectively demonstrate the capabilities of ERA when applied to systems with ideal input data characteristics.

## Conclusion

The experimental investigation reveals that while OKID and ERA are powerful tools for system identification under ideal conditions, their application to real experimental data from mechanical systems is constrained by fundamental data and methodological limitations. The results underscore the importance of careful data preprocessing, appropriate method selection based on data characteristics, and the consideration of hybrid identification approaches when dealing with non-ideal real-world measurements.
