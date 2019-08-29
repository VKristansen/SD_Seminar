codeunit 50100 "CSD Seminar-Post"
{
    //28/08/2019  Chapter 7 - Lab 4-7
    TableNo = 50110;

    trigger OnRun();
    /*the code clears all variables and sets 
    the SeminarRegHeader record variable to the current record.*/
    begin
        ClearAll;
        SeminarRegHeader := Rec;
        with SeminarRegHeader do begin
            TestField("Posting Date");
            TestField("Document Date");
            TestField("Seminar No.");
            TestField(Duration);
            TestField("Instructor Resource No.");
            TestField("Room Resource No.");
            TestField(Status, Status::Closed);//sets the status field to closed
            //if there are no lines for the current document will throw an error
            SeminarRegLine.Reset;
            SeminarRegLine.SetRange("Document No.", "No.");
            if SeminarRegLine.IsEmpty then
                Error(Text001);
            //open a dialog box to show the posting progress
            Window.Open('#1#################################\\' + Text002);
            Window.Update(1, StrSubstNo('%1 %2', Text003, "No."));
            /*If the Posting No. is blank on the registration header ,make sure that the 
            Posting No. Series is not blank. Then assign the Posting No. to the next
            number from the posting number series, as indicated on the header. Then,
            modify the header and perform a commit. Finally, lock the Seminar Registration
            Line table.*/
            if SeminarRegHeader."Posting No." = '' then begin
                TestField("Posting No. Series");
                "Posting No." := NoSeriesMgt.GetNextNo("Posting No. Series", "Posting Date", true);
                Modify;
                Commit;
            end;
            SeminarRegLine.LockTable;
            //assign the SourceCode variable from the Seminar field of the Source Code Setup table
            SourceCodeSetup.Get;
            SourceCode := SourceCodeSetup."CSD Seminar";
            /*Initialize a new Posted Seminar Reg. Header record, and then transfer the 
            fields from the registration header. Assign No. and No. Series to the Posting No.
            and Posting No. Series fields from the registration header. Asign Source Code 
            from the SourceCode variable, and User ID from the userid function. Finally, insert 
            the Seminar Reg. Header record.*/
            PstdSeminarRegHeader.Init;
            PstdSeminarRegHeader.TransferFields(SeminarRegHeader);
            PstdSeminarRegHeader."No." := "Posting No.";
            PstdSeminarRegHeader."No. Series" := "Posting No. Series";
            PstdSeminarRegHeader."Source Code" := SourceCode;
            PstdSeminarRegHeader."User Id" := UserId;
            PstdSeminarRegHeader.Insert;
            Window.Update(1, StrSubstNo(Text004, "No.", PstdSeminarRegHeader."No."));//update the dialog box
            /*Copy the comment lines and charges from the registration header to the posted
            registration header, by calling the CopyCommentLines and CopyCharges functions.*/
            CopyCommentLines(SeminarCommentLine."Table Name"::"Seminar Registration Header",
            SeminarCommentLine."Table Name"::"Posted Seminar Reg. Header", "No.", PstdSeminarRegHeader."No.");
            CopyCharges("No.", PstdSeminarRegHeader."No.");
            /*Set the LineCount to zero and prepare the loop for the 
            registration lines of the current registrationheader*/
            LineCount := 0;
            SeminarRegLine.Reset;
            SeminarRegLine.SetRange("Document No.", "No.");
            if SeminarRegLine.FindSet then begin
                repeat
                until SeminarRegLine.Next = 0;
            end;
            /*For each registration line, increase the LineCount variable by one,
            update the dialog window, and make sure thet Bill-to Customer No. and 
            Participant Contact No. are not empty. If the line should not be invoiced, reset
            its Seminar Price, Line Discount %, Discount Amount and Amount fields to zero. Post
            the participant line by calling the PostSeminarLine function. Finally initialize
            and insert a new posted registration line, and assigning the approriate
            Document No. value.*/
            Window.Update(2, LineCount);
            SeminarRegLine.TestField("Bill-to Customer No.");
            SeminarRegLine.TestField("Participant Contact No.");
            if not SeminarRegLine."To Invoice" then begin
                SeminarRegLine."Seminar Price" := 0;
                SeminarRegLine."Line Discount %" := 0;
                SeminarRegLine."Line Discount Amount" := 0;
                SeminarRegLine.Amount := 0;
            end;
            //Post seminar entry 
            PostSeminarJnlLine(2);//Participant
            //insert posted seminar registration line
            PstdSeminarRegLine.Init;
            PstdSeminarRegLine.TransferFields(SeminarRegLine);
            PstdSeminarRegLine."Document No." := PstdSeminarRegHeader."No.";
            PstdSeminarRegLine.Insert;
            /*Post the charges by calling the PostCharges function. Then post the seminar
            ledger entry for the instructor and the room by calling the 
            PostSeminarJnlLine function.*/
            //Post charges to seminar ledger
            PostCharges;
            //post instructor to seminar ledger
            PostSeminarJnlLine(0);//instructor
            //post seminar room to seminar ledger
            PostSeminarJnlLine(1);//room
            //Delete the registration header, lines, comments and charges
            /*Using the true parameter on the Delete command 
            fires the OnDelete trigger on the Seminar Registration Header*/
            Delete(true);
        end;
        Rec := SeminarRegHeader;
    end;

    var
        SeminarRegHeader: Record "CSD Seminar Reg. Header";
        SeminarRegLine: Record "CSD Seminar Registration Line";
        PstdSeminarRegHeader: Record "CSD Posted Seminar Reg. Header";
        PstdSeminarRegLine: Record "CSD Posted Seminar Reg. Line";
        SeminarCommentLine: Record "CSD Seminar Comment Line";
        SeminarCommentLine2: Record "CSD Seminar Comment Line";
        SeminarCharge: Record "CSD Seminar Charge";
        PstdSeminarCharge: Record "CSD Posted Seminar Charge";
        Room: Record Resource;
        Instructor: Record Resource;
        Customer: Record Customer;
        ResLedgEntry: Record "Res. Ledger Entry";
        SeminarJnlLine: Record "CSD Seminar Journal Line";
        SourceCodeSetup: Record "Source Code Setup";
        ResJnlLine: Record "Res. Journal Line";
        SeminarJnlPostLine: Codeunit "CSD Seminar Jnl.-Post Line";
        ResJnlPostLine: Codeunit "Res. Jnl.-Post Line";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        DimMgt: Codeunit DimensionManagement;
        Window: Dialog;
        SourceCode: Code[10];
        LineCount: Integer;
        Text001: Label 'There is no participant to post.';
        Text002: Label 'Posting lines              #2######\';
        Text003: Label 'Registration';
        Text004: Label 'Registration %1  -> Posted Reg. %2';
        Text005: Label 'The combination of dimensions used in %1 is blocked. %2';
        Text006: Label 'The combination of dimensions used in %1,  line no. %2 is blocked. %3';
        Text007: Label 'The dimensions used in %1 are invalid. %2';
        Text008: Label 'The dimensions used in %1, line no. %2 are invalid. %3';

    local procedure CopyCommentLines(FromDocumentType: Integer; ToDocumentType: Integer; FromNumber: Code[20]; ToNumber: Code[20]);
    /*finds records in the Seminar Comment Line table that matches the specified FromDocumentType and FromNumber,
     and for each record inserts a copy of the old record,
     with the Document Type and No. set to the ToDocumentType and ToNumber*/
    begin
        SeminarCommentLine.Reset;
        SeminarCommentLine.SetRange("Table Name", FromDocumentType);
        SeminarCommentLine.SetRange("No.", FromNumber);
        if SeminarCommentLine.FindSet then
            repeat
                SeminarCommentLine2 := SeminarCommentLine;
                SeminarCommentLine2."Table Name" := ToDocumentType;
                SeminarCommentLine2."No." := ToNumber;
                SeminarCommentLine2.Insert;
            until SeminarCommentLine.Next = 0;
    end;

    local procedure CopyCharges(FromNumber: Code[20]; ToNumber: Code[20]);
    /*finds all Seminar Charge records that correspond to the specified FromNumber. 
    For each record found, the function transfers the values to a new Posted Seminar Charge record,
     by using the ToNumber as the Seminar Registration No*/
    begin
        SeminarCharge.Reset;
        SeminarCharge.SetRange("Document No.", FromNumber);
        if SeminarCharge.FindSet then
            repeat
                PstdSeminarCharge.TransferFields(SeminarCharge);
                PstdSeminarCharge."Document No." := ToNumber;
                PstdSeminarCharge.Insert;
            until SeminarCharge.Next = 0;
    end;

    //makes sure that the quantity per day field in the resource record is not empty
    local procedure PostResJnlLine(Resource: Record Resource): Integer;
    begin
        with SeminarRegHeader do begin
            ResJnlLine.Init;//initializes the Resource Journal Line record
            ResJnlLine."Entry Type" := ResJnlLine."Entry Type"::Usage;//sets the entry type to usage
            ResJnlLine."Document No." := PstdSeminarRegHeader."No.";//assigns the Document No. from No. field on the PstSeminarHeader record variable
            ResJnlLine."Resource No." := Resource."No.";//assigns the Resource No. from Resource record parameter
            ResJnlLine."Posting Date" := "Posting Date";
            ResJnlLine."Reason Code" := "Reason Code";
            ResJnlLine.Description := "Seminar Name";
            ResJnlLine."Source Code" := SourceCode;//assigns the Source Code from the global variable
            ResJnlLine."Gen. Prod. Posting Group" := "Gen. Prod. Posting Group";
            ResJnlLine."Posting No. Series" := "Posting No. Series";
            ResJnlLine."Resource No." := Resource."No.";
            ResJnlLine."Unit of Measure Code" := Resource."Base Unit of Measure";
            ResJnlLine."Unit Cost" := Resource."Unit Cost";
            ResJnlLine."Qty. per Unit of Measure" := 1;
            /*calculates the Quantity field as the product of the Duration 
            field from the SeminarRegHeader record variable. 
            Then, calculate the Total Cost field as the product 
            of the Unit Cost and Quantity field values. 
            Then, assign values to Seminar No. and Seminar Registration No. fields.*/
            ResJnlLine.Quantity := Duration * Resource."CSD Quantity Per Day";
            ResJnlLine."Total Cost" := ResJnlLine."Unit Cost" * ResJnlLine.Quantity;
            ResJnlLine."CSD Seminar No." := "Seminar No.";
            ResJnlLine."CSD Seminar Registration No." := PstdSeminarRegHeader."No.";
            ResJnlPostLine.RunWithCheck(ResJnlLine);
        end;
        //find the last Resource Ledger Entry, and return its Entry No. field value as the function return value
        ResLedgEntry.FindLast;
        exit(ResLedgEntry."Entry No.");
    end;

    local procedure PostSeminarJnlLine(ChargeType: Option Instructor,Room,Participant,Charge);
    begin
        with SeminarRegHeader do begin
            SeminarJnlLine.Init;
            SeminarJnlLine."Seminar No." := "Seminar No.";
            SeminarJnlLine."Posting Date" := "Posting Date";
            SeminarJnlLine."Document Date" := "Document Date";
            SeminarJnlLine."Document No." := PstdSeminarRegHeader."No.";
            SeminarJnlLine."Charge Type" := ChargeType;
            SeminarJnlLine."Instructor Resource No." := "Instructor Resource No.";
            SeminarJnlLine."Starting Date" := "Starting Date";
            SeminarJnlLine."Seminar Registration No." := PstdSeminarRegHeader."No.";
            SeminarJnlLine."Room Resource No." := "Room Resource No.";
            SeminarJnlLine."Source Type" := SeminarJnlLine."Source Type"::Seminar;
            SeminarJnlLine."Source No." := "Seminar No.";
            SeminarJnlLine."Source Code" := SourceCode;
            SeminarJnlLine."Reason Code" := "Reason Code";
            SeminarJnlLine."Posting No. Series" := "Posting No. Series";
            //the code below compares the ChargeType parameter to all possible option values that it can have
            case ChargeType of
                /*If the ChargeType is Instructor, 
                retrieve the appropriate Resource record, and then on the SeminarJnlLine record variable, 
                assign Description from the instructor Name, set Type to Resource, set Chargeable to false,
                and set Quantity to the Duration field from the SeminarRegHeader. Finally, call the PostResJnlLine,
                and assign its return value to the Res. Ledger Entry No.
                field of the SeminarJnlLine record variable.*/
                ChargeType::Instructor:
                    begin
                        Instructor.Get("Instructor Resource No.");
                        SeminarJnlLine.Description := "Instructor Name";
                        SeminarJnlLine.Type := SeminarJnlLine.Type::Resource;
                        SeminarJnlLine.Chargeable := false;
                        SeminarJnlLine.Quantity := Duration;
                        SeminarJnlLine."Res. Ledger Entry No." := PostResJnlLine(Instructor);
                    end;
                    /*If the ChargeType is Room, retrieve the appropriate Resource, and then on the SeminarJnlLine record variable,
                    assign Description from the room Name, set Type to Resource, set Chargeable to false,
                    and set Quantity to the Duration field from the SeminarRegHeader.
                    Finally, call the PostResJnlLine, and assign its return value to the
                    Res. Ledger Entry No. field of the SeminarJnlLine record variable.*/
                ChargeType::Room:
                    begin
                        Room.Get("Room Resource No.");
                        SeminarJnlLine.Description := Room.Name;
                        SeminarJnlLine.Type := SeminarJnlLine.Type::Resource;
                        SeminarJnlLine.Chargeable := false;
                        SeminarJnlLine.Quantity := Duration;
                        SeminarJnlLine."Res. Ledger Entry No." := PostResJnlLine(Room);
                    end;
                /*If the ChargeType is Participant, assign the fields to the SeminarJnlLine
                record variable from the SeminarRegLine record variable*/
                ChargeType::Participant:
                    begin
                        SeminarJnlLine."Bill-to Customer No." := SeminarRegLine."Bill-to Customer No.";
                        SeminarJnlLine."Participant Contact No." := SeminarRegLine."Participant Contact No.";
                        SeminarJnlLine."Participant Name" := SeminarRegLine."Participant Name";
                        SeminarJnlLine.Description := SeminarRegLine."Participant Name";
                        SeminarJnlLine.Type := SeminarJnlLine.Type::Resource;
                        SeminarJnlLine.Chargeable := SeminarRegLine."To Invoice";
                        SeminarJnlLine.Quantity := 1;
                        SeminarJnlLine."Unit Price" := SeminarRegLine.Amount;
                        SeminarJnlLine."Total Price" := SeminarRegLine.Amount;
                    end;
                /*If ChargeType is Charge, then assign the fields to the 
                SeminarJnlLine record variable from the SeminarCharge record variable.*/
                ChargeType::Charge:
                    begin
                        SeminarJnlLine.Description := SeminarCharge.Description;
                        SeminarJnlLine."Bill-to Customer No." := SeminarCharge."Bill-to Customer No.";
                        SeminarJnlLine.Type := SeminarCharge.Type;
                        SeminarJnlLine.Quantity := SeminarCharge.Quantity;
                        SeminarJnlLine."Unit Price" := SeminarCharge."Unit Price";
                        SeminarJnlLine."Total Price" := SeminarCharge."Total Price";
                        SeminarJnlLine.Chargeable := SeminarCharge."To Invoice";
                    end;
            end;
            SeminarJnlPostLine.RunWithCheck(SeminarJnlLine);
        end;
    end;
    /*the code calls the PostSeminarJnlLine function for every Seminar Charge 
    for the current SeminarRegHeader.*/
    local procedure PostCharges();
    begin
        SeminarCharge.Reset;
        SeminarCharge.SetRange("Document No.", SeminarRegHeader."No.");
        if SeminarCharge.FindSet(false, false) then //Finds a set of records in a table based on the current key and filter.
            repeat
                PostSeminarJnlLine(3);//Charge
            until SeminarCharge.Next = 0;
    end;
}

