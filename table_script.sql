--тип измерения
CREATE TABLE IF NOT EXISTS "Mike".measurement_type
(
    id integer NOT NULL,
    name character varying(100) COLLATE pg_catalog."default",
    CONSTRAINT measurement_type_pkey PRIMARY KEY (id)
);


INSERT INTO "Mike".measurement_type VALUES (1, 'ДМК');
INSERT INTO "Mike".measurement_type VALUES (2, 'ВР');


--должность
CREATE TABLE IF NOT EXISTS "Mike".military_rank
(
    id integer NOT NULL,
    rank_name character varying(80) COLLATE pg_catalog."default",
    CONSTRAINT military_rank_pkey PRIMARY KEY (id)
);

INSERT INTO "Mike".military_rank VALUES (1,'Рядовой');
INSERT INTO "Mike".military_rank VALUES (2,'Сержант');


--пользователи
CREATE SEQUENCE IF NOT EXISTS "Mike".military_user_sequence
    INCREMENT 1
    START 1
    MINVALUE 1
    MAXVALUE 9223372036854775807
    CACHE 1;

CREATE TABLE IF NOT EXISTS "Mike".military_user
(
    id integer NOT NULL DEFAULT nextval('"Mike".military_user_sequence'::regclass),
    name character varying(80) COLLATE pg_catalog."default",
    rank_id integer NOT NULL,
    CONSTRAINT military_user_pkey PRIMARY KEY (id)
);


INSERT INTO "Mike".military_user VALUES(1,"Иванов Иван",1);
INSERT INTO "Mike".military_user VALUES(2,"Петров Петр",2);

--история запросов
CREATE SEQUENCE IF NOT EXISTS "Mike".measurement_batch_seq
    INCREMENT 1
    START 1
    MINVALUE 1
    MAXVALUE 9223372036854775807
    CACHE 1;


CREATE TABLE IF NOT EXISTS "Mike".measurement_batch
(
    id integer NOT NULL DEFAULT nextval('"Mike".measurement_batch_seq'::regclass),
    startperiod timestamp without time zone DEFAULT now(),
    positionx numeric(3,2),
    positiony numeric(3,2),
    user_id integer NOT NULL,
    CONSTRAINT batch_time_pkey PRIMARY KEY (id)
);

INSERT INTO "Mike".measurement_batch (positionx,positiony,user_id) VALUES (3.3,2.2,1);
INSERT INTO "Mike".measurement_batch (positionx,positiony,user_id) VALUES (3.5,4.2,2);


--парамтеры измерениия
CREATE SEQUENCE IF NOT EXISTS "Mike".measurement_params_seq
    INCREMENT 1
    START 1
    MINVALUE 1
    MAXVALUE 9223372036854775807
    CACHE 1;

CREATE TABLE IF NOT EXISTS "Mike".measurement_params
(
    id integer NOT NULL DEFAULT nextval('"Mike".measurement_params_seq'::regclass),
    measurement_type_id integer NOT NULL,
    measurement_batch_id integer NOT NULL,
    height numeric(8,2),
    temperature numeric(8,2),
    pressure numeric(8,2),
    wind_speed numeric(8,2),
    wind_direction numeric(8,2),
    bullet_speed numeric(8,2),
    CONSTRAINT measurement_params_pkey PRIMARY KEY (id)
);


INSERT INTO "Mike".measurement_params VALUES (1, 1, 1, 100.00, 12.00, 34.00, 45.00, 0.20, NULL);
INSERT INTO "Mike".measurement_params VALUES (2, 2, 2, 100.00, 12.00, 34.00, 0.20, NULL, 45.00);

