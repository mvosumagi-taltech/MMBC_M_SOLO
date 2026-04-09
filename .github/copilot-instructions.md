# MMBC_M_SOLO AI Agent Guidelines

## Project Overview

MMBC_M_SOLO is a Business Central extension (version 27.0, AL runtime 16.0) for managing raw material shelf life extension requests **with the SLE Document module** (full workflow: request → vendor approval → extension document → posting → reclassification). The project uses object IDs in range 59200–59249 and deploys to an on-premises Business Central instance.

> **Note for GitHub Copilot:** `.claude/` directory and `CLAUDE.md` files are configuration for Claude Code CLI only. All project coding guidelines are in this file.

## Code Style

### AL Language Conventions
- **PascalCase** for object names and procedures; **camelCase** for local variables
- **Captions**: always provide human-readable captions; place `Caption` as the **first property** in every object and field
- **Comments**: inline comments for complex logic; no file-level or object-level summary comments
- **NoImplicitWith**: always use explicit `Rec.` prefix in page triggers and table procedures
- **Error/Message/Confirm texts**: always define as Labels in `var` section. Never hardcode in `Error()`, `Message()`, `Confirm()`, `StrSubstNo()`. Suffix: `Err` errors, `Msg` messages, `Qst` questions
- **Field assignment in OnValidate**: always `Validate("Field", value)` — never direct `:=`
- **TestStatusOpen()**: every `OnValidate` trigger in `ExtensionRequest` table must call this as the very first line
- **ApplicationArea**: define at **page level only** (`ApplicationArea = All`) — do not repeat on individual fields
- **ToolTips**: required on every page field and action
- **LookupPageID / DrillDownPageID**: define on table, never on page
- **DataCaptionFields**: set on table for better record display
- **Codeunits**: no `Caption` property allowed (AL0124 error)
- **Do not use `Description` property on fields** — use `Caption` only

### Data Classification
- `DataClassification = SystemMetadata` — setup/config tables (`MMBCSetup`)
- `DataClassification = CustomerContent` — business data tables (`ExtensionRequest`, `ExtensionDocument`, `PostedExtensionDocument`, `AuditLog`)
- Set at **table level** for new tables; at **field level** for table extensions

### File Organization
One AL object per file. Pattern: `ObjectName.ObjectType.al`

```
src/
├── Enums/           RequestStatus.Enum.al, ExtDocumentStatus.Enum.al
├── Tables/          MMBCSetup.Table.al, ExtensionRequest.Table.al,
│                    ExtensionDocument.Table.al, PostedExtensionDocument.Table.al,
│                    AuditLog.Table.al, ItemExtension.TableExt.al,
│                    LotNoInfoExtension.TableExt.al
├── Pages/           MMBCSetup.Page.al, ExtensionRequests.Page.al,
│                    ExtensionRequestCard.Page.al, ExtensionDocuments.Page.al,
│                    ExtensionDocumentCard.Page.al, PostedExtensionDocuments.Page.al,
│                    PostedExtensionDocumentCard.Page.al, ExpiringLots.Page.al,
│                    AuditLog.Page.al, LotNoInfoCardExt.PageExt.al,
│                    RoleCenterExt.PageExt.al
├── Codeunits/       PostExtDocument.Codeunit.al, EmailManagement.Codeunit.al,
│                    Subscribers.Codeunit.al
├── Reports/         ExtRequestPrint.Report.al, ExtDocumentPrint.Report.al,
│                    LotLabel.Report.al
└── PermissionSets/  MMBCUser.PermissionSet.al, MMBCAdmin.PermissionSet.al
```

## Architecture

### Object ID Map (59200–59249)

| ID | Type | Name |
|---|---|---|
| 59200 | Enum | Request Status |
| 59201 | Enum | Ext. Document Status |
| 59202 | Table | MMBC Setup |
| 59203 | Table | Extension Request |
| 59204 | Table | Extension Document |
| 59205 | Table | Posted Extension Document |
| 59206 | Page | MMBC Setup |
| 59207 | Page | Extension Requests |
| 59208 | Page | Extension Request Card |
| 59209 | Page | Extension Documents |
| 59210 | Page | Extension Document Card |
| 59211 | Page | Posted Extension Documents |
| 59212 | Page | Posted Extension Document Card |
| 59213 | Page | Expiring Lots |
| 59214 | Codeunit | Post Ext. Document |
| 59215 | Codeunit | Email Management |
| 59216 | Report | Ext. Request Print |
| 59217 | Report | Ext. Document Print |
| 59218 | Codeunit | Subscribers |
| 59219 | Report | Lot Label |
| 59220 | TableExt | Item Extension |
| 59221 | PageExt | Lot No. Info Card Ext |
| 59222 | PageExt | Role Center Ext |
| 59223 | Table | MMBC Audit Log |
| 59224 | Page | MMBC Audit Log |
| 59225 | TableExt | Lot No. Info Extension |
| 59226 | Codeunit | MMBC Demo Setup |
| 59227 | Table | MMBC Cue |
| 59228 | Page | MMBC Activities |

### Core Workflow

```
Extension Request (Pending → Sent → Approved/Rejected)
       ↓ CreateExtensionDocument()
Extension Document (Open)
       ↓ PostExtDocument codeunit
Posted Extension Document (read-only) + Lot Reclassification
```

### Key Patterns

#### No. Series (BC 27 — use NoSeries codeunit, not obsolete NoSeriesMgt)
```al
// In table OnInsert trigger (not in Subscribers):
var
    NoSeries: Codeunit "No. Series";
    MMBCSetup: Record "MMBC Setup";
begin
    MMBCSetup.Get();
    Rec."No." := NoSeries.GetNextNo(MMBCSetup."Extension Request Nos.");
end;
```

#### Setup Table Pattern
```al
trigger OnOpenPage()
begin
    Rec.Reset();
    if not Rec.Get() then begin
        Rec.Init();
        Rec.Insert();
    end;
end;
```

#### Status Guard (every OnValidate in ExtensionRequest)
```al
trigger OnValidate()
begin
    TestStatusOpen();  // ALWAYS first
    ...
end;
```

#### Lot Number Versioning
```
LOT001 → LOT001-V2 (first extension)
LOT001-V2 → LOT001-V3 (second extension)
```
`GenerateNewLotNo()` in `Post Ext. Document` codeunit. Must include conflict check.

#### Email Pattern (BC 27)
```al
[TryFunction]
procedure SendRequestEmail(ExtReq: Record "Extension Request")
var
    Email: Codeunit Email;
    EmailMessage: Codeunit "Email Message";
begin
    EmailMessage.Create(ExtReq."Vendor Email", Subject, Body, true);
    Email.Send(EmailMessage, Enum::"Email Scenario"::Default);
end;
```

#### PermissionSet Pattern
Both `tabledata` AND `table` for each table:
```al
Permissions = tabledata "Extension Request" = RIMD,
              table "Extension Request" = X,
              page "Extension Requests" = X,
              codeunit "Post Ext. Document" = X;
```

#### Post Ext. Document Pattern (BC standard posting muster)
```al
// Post() → RunCheck() → RunPost() → FinalizePost()
// RunPost: Item Reclass. Journal write + post + new Lot No. Info
// FinalizePost: create Posted record, delete open document, Audit Log entry
// Navigate after posting: CurrPage.Close(); Page.Run(Page::"Posted Extension Documents")
```

### Standard BC Table References
- **Table 27 Item** — Blocked check, Item Description auto-fill
- **Table 23 Vendor** — Vendor Name auto-fill
- **Table 32 Item Ledger Entry** — remaining quantity, location code
- **Table 6505 Lot No. Information** — current expiration date
- **Table 83 Item Journal Line** — Item Reclassification Journal (Template: RECLASS)
- **Table 308 No. Series** — number series
- **Page 1173 Document Attachment Factbox** — attachments (SubPageLink by table ID)

## Build and Test

### Environment
- **IDE**: VS Code with AL Language Extension
- **Server**: `https://itb2204.bc365.eu/` / Instance: `BC` / Tenant: `MMBC`
- **Authentication**: UserPassword
- **Schema update**: `ForceSync`

### Commands
- **Build**: `Ctrl+Shift+B`
- **Publish & Debug**: `F5`
- **Download Symbols**: `Ctrl+Shift+P` → `AL: Download Symbols`

## Security

### PermissionSets
- `MMBC User` — RIMD on ExtensionRequest + ExtensionDocument, RIM on PostedExtensionDocument + AuditLog, X on pages and codeunits
- `MMBC Admin` — all User permissions + RIMD on MMBCSetup
- AuditLog: no Delete permission for User role (RIM only)
- Create PermissionSets **last** — after all tables, pages, codeunits exist

### Data Protection
- All business data: `DataClassification = CustomerContent`
- All object IDs within 59200–59249
