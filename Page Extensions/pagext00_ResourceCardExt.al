pageextension 50100 "CSD ResourceCardExt" extends "Resource Card"
//CSD 1.00 - 2018-02-01 - D. E. Veloper
//Chapter 5 Lab 1-2
//Added new fields:
//-Internal/External
//-Maximoum Participants
//Added new FastTab
//Added code OnOpenPage trigger
{
    layout
    {
        addlast(General)
        {
            field("CSD Resource Type"; "CSD Recource Type")
            {

            }
            field("CSD Quantity Per Day"; "CSD Quantity Per Day")
            {

            }
        }

        addafter("Personal Data")
        {
            group("CSD Room")
            {
                Caption = 'Room';
                Visible = ShowMaxField;

                field("CSD Maximum Participants"; "CSD Maximum Participants")
                {

                }
            }
        }
    }


    trigger OnAfterGetRecord();
    begin
        ShowMaxField := (Type = Type::Machine);
        CurrPage.Update(false);
    end;

    var
        [InDataSet]
        ShowMaxField: Boolean;
}