page 59228 "MMBC Demo Setup"
{
    Caption = 'MMBC Demo Setup';
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';

                field(InstructionText; instructionText)
                {
                    Caption = 'Instruction';
                    Editable = false;
                    ToolTip = 'Explains what data will be created by the demo setup action.';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(RunDemoSetup)
            {
                Caption = 'Run Demo Setup';
                ApplicationArea = All;
                Image = Setup;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Creates demo number series, setup data, vendor, item, and opening lot quantity.';

                trigger OnAction()
                var
                    mmbcDemoSetup: Codeunit "MMBC Demo Setup";
                begin
                    mmbcDemoSetup.RunDemoSetup();
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        instructionText := InstructionTextLbl;
    end;

    var
        instructionText: Text[250];
        InstructionTextLbl: Label 'Run Demo Setup to create baseline demo data for MMBC development and testing.';
}
