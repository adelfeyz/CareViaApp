# v3

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.



The sampole device info:
Here are the key hardware identifiers extracted from the box:

Ring Serial Number (SN): 321241000724

Charger Serial Number (SN): 120941030686

MAC Address: E5:F4:E5:36:C3:C9

Model Info:

Color: Silver

Size: US 12 Set

Contents: Ring, Charging Dock, USB Cable, Quick Guide

This info is useful for:

Verifying ring-device pairing.

Registering the device through the app.

Troubleshooting connection issues with MAC filtering or whitelist configurations.

Let me know if you'd like help writing the pairing logic using this MAC or serial number.

## Local-data pipeline (current state)

The app now captures every BLE frame, stores it safely, and remembers how far
post-processing has progressed.  This groundwork was laid in steps 0-3 and is
summarised below:

```
 BLE Callback → RawDataRepository.append() ──► raw/YYYY-MM-DD.hive
                                            │
                                            │  (Stream<RawFrame>)
                                            ▼
                                    (HistoryProcessor – step 4)
                                            ▼
                                processed/…  +  SyncStateRepository
```

Component cheat-sheet

| Piece                         | Purpose                                                            |
|-------------------------------|--------------------------------------------------------------------|
| **RawFrame** (Hive types 1/2) | Loss-less snapshot of a packet (`uuid`, `kind`, `payload`, `ts`).  |
| **RawDataRepository**         | • One lazy Hive box per day.<br>• Fire-and-forget `append()`.<br>•  Stream so the background isolate can react without polling. |
| **SyncStateRepository**       | Stores the highest `uuid` that has been fully processed (`maxUuid`). |
| **main.dart** initialisation | `await RawDataRepository.instance.init();`<br>`await SyncStateRepository.instance.init();` |

With these in place we can build Step 4 — the **HistoryProcessorIsolate** — that
reads frames `> maxUuid`, runs algorithm workers, writes derived metrics, then
updates `maxUuid` when done.

### Detailed architecture

#### Storage layout
```
<app-docs>/
 ├─ raw/                  # step-0/1  – immutable raw frames
 │   ├─ raw_2025-05-21.hive
 │   ├─ raw_2025-05-22.hive
 │   └─ …
 ├─ processed_boxes/      # step-4+   – durable metrics for UI / sync
 │   ├─ sleep.hive
 │   ├─ vitals.hive
 │   └─ activity.hive
 ├─ sync_state.hive       # step-3    – cursor & housekeeping flags
 └─ <hive lock files>
```

* 1 raw box ≈ one calendar day of packets → fast purge by deleting whole file.
* Processed boxes are logical: one per domain (sleep, cardio, activity, …).
* `sync_state.hive` keeps **only primitive keys** so we can open it instantly on the main isolate.

#### Object responsibilities
| Class / file | Layer | Key methods | Notes |
|--------------|-------|-------------|-------|
| `RawFrame` | model | — | HiveType(1/2); raw bytes are never mutated. |
| `RawDataRepository` | data-source | `append()`, `framesSince()`, `stream` | Uses `Hive.openLazyBox` so payload bytes are loaded on demand. |
| `SyncStateRepository` | metadata | `getLastUuid()`, `setLastUuid()` | Synchronous getter; box opened at app-start. |
| `HistoryProcessorIsolate` *(step 4)* | service | `run(fromUuid)` | Runs in background isolate; feeds algorithm workers, then updates sync-state. |
| `SleepProcessor` etc. *(step 5+)* | domain-logic | `accept(RawFrame)` | Buffer, aggregate, save to processed boxes. |

#### Data life-cycle
1. **Reception** – BLE callback turns packet → `RawFrame` → `RawDataRepository.append()` (O(1) write).
2. **Trigger** – `append()` also pushes the frame on `stream`. A debounce will enqueue a Workmanager job (coming in step 4b) so we never block BLE.
3. **Processing** – The job starts `HistoryProcessorIsolate` with `fromUuid = SyncState.maxUuid`. It consumes `framesSince(cursor)` and invokes each domain processor.
4. **Commit** – After all processors flush successfully, the isolate replies with `newMaxUuid`; the main isolate then calls `SyncState.setLastUuid(newMax)`.
5. **Retention (T+30 days)** – A simple daily check deletes raw boxes whose filename date is older than the configured TTL **and** whose max uuid < `syncState.maxUuid`.

#### Why save-first, process-later?
* BLE callbacks stay micro-fast → no dropped packets.  
* Future algorithm upgrades can replay historic data for new insights.  
* Fail-safe: if the processor crashes, we still have the bytes on disk and the cursor remains unchanged, so the next attempt resumes automatically.

#### Roadmap
| Step | Deliverable |
|------|-------------|
| 4a   | ✔️  Isolate scaffold that finds new maxUuid and reports back. |
| 4b   | Wire raw-stream debounce → Workmanager; success path updates maxUuid. |
| 5    | Implement first real processor: Sleep algorithm (uses smartring_plugin). |
| 6    | Cardio processor (RHR, HRV, Immersion). |
| 7    | Temperature fluctuation & stress baseline processors. |
| 8    | Retention / purge job + settings for TTL. |

That should provide enough context for new contributors and future maintenance.
