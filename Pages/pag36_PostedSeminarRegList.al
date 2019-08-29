page 50136 "CSD Posted Seminar Reg. List"
{
    // CSD1.00 - 2018-01-01 - D. E. Veloper
    //   Chapter 7 - Lab 3
    //     - Created new page

    Caption = 'Seminar Registration List';
    CardPageID = "CSD Posted Seminar Reg.";
    Editable = false;
    PageType = List;
    SourceTable = "CSD Posted Seminar Reg. Header";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; "No.")
                {
                }
                field("Starting Date"; "Starting Date")
                {
                }
                field("Seminar No."; "Seminar No.")
                {
                }
                field("Seminar Name"; "Seminar Name")
                {
                }
                field(Status; Status)
                {
                }
                field(Duration; Duration)
                {
                }
                field("Maximum Participants"; "Maximum Participants")
                {
                }
                field("Room Resource No."; "Room Resource No.")
                {
                }
            }
        }
        area(factboxes)
        {
            part("CSD Seminar Details FactBox"; 50117)
            {
                SubPageLink = "No." = Field ("Seminar No.");
            }
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
        area(navigation)
        {
            group("&Seminar Registration")
            {
                Caption = '&Seminar Registration';
                action("Co&mments")
                {
                    Caption = 'Co&mments';
                    Image = Comment;
                    RunObject = Page 50106;
                    RunPageLink = "No." = Field ("No.");
                    RunPageView = sorting ("Document Line No.");
                }
                action("Charges")
                {
                    Caption = '&Charges';
                    Image = Costs;
                    RunObject = Page 50139;
                    RunPageLink = "Document No." = Field ("No.");
                }
            }
        }
    }
}

