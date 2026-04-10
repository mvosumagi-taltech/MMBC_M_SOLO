codeunit 59226 "MMBC Demo Setup"
{
    trigger OnRun()
    begin
        RunDemoSetup();
    end;

    procedure RunDemoSetup()
    begin
        SetupNoSeries();
        SetupMMBCSetup();
        SetupVendor();
        SetupItem();
        PostItemJournal();
        Message(SetupCompletedMsg);
    end;

    var
        SetupCompletedMsg: Label 'MMBC demo seadistus on loodud.';

    local procedure SetupNoSeries()
    var
        noSeries: Record "No. Series";
        noSeriesLine: Record "No. Series Line";
    begin
        if not noSeries.Get('MMBC-REQ') then begin
            noSeries.Init();
            noSeries.Code := 'MMBC-REQ';
            noSeries.Description := 'Extension Request Numbers';
            noSeries."Default Nos." := true;
            noSeries.Insert(false);
        end;

        noSeriesLine.Reset();
        noSeriesLine.SetRange("Series Code", 'MMBC-REQ');
        if noSeriesLine.IsEmpty() then begin
            noSeriesLine.Init();
            noSeriesLine."Series Code" := 'MMBC-REQ';
            noSeriesLine."Line No." := 10000;
            noSeriesLine."Starting No." := 'REQ-0001';
            noSeriesLine."Increment-by No." := 1;
            noSeriesLine.Insert(false);
        end;

        if not noSeries.Get('MMBC-DOC') then begin
            noSeries.Init();
            noSeries.Code := 'MMBC-DOC';
            noSeries.Description := 'Extension Document Numbers';
            noSeries."Default Nos." := true;
            noSeries.Insert(false);
        end;

        noSeriesLine.Reset();
        noSeriesLine.SetRange("Series Code", 'MMBC-DOC');
        if noSeriesLine.IsEmpty() then begin
            noSeriesLine.Init();
            noSeriesLine."Series Code" := 'MMBC-DOC';
            noSeriesLine."Line No." := 10000;
            noSeriesLine."Starting No." := 'DOC-0001';
            noSeriesLine."Increment-by No." := 1;
            noSeriesLine.Insert(false);
        end;
    end;

    local procedure SetupMMBCSetup()
    var
        mmBcSetup: Record "MMBC Setup";
    begin
        if not mmBcSetup.Get() then begin
            mmBcSetup.Init();
            mmBcSetup.Insert(false);
        end;
        mmBcSetup."Request Nos." := 'MMBC-REQ';
        mmBcSetup."Extension Document Nos." := 'MMBC-DOC';
        mmBcSetup."Default Warning Period (Days)" := 30;
        mmBcSetup.Modify(false);
    end;

    local procedure SetupVendor()
    var
        vendor: Record Vendor;
    begin
        if vendor.Get('MMBC-V001') then
            exit;
        vendor.Init();
        vendor."No." := 'MMBC-V001';
        vendor.Name := 'MMBC Test Tarnija';
        vendor.Validate("E-Mail", 'tarnija@mmbc-test.ee');
        vendor.Insert(false);
    end;

    local procedure SetupItem()
    var
        itemTrackingCode: Record "Item Tracking Code";
        item: Record Item;
    begin
        if not itemTrackingCode.Get('MMBC-LOT') then begin
            itemTrackingCode.Init();
            itemTrackingCode.Code := 'MMBC-LOT';
            itemTrackingCode.Description := 'MMBC Lot Tracking';
            itemTrackingCode.Insert(false);
        end;

        if item.Get('MMBC-I001') then
            exit;
        item.Init();
        item."No." := 'MMBC-I001';
        item.Description := 'MMBC Test Tooraine';
        item."Item Tracking Code" := 'MMBC-LOT';
        item.Insert(false);
    end;

    local procedure PostItemJournal()
    var
        itemLedgerEntry: Record "Item Ledger Entry";
        itemJournalLine: Record "Item Journal Line";
        itemJnlPostLine: Codeunit "Item Jnl.-Post Line";
    begin
        itemLedgerEntry.SetRange("Item No.", 'MMBC-I001');
        itemLedgerEntry.SetRange("Entry Type", itemLedgerEntry."Entry Type"::"Positive Adjmt.");
        if not itemLedgerEntry.IsEmpty() then
            exit;

        itemJournalLine.Init();
        itemJournalLine."Journal Template Name" := 'ITEM';
        itemJournalLine."Journal Batch Name" := 'DEFAULT';
        itemJournalLine."Line No." := 10000;
        itemJournalLine."Entry Type" := itemJournalLine."Entry Type"::"Positive Adjmt.";
        itemJournalLine."Posting Date" := WorkDate();
        itemJournalLine.Validate("Item No.", 'MMBC-I001');
        itemJournalLine.Validate(Quantity, 100);
        itemJournalLine."Lot No." := 'LOT001';
        itemJnlPostLine.RunWithCheck(itemJournalLine);
    end;
}
