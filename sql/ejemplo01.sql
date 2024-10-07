CREATE TABLE IF NOT EXISTS words (
    id SERIAL PRIMARY KEY,
    word TEXT,
    count INTEGER
);

CREATE OR REPLACE PROCEDURE contar_palabras(star_value TEXT)
LANGUAGE plpgsql
AS $$
DECLARE
    word_lower TEXT;  -- Variable para la cadena en minúsculas
    words_arr TEXT[];  -- Array que contendrá las palabras
    str_word TEXT;     -- Variable para iterar sobre cada palabra
    word_count INT;    -- Variable para almacenar el conteo de la palabra
BEGIN
    word_lower = regexp_replace(lower(star_value), '[^a-z ]', '', 'g');

    words_arr = string_to_array(word_lower, ' ');

    TRUNCATE TABLE words;

    FOREACH str_word IN ARRAY words_arr LOOP
        -- Verificar si la palabra ya existe en la tabla 'words'
        SELECT count INTO word_count FROM words WHERE word = str_word;

        -- Si existe, actualizamos el contador
        IF word_count IS NOT NULL THEN
            UPDATE words 
            SET count = count + 1
            WHERE word = str_word;
        ELSE
            -- Si no existe, la insertamos con un contador de 1
            INSERT INTO words (word, count)
            VALUES (str_word, 1);
        END IF;
    END LOOP;
END;
$$;

CALL contar_palabras('hello world, big world');
SELECT * FROM words;

DROP TABLE words;
DROP PROCEDURE contar_palabras;