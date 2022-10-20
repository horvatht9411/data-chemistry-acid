/**
 * Normalize the database
 *
 * Create new tables and define their relationships based on the schema in `normalization.png`
 */
DROP TABLE IF EXISTS gender;
CREATE TABLE gender
(
    id SERIAL PRIMARY KEY,
    name CHAR(1) NOT NULL
);

DROP TABLE IF EXISTS race;
CREATE TABLE race
(
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL
);

DROP TABLE IF EXISTS category;
CREATE TABLE category
(
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL
);

DROP TABLE IF EXISTS tolkien_character;
CREATE TABLE tolkien_character
(
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    gender_id SERIAL NOT NULL,
    race_id SERIAL NOT NULL,
    category_id SERIAL NOT NULL,
    CONSTRAINT fk_tolkien_character_gender_id FOREIGN KEY(gender_id) REFERENCES gender(id),
    CONSTRAINT fk_tolkien_character_race_id FOREIGN KEY(race_id) REFERENCES race(id),
    CONSTRAINT fk_tolkien_character_category_id FOREIGN KEY(category_id) REFERENCES category(id)
);

/**
 * Populate the new tables
 *
 * Populate the new tables with data from the `middle_earth_character` table.
 * Use transaction(s).
 */
BEGIN;
SAVEPOINT before_insert;

INSERT INTO gender (name)
(SELECT DISTINCT gender FROM middle_earth_character);

INSERT INTO race (name)
(SELECT DISTINCT race FROM middle_earth_character);

INSERT INTO category (name)
(SELECT DISTINCT category FROM middle_earth_character);

INSERT INTO tolkien_character (id, name, gender_id, race_id, category_id)
(
    SELECT
        middle_earth_character.id,
        middle_earth_character.name,
        gender.id AS gender_id,
        race.id AS race_id,
        category.id AS category_id
    FROM
        middle_earth_character
    INNER JOIN
        gender ON gender.name = middle_earth_character.gender
    INNER JOIN
        race ON race.name = middle_earth_character.race
    INNER JOIN
        category ON category.name = middle_earth_character.category
    ORDER BY
        middle_earth_character.id ASC
);

COMMIT;

/**
 * Refactor the database
 *
 * Rename the `middle_earth_character` table to `deprecated_middle_earth_character`.
 * Create a view named `middle_earth_character` with the original structure of the data.
 * Run the query in the `app.pgsql` file and check the results.
 */
ALTER TABLE IF EXISTS middle_earth_character
RENAME TO deprecated_middle_earth_character;

CREATE VIEW middle_earth_character AS
(
    SELECT
        tolkien_character.id,
        tolkien_character.name,
        gender.name AS gender,
        race.name AS race,
        category.name AS category
    FROM
        tolkien_character
    INNER JOIN
        gender ON gender.id = tolkien_character.gender_id
    INNER JOIN
        race ON race.id = tolkien_character.race_id
    INNER JOIN
        category ON category.id = tolkien_character.category_id
    ORDER BY
        tolkien_character.id ASC
);

/**
 * Delete legacy data
 *
 * Delete the `deprecated_middle_earth_character` table.
 */
DROP TABLE IF EXISTS deprecated_middle_earth_character;