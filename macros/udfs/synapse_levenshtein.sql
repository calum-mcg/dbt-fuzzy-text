{% macro synapse_create_levenshtein() %}
-- =============================================
-- Computes and returns the Levenshtein edit distance between two strings, i.e. the
-- number of insertion, deletion, and sustitution edits required to transform one
-- string to the other, or NULL if @max is exceeded. Comparisons use the case-
-- sensitivity configured in SQL Server (case-insensitive by default).
-- http://blog.softwx.net/2014/12/optimizing-levenshtein-algorithm-in-tsql.html
-- 
-- Based on Sten Hjelmqvist's "Fast, memory efficient" algorithm, described
-- at http://www.codeproject.com/Articles/13525/Fast-memory-efficient-Levenshtein-algorithm,
-- with some additional optimizations.
-- =============================================
CREATE FUNCTION {{target.schema}}.levenshtein(
    @s nvarchar(4000)
  , @t nvarchar(4000)
  , @max int = 10
)
RETURNS int
WITH SCHEMABINDING
AS
BEGIN
    DECLARE @distance int = 0 -- return variable
          , @v0 nvarchar(4000)-- running scratchpad for storing computed distances
          , @start int = 1      -- index (1 based) of first non-matching character between the two string
          , @i int, @j int      -- loop counters: i for s string and j for t string
          , @diag int          -- distance in cell diagonally above and left if we were using an m by n matrix
          , @left int          -- distance in cell to the left if we were using an m by n matrix
          , @sChar nchar      -- character at index i from s string
          , @thisJ int          -- temporary storage of @j to allow SELECT combining
          , @jOffset int      -- offset used to calculate starting value for j loop
          , @jEnd int          -- ending value for j loop (stopping point for processing a column)
          -- get input string lengths including any trailing spaces (which SQL Server would otherwise ignore)
          , @sLen int = datalength(@s) / datalength(left(left(@s, 1) + '.', 1))    -- length of smaller string
          , @tLen int = datalength(@t) / datalength(left(left(@t, 1) + '.', 1))    -- length of larger string
          , @lenDiff int      -- difference in length between the two strings
    -- if strings of different lengths, ensure shorter string is in s. This can result in a little
    -- faster speed by spending more time spinning just the inner loop during the main processing.
    
    IF (@sLen > @tLen) BEGIN
        SET @v0 = @s
        SET @i = @sLen -- temporarily use v0 for swap
        SET @s = @t
        SET @sLen = @tLen
        SET @t = @v0
        SET @tLen = @i
    END
    SET @max = ISNULL(@max, @tLen)
    SET @lenDiff = @tLen - @sLen
    IF @lenDiff > @max RETURN NULL

    -- suffix common to both strings can be ignored
    WHILE(@sLen > 0 AND SUBSTRING(@s, @sLen, 1) = SUBSTRING(@t, @tLen, 1)) BEGIN
        SET @sLen = @sLen - 1
        SET @tLen = @tLen - 1
    END

    IF (@sLen = 0) RETURN @tLen

    -- prefix common to both strings can be ignored
    WHILE (@start < @sLen AND SUBSTRING(@s, @start, 1) = SUBSTRING(@t, @start, 1)) BEGIN
        SET @start = @start + 1
    END
    IF (@start > 1) BEGIN
        SET @sLen = @sLen - (@start - 1)
        SET @tLen = @tLen - (@start - 1)

        -- if all of shorter string matches prefix and/or suffix of longer string, then
        -- edit distance is just the delete of additional characters present in longer string
        IF (@sLen <= 0) RETURN @tLen

        SET @s = SUBSTRING(@s, @start, @sLen)
        SET @t = SUBSTRING(@t, @start, @tLen)
    END

    -- initialize v0 array of distances
    SET @v0 = ''
    SET @j = 1
    WHILE (@j <= @tLen) BEGIN
        SET @v0 = @v0 + NCHAR(CASE WHEN @j > @max THEN @max ELSE @j END)
        SET @j = @j + 1
    END

    SET @jOffset = @max - @lenDiff
    SET @i = 1
    WHILE (@i <= @sLen) BEGIN
        SET @distance = @i
            SET @diag = @i - 1
            SET @sChar = SUBSTRING(@s, @i, 1)
             -- no need to look beyond window of upper left diagonal (@i) + @max cells
             -- and the lower right diagonal (@i - @lenDiff) - @max cells
            SET @j = CASE WHEN @i <= @jOffset THEN 1 ELSE @i - @jOffset END
            SET @jEnd = CASE WHEN @i + @max >= @tLen THEN @tLen ELSE @i + @max END
        WHILE (@j <= @jEnd) BEGIN
            -- at this point, @distance holds the previous value (the cell above if we were using an m by n matrix)
            SET @left = UNICODE(SUBSTRING(@v0, @j, 1))
              SET @thisJ = @j
            SET @distance = 
                CASE WHEN (@sChar = SUBSTRING(@t, @j, 1)) THEN @diag                    --match, no change
                     ELSE 1 + CASE WHEN @diag < @left AND @diag < @distance THEN @diag    --substitution
                                   WHEN @left < @distance THEN @left                    -- insertion
                                   ELSE @distance                                        -- deletion
                                END    END
            SET @v0 = STUFF(@v0, @thisJ, 1, NCHAR(@distance))
              SET @diag = @left
              SET @j = case when (@distance > @max) AND (@thisJ = @i + @lenDiff) then @jEnd + 2 else @thisJ + 1 end
        END
        SET @i = CASE WHEN @j > @jEnd + 1 THEN @sLen + 1 ELSE @i + 1 END
    END
    RETURN CASE WHEN @distance <= @max THEN @distance ELSE NULL END
END;
{% endmacro %}