page 59206 "MMBC Setup"
{
    Caption = 'MMBC Setup';
    PageType = Card;
    SourceTable = "MMBC Setup";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field("Request Nos."; Rec."Request Nos.")
                {
                    ToolTip = 'Pikendamispäringu numbriseeriad.';
                }
                field("Extension Document Nos."; Rec."Extension Document Nos.")
                {
                    ToolTip = 'Pikendamisdokumendi numbriseeriad.';
                }
                field("Email Scenario"; Rec."Email Scenario")
                {
                    ToolTip = 'E-kirja saatmise stsenaarium.';
                }
                field("Default Warning Period (Days)"; Rec."Default Warning Period (Days)")
                {
                    ToolTip = 'Mitu päeva enne aegumist kuvatakse hoiatus aeguvate partiide vaates.';
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;
    end;
}
