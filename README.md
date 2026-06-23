# COBOL Banking Masterclass

**A production-style banking transaction processor, written in COBOL, that you can actually compile and run.**

I started my career in COBOL in the 1990s. Today I build AI agents. This repository is the bridge between those two things: a working banking batch system that shows what real COBOL looks like in the kind of financial systems that have been running, untouched, since before most software engineers were born.

It is not a "hello world." It is an account master file, a transaction processor with validation and rejection handling, an interest calculator with real day-count conventions, a hash-chained audit trail, a financial report generator with control breaks, and a batch controller that ties the cycle together. Clone it, run `make run-batch`, and watch a night at the bank happen on your laptop.

## Why this still matters

A few figures that get repeated in this corner of the industry, because they hold up:

- Roughly **95% of ATM swipes** touch COBOL on the back end.
- An estimated **$3 trillion in commerce** moves through COBOL systems every day.
- The IRS, the Social Security Administration, and most large banks still run core ledgers on it.
- During COVID, several states could not scale their unemployment systems because they could not find enough COBOL programmers.

The systems are not going anywhere. The people who understand them are retiring. That gap is the whole point of putting this online.

## Quick start

You need [GnuCOBOL](https://gnucobol.sourceforge.io/) (the `cobc` compiler), which is free and open source.

```bash
# Install GnuCOBOL
#   Ubuntu/Debian:  sudo apt install gnucobol
#   macOS:          brew install gnucobol
#   Windows:        choco install gnucobol   (or use WSL)

make all          # compile every program
make run-batch    # run the full nightly batch cycle end to end
```

Prefer Docker? `docker build -t cobol-masterclass . && docker run -it cobol-masterclass`.

After `make run-batch`, the generated reports land in `bin/`: `ACCTLIST.RPT`, `INTEREST.RPT`, `FINREPORT.RPT`, and `AUDITRPT.RPT`.

## What's inside

| Program | What it demonstrates | What you see when you run it |
|---------|----------------------|------------------------------|
| `ACCTMSTR.cbl` | CRUD on an indexed (ISAM) file: create, read, update, business rules | Loads 6 sample accounts, runs read/update operations, blocks a frozen account |
| `TXNPROC.cbl` | Batch transaction processing: validate, apply, reject, balance | Reads 10 transactions, posts 7, rejects 3 (frozen, dormant, unknown account) |
| `INTCALC.cbl` | Compound interest and day-count conventions (ACT/360, ACT/365, 30/360) | Shows how the same period yields different interest under each convention |
| `RPTGEN.cbl` | Formatted reporting with multi-level control breaks and subtotals | Writes a consolidated position report grouped by bank, branch, and type |
| `AUDITLOG.cbl` | Immutable audit trail with a hash chain, plus `INSPECT` text processing | Verifies the chain written by `TXNPROC` is intact, masks a sample SSN |
| `VALENGN.cbl` | A callable subprogram: Luhn check digits, date and amount validation | Invoked through `VALDEMO` (see below) |
| `VALDEMO.cbl` | How a program `CALL`s a subprogram and reads back results | Runs `VALENGN` against valid and invalid cards, dates, and accounts |
| `BATCHCTL.cbl` | JCL-style step orchestration with return-code handling | Simulates the nightly job stream and rolls up a batch return code |

Run any piece on its own:

```bash
make run-accounts   # ACCTMSTR
make run-txn        # TXNPROC
make run-interest   # INTCALC
make run-reports    # RPTGEN
make run-audit      # AUDITLOG
make run-validate   # VALDEMO -> VALENGN
```

`make run-batch` runs `ACCTMSTR`, then `TXNPROC`, then `INTCALC`, `RPTGEN`, and `AUDITLOG` in sequence, the same order a real batch window would.

## Copybooks (shared data structures)

Copybooks are COBOL's version of shared types: one record layout, copied into every program that touches it.

| Copybook | Defines |
|----------|---------|
| `ACCTREC.cpy` | Account master record (identity, balances, dates, activity counters, flags) |
| `TXNREC.cpy` | Transaction record (type, channel, amounts, originator, status) |
| `AUDITREC.cpy` | Audit trail record (who, what, before/after image, hash chain) |
| `ERRCODES.cpy` | System-wide error codes |
| `DATEUTIL.cpy` | Date handling fields and utilities |

## Architecture

```
┌─────────────┐     ┌──────────────┐     ┌───────────┐
│  BATCHCTL   │────>│   TXNPROC    │────>│  AUDITLOG │
│  (Control)  │     │  (Process)   │     │  (Trail)  │
└──────┬──────┘     └──────┬───────┘     └───────────┘
       │                   │
       v                   v
┌─────────────┐     ┌──────────────┐     ┌───────────┐
│   VALENGN   │     │   ACCTMSTR   │     │  INTCALC  │
│  (Validate) │     │  (Accounts)  │     │ (Interest)│
└─────────────┘     └──────────────┘     └───────────┘
                           │
                           v
                    ┌──────────────┐
                    │    RPTGEN    │
                    │   (Reports)  │
                    └──────────────┘
```

A controller drives validation, processing, account updates, interest, audit logging, and reporting, all inside a single nightly window. That is the shape of a real mainframe batch.

## COBOL concepts demonstrated

Everything in this list is exercised by code that runs, not just mentioned in a comment:

- **Fixed-format source** (columns 1 to 6 sequence, 7 indicator, 8 to 11 Area A, 12 to 72 Area B)
- **Indexed (ISAM) file handling** with `RECORD KEY` and `INVALID KEY`
- **Binary vs line-sequential files**, and why packed-decimal records need binary organization
- **WORKING-STORAGE and LINKAGE SECTION** for storage and parameter passing
- **COPY** for shared record layouts across programs
- **88-level condition names** so business logic reads like English
- **REDEFINES** for overlaying multiple views on the same bytes
- **OCCURS DEPENDING ON** for variable-length tables (`INTCALC`)
- **Packed decimal (COMP-3)** for exact financial arithmetic, no floating point
- **PERFORM VARYING** loops and **PERFORM THRU** paragraph ranges
- **EVALUATE** and **EVALUATE TRUE ALSO TRUE** for multi-condition business rules
- **Control-break reporting** with subtotals and grand totals (`RPTGEN`)
- **STRING** and **reference modification** for substring work
- **INSPECT / TALLYING / REPLACING / CONVERTING** for character processing (`AUDITLOG`)
- **DECLARATIVES** for file-error handling (`AUDITLOG`)
- **CALL ... USING** between a driver and a callable subprogram (`VALDEMO` to `VALENGN`)
- **FILE STATUS** codes for robust I/O error handling
- **The Luhn algorithm**, the same checksum on every card you own (`VALENGN`)

## From COBOL to AI agents

What COBOL drilled into me has not gone out of date: know exactly how big your data is, make every state explicit, validate at the boundary, and leave an audit trail you can defend. The languages change. That discipline is the same thing I bring to building AI systems now.

This repo is here as a reference, a teaching tool, and a small piece of where I came from. Use it, run it, teach with it.

## License

MIT. Use it, learn from it, teach with it.
