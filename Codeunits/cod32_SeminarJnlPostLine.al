//this codeunit must handle the following:
//-run the Seminar Jnl.-Check Line codeunit
//-increase the Entry No. of the ledger entries it creates by one
//-make sure that one register record is created and maintained
// throughout the journal posting process to reflect the first and 
// last entry number
//-populate the ledger entry from the fields of the Seminar Journal table
// and insert it

codeunit 50132 "CSD Seminar Jnl.-Post Line"
//CSD1.00 23/08/2019
//Chapter 7 Lab 2-8
{
    TableNo = "CSD Seminar Journal Line";

    trigger OnRun()
    begin

    end;

    var
        //global variable declaration
        SeminarJnlLine: Record "CSD Seminar Journal Line";
        SeminarLedgerEntry: Record "CSD Seminar Ledger Entry";
        SeminarRegister: Record "CSD Seminar Register";
        //global variable declaration for the codeunit
        SeminarJnlCheckLine: Codeunit "CSD Seminar Jnl.-Check Line";
        NextEntryNo: Integer;

    procedure RunWithCheck(var SeminarJnlLine2: Record "CSD Seminar Journal Line");
    var
        myInt: Integer;
    begin
        with SeminarJnlLine2 do begin
            SeminarJnlLine := SeminarJnlLine2;
            /*If the NextEntryNo is 0, 
            lock the SeminarLedgEntry record, then set 
            the NextEntryNo to the Entry No. of the last record in 
            the SeminarLedgEntry table, if it can be found. 
            Then, increase the NextEntryNo by one.*/
            if NextEntryNo = 0 then begin
                SeminarLedgerEntry.LockTable;
                if SeminarLedgerEntry.FindLast then
                    NextEntryNo := SeminarLedgerEntry."Entry No.";
                NextEntryNo := NextEntryNo + 1;
            end;
            /*Create or update the SeminarRegister record,
             depending on whether the register record was previously created 
             for this posting. When you create the register record, 
            initialize all fields according to their meaning.*/
            if SeminarRegister."No." = 0 then begin
                SeminarRegister.LockTable;
                if (not SeminarRegister.FindLast) or (SeminarRegister."To Entry No." <> 0)
                then begin
                    SeminarRegister.Init;
                    SeminarRegister."No." := SeminarRegister."No." + 1;
                    SeminarRegister."From Entry No." := NextEntryNo;
                    SeminarRegister."To Entry No." := NextEntryNo;
                    SeminarRegister."Creation Date" := Today;
                    SeminarRegister."Source Code" := "Source Code";
                    SeminarRegister."Journal Batch Name" := "Journal Batch Name";
                    SeminarRegister."User ID" := UserId;
                    SeminarRegister.Insert;
                end;
            end;
            SeminarRegister."To Entry No." := NextEntryNo;
            SeminarRegister.Modify;
            /*Create a new SeminarLedgerEntry record, 
            populate the fields from the SeminarJnlLine record, 
            set the Entry No. field to the NextEntryNo variable, 
            insert the new record, 
            and then increment the NextEntryNo variable by one.*/
            SeminarLedgerEntry.Init;
            SeminarLedgerEntry."Seminar No." := "Seminar No.";
            SeminarLedgerEntry."Posting Date" := "Posting Date";
            SeminarLedgerEntry."Document Date" := "Document Date";
            SeminarLedgerEntry."Entry Type" := "Entry Type";
            SeminarLedgerEntry."Document No." := "Document No.";
            SeminarLedgerEntry.Description := Description;
            SeminarLedgerEntry."Bill-to Customer No." := "Bill-to Customer No.";
            SeminarLedgerEntry."Charge Type" := "Charge Type";
            SeminarLedgerEntry.Type := Type;
            SeminarLedgerEntry.Quantity := Quantity;
            SeminarLedgerEntry."Unit Price" := "Unit Price";
            SeminarLedgerEntry."Total Price" := "Total Price";
            SeminarLedgerEntry."Participant Contact No." := "Participant Contact No.";
            SeminarLedgerEntry."Participant Name" := "Participant Name";
            SeminarLedgerEntry.Chargeable := Chargeable;
            SeminarLedgerEntry."Room Resource No." := "Room Resource No.";
            SeminarLedgerEntry."Instructor Resource No." := "Instructor Resource No.";
            SeminarLedgerEntry."Starting Date" := "Starting Date";
            SeminarLedgerEntry."Seminar Registration No." := "Seminar Registration No.";
            SeminarLedgerEntry."Res. Ledger Entry No." := "Res. Ledger Entry No.";
            SeminarLedgerEntry."Source Type" := "Source Type";
            SeminarLedgerEntry."Source No." := "Source No.";
            SeminarLedgerEntry."Journal Batch Name" := "Journal Batch Name";
            SeminarLedgerEntry."Source Code" := "Source Code";
            SeminarLedgerEntry."Reason Code" := "Reason Code";
            SeminarLedgerEntry."No. Series" := "Posting No. Series";
            SeminarLedgerEntry."Entry No." := NextEntryNo;
            NextEntryNo += 1;
            SeminarLedgerEntry.Insert;
            SeminarJnlLine2 := SeminarJnlLine;
        end;
    end;
}