Creation of Matview from Jsonb table: 

--Step 1 
    --Execute following script
    -- replace <schema-name > with the actual schema name
    -- replace <table-name > with the actual jsonb table name
    -- replace <col-name> with the actual column name of the jsonb table hwihc holds the jsonb records
SELECT FORMAT(
                $$ SELECT * FROM %I.%I CROSS JOIN LATERAL jsonb_to_record(%I) AS rs(%s); $$,
                '<schema-name>',   
                '<table_name>',   
                '<col-name>',   
                array_to_string
                        (
                            (SELECT ARRAY
                                (
                                    SELECT DISTINCT col 
                                    FROM '<table_name>'   --remove single quotes
                                        CROSS JOIN LATERAL jsonb_object_keys('<col-name>') AS t(col)  --remove single quotes
                                    ORDER BY col
                                )
                            ), ' text , '   
                        ) || ' text' 
            ); 

--Step 2 
    -- Above query result will give you query of the materialized view query
    -- Like below
    --  SELECT * FROM public.asi_jsonb CROSS JOIN LATERAL jsonb_to_record(data) AS rs(expand text , fields text , id text , key text , self text); 
    -- Enclose all reserved keywords column by ""(double quotes)
    --run the below 
CREATE MATERIALIZED VIEW public.'<matview-name>'--remove single quotes
TABLESPACE pg_default
AS
SELECT now() AS last_refresh, 
-- rs.*   in place of SELECT * from the Step 1 query result 
rs.* FROM '<Step 1 query result with Select * removed>'; -- remove single quotes
