tableextension 50104 "CSD ResJournalLineExt" extends "Res. Journal Line"
//27/08/2019 Chapter 7 Lab 4-2
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