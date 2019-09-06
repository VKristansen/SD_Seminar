report 50100 "Create Seminar Invoices"
{
    // CSD1.00 - 2018-01-01 - D. E. Veloper
    //   Chapter 9 - Lab 2
    //     - Created new report

    Caption = 'Create Seminar Invoices';
    UsageCategory = ReportsAndAnalysis;
    ProcessingOnly = true;

    dataset
    {
        dataitem("Seminar Ledger Entry"; "CSD Seminar Ledger Entry")
        {

            trigger OnAfterGetRecord();
            begin
                //if the customer no has charged, get the new customer rec
                if "Bill-to Customer No." <> Customer."No." then
                    Customer.Get("Bill-to Customer No.");
                //if the new customer is blocked, add it to the error counter
                if Customer.Blocked in [Customer.Blocked::All, Customer.Blocked::Invoice] then begin
                    NoofSalesInvErrors := NoofSalesInvErrors + 1;
                end else begin
                    //if the sales header no is not empty then finalize the previous sales header
                    if "Seminar Ledger Entry"."Bill-to Customer No." <> SalesHeader."Bill-to Customer No." then begin
                        Window.Update(1, "Bill-to Customer No.");
                        if SalesHeader."No." <> '' then
                            FinalizeSalesInvoiceHeader;
                        //then initialize a new sales header
                        InsertSalesInvoiceHeader;
                    end;
                    Window.Update(2, "Seminar Registration No.");//update the dialog
                    //fill the No. depending on the charge 
                    case Type of
                        Type::Resource:
                            begin
                                SalesLine.Type := SalesLine.Type::Resource;
                                case "Charge Type" of
                                    "Charge Type"::Instructor:
                                        SalesLine."No." := "Instructor Resource No.";
                                    "Charge Type"::Room:
                                        SalesLine."No." := "Room Resource No.";
                                    "Charge Type"::Participant:
                                        SalesLine."No." := "Instructor Resource No.";
                                end;
                            end;
                    end;
                    //fill out the primary key from the sales header and set the next line no
                    SalesLine."document Type" := SalesHeader."document Type";
                    SalesLine."document No." := SalesHeader."No.";
                    SalesLine."Line No." := NextLineNo;
                    //validate the No. field with the value set in the previous section
                    SalesLine.Validate("No.");
                    Seminar.Get("Seminar No.");
                    //set the description either to the description from the Seminar Ledger Entry 
                    //or from the seminar name
                    if "Seminar Ledger Entry".Description <> '' then
                        SalesLine.Description := "Seminar Ledger Entry".Description
                    else
                        SalesLine.Description := Seminar.Name;
                    //set the seminar price from the seminar ledger entry
                    SalesLine."Unit Price" := "Unit Price";
                    //test if the currency factor is set if the currency code is filled
                    if SalesHeader."Currency Code" <> '' then begin
                        SalesHeader.TestField("Currency Factor");
                        //calculate the unit price
                        SalesLine."Unit Price" :=
                          ROUND(
                            CurrencyExchRate.ExchangeAmtLCYTofCY(
                            WorkDate, SalesHeader."Currency Code",
                            SalesLine."Unit Price", SalesHeader."Currency Factor"));
                    end;
                    //valdate the quantity from the seminar ledger entry
                    SalesLine.Validate(Quantity, Quantity);
                    //insert the sales line
                    SalesLine.Insert;
                    //update the next line number
                    NextLineNo := NextLineNo + 10000;
                end;
            end;

            trigger OnPostDataItem();
            begin
                //close the dialog and give a message if there is nothing to post
                Window.Close;
                if SalesHeader."No." = '' then begin
                    Message(Text007);
                end else begin
                    //finalize the sales invoice header and give a message to user
                    FinalizeSalesInvoiceHeader;
                    if NoofSalesInvErrors = 0 then
                        Message(
                          Text005,
                          NoofSalesInv)
                    else
                        Message(
                          Text006,
                          NoofSalesInvErrors)
                end;
            end;

            trigger OnPreDataItem();
            //throw an error if the posting date data or document date data is empty
            begin
                if PostingDateReq = 0D then
                    ERROR(Text000);
                if docDateReq = 0D then
                    ERROR(Text001);

                Window.Open(
                  Text002 +
                  Text003 +
                  Text004);
            end;
        }
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(PostingDateReq; PostingDateReq)
                    {
                        Caption = 'Posting Date';
                    }
                    field(docDateReq; docDateReq)
                    {
                        Caption = 'Document Date';
                    }
                    field(CalcInvoiceDiscount; CalcInvoiceDiscount)
                    {
                        Caption = 'Calc. Inv. Discount';
                    }
                    field(PostInvoices; PostInvoices)
                    {
                        Caption = 'Post Invoices';
                    }
                }
            }
        }

        actions
        {
        }

        trigger OnOpenPage();
        begin
            if PostingDateReq = 0D then
                PostingDateReq := WorkDate;//set the posting date to be the working date
            if docDateReq = 0D then
                docDateReq := WorkDate;//set the document date to be the working date
            SalesSetup.Get;//get the sales set up record
            CalcInvoiceDiscount := SalesSetup."Calc. Inv. Discount";//set the calculate invoice discount from the sales setup
        end;
    }

    labels
    {
    }

    var
        CurrencyExchRate: Record "Currency Exchange Rate";
        Customer: Record Customer;
        GLSetup: Record "General Ledger Setup";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesSetup: Record "Sales & Receivables Setup";
        SalesCalcDiscount: Codeunit "Sales-Calc. Discount";
        SalesPost: Codeunit "Sales-Post";
        CalcInvoiceDiscount: Boolean;
        PostInvoices: Boolean;
        NextLineNo: Integer;
        NoofSalesInvErrors: Integer;
        NoofSalesInv: Integer;
        PostingDateReq: Date;
        docDateReq: Date;
        Window: Dialog;
        Seminar: Record "CSD Seminar";
        Text000: Label 'Please enter the posting date.';
        Text001: Label 'Please enter the document date.';
        Text002: Label 'Creating Seminar Invoices...\\';
        Text003: Label 'Customer No.      #1##########\';
        Text004: Label 'Registration No.   #2##########\';
        Text005: Label 'The number of invoice(s) created is %1.';
        Text006: Label 'not all the invoices were posted. A total of %1 invoices were not posted.';
        Text007: Label 'There is nothing to invoice.';


    local procedure FinalizeSalesInvoiceHeader();
    begin
        with SalesHeader do begin
            if CalcInvoiceDiscount then
                SalesCalcDiscount.Run(SalesLine);
            Get("document Type", "No.");
            Commit;
            Clear(SalesCalcDiscount);
            Clear(SalesPost);
            NoofSalesInv := NoofSalesInv + 1;
            if PostInvoices then begin
                Clear(SalesPost);
                if not SalesPost.Run(SalesHeader) then
                    NoofSalesInvErrors := NoofSalesInvErrors + 1;
            end;
        end;
    end;

    local procedure InsertSalesInvoiceHeader();
    begin
        with SalesHeader do begin
            //initialize the sales header value
            Init;
            //set the document type to select the correct number series
            "document Type" := "document Type"::Invoice;
            "No." := '';
            //insert true to fetch the next number from the number series
            Insert(true);
            //validate the fields
            Validate("Sell-to Customer No.", "Seminar Ledger Entry"."Bill-to Customer No.");
            if "Bill-to Customer No." <> "Sell-to Customer No." then
                Validate("Bill-to Customer No.", "Seminar Ledger Entry"."Bill-to Customer No.");
            Validate("Posting Date", PostingDateReq);
            Validate("document Date", docDateReq);
            Validate("Currency Code", '');
            //modify and commit the record
            Modify;
            Commit;
            //set the next line number for the lines
            NextLineNo := 10000;
        end;
    end;
}

