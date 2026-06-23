      ******************************************************************
      * VALDEMO.cbl - Validation Engine Demonstration Driver
      *
      * VALENGN is a callable subprogram - it has no main routine of
      * its own, so it cannot be run directly. This driver exercises
      * it the way a real production program would: by CALLing it with
      * a function code and a data buffer, then reading back the
      * result and error fields.
      *
      * COBOL LESSON: This shows the other half of the CALL contract.
      * VALENGN declares its parameters in its LINKAGE SECTION; the
      * caller passes matching fields on the CALL ... USING list, in
      * the same order, size, and type. BY REFERENCE (the default)
      * lets the subprogram write results straight back into our
      * WORKING-STORAGE.
      ******************************************************************

       IDENTIFICATION DIVISION.
       PROGRAM-ID.    VALDEMO.
       AUTHOR.        COBOL-BANKING-MASTERCLASS.

       ENVIRONMENT DIVISION.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

      *    ---- CALL Parameters (mirror VALENGN's LINKAGE SECTION) ----
       01  WS-FUNCTION-CODE             PIC X(4).
       01  WS-INPUT-DATA                PIC X(80).
       01  WS-RESULT-CODE               PIC X(1).
           88  WS-RESULT-VALID          VALUE "Y".
       01  WS-ERR-CODE                  PIC X(4).
       01  WS-ERR-MESSAGE               PIC X(80).

      *    ---- Display Helper ----
       01  WS-VERDICT                   PIC X(7).

       PROCEDURE DIVISION.

       0000-MAIN-CONTROL.
           DISPLAY "================================================"
           DISPLAY "  VALDEMO - Validation Engine Demonstration"
           DISPLAY "  COBOL Banking Masterclass"
           DISPLAY "================================================"
           DISPLAY SPACES

           PERFORM 1000-DEMO-ACCOUNT-NUMBERS
           PERFORM 2000-DEMO-LUHN
           PERFORM 3000-DEMO-DATES
           PERFORM 4000-DEMO-AMOUNTS

           DISPLAY "================================================"
           DISPLAY "  VALDEMO Complete"
           DISPLAY "================================================"
           STOP RUN
           .

      ******************************************************************
      * ACCOUNT NUMBER VALIDATION (function VACT)
      *
      * Checks the bank code against a known table, confirms the
      * branch and sequence are well-formed, and runs a Luhn check
      * over the account number.
      ******************************************************************
       1000-DEMO-ACCOUNT-NUMBERS.
           DISPLAY "--- Account Number Validation (VACT) ---"
           MOVE "VACT" TO WS-FUNCTION-CODE

           MOVE "BNKA000100000011" TO WS-INPUT-DATA
           PERFORM 9000-CALL-VALENGN
           DISPLAY "  BNKA000100000011  " WS-VERDICT

           MOVE "ZZZZ000100000011" TO WS-INPUT-DATA
           PERFORM 9000-CALL-VALENGN
           DISPLAY "  ZZZZ000100000011  " WS-VERDICT
                   "  " WS-ERR-MESSAGE(1:40)
           DISPLAY SPACES
           .

      ******************************************************************
      * LUHN CHECK DIGIT (function LUHN)
      *
      * The same checksum that guards every credit card number.
      ******************************************************************
       2000-DEMO-LUHN.
           DISPLAY "--- Luhn Check Digit (LUHN) ---"
           MOVE "LUHN" TO WS-FUNCTION-CODE

           MOVE "4539148803436467" TO WS-INPUT-DATA
           PERFORM 9000-CALL-VALENGN
           DISPLAY "  4539148803436467  " WS-VERDICT "  (valid card)"

           MOVE "4539148803436460" TO WS-INPUT-DATA
           PERFORM 9000-CALL-VALENGN
           DISPLAY "  4539148803436460  " WS-VERDICT
                   "  " WS-ERR-MESSAGE(1:40)
           DISPLAY SPACES
           .

      ******************************************************************
      * DATE VALIDATION (function VDAT)
      *
      * Full YYYYMMDD validation including the leap-year rules that
      * caused so many Y2K-era bugs.
      ******************************************************************
       3000-DEMO-DATES.
           DISPLAY "--- Date Validation (VDAT) ---"
           MOVE "VDAT" TO WS-FUNCTION-CODE

           MOVE "20240229" TO WS-INPUT-DATA
           PERFORM 9000-CALL-VALENGN
           DISPLAY "  20240229          " WS-VERDICT
                   "  (2024 is a leap year)"

           MOVE "20230229" TO WS-INPUT-DATA
           PERFORM 9000-CALL-VALENGN
           DISPLAY "  20230229          " WS-VERDICT
                   "  " WS-ERR-MESSAGE(1:40)
           DISPLAY SPACES
           .

      ******************************************************************
      * AMOUNT VALIDATION (function VAMT)
      ******************************************************************
       4000-DEMO-AMOUNTS.
           DISPLAY "--- Amount Validation (VAMT) ---"
           MOVE "VAMT" TO WS-FUNCTION-CODE

           MOVE "000000000250000" TO WS-INPUT-DATA
           PERFORM 9000-CALL-VALENGN
           DISPLAY "  000000000250000   " WS-VERDICT "  ($2,500.00)"

           MOVE "00000000025X000" TO WS-INPUT-DATA
           PERFORM 9000-CALL-VALENGN
           DISPLAY "  00000000025X000   " WS-VERDICT
                   "  " WS-ERR-MESSAGE(1:40)
           DISPLAY SPACES
           .

      ******************************************************************
      * CALL THE VALIDATION ENGINE
      *
      * COBOL LESSON: One CALL site, reused for every function. The
      * USING list must line up exactly with VALENGN's PROCEDURE
      * DIVISION USING clause.
      ******************************************************************
       9000-CALL-VALENGN.
           CALL "VALENGN" USING
               WS-FUNCTION-CODE
               WS-INPUT-DATA
               WS-RESULT-CODE
               WS-ERR-CODE
               WS-ERR-MESSAGE
           END-CALL

           IF WS-RESULT-VALID
               MOVE "VALID  " TO WS-VERDICT
           ELSE
               MOVE "INVALID" TO WS-VERDICT
           END-IF
           .
