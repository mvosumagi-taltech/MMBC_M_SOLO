tableextension 59220 "Item Extension" extends Item
{
    fields
    {
        field(59220; "Shelf Life Extension Allowed"; Boolean)
        {
            Caption = 'Shelf Life Extension Allowed';
            DataClassification = CustomerContent;
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
