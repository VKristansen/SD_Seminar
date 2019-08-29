codeunit 50131 "CSD Seminar Jnl.-Check Line"
//CSD1.00 23/08/2019
//Chapter 7 - Lab 2-1
{
    //make the table the source table for the codeunit
    TableNo = "CSD Seminar Journal Line";
    trigger OnRun()
    begin
        RunCheck(Rec);
    end;

    var

        GlSetup: Record "General Ledger Setup";
        UserSetup: Record "User Setup";
        AllowPostingFrom: Date;
        AllowPostingTo: Date;
        ClosingDateTxt: Label 'cannot be a closing date.';
        PostingDateTxt: Label 'is not within your range of allowed posting dates.';

    procedure RunCheck(var SemJnlLine: Record "CSD Seminar Journal Line");
    var
        myInt: Integer;
    begin
        with SemJnlLine do begin
            //if the line is empty the function it exits
            if EmptyLine then
                exit;
            TestField("Posting Date");
            TestField("Instructor Resource No.");
            TestField("Seminar No.");
            //make sure that that fields are not empty
            case "Charge Type" of
                "Charge Type"::Instructor:
                    TestField("Instructor Resource No.");
                "Charge Type"::Room:
                    TestField("Room Resource No.");
                "Charge Type"::Participant:
                    TestField("Participant Contact No.");
            end;
            //if the line is chargeable make sure that that field is not empty
            if Chargeable then
                TestField("Bill-to Customer No.");
            //show an error if the posting date is a closing date
            if "Posting Date" = ClosingDate("Posting Date") then
                FieldError("Posting Date", ClosingDateTxt);
            /*make sure that the posting date field is between the allow posting
            from field and the allow posting to field values in the user setup
            table.If those fields are not defined there, then make sure that the 
            posting date field is between the allow posting from and allow posting
            to field in G/L Setup table*/
            if (AllowPostingFrom = 0D) and (AllowPostingTo = 0D) then begin
                if UserId <> '' then
                    if UserSetup.Get(UserId) then begin
                        AllowPostingFrom := UserSetup."Allow Posting From";
                        AllowPostingTo := UserSetup."Allow Posting To";
                    end;
                if (AllowPostingFrom = 0D) and (AllowPostingTo = 0D) then begin
                    GlSetup.Get;
                    AllowPostingFrom := GlSetup."Allow Posting From";
                    AllowPostingTo := GlSetup."Allow Posting To";
                end;
                if AllowPostingTo = 0D then
                    AllowPostingTo := DMY2Date(31, 12, 9999);//DMY2Date this mitigates any problems when handling multiple regional settings

            end;
            if ("Posting Date" < AllowPostingFrom) or ("Posting Date" > AllowPostingTo) then
                FieldError("Posting Date", PostingDateTxt);
            //show an error if the document date field is a closing date
            if ("Document Date" <> 0D) then
                if ("Document Date" = ClosingDate("Document Date")) then
                    FieldError("Document Date", PostingDateTxt);


        end;
    end;
}