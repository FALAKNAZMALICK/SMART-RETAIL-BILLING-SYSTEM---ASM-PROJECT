###  SMART RETAIL BILLING SYSTEM

##  Introduction & Problem Statement 

This project implements a fully functional, interactive retail billing system using **8086 Assembly Language** running inside **EMU8086**. Despite operating at the processor register level—where there are no built-in data types, no automatic memory management, and no high-level abstractions—the system successfully handles real-world retail workflows including item selection, quantity entry, billing calculation with discounts and progressive tax, invoice generation, and customer loyalty points. 

---

##  Objectives Achieved 
This project successfully demonstrates the following learning outcomes: 
* **Application of core 8086 processor concepts:** Register usage, memory segmentation, and interrupt-driven I/O.
* **Integration of multiple assembly constructs:** Procedures, macros, loops, conditional jumps, and arrays.
* **Problem Solving:** Translation of a real-world business problem into a low-level computing solution.
* **Modular Program Design:** Creating logic that remains readable and maintainable in pure assembly.
* **Bonus Features Implemented:** Correct execution of category-based discounts, progressive taxation, and loyalty points tracking.

---

##  Key Takeaways 
Working at the assembly level forces a deep understanding of concepts that higher-level languages hide behind abstraction. This project revealed: 
* How a processor actually reads input character-by-character and how ASCII encoding is used for digit conversion.
* Why word-aligned memory access matters and how byte offsets must be manually calculated for array indexing.
* How conditional branching (not if/else) implements all decision logic in real hardware.
* The importance of register discipline—knowing which registers are clobbered by DOS interrupts and protecting others with PUSH/POP.
* That modular design is possible—and essential—even in assembly, through careful use of procedures and macros.

---

##  Possible Extensions 
With more time and complexity, the system could be extended to support: 
* Multi-digit quantity input (currently limited to 0–9 for single character read).
* A return/refund flow that decrements quantities.
* Item inventory tracking with stock limits.
* A persistent session using file I/O via INT 21H extended functions.

---

> This project stands as a complete, working demonstration that real-world business software can be built at the very bottom of the computing stack—one register, one jump, one interrupt at a time.

---

## 📄 Full Project Document
For the complete, unedited project overview, view or download the raw document here:
[Download CAO PROJECT REPORT.pdf](CAO PROJECT REPORT.pdf)

