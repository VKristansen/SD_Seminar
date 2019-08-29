page 50134 "CSD Posted Seminar Reg."
{
    // CSD1.00 - 2018-01-01 - D. E. Veloper
    //   Chapter 7 - Lab 3
    //     - Created new page

    Caption = 'Seminar Registration';
    Editable = false;
    PageType = Document;
    SourceTable = "CSD Posted Seminar Reg. Header";

    layout
    {
        area(content)
        {
            group(General)
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
                field("Instructor Resource No."; "Instructor Resource No.")
                {
                }
                field("Instructor Name"; "Instructor Name")
                {
                }
                field("Posting Date"; "Posting Date")
                {
                }
                field("Document Date"; "Document Date")
                {
                }
                field(Status; Status)
                {
                }
                field(Duration; Duration)
                {
                }
                field("Minimum Participants"; "Minimum Participants")
                {
                }
                field("Maximum Participants"; "Maximum Participants")
                {
                }
            }
            part("Post Seminar Reg. Subpage"; 50135)
            {
                SubPageLink = "Document No." = Field ("No.");
            }
            group("Seminar Room")
            {
                field("Room Resource No."; "Room Resource No.")
                {
                }
                field("Room Name"; "Room Name")
                {
                }
                field("Room Address"; "Room Address")
                {
                }
                field("Room Address 2"; "Room Address 2")
                {
                }
                field("Room Post Code"; "Room Post Code")
                {
                }
                field("Room City"; "Room City")
                {
                }
                field("Room Country/Reg. Code"; "Room Country/Reg. Code")
                {
                }
                field("Room County"; "Room County")
                {
                }
            }
            group(Invoicing)
            {
                field("Gen. Prod. Posting Group"; "Gen. Prod. Posting Group")
                {
                }
                field("VAT Prod. Posting Group"; "VAT Prod. Posting Group")
                {
                }
                field("Seminar Price"; "Seminar Price")
                {
                }
            }
        }
        area(factboxes)
        {
            part("Seminar Details FactBox"; 50117)
            {
                SubPageLink = "No." = Field ("Seminar No.");
            }
            part("Customer Details FactBox"; 9084)
            {
                Provider = "Customer Details FactBox";
                SubPageLink = "No." = Field ("Bill-to Customer No.");
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
            group("Seminar Registration")
            {
                Caption = '&Seminar Registration';
                action("Comments")
                {
                    Caption = 'Co&mments';
                    Image = Comment;
                    RunObject = Page 50106;
                    RunPageLink = "No." = Field ("No.");
                    RunPageView = sorting ("Document Line No.");
                }
                action("&Charges")
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

