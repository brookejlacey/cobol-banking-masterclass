# COBOL Banking Masterclass - Build System
#
# Requires GnuCOBOL (cobc compiler)
# Install: apt install gnucobol | brew install gnucobol | choco install gnucobol

COBC = cobc
COBFLAGS = -x -fixed -I copybooks
SRCDIR = src
BINDIR = bin
DATADIR = data

# All programs
PROGRAMS = ACCTMSTR TXNPROC INTCALC RPTGEN AUDITLOG BATCHCTL VALDEMO VALENGN

# Callable subprograms (compiled as modules, not executables)
MODULES = VALENGN

# Executables
EXECUTABLES = ACCTMSTR TXNPROC INTCALC RPTGEN AUDITLOG BATCHCTL VALDEMO

.PHONY: all modules clean run-batch run-accounts run-txn run-interest run-reports run-audit run-validate help

all: $(BINDIR) modules $(addprefix $(BINDIR)/, $(EXECUTABLES))

# Compile VALENGN as a standalone callable module. cobc -m emits the
# platform's shared-object extension (.so on Linux, .dylib on macOS),
# so this is a phony step rather than a named-file target.
modules: $(BINDIR)
	$(COBC) -m -fixed -I copybooks -o $(BINDIR)/VALENGN $(SRCDIR)/VALENGN.cbl

$(BINDIR):
	mkdir -p $(BINDIR)

# Compile each program
$(BINDIR)/ACCTMSTR: $(SRCDIR)/ACCTMSTR.cbl copybooks/*.cpy
	$(COBC) $(COBFLAGS) -o $@ $<

$(BINDIR)/TXNPROC: $(SRCDIR)/TXNPROC.cbl copybooks/*.cpy
	$(COBC) $(COBFLAGS) -o $@ $<

$(BINDIR)/INTCALC: $(SRCDIR)/INTCALC.cbl copybooks/*.cpy
	$(COBC) $(COBFLAGS) -o $@ $<

$(BINDIR)/RPTGEN: $(SRCDIR)/RPTGEN.cbl copybooks/*.cpy
	$(COBC) $(COBFLAGS) -o $@ $<

$(BINDIR)/AUDITLOG: $(SRCDIR)/AUDITLOG.cbl copybooks/*.cpy
	$(COBC) $(COBFLAGS) -o $@ $<

$(BINDIR)/BATCHCTL: $(SRCDIR)/BATCHCTL.cbl
	$(COBC) $(COBFLAGS) -o $@ $<

# VALDEMO statically links the VALENGN subprogram so the demo runs
# anywhere with no module-path setup. VALENGN is also built as a
# standalone module above (the `modules` target) to show both styles.
$(BINDIR)/VALDEMO: $(SRCDIR)/VALDEMO.cbl $(SRCDIR)/VALENGN.cbl copybooks/*.cpy
	$(COBC) $(COBFLAGS) -o $@ $(SRCDIR)/VALDEMO.cbl $(SRCDIR)/VALENGN.cbl

# Run targets
run-accounts: $(BINDIR)/ACCTMSTR
	@echo "=== Running Account Master File Manager ==="
	cd $(BINDIR) && ./ACCTMSTR

run-txn: $(BINDIR)/TXNPROC
	@echo "=== Running Transaction Processor ==="
	cd $(BINDIR) && ./TXNPROC

run-interest: $(BINDIR)/INTCALC
	@echo "=== Running Interest Calculator ==="
	cd $(BINDIR) && ./INTCALC

run-reports: $(BINDIR)/RPTGEN
	@echo "=== Running Report Generator ==="
	cd $(BINDIR) && ./RPTGEN

run-audit: $(BINDIR)/AUDITLOG
	@echo "=== Running Audit Logger ==="
	cd $(BINDIR) && ./AUDITLOG

run-validate: $(BINDIR)/VALDEMO
	@echo "=== Running Validation Engine Demo ==="
	cd $(BINDIR) && ./VALDEMO

# Run the full batch cycle in sequence
run-batch: all
	@echo ""
	@echo "============================================"
	@echo "  RUNNING FULL NIGHTLY BATCH CYCLE"
	@echo "  This is what happens at your bank every"
	@echo "  single night while you sleep."
	@echo "============================================"
	@echo ""
	cd $(BINDIR) && ./ACCTMSTR
	@echo ""
	@echo "--- Step 1 Complete: Accounts Loaded ---"
	@echo ""
	cd $(BINDIR) && ./TXNPROC
	@echo ""
	@echo "--- Step 2 Complete: Transactions Processed ---"
	@echo ""
	cd $(BINDIR) && ./INTCALC
	@echo ""
	@echo "--- Step 3 Complete: Interest Calculated ---"
	@echo ""
	cd $(BINDIR) && ./RPTGEN
	@echo ""
	@echo "--- Step 4 Complete: Reports Generated ---"
	@echo ""
	cd $(BINDIR) && ./AUDITLOG
	@echo ""
	@echo "--- Step 5 Complete: Audit Verified ---"
	@echo ""
	@echo "============================================"
	@echo "  BATCH CYCLE COMPLETE"
	@echo "  Check bin/ for generated reports:"
	@echo "    ACCTLIST.RPT  - Account listing"
	@echo "    INTEREST.RPT  - Interest accrual"
	@echo "    FINREPORT.RPT - Financial position"
	@echo "    AUDITRPT.RPT  - Audit trail"
	@echo "============================================"

# Clean build artifacts
clean:
	rm -rf $(BINDIR)
	rm -f *.DAT *.RPT *.TMP

help:
	@echo "COBOL Banking Masterclass - Build Targets"
	@echo ""
	@echo "  make all          - Compile all programs"
	@echo "  make run-batch    - Run the full batch cycle"
	@echo "  make run-accounts - Run account manager only"
	@echo "  make run-txn      - Run transaction processor"
	@echo "  make run-interest - Run interest calculator"
	@echo "  make run-reports  - Run report generator"
	@echo "  make run-audit    - Run audit logger"
	@echo "  make run-validate - Run the validation engine demo"
	@echo "  make clean        - Remove build artifacts"
	@echo ""
	@echo "Prerequisites: GnuCOBOL (cobc)"
	@echo "  Ubuntu:  sudo apt install gnucobol"
	@echo "  macOS:   brew install gnucobol"
	@echo "  Windows: choco install gnucobol"
