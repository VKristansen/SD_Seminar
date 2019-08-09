pageextension 50101 "CSD ResourceListExt" extends "Resource List"
// CSD 1.00 - 2018-01-01 - D. E. Veloper
//Chapter 5 Lab 1-3
//Changed property to the Type field
//Added new fields:
//-Internal/External
//-Maximoum Participants
//Added code to OnOpenPage trigger
{
    layout
    {

        modify(Type)
        {
            Visible = Showtype;
        }
        addafter(Type)
        {
            field("CSD Recource Type"; "CSD Recource Type")
            {

            }
            field("CSD Maximum Participants"; "CSD Maximum Participants")
            {
                Visible = ShowMaxField;
            }
        }

    }

    trigger OnOpenPage();
    begin
        ShowType := (GetFilter(Type) = '');
        ShowMaxField := (GetFilter(Type) = format(Type::Machine));
    end;

    var
        [InDataSet]
        ShowMaxField: Boolean;
        [InDataSet]
        Showtype: Boolean;

}