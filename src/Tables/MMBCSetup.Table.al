table 59202 "MMBC Setup"
{
    Caption = 'MMBC Setup';
    DataClassification = SystemMetadata;
    LookupPageID = "MMBC Setup";

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
        }
        field(2; "Request Nos."; Code[20])
        {
            Caption = 'Request Nos.';
            TableRelation = "No. Series";
        }
        field(3; "Extension Document Nos."; Code[20])
        {
            Caption = 'Extension Document Nos.';
            TableRelation = "No. Series";
        }
        field(4; "Email Scenario"; Enum "Email Scenario")
        {
            Caption = 'Email Scenario';
        }
        field(5; "Default Warning Period (Days)"; Integer)
        {
            Caption = 'Default Warning Period (Days)';
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }
}
