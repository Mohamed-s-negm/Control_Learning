# Control_Learning

A practical control-engineering learning repository focused on building intuition through real system models, simulation, and controller design.

Control engineering is not learned as:

> PID → LQR → MPC → SINDy → DMD → ...

It is learned as:

> Problem → Modeling → Identification → Analysis → Control → Validation

This repository follows that approach. The current implementation focuses on the projects that are already present in the workspace folders.

---

## What this repository contains

The current portfolio covers the first two major learning stages:

- Stage 1 — Classical Control Engineer
- Stage 2 — State-Space Engineer

These projects are designed to help you move from basic system understanding to modern state-space control methods using MATLAB/Simulink and related scripts.

---

## Current implemented project portfolio

### Stage 1 — Classical Control Engineer

This stage builds intuition for dynamics, transfer functions, identification, PID control, and simulation.

1. DC Motor Speed Control
   - Derive the motor model
   - Identify parameters
   - Obtain a transfer function
   - Design and compare P, PI, and PID controllers

2. Mass-Spring-Damper
   - Derive the governing equations
   - Estimate system parameters
   - Identify a second-order model
   - Design a PID controller for performance analysis

3. Thermal Control
   - Model a thermal process
   - Analyze temperature dynamics
   - Design a PI-based temperature controller

### Stage 2 — State-Space Engineer

This stage introduces controllability, observability, pole placement, observers, and LQR design.

1. Active Suspension
   - Develop a quarter-car state-space model
   - Analyze suspension dynamics and control objectives
   - Implement an LQR-based active suspension strategy

2. Cart-Pole
   - Build a state-space model
   - Analyze controllability and stability
   - Design an LQR controller

3. Magnetic Levitation
   - Linearize a nonlinear system
   - Study controllability and observer design
   - Implement LQR regulation and closed-loop analysis

4. Quadrotor Altitude Control
   - Derive vertical dynamics
   - Develop a state-space control formulation
   - Explore altitude regulation concepts

---

## Repository structure

- Stage_1/
  - DC Motor Speed Control/
  - Mass Damper Spring/
  - Thermal Control/
- Stage_2/
  - Active Suspension/
  - Cart_Pole/
  - Magnetic_Levitation/
  - Quadrotor_Altitude/

---

## Assets and notes

I have also added my personal work, notes, and photos in the Assets folder.

The materials are organized by stage for easy reference:

- Assets/Stage_1/ — notes and images related to Stage 1 projects
- Assets/Stage_2/ — notes and images related to Stage 2 projects

This section helps keep the theoretical work, handwritten notes, and visual documentation connected to each project in the repository.

---

## Learning goals

By working through these projects, you will develop skills in:

- modeling physical systems
- identifying parameters and transfer functions
- understanding poles, stability, and transient response
- designing classical and state-feedback controllers
- validating controller behavior through simulation

---

## Recommended workflow

1. Start with the physical model and assumptions.
2. Identify the key dynamics and system order.
3. Analyze the open-loop behavior.
4. Design and tune the controller.
5. Validate the result through simulation.

This is the mindset this repository aims to reinforce: understand the system first, then choose the right control method.

