codeunit 50139 "CSD EventSubscriptions"
//28/08/2019 Chapter 7 Lab 4-4
//Specifies the current subscriptions to published events
{
    [EventSubscriber(ObjectType::Codeunit, 212, 'OnBeforeResLedgEntryInsert', '', true, true)]
    local procedure PostResJnlLineOnBeforeLedgEntryInsert
        (var ResLedgerEntry: Record "Res. Ledger Entry";
             ResJournalLine: Record "Res. Journal Line");
    begin
        ResLedgerEntry."CSD Seminar No." := ResJournalLine."CSD Seminar No.";
        ResLedgerEntry."CSD Seminar Registration No." := ResJournalLine."CSD Seminar Registration No.";
    end;

}