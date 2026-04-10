tableextension 59220 "Item Extension" extends Item
{
    fields
    {
        field(59220; "Shelf Life Extension Allowed"; Boolean)
        {
            Caption = 'Shelf Life Extension Allowed';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if Rec."Shelf Life Extension Allowed" then begin
                    if Rec."Default Warning Period (Days)" = 0 then
                        Rec."Default Warning Period (Days)" := 14;
                end else
                    Rec."Default Warning Period (Days)" := 0;
            end;
        }
        field(59221; "Default Warning Period (Days)"; Integer)
        {
            Caption = 'Default Warning Period (Days)';
            DataClassification = CustomerContent;
            InitValue = 14;
            MinValue = 0;
        }
    }
}
