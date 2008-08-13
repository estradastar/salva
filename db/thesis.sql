------------
-- Thesis --
------------
CREATE TABLE thesisstatuses (
    id SERIAL,
    name text NOT NULL,
    moduser_id int4 NULL                    -- Use it to known who
    REFERENCES users(id)            -- has inserted, updated or deleted
    ON UPDATE CASCADE               -- data into or  from this table.
    DEFERRABLE,
    created_on timestamp DEFAULT CURRENT_TIMESTAMP,
    updated_on timestamp DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE (name)
);
COMMENT ON TABLE thesisstatuses IS
        'Estado de avance de la tesis: En proceso, aprobada, publicada, ...';

CREATE TABLE thesismodalities (
    id SERIAL,
    name text NOT NULL,
    moduser_id int4 NULL                    -- Use it to known who
    REFERENCES users(id)            -- has inserted, updated or deleted
    ON UPDATE CASCADE               -- data into or  from this table.
    DEFERRABLE,
    created_on timestamp DEFAULT CURRENT_TIMESTAMP,
    updated_on timestamp DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE (name)
);
COMMENT ON TABLE thesismodalities IS
        'Modalidad del trabajo generado:  Tesis, tesina, informe académico, ...';

CREATE TABLE roleintheses (
    id SERIAL,
    name text NOT NULL,
    moduser_id int4 NULL                    -- Use it to known who
    REFERENCES users(id)            -- has inserted, updated or deleted
    ON UPDATE CASCADE               -- data into or  from this table.
    DEFERRABLE,
    created_on timestamp DEFAULT CURRENT_TIMESTAMP,
    updated_on timestamp DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE (name)
);
COMMENT ON TABLE roleintheses IS
        'Roles en una tesis:
        - Rol del usuario en la tesis: Director, tutor o asesor, ...
        - Se considera participación comités tutorales cuando
        el usuario NO es director de tesis. Por ejemplo:
        un comité tutoral puede estar integrado po el director
        de tesis y dos Asesores.';

CREATE TABLE theses (
        id SERIAL NOT NULL,
        title text NOT NULL,
        authors text NOT NULL,
        institutioncareer_id int4 NOT NULL
            REFERENCES institutioncareers(id)
            ON UPDATE CASCADE
            DEFERRABLE,
        thesisstatus_id integer NOT NULL
            REFERENCES thesisstatuses(id)
            ON UPDATE CASCADE
            DEFERRABLE,
        thesismodality_id integer NOT NULL
            REFERENCES thesismodalities(id)
            ON UPDATE CASCADE
            DEFERRABLE,
        startyear int4 NOT NULL,
        startmonth int4 NULL CHECK (startmonth >= 1 AND startmonth <= 12),
        endyear int4  NULL,
        endmonth int4 NULL CHECK (endmonth >= 1 AND endmonth <= 12),
        other text NULL,
        moduser_id int4 NULL                        -- Use it to known who
        REFERENCES users(id)            -- has inserted, updated or deleted
        ON UPDATE CASCADE               -- data into or  from this table.
        DEFERRABLE,
        created_on timestamp DEFAULT CURRENT_TIMESTAMP,
        updated_on timestamp DEFAULT CURRENT_TIMESTAMP,
        PRIMARY KEY (id),
        UNIQUE (title, institutioncareer_id, startyear)
);
COMMENT ON TABLE theses IS
        'Datos generales de cada una de las tesis';

CREATE TABLE user_theses (
   id SERIAL,
   thesis_id integer NOT NULL
            REFERENCES theses(id)
            ON UPDATE CASCADE
            DEFERRABLE,
   user_id integer NOT NULL
            REFERENCES users(id)
            ON UPDATE CASCADE
            DEFERRABLE,
   roleinthesis_id integer NOT NULL
            REFERENCES roleintheses(id)
            ON UPDATE CASCADE
            DEFERRABLE,
   other text NULL,
   moduser_id int4 NULL                     -- Use it to known who
   REFERENCES users(id)            -- has inserted, updated or deleted
   ON UPDATE CASCADE               -- data into or  from this table.
   DEFERRABLE,
   created_on timestamp DEFAULT CURRENT_TIMESTAMP,
   updated_on timestamp DEFAULT CURRENT_TIMESTAMP,
   PRIMARY KEY (id),
   -- Sanity checks: If the user is a full system user, require the user
   -- to be filled in. Likewise for an external one.
--   CHECK (user_is_internal = 't' OR
--      (internaluser_id IS NOT NULL AND externaluser_id IS NULL)),
--   CHECK (user_is_internal = 'f' OR
--      (externaluser_id IS NOT NULL AND internaluser_id IS NULL)),
   -- By having only internal or external present, we can make this UNIQUE
   -- constraint on thesis_id and both of them, and then have unicity on
   -- (anyuser, thesis_id).
   UNIQUE (thesis_id, user_id, roleinthesis_id)
);
COMMENT ON TABLE user_theses IS
        'La relación entre un usuario (en rol de director/asesor/etc.) y una
        tesis';


CREATE TABLE theses_logs (
    id SERIAL,
    thesis_id integer NOT NULL,
    old_thesisstatus_id integer  NOT NULL,
    startyear int4 NOT NULL,
    startmonth int4 NULL CHECK (startmonth >= 1 AND startmonth <= 12),
    endyear int4  NULL,
    endmonth int4 NULL CHECK (endmonth >= 1 AND endmonth <= 12),
    moduser_id integer NULL,      -- It will be used only to know who has

    created_on timestamp DEFAULT CURRENT_TIMESTAMP,
    updated_on timestamp DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
);
COMMENT ON TABLE theses_logs IS
        'Bitácora de cambios de estado en la tesis';


CREATE TABLE roleinjuries (
        id SERIAL,
        name text NOT NULL,
        moduser_id int4 NULL                        -- Use it to known who
        REFERENCES users(id)            -- has inserted, updated or deleted
        ON UPDATE CASCADE               -- data into or  from this table.
        DEFERRABLE,
        created_on timestamp DEFAULT CURRENT_TIMESTAMP,
        updated_on timestamp DEFAULT CURRENT_TIMESTAMP,
        PRIMARY KEY (id),
        UNIQUE (name)
);
COMMENT ON TABLE roleinjuries IS
        'Jurado de examenes: Presidente, Secretario, Vocal, ...';
-- Role in thesis presentations or dissertations.


CREATE TABLE thesis_jurors (
   id SERIAL,
   user_id integer NOT NULL
            REFERENCES users(id)
            ON UPDATE CASCADE
            DEFERRABLE,
   thesis_id integer NOT NULL
            REFERENCES theses(id)
            ON UPDATE CASCADE
            DEFERRABLE,
   roleinjury_id integer NOT NULL
            REFERENCES roleinjuries(id)
            ON UPDATE CASCADE
            DEFERRABLE,
   year integer NOT NULL,
   month integer NULL,
   moduser_id int4 NULL                     -- Use it to known who
   REFERENCES users(id)            -- has inserted, updated or deleted
   ON UPDATE CASCADE               -- data into or  from this table.
   DEFERRABLE,
   created_on timestamp DEFAULT CURRENT_TIMESTAMP,
   updated_on timestamp DEFAULT CURRENT_TIMESTAMP,
   PRIMARY KEY (id),
   UNIQUE (user_id, thesis_id, roleinjury_id)
);
COMMENT ON TABLE thesis_jurors IS
        'La relación entre un usuario, el rol en la disertación
        (sinodal, presidente, secretario y vocal) y la tesis';


------
-- Update thesislog if there was a status change
------
CREATE OR REPLACE FUNCTION thesis_update() RETURNS TRIGGER
SECURITY DEFINER AS '
DECLARE
BEGIN
        IF OLD.thesisstatus_id = NEW.thesisstatus_id THEN
                RETURN NEW;
        END IF;
        INSERT INTO theses_logs (thesis_id, old_thesisstatus_id, startyear, startmonth, endyear, endmonth,  moduser_id  )
                VALUES (OLD.id, OLD.thesisstatus_id, OLD.startyear, OLD.startmonth, OLD.endyear, OLD.endmonth,  OLD.moduser_id);
        RETURN NEW;
END;
' LANGUAGE 'plpgsql';


CREATE OR REPLACE FUNCTION thesis_delete() RETURNS TRIGGER
SECURITY DEFINER AS '
DECLARE
BEGIN
        INSERT INTO theses_logs (thesis_id, old_thesisstatus_id, startyear, startmonth, endyear, endmonth,  moduser_id  )
                VALUES (OLD.id, OLD.thesisstatus_id, OLD.startyear, OLD.startmonth, OLD.endyear, OLD.endmonth,  OLD.moduser_id);
                RETURN NULL;
END;
' LANGUAGE 'plpgsql';

CREATE TRIGGER thesis_delete AFTER DELETE ON theses
        FOR EACH ROW EXECUTE PROCEDURE thesis_delete();

CREATE TRIGGER thesis_update BEFORE UPDATE ON theses
        FOR EACH ROW EXECUTE PROCEDURE thesis_update();
