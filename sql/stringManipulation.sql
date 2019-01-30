--used to find a specific string between 2 characters (/ and . in this example)
-- replace 'col' with your string (or column)

SELECT 
  SUBSTRING(col, LEN(LEFT(col, CHARINDEX ('/', col))) + 1, 
  LEN(col) - LEN(LEFT(col, CHARINDEX ('/', col))) - LEN(RIGHT(col, LEN(col) - CHARINDEX ('.', col))) - 1);