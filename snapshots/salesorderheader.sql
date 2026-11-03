{% snapshot salesorderheader_snapshot %}

{{
    config(
        file_format = "delta",
        target_schema = "snapshots_silver",
        location_root = "abfss://silver@medallionstorageaccount.dfs.core.windows.net/salesorderheader",
        invalidate_hard_deletes = True,
        unique_key = "SalesOrderID",
        strategy = "check",
        check_cols = "all"
    )
}}

with salesorderheader_snapshot as (
    SELECT
        SalesOrderID,
        RevisionNumber,
        OrderDate,
        DueDate,
        ShipDate,
        Status,
        OnlineOrderFlag,
        SalesOrderNumber,
        PurchaseOrderNumber,
        AccountNumber,
        CustomerID,
        ShipToAddressID,
        BillToAddressID,
        ShipMethod,
        CreditCardApprovalCode,
        SubTotal,
        TaxAmt,
        Freight,
        TotalDue,
        Comment
    FROM {{ source('saleslt', 'salesorderheader') }}
)

select * from salesorderheader_snapshot

{% endsnapshot %}