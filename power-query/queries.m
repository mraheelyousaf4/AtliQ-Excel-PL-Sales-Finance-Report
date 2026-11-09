// Power Query (M) code exported from p_and_l_add_quarters.xlsx
// Data > Queries & Connections. Local folder paths are from the author's machine;
// change the folder path in 'sales ref' and the file paths in 'finance ref' and 'ns_targets_2021' before refreshing.

section Section1;

shared #"sales ref" = let
    Source = Folder.Files("C:\Users\rahee\OneDrive\Desktop\Excel P&L\Sales")
in
    Source;

shared dim_customer = let
    Source = #"sales ref",
    #"C:\Users\rahee\OneDrive\Desktop\Excel P&L\Sales\_dim_customer csv" = Source{[#"Folder Path"="C:\Users\rahee\OneDrive\Desktop\Excel P&L\Sales\",Name="dim_customer.csv"]}[Content],
    #"Imported CSV" = Csv.Document(#"C:\Users\rahee\OneDrive\Desktop\Excel P&L\Sales\_dim_customer csv",[Delimiter=",", Columns=5, Encoding=1252, QuoteStyle=QuoteStyle.None]),
    #"Promoted Headers" = Table.PromoteHeaders(#"Imported CSV", [PromoteAllScalars=true]),
    #"Changed Type" = Table.TransformColumnTypes(#"Promoted Headers",{{"customer_code", Int64.Type}, {"customer", type text}, {"market", type text}, {"platform", type text}, {"channel", type text}}),
    #"Replaced Value" = Table.ReplaceValue(#"Changed Type","Atliq Exclusive","AtliQ Exclusive",Replacer.ReplaceText,{"customer"}),
    #"Replaced Value1" = Table.ReplaceValue(#"Replaced Value","AltiQ Exclusive","AtliQ Exclusive",Replacer.ReplaceText,{"customer"})
in
    #"Replaced Value1";

shared dim_market = let
    Source = #"sales ref",
    #"C:\Users\user\Desktop\Codebasics Excel Course\Sales\Sales\_dim_market csv" = Source{[#"Folder Path"="C:\Users\rahee\OneDrive\Desktop\Excel P&L\Sales\",Name="dim_market.csv"]}[Content],
    #"Imported CSV" = Csv.Document(#"C:\Users\user\Desktop\Codebasics Excel Course\Sales\Sales\_dim_market csv",[Delimiter=",", Columns=3, Encoding=1252, QuoteStyle=QuoteStyle.None]),
    #"Changed Type" = Table.TransformColumnTypes(#"Imported CSV",{{"Column1", type text}, {"Column2", type text}, {"Column3", type text}}),
    #"Promoted Headers" = Table.PromoteHeaders(#"Changed Type", [PromoteAllScalars=true]),
    #"Changed Type1" = Table.TransformColumnTypes(#"Promoted Headers",{{"market", type text}, {"sub_zone", type text}, {"region", type text}}),
    #"Replaced NAN in subzone" = Table.ReplaceValue(#"Changed Type1","nan","NA",Replacer.ReplaceText,{"sub_zone"}),
    #"Replaced NAN in region" = Table.ReplaceValue(#"Replaced NAN in subzone","nan","NA",Replacer.ReplaceText,{"region"})
in
    #"Replaced NAN in region";

shared dim_product = let
    Source = #"sales ref",
    #"C:\Users\user\Desktop\Codebasics Excel Course\Sales\Sales\_dim_product csv" = Source{[#"Folder Path"="C:\Users\rahee\OneDrive\Desktop\Excel P&L\Sales\",Name="dim_product.csv"]}[Content],
    #"Imported CSV" = Csv.Document(#"C:\Users\user\Desktop\Codebasics Excel Course\Sales\Sales\_dim_product csv",[Delimiter=",", Columns=6, Encoding=1252, QuoteStyle=QuoteStyle.None]),
    #"Changed Type" = Table.TransformColumnTypes(#"Imported CSV",{{"Column1", type text}, {"Column2", type text}, {"Column3", type text}, {"Column4", type text}, {"Column5", type text}, {"Column6", type text}}),
    #"Promoted Headers" = Table.PromoteHeaders(#"Changed Type", [PromoteAllScalars=true]),
    #"Changed Type1" = Table.TransformColumnTypes(#"Promoted Headers",{{"product_code", type text}, {"division", type text}, {"segment", type text}, {"category", type text}, {"product", type text}, {"variant", type text}})
in
    #"Changed Type1";

shared fact_sales_monthly_with_cost = let
    Source = #"finance ref",
    #"Changed Type" = Table.TransformColumnTypes(Source,{{"date", type datetime}, {"product_code", type text}, {"customer_code", Int64.Type}, {"Qty", Int64.Type}, {"net_sales_amount", type number}}),
    #"Calculated Absolute Value" = Table.TransformColumns(#"Changed Type",{{"Qty", Number.Abs, Int64.Type}}),
    #"Sorted Rows" = Table.Sort(#"Calculated Absolute Value",{{"date", Order.Descending}})
in
    #"Sorted Rows";

shared dim_date = let
    Source = {Number.From(#date(2018,9,1))..Number.From(#date(2021,8,1))},
    #"Converted to Table" = Table.FromList(Source, Splitter.SplitByNothing(), null, null, ExtraValues.Error),
    #"Renamed Columns" = Table.RenameColumns(#"Converted to Table",{{"Column1", "date"}}),
    #"Changed Type" = Table.TransformColumnTypes(#"Renamed Columns",{{"date", type date}}),
    #"Inserted Start of Month" = Table.AddColumn(#"Changed Type", "month", each Date.StartOfMonth([date]), type date),
    #"Inserted Year" = Table.AddColumn(#"Inserted Start of Month", "year", each Date.Year([month]), Int64.Type),
    #"Changed Type1" = Table.TransformColumnTypes(#"Inserted Year",{{"year", type text}}),
    #"Added Custom" = Table.AddColumn(#"Changed Type1", "FY Month", each Date.AddMonths([month],4)),
    #"Added Custom1" = Table.AddColumn(#"Added Custom", "FY", each Date.Year([FY Month])),
    #"Removed Columns" = Table.RemoveColumns(#"Added Custom1",{"year", "FY Month"}),
    #"Changed Type2" = Table.TransformColumnTypes(#"Removed Columns",{{"FY", type text}})
in
    #"Changed Type2";

shared ns_targets_2021 = let
    Source = Csv.Document(File.Contents("C:\Users\rahee\OneDrive\Desktop\Excel P&L\Sales\ns_targets_2021.csv"),[Delimiter=",", Columns=3, Encoding=1252, QuoteStyle=QuoteStyle.None]),
    #"Promoted Headers" = Table.PromoteHeaders(Source, [PromoteAllScalars=true]),
    #"Changed Type" = Table.TransformColumnTypes(#"Promoted Headers",{{"market", type text}, {"date", type date}, {"ns_target", type number}})
in
    #"Changed Type";

shared #"finance ref" = let
    Source = Csv.Document(File.Contents("C:\Users\rahee\OneDrive\Desktop\Excel P&L\Sales\fact_sales_monthly_with_cost.csv"),[Delimiter=",", Columns=7, Encoding=65001, QuoteStyle=QuoteStyle.None]),
    #"Promoted Headers" = Table.PromoteHeaders(Source, [PromoteAllScalars=true]),
    #"Changed Type" = Table.TransformColumnTypes(#"Promoted Headers",{{"date", type date}, {"product_code", type text}, {"customer_code", Int64.Type}, {"Qty", Int64.Type}, {"net_sales_amount", type number}, {"freight_cost", type number}, {"manufacturing_cost", type number}})
in
    #"Changed Type";