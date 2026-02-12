# PythonBridge (Pharo 13 compatible fork)

Fork of [ObjectProfile/PythonBridge](https://github.com/ObjectProfile/PythonBridge) adapted for **Pharo 13** compatibility.

## Changes from upstream

- **MessagePack dependency** points to [francocz/msgpack-smalltalk](https://github.com/francocz/msgpack-smalltalk), which fixes two Pharo 13 incompatibilities:
  - `TimeStamp` class removed (replaced by `DateAndTime`)
  - `convertFromEncoding:` method removed from `ByteString`
- **PBManager** facade class added, providing a simplified API for starting, stopping and using the bridge, with both synchronous and asynchronous execution.

## Installation
```smalltalk
Metacello new
    baseline: 'PythonBridge';
    repository: 'github://francocz/PythonBridge/src';
    load.
```

## Quick start
```smalltalk
PBManager start.
PBManager execute: '2 + 3'.           "=> 5 (blocking)"
PBManager executeAsync: '2 + 3'.      "=> result in Transcript (non-blocking)"
PBManager run: 'import math'.         "=> statement, no return value"
PBManager execute: 'math.sqrt(144)'.  "=> 12.0"
PBManager stop.
```

## PBManager API

| Method | Description |
|---|---|
| `PBManager start` | Start the bridge |
| `PBManager stop` | Stop the bridge |
| `PBManager isRunning` | Check if bridge is active |
| `PBManager execute: expr` | Evaluate Python expression, return result (blocking) |
| `PBManager run: stmt` | Execute Python statement (blocking) |
| `PBManager executeAsync: expr` | Non-blocking execution, result in Transcript |
| `PBManager executeAsync: expr then: aBlock` | Non-blocking execution with callback |
| `PBManager do: aBlock` | Advanced: direct access to PBCF |
| `PBManager status` | Status dictionary (for programmatic use) |
| `PBManager statusReport` | Status string (human-readable) |
| `PBManager checkPythonDependencies` | Verify Python and libraries |
| `PBManager python3Path` / `python3Path:` | Get/set Python path |

## Requirements

- Pharo 13
- Python 3.6+
- pip packages: flask, requests, msgpack

## Original project

See [ObjectProfile/PythonBridge](https://github.com/ObjectProfile/PythonBridge) for the original documentation.
