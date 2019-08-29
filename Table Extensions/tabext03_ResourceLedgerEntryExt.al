tableextension 50103 "CSD ResourceLedgerEntryExt" extends "Res. Ledger Entry"
//27/08/2019 Chapter 7 Lab 4-1
{
    fields
    {
        field(50100; "CSD Seminar No."; Code[20])
        {
            Caption = 'Seminar No.';
            TableRelation = "CSD Seminar";
        }
        field(50101; "CSD Seminar Registration No."; Code[20])
        {
            Caption = 'Seminar Registration No.';
            TableRelation = "CSD Seminar Reg. Header";
        }
    }
}