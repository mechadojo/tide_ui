# Tide Chart Editor
## A Flutter/Dart web application for developing with Tide Charts

Tide Chart Editor is available online at https://tidecharts.app 

*Tide Chart Editor is built for Chrome and works best in App mode.  If you want to use the keyboard shortcuts related to tabs (Ctrl+N, Ctrl+W, Ctrl+Tab, ...) Chrome requires App mode. To start in App mode use the following menu "More tools...Create Shortcut...select Open as window".  After this setup the App can be accessed from the Apps icon on the shortcut bar or at [chrome://apps](chrome://apps)*

A Tide Chart is a JSON based data flow graph. These files are used by a suite of related applications to assist teams in using data flow graphs effectively in their FIRST Tech Challenge robots.

There are two ways a team can run the data flow graph contained in a Tide Chart:
* High Tide - Virtual Machine
* Low Tide - Code Only

## High Tide - Virtual Machine

High Tide runs the Tide Chart in a virtual machine (VM) that emulates event message passing between nodes of the data flow graphs. Running graphs in a virtual machine environment allows robust runtime analysis and control. 

* Hot reload - graph definition can be changed while the VM is running
* Event tracing - track events moving thru the graphs of the VM 
* Pause execution - stop portions or all of the VM to inspect properties
* Time travel - reset the state of the VM to any previous point in time
* Profiling - record state of the VM for analysis and playback

### Luna VM

Luna VM is a reference implementation of the High Tide VM written in dart

### Tide Chart Editor

The Luna VM is included with the Tide Chart Editor to visualize running data flow graphs directly in the editor.  Remote debugging works by mirroring state changes between the embedded and remote VMs. 

Sometimes its useful to execute data flow graphs directly on the embedded Luna VM without needed a connection to a physical robot
* Visualizing the flow of events thru the graph
* Playback of graph execution from a recording (possibly on a live robot)
* Gamepad, Timer and OpMode (Init/Start/Stop) events can all be tested directly in the editor.

The Tide Chart Editor can leverage external simulators for testing graphs that involve robot sensors, actuators and custom Java code without access to a physical robot.

### Lighthouse

Lighthouse is a Flutter/Dart android application that integrates the Luna VM and the core components of the FTC Robot Controller SDK.

**Lighthouse is intended only for development and is not legal for use in competition.**

During development Lighthouse runs on the robot in place of the standard SDK Robot Controller app. By running a Luna VM directly on the robot, Tide Charts have direct access to physical robot sensors, motors and servos like they would in competition mode.

Teams can provide custom Java code libraries to Lighthouse to implement graph nodes directly in Java code (Java Nodes).

## Low Tide - Code Only

Low Tide runs Tide Chart data flow graphs with code that executes equivalent to how the graph runs in a VM.

### Kraken

Kraken is a Low Tide code generator written in Dart that produces Java code from Tide Chart data flow graphs. Code produced by Kraken is easy to read and runs efficiently.

Lighthouse uses Kraken and *FTC OnBot Java* to produce generate competition ready versions of the data flow graph that run on the official FTC Robot Controller.

Tide Chart Editor can use Kraken to output Java code that teams can include with their customized Robot Controller using *Android Studio.*
