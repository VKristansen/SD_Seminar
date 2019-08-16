page 50106 "CSD Seminar Comment Sheet"
//CSD 1.00 16/8/2019 Lab 5.3
//Create the Seminar Comment Sheet Page
{
    PageType = List;
    SourceTable = "CSD Seminar Comment Line";
    Caption = 'Seminar Comment Sheet';

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(Date; Date)
                {

                }
                field(Code; Code)
                {
                    Visible = false;
                }
                field(Comment; Comment)
                {

                }
            }
        }
    }

}