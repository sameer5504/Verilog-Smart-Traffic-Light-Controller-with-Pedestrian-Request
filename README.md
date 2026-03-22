# 🚦 Smart Traffic Light Controller with Pedestrian Request (SystemVerilog)

This project implements a **smart traffic light controller** using a **Moore Finite State Machine (FSM)** in SystemVerilog. The system manages traffic flow between a main road, side road, and pedestrian crossing while ensuring safe transitions and efficient timing behavior.

---

## 📌 Project Overview

The controller dynamically adjusts traffic signals based on:
- Vehicle sensor inputs (VS)
- Pedestrian button requests (PB)

It ensures:
- Minimum guaranteed green time for the main road
- Safe transitions using yellow and all-red states
- Proper handling and queuing of pedestrian requests

---

## 🧠 FSM Design

The system is implemented as a **3-bit encoded Moore FSM** with 8 states:

| State | Code | Description |
|------|------|------------|
| S_MG_MIN | 000 | Main road green (minimum time) |
| S_MG_EXT | 001 | Extended main green (no requests) |
| S_MY | 010 | Main road yellow |
| S_AR1 | 011 | All-red (before side road) |
| S_SG | 100 | Side road green |
| S_SY | 101 | Side road yellow |
| S_AR2 | 110 | All-red (before pedestrian/main) |
| S_PG | 111 | Pedestrian walk |

Outputs follow Moore behavior (depend only on current state) :contentReference[oaicite:1]{index=1}

---

## 🚥 Output Encoding

Traffic lights are encoded as:
- RED = `3'b100`
- YELLOW = `3'b010`
- GREEN = `3'b001`

---

## ⏱️ Timing Control

The system uses a **countdown timer** to control state durations:

| Parameter | Value |
|----------|------|
| Main Green | 60 sec (minimum, extendable) |
| Side Green | 40 sec |
| Pedestrian Walk | 40 sec |
| Yellow | 5 sec |
| All-Red | 1 sec |

- Main road can **extend green time** if no requests exist  
- Pedestrian and vehicle requests are **latched and queued**  
- Safe transitions are enforced between conflicting flows :contentReference[oaicite:2]{index=2}

---

## 🧪 Verification & Testing

A **self-checking testbench** was developed:

- Compares DUT vs reference model cycle-by-cycle
- Signals verified:
  - `light_main`
  - `light_side`
  - `walk`
- Outputs sampled every clock cycle

### ✅ Results:
- Multiple scenarios tested (vehicle + pedestrian)
- Full traffic cycles validated
- **Zero mismatches detected**

---

## 📊 Waveform Analysis

Simulation confirms:
- Correct FSM state transitions
- Accurate timing behavior
- Proper request handling
- No glitches in outputs

The controller:
- Initializes in **Main Green**
- Extends green when no requests exist
- Handles queued pedestrian requests correctly
- Returns safely to default flow after each cycle :contentReference[oaicite:3]{index=3}

---

## 📁 Project Structure
├── design.sv # FSM-based traffic controller
├── testbench.sv # Self-checking testbench
├── FSM_state_diagram.pdf # State diagram
├── Advanced_project_report.pdf# Full technical report


---

## 🛠️ Tools Used

- SystemVerilog (RTL Design)
- VScode
- Git & GitHub (Version Control)

---

## 🎯 Key Learning Outcomes

- FSM design using Moore model
- State encoding and timing control
- Digital system verification using testbenches
- Handling asynchronous requests in hardware systems
- Writing clean, structured RTL code

---

## 👤 Author

**Sameer**  
Birzeit University – Computer Engineering  

---


