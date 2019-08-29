page 50122 "CSD Seminar Registers"
//CSD1.00 26/08/2019
//Chapter 7 -Lab 2-11
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "CSD Seminar Register";
    Caption = 'Seminar Registers';
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("No."; "No.")
                {

                }
                field("Creation Date"; "Creation Date")
                {

                }
                field("User ID"; "User ID")
                {

                }
                field("Source Code"; "Source Code")
                {

                }
                field("Journal Batch Name"; "Journal Batch Name")
                {

                }
            }
        }
        area(FactBoxes)
        {
            systempart("Links"; Links)
            {

            }
            systempart("Notes"; Notes)
            {

            }
        }
    }

    actions
    {
        area(Navigation)
        {
            action("Seminar Ledgers")
            {
                //show this icon
                Image = WarrantyLedger;
                //run the "CSD Seminar Reg.-Show Ledger" codeunit
                RunObject = codeunit "CSD Seminar Reg.-Show Ledger";
            }
        }
    }

}