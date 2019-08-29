codeunit 50134 "CSD Seminar Reg.-Show Ledger"
//CSD1.00 26/08/2019
//Chapter 7 -Lab 2-10
{
    TableNo = "CSD Seminar Register";

    trigger OnRun()
    begin
        SeminarLedgerEntry.Setrange("Entry No.", "From Entry No.", "To Entry No.");
        //shows, by default, the record last displayed on the page(PAGE.RUN(Number[, Record] [, Field]))
        Page.Run(Page::"CSD Seminar Ledger Entries", SeminarLedgerEntry);

    end;

    var
        SeminarLedgerEntry: Record "CSD Seminar Ledger Entry";

}