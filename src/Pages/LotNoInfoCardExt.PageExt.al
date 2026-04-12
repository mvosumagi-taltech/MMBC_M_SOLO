pageextension 59221 "Lot No. Info Card Ext" extends "Lot No. Information Card"
{
    actions
    {
        addlast(processing)
        {
            group(ShelfLifeExtension)
            {
                Caption = 'Säilivusaja pikendamine';

                action(CreateExtensionRequest)
                {
                    Caption = 'Loo pikendamispäring';
                    ApplicationArea = All;
                    ToolTip = 'Loob uue säilivusaja pikendamispäringu selle partii jaoks.';
                    Image = NewDocument;

                    trigger OnAction()
                    var
                        Item: Record Item;
                    begin
                        Item.Get(Rec."Item No.");
                        if not Item."Shelf Life Extension Allowed" then
                            Error(ExtensionNotAllowedErr);

                        // TODO: #25 - Ava pikendamispäringu kaart eeltäidetuna
                        // ExtReq.Init();
                        // ExtReq."Item No." := Rec."Item No.";
                        // ExtReq."Lot No." := Rec."Lot No.";
                        // Page.Run(Page::"Extension Request Card", ExtReq);
                    end;
                }
            }
        }
    }

    var
        ExtensionNotAllowedErr: Label 'Selle kauba säilivusaja pikendamine ei ole lubatud.';
}
