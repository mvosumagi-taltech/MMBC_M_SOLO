pageextension 59229 "Item Card Ext." extends "Item Card"
{
    layout
    {
        addlast(content)
        {
            group(ShelfLifeExtension)
            {
                Caption = 'Shelf Life Extension';

                field("Shelf Life Extension Allowed"; Rec."Shelf Life Extension Allowed")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether the shelf life of this item can be extended beyond the standard expiration date.';
                }
                field("Default Warning Period (Days)"; Rec."Default Warning Period (Days)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the default number of days before expiry when a warning is triggered for shelf life extension.';
                }
            }
        }
    }
}
