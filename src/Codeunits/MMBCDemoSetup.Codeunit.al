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
        SetupInventorySetup();
        SetupPostingGroups();
        SetupItemTrackingCode();
        SetupItems();
        SetupCustomers();
        SetupVendor();
        PostItemJournals();
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

    local procedure SetupInventorySetup()
    var
        inventorySetup: Record "Inventory Setup";
    begin
        inventorySetup.Get();
        inventorySetup."Automatic Cost Posting" := false;
        inventorySetup."Expected Cost Posting to G/L" := false;
        inventorySetup.Modify(false);
    end;

    local procedure SetupPostingGroups()
    var
        genProdPostingGroup: Record "Gen. Product Posting Group";
        generalPostingSetup: Record "General Posting Setup";
        inventoryPostingGroup: Record "Inventory Posting Group";
        inventoryPostingSetup: Record "Inventory Posting Setup";
    begin
        if not genProdPostingGroup.Get('MMBC-PROD') then begin
            genProdPostingGroup.Init();
            genProdPostingGroup.Code := 'MMBC-PROD';
            genProdPostingGroup.Description := 'MMBC Raw Materials';
            genProdPostingGroup."Auto Insert Default" := false;
            genProdPostingGroup.Insert(false);
        end;

        if not generalPostingSetup.Get('', 'MMBC-PROD') then begin
            generalPostingSetup.Init();
            generalPostingSetup."Gen. Bus. Posting Group" := '';
            generalPostingSetup."Gen. Prod. Posting Group" := 'MMBC-PROD';
            generalPostingSetup.Insert(false);
        end;

        if not inventoryPostingGroup.Get('MMBC-INV') then begin
            inventoryPostingGroup.Init();
            inventoryPostingGroup.Code := 'MMBC-INV';
            inventoryPostingGroup.Description := 'MMBC Inventory';
            inventoryPostingGroup.Insert(false);
        end;

        if not inventoryPostingSetup.Get('', 'MMBC-INV') then begin
            inventoryPostingSetup.Init();
            inventoryPostingSetup."Location Code" := '';
            inventoryPostingSetup."Invt. Posting Group Code" := 'MMBC-INV';
            inventoryPostingSetup."Inventory Account" := FindInventoryAccount();
            inventoryPostingSetup.Insert(false);
        end;
    end;

    local procedure FindInventoryAccount(): Code[20]
    var
        existingSetup: Record "Inventory Posting Setup";
    begin
        existingSetup.SetFilter("Inventory Account", '<>%1', '');
        if existingSetup.FindFirst() then
            exit(existingSetup."Inventory Account");
        exit('');
    end;

    local procedure SetupItemTrackingCode()
    var
        itemTrackingCode: Record "Item Tracking Code";
    begin
        if not itemTrackingCode.Get('MMBC-LOT') then begin
            itemTrackingCode.Init();
            itemTrackingCode.Code := 'MMBC-LOT';
            itemTrackingCode.Description := 'MMBC Lot Tracking';
            itemTrackingCode.Insert(false);
        end;
        itemTrackingCode."Lot Sales Outbound Tracking" := true;
        itemTrackingCode."Lot Purchase Inbound Tracking" := true;
        itemTrackingCode."Use Expiration Dates" := true;
        itemTrackingCode.Modify(false);
    end;

    local procedure SetupItems()
    var
        item: Record Item;
        unitOfMeasure: Record "Unit of Measure";
    begin
        if not unitOfMeasure.Get('PCS') then begin
            unitOfMeasure.Init();
            unitOfMeasure.Code := 'PCS';
            unitOfMeasure.Description := 'Pieces';
            unitOfMeasure.Insert(false);
        end;

        if not item.Get('MMBC-I001') then begin
            item.Init();
            item."No." := 'MMBC-I001';
            item.Description := 'Piim 3,5%';
            item."Gen. Prod. Posting Group" := 'MMBC-PROD';
            item."Inventory Posting Group" := 'MMBC-INV';
            item."Inventory Value Zero" := true;
            item.Insert(false);
            item.Validate("Base Unit of Measure", 'PCS');
            item.Validate("Item Tracking Code", 'MMBC-LOT');
            item.Modify(false);
        end;

        if not item.Get('MMBC-I002') then begin
            item.Init();
            item."No." := 'MMBC-I002';
            item.Description := 'Jogurt Maasikas';
            item."Gen. Prod. Posting Group" := 'MMBC-PROD';
            item."Inventory Posting Group" := 'MMBC-INV';
            item."Inventory Value Zero" := true;
            item.Insert(false);
            item.Validate("Base Unit of Measure", 'PCS');
            item.Validate("Item Tracking Code", 'MMBC-LOT');
            item.Modify(false);
        end;

        if not item.Get('MMBC-I003') then begin
            item.Init();
            item."No." := 'MMBC-I003';
            item.Description := 'Hapukoor 20%';
            item."Gen. Prod. Posting Group" := 'MMBC-PROD';
            item."Inventory Posting Group" := 'MMBC-INV';
            item."Inventory Value Zero" := true;
            item.Insert(false);
            item.Validate("Base Unit of Measure", 'PCS');
            item.Validate("Item Tracking Code", 'MMBC-LOT');
            item.Modify(false);
        end;
    end;

    local procedure SetupCustomers()
    var
        customer: Record Customer;
    begin
        if not customer.Get('MMBC-C001') then begin
            customer.Init();
            customer."No." := 'MMBC-C001';
            customer.Name := 'RIMI Eesti OÜ';
            customer.Validate("E-Mail", 'ost@rimi.ee');
            customer.Insert(false);
        end;

        if not customer.Get('MMBC-C002') then begin
            customer.Init();
            customer."No." := 'MMBC-C002';
            customer.Name := 'Maxima Eesti OÜ';
            customer.Validate("E-Mail", 'tellimused@maxima.ee');
            customer.Insert(false);
        end;
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

    local procedure PostItemJournals()
    begin
        PostItemJournalLine('MMBC-I001', 'LOT001', 50, WorkDate() + 60);
        PostItemJournalLine('MMBC-I001', 'LOT002', 50, WorkDate() + 10);
        PostItemJournalLine('MMBC-I002', 'LOT010', 50, WorkDate() + 45);
        PostItemJournalLine('MMBC-I003', 'LOT020', 50, WorkDate() + 5);
    end;

    local procedure PostItemJournalLine(itemNo: Code[20]; lotNo: Code[50]; qty: Decimal; expirationDate: Date)
    var
        itemLedgerEntry: Record "Item Ledger Entry";
        itemJournalLine: Record "Item Journal Line";
        itemJnlPostLine: Codeunit "Item Jnl.-Post Line";
    begin
        itemLedgerEntry.SetRange("Item No.", itemNo);
        itemLedgerEntry.SetRange("Lot No.", lotNo);
        if not itemLedgerEntry.IsEmpty() then
            exit;

        itemJournalLine.Init();
        itemJournalLine."Journal Template Name" := '';
        itemJournalLine."Journal Batch Name" := '';
        itemJournalLine."Line No." := 10000;
        itemJournalLine."Entry Type" := itemJournalLine."Entry Type"::"Positive Adjmt.";
        itemJournalLine."Posting Date" := WorkDate();
        itemJournalLine."Document No." := 'MMBC-DEMO';
        itemJournalLine.Validate("Item No.", itemNo);
        itemJournalLine.Validate(Quantity, qty);
        CreateTrackingSpec(itemNo, lotNo, qty, expirationDate, itemJournalLine."Line No.");
        itemJnlPostLine.RunWithCheck(itemJournalLine);
    end;

    local procedure CreateTrackingSpec(itemNo: Code[20]; lotNo: Code[50]; qty: Decimal; expirationDate: Date; lineNo: Integer)
    var
        reservEntry: Record "Reservation Entry";
        nextEntryNo: Integer;
    begin
        reservEntry.LockTable();
        if reservEntry.FindLast() then
            nextEntryNo := reservEntry."Entry No." + 1
        else
            nextEntryNo := 1;

        reservEntry.Init();
        reservEntry."Entry No." := nextEntryNo;
        reservEntry.Positive := true;
        reservEntry."Item No." := itemNo;
        reservEntry."Location Code" := '';
        reservEntry."Quantity (Base)" := qty;
        reservEntry."Qty. to Handle (Base)" := qty;
        reservEntry."Qty. to Invoice (Base)" := qty;
        reservEntry."Reservation Status" := reservEntry."Reservation Status"::Prospect;
        reservEntry."Source Type" := Database::"Item Journal Line";
        reservEntry."Source Subtype" := 2; // Entry Type: Positive Adjmt.
        reservEntry."Source ID" := '';
        reservEntry."Source Batch Name" := '';
        reservEntry."Source Ref. No." := lineNo;
        reservEntry."Lot No." := lotNo;
        reservEntry."Expiration Date" := expirationDate;
        reservEntry."Creation Date" := Today();
        reservEntry."Created By" := UserId();
        reservEntry.Insert();
    end;
}
