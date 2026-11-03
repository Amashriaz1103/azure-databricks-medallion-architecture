
{{
    config(
        materialized = "table",
        file_format = "delta",
        schema = "gold"
    )
}}

with salesorderdetail_snapshot as (

    select
        SalesOrderID,
        SalesOrderDetailID,
        OrderQty,
        ProductID,
        UnitPrice,
        UnitPriceDiscount,
        LineTotal
    from {{ ref("salesorderdetail_snapshot") }}
    where dbt_valid_to is null

),

product_snapshot as (

    select
        ProductID,
        Name,
        ProductNumber,
        Color,
        StandardCost,
        ListPrice,
        Size,
        Weight,
        SellStartDate,
        SellEndDate,
        DiscontinuedDate,
        ThumbnailPhotoFileName
    from {{ ref("product_snapshot") }}
    where dbt_valid_to is null

),

salesorderheader_snapshot as (

    select
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
    from {{ ref("salesorderheader_snapshot") }}
    where dbt_valid_to is null

),

transformed as (

    select
        sod.SalesOrderID,
        sod.SalesOrderDetailID,
        sod.OrderQty,
        sod.ProductID,
        sod.UnitPrice,
        sod.UnitPriceDiscount,
        sod.LineTotal,

        p.Name,
        p.ProductNumber,
        p.Color,
        p.StandardCost,
        p.ListPrice,
        p.Size,
        p.Weight,
        p.SellStartDate,
        p.SellEndDate,
        p.DiscontinuedDate,
        p.ThumbnailPhotoFileName,

        soh.RevisionNumber,
        soh.OrderDate,
        soh.DueDate,
        soh.ShipDate,
        soh.Status,
        soh.OnlineOrderFlag,
        soh.SalesOrderNumber,
        soh.PurchaseOrderNumber,
        soh.AccountNumber,
        soh.CustomerID,
        soh.ShipToAddressID,
        soh.BillToAddressID,
        soh.ShipMethod,
        soh.CreditCardApprovalCode,
        soh.SubTotal,
        soh.TaxAmt,
        soh.Freight,
        soh.TotalDue,
        soh.Comment

    from salesorderdetail_snapshot sod

    left join product_snapshot p
        on sod.ProductID = p.ProductID

    left join salesorderheader_snapshot soh
        on sod.SalesOrderID = soh.SalesOrderID

)

select *
from transformed
