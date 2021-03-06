--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

--
-- Name: answer_type; Type: TYPE; Schema: public; Owner: fstrub
--

CREATE TYPE answer_type AS ENUM (
    'Yes',
    'No',
    'N/A'
);


ALTER TYPE answer_type OWNER TO fstrub;

--
-- Name: guess_order(); Type: FUNCTION; Schema: public; Owner: fstrub
--

CREATE FUNCTION guess_order() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
    new.order:= next_guess(new.dialogue_id);
    return new;
end $$;


ALTER FUNCTION public.guess_order() OWNER TO fstrub;

--
-- Name: next_guess(integer); Type: FUNCTION; Schema: public; Owner: fstrub
--

CREATE FUNCTION next_guess(integer) RETURNS integer
    LANGUAGE sql
    AS $_$
SELECT COALESCE(((SELECT MAX(q.order) FROM guess AS q WHERE q.dialogue_id = $1) +1), 0)  ;
$_$;


ALTER FUNCTION public.next_guess(integer) OWNER TO fstrub;

--
-- Name: next_order(integer); Type: FUNCTION; Schema: public; Owner: fstrub
--

CREATE FUNCTION next_order(integer) RETURNS integer
    LANGUAGE sql
    AS $_$
SELECT COALESCE(((SELECT MAX(q.order) FROM question AS q WHERE q.dialogue_id = $1) +1), 0)  ;
$_$;


ALTER FUNCTION public.next_order(integer) OWNER TO fstrub;

--
-- Name: next_order2(integer); Type: FUNCTION; Schema: public; Owner: fstrub
--

CREATE FUNCTION next_order2(integer) RETURNS integer
    LANGUAGE sql
    AS $_$
SELECT 1 + (SELECT MAX(q.order) FROM question AS q WHERE q.dialogue_id = $1);
$_$;


ALTER FUNCTION public.next_order2(integer) OWNER TO fstrub;

--
-- Name: question_order(); Type: FUNCTION; Schema: public; Owner: fstrub
--

CREATE FUNCTION question_order() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
    new.order:= next_order(new.dialogue_id);
    return new;
end $$;


ALTER FUNCTION public.question_order() OWNER TO fstrub;

--
-- Name: answer_seq; Type: SEQUENCE; Schema: public; Owner: fstrub
--

CREATE SEQUENCE answer_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE answer_seq OWNER TO fstrub;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: answer; Type: TABLE; Schema: public; Owner: fstrub; Tablespace: 
--

CREATE TABLE answer (
    answer_id integer DEFAULT nextval('answer_seq'::regclass) NOT NULL,
    hit_id integer NOT NULL,
    question_id integer NOT NULL,
    content answer_type NOT NULL
);


ALTER TABLE answer OWNER TO fstrub;

--
-- Name: dialogue_seq; Type: SEQUENCE; Schema: public; Owner: fstrub
--

CREATE SEQUENCE dialogue_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE dialogue_seq OWNER TO fstrub;

--
-- Name: dialogue; Type: TABLE; Schema: public; Owner: fstrub; Tablespace: 
--

CREATE TABLE dialogue (
    dialogue_id integer DEFAULT nextval('dialogue_seq'::regclass) NOT NULL,
    picture_id integer NOT NULL,
    "timestamp" timestamp without time zone DEFAULT now() NOT NULL,
    object_id integer
);


ALTER TABLE dialogue OWNER TO fstrub;

--
-- Name: guess_seq; Type: SEQUENCE; Schema: public; Owner: fstrub
--

CREATE SEQUENCE guess_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE guess_seq OWNER TO fstrub;

--
-- Name: guess; Type: TABLE; Schema: public; Owner: fstrub; Tablespace: 
--

CREATE TABLE guess (
    guess_id integer DEFAULT nextval('guess_seq'::regclass) NOT NULL,
    "order" integer NOT NULL,
    object_id integer NOT NULL,
    "timestamp" timestamp without time zone DEFAULT now(),
    dialogue_id integer NOT NULL
);


ALTER TABLE guess OWNER TO fstrub;

--
-- Name: hit_seq; Type: SEQUENCE; Schema: public; Owner: fstrub
--

CREATE SEQUENCE hit_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE hit_seq OWNER TO fstrub;

--
-- Name: hit; Type: TABLE; Schema: public; Owner: fstrub; Tablespace: 
--

CREATE TABLE hit (
    hit_id integer DEFAULT nextval('hit_seq'::regclass) NOT NULL,
    worker_amazon_id integer NOT NULL,
    is_valid boolean DEFAULT false NOT NULL,
    "timestamp" timestamp without time zone DEFAULT now() NOT NULL,
    hit_amazon_id integer NOT NULL
);


ALTER TABLE hit OWNER TO fstrub;

--
-- Name: object_seq; Type: SEQUENCE; Schema: public; Owner: fstrub
--

CREATE SEQUENCE object_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE object_seq OWNER TO fstrub;

--
-- Name: object; Type: TABLE; Schema: public; Owner: fstrub; Tablespace: 
--

CREATE TABLE object (
    object_id bigint DEFAULT nextval('object_seq'::regclass) NOT NULL,
    picture_id integer NOT NULL,
    category_id integer NOT NULL,
    segment jsonb NOT NULL,
    bbox jsonb,
    is_crowd boolean DEFAULT false NOT NULL,
    area numeric DEFAULT 0 NOT NULL
);


ALTER TABLE object OWNER TO fstrub;

--
-- Name: object_category; Type: TABLE; Schema: public; Owner: fstrub; Tablespace: 
--

CREATE TABLE object_category (
    category_id numeric NOT NULL,
    name character varying(50),
    supercategory_id integer NOT NULL
);


ALTER TABLE object_category OWNER TO fstrub;

--
-- Name: object_supercategory; Type: TABLE; Schema: public; Owner: fstrub; Tablespace: 
--

CREATE TABLE object_supercategory (
    supercategory_id integer NOT NULL,
    name character varying(50)
);


ALTER TABLE object_supercategory OWNER TO fstrub;

--
-- Name: picture_seq; Type: SEQUENCE; Schema: public; Owner: fstrub
--

CREATE SEQUENCE picture_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE picture_seq OWNER TO fstrub;

--
-- Name: picture; Type: TABLE; Schema: public; Owner: fstrub; Tablespace: 
--

CREATE TABLE picture (
    picture_id integer NOT NULL,
    flickr_url text,
    file_name character varying(255),
    height integer,
    width integer,
    coco_url text NOT NULL,
    serial_id integer DEFAULT nextval('picture_seq'::regclass) NOT NULL
);


ALTER TABLE picture OWNER TO fstrub;

--
-- Name: question_seq; Type: SEQUENCE; Schema: public; Owner: fstrub
--

CREATE SEQUENCE question_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE question_seq OWNER TO fstrub;

--
-- Name: question; Type: TABLE; Schema: public; Owner: fstrub; Tablespace: 
--

CREATE TABLE question (
    question_id integer DEFAULT nextval('question_seq'::regclass) NOT NULL,
    hit_id integer NOT NULL,
    dialogue_id integer NOT NULL,
    content text,
    "order" integer
);


ALTER TABLE question OWNER TO fstrub;

--
-- Data for Name: answer; Type: TABLE DATA; Schema: public; Owner: fstrub
--

COPY answer (answer_id, hit_id, question_id, content) FROM stdin;
\.


--
-- Name: answer_seq; Type: SEQUENCE SET; Schema: public; Owner: fstrub
--

SELECT pg_catalog.setval('answer_seq', 1, false);


--
-- Data for Name: dialogue; Type: TABLE DATA; Schema: public; Owner: fstrub
--

COPY dialogue (dialogue_id, picture_id, "timestamp", object_id) FROM stdin;
\.


--
-- Name: dialogue_seq; Type: SEQUENCE SET; Schema: public; Owner: fstrub
--

SELECT pg_catalog.setval('dialogue_seq', 1, false);


--
-- Data for Name: guess; Type: TABLE DATA; Schema: public; Owner: fstrub
--

COPY guess (guess_id, "order", object_id, "timestamp", dialogue_id) FROM stdin;
\.


--
-- Name: guess_seq; Type: SEQUENCE SET; Schema: public; Owner: fstrub
--

SELECT pg_catalog.setval('guess_seq', 1, false);


--
-- Data for Name: hit; Type: TABLE DATA; Schema: public; Owner: fstrub
--

COPY hit (hit_id, worker_amazon_id, is_valid, "timestamp", hit_amazon_id) FROM stdin;
\.


--
-- Name: hit_seq; Type: SEQUENCE SET; Schema: public; Owner: fstrub
--

SELECT pg_catalog.setval('hit_seq', 1, false);


--
-- Data for Name: object; Type: TABLE DATA; Schema: public; Owner: fstrub
--

COPY object (object_id, picture_id, category_id, segment, bbox, is_crowd, area) FROM stdin;
\.


--
-- Data for Name: object_category; Type: TABLE DATA; Schema: public; Owner: fstrub
--

COPY object_category (category_id, name, supercategory_id) FROM stdin;
\.


--
-- Name: object_seq; Type: SEQUENCE SET; Schema: public; Owner: fstrub
--

SELECT pg_catalog.setval('object_seq', 1, false);


--
-- Data for Name: object_supercategory; Type: TABLE DATA; Schema: public; Owner: fstrub
--

COPY object_supercategory (supercategory_id, name) FROM stdin;
\.


--
-- Data for Name: picture; Type: TABLE DATA; Schema: public; Owner: fstrub
--

COPY picture (picture_id, flickr_url, file_name, height, width, coco_url, serial_id) FROM stdin;
\.


--
-- Name: picture_seq; Type: SEQUENCE SET; Schema: public; Owner: fstrub
--

SELECT pg_catalog.setval('picture_seq', 1, false);


--
-- Data for Name: question; Type: TABLE DATA; Schema: public; Owner: fstrub
--

COPY question (question_id, hit_id, dialogue_id, content, "order") FROM stdin;
\.


--
-- Name: question_seq; Type: SEQUENCE SET; Schema: public; Owner: fstrub
--

SELECT pg_catalog.setval('question_seq', 1, false);


--
-- Name: Answer_pkey; Type: CONSTRAINT; Schema: public; Owner: fstrub; Tablespace: 
--

ALTER TABLE ONLY answer
    ADD CONSTRAINT "Answer_pkey" PRIMARY KEY (answer_id);


--
-- Name: Dialogue_pkey; Type: CONSTRAINT; Schema: public; Owner: fstrub; Tablespace: 
--

ALTER TABLE ONLY dialogue
    ADD CONSTRAINT "Dialogue_pkey" PRIMARY KEY (dialogue_id);


--
-- Name: Hit_hit_amazon_id_key; Type: CONSTRAINT; Schema: public; Owner: fstrub; Tablespace: 
--

ALTER TABLE ONLY hit
    ADD CONSTRAINT "Hit_hit_amazon_id_key" UNIQUE (hit_amazon_id);


--
-- Name: Hit_pkey; Type: CONSTRAINT; Schema: public; Owner: fstrub; Tablespace: 
--

ALTER TABLE ONLY hit
    ADD CONSTRAINT "Hit_pkey" PRIMARY KEY (hit_id);


--
-- Name: Object_category_pkey; Type: CONSTRAINT; Schema: public; Owner: fstrub; Tablespace: 
--

ALTER TABLE ONLY object_category
    ADD CONSTRAINT "Object_category_pkey" PRIMARY KEY (category_id);


--
-- Name: Object_pkey; Type: CONSTRAINT; Schema: public; Owner: fstrub; Tablespace: 
--

ALTER TABLE ONLY object
    ADD CONSTRAINT "Object_pkey" PRIMARY KEY (object_id);


--
-- Name: Picture_pkey; Type: CONSTRAINT; Schema: public; Owner: fstrub; Tablespace: 
--

ALTER TABLE ONLY picture
    ADD CONSTRAINT "Picture_pkey" PRIMARY KEY (picture_id);


--
-- Name: Question_pkey; Type: CONSTRAINT; Schema: public; Owner: fstrub; Tablespace: 
--

ALTER TABLE ONLY question
    ADD CONSTRAINT "Question_pkey" PRIMARY KEY (question_id);


--
-- Name: answer_question_id_key; Type: CONSTRAINT; Schema: public; Owner: fstrub; Tablespace: 
--

ALTER TABLE ONLY answer
    ADD CONSTRAINT answer_question_id_key UNIQUE (question_id);


--
-- Name: guess_pkey; Type: CONSTRAINT; Schema: public; Owner: fstrub; Tablespace: 
--

ALTER TABLE ONLY guess
    ADD CONSTRAINT guess_pkey PRIMARY KEY (guess_id);


--
-- Name: object_supercategory_pkey; Type: CONSTRAINT; Schema: public; Owner: fstrub; Tablespace: 
--

ALTER TABLE ONLY object_supercategory
    ADD CONSTRAINT object_supercategory_pkey PRIMARY KEY (supercategory_id);


--
-- Name: picture_serial_id_key; Type: CONSTRAINT; Schema: public; Owner: fstrub; Tablespace: 
--

ALTER TABLE ONLY picture
    ADD CONSTRAINT picture_serial_id_key UNIQUE (serial_id);


--
-- Name: fki_answer_to_exchange_fkey; Type: INDEX; Schema: public; Owner: fstrub; Tablespace: 
--

CREATE INDEX fki_answer_to_exchange_fkey ON answer USING btree (question_id);


--
-- Name: fki_answer_to_hit; Type: INDEX; Schema: public; Owner: fstrub; Tablespace: 
--

CREATE INDEX fki_answer_to_hit ON answer USING btree (hit_id);


--
-- Name: fki_category_to_supercategory_fkey; Type: INDEX; Schema: public; Owner: fstrub; Tablespace: 
--

CREATE INDEX fki_category_to_supercategory_fkey ON object_category USING btree (supercategory_id);


--
-- Name: fki_dialogue_to_guess_fkey; Type: INDEX; Schema: public; Owner: fstrub; Tablespace: 
--

CREATE INDEX fki_dialogue_to_guess_fkey ON dialogue USING btree (object_id);


--
-- Name: fki_dialogue_to_picture_fkey; Type: INDEX; Schema: public; Owner: fstrub; Tablespace: 
--

CREATE INDEX fki_dialogue_to_picture_fkey ON dialogue USING btree (picture_id);


--
-- Name: fki_guess_to_dialogue_fkey; Type: INDEX; Schema: public; Owner: fstrub; Tablespace: 
--

CREATE INDEX fki_guess_to_dialogue_fkey ON guess USING btree (dialogue_id);


--
-- Name: fki_guess_to_object_fkey; Type: INDEX; Schema: public; Owner: fstrub; Tablespace: 
--

CREATE INDEX fki_guess_to_object_fkey ON guess USING btree (object_id);


--
-- Name: fki_hit_to_worker_fkey; Type: INDEX; Schema: public; Owner: fstrub; Tablespace: 
--

CREATE INDEX fki_hit_to_worker_fkey ON hit USING btree (worker_amazon_id);


--
-- Name: fki_object_to_category_fkey; Type: INDEX; Schema: public; Owner: fstrub; Tablespace: 
--

CREATE INDEX fki_object_to_category_fkey ON object USING btree (category_id);


--
-- Name: fki_object_to_picture_fkey; Type: INDEX; Schema: public; Owner: fstrub; Tablespace: 
--

CREATE INDEX fki_object_to_picture_fkey ON object USING btree (picture_id);


--
-- Name: fki_question_to_exchange_fkey; Type: INDEX; Schema: public; Owner: fstrub; Tablespace: 
--

CREATE INDEX fki_question_to_exchange_fkey ON question USING btree (dialogue_id);


--
-- Name: fki_question_to_hit_fkey; Type: INDEX; Schema: public; Owner: fstrub; Tablespace: 
--

CREATE INDEX fki_question_to_hit_fkey ON question USING btree (hit_id);


--
-- Name: serial_index; Type: INDEX; Schema: public; Owner: fstrub; Tablespace: 
--

CREATE INDEX serial_index ON picture USING btree (serial_id);


--
-- Name: guess_order; Type: TRIGGER; Schema: public; Owner: fstrub
--

CREATE TRIGGER guess_order BEFORE INSERT OR UPDATE ON guess FOR EACH ROW EXECUTE PROCEDURE guess_order();


--
-- Name: question_order; Type: TRIGGER; Schema: public; Owner: fstrub
--

CREATE TRIGGER question_order BEFORE INSERT OR UPDATE ON question FOR EACH ROW EXECUTE PROCEDURE question_order();


--
-- Name: answer_to_hit_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fstrub
--

ALTER TABLE ONLY answer
    ADD CONSTRAINT answer_to_hit_fkey FOREIGN KEY (hit_id) REFERENCES hit(hit_id) ON UPDATE CASCADE;


--
-- Name: answer_to_question_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fstrub
--

ALTER TABLE ONLY answer
    ADD CONSTRAINT answer_to_question_fkey FOREIGN KEY (question_id) REFERENCES question(question_id);


--
-- Name: category_to_supercategory_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fstrub
--

ALTER TABLE ONLY object_category
    ADD CONSTRAINT category_to_supercategory_fkey FOREIGN KEY (supercategory_id) REFERENCES object_supercategory(supercategory_id);


--
-- Name: dialogue_to_guess_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fstrub
--

ALTER TABLE ONLY dialogue
    ADD CONSTRAINT dialogue_to_guess_fkey FOREIGN KEY (object_id) REFERENCES object(object_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: dialogue_to_picture_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fstrub
--

ALTER TABLE ONLY dialogue
    ADD CONSTRAINT dialogue_to_picture_fkey FOREIGN KEY (picture_id) REFERENCES picture(picture_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: guess_to_dialogue_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fstrub
--

ALTER TABLE ONLY guess
    ADD CONSTRAINT guess_to_dialogue_fkey FOREIGN KEY (dialogue_id) REFERENCES dialogue(dialogue_id);


--
-- Name: guess_to_object_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fstrub
--

ALTER TABLE ONLY guess
    ADD CONSTRAINT guess_to_object_fkey FOREIGN KEY (object_id) REFERENCES object(object_id);


--
-- Name: object_to_category_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fstrub
--

ALTER TABLE ONLY object
    ADD CONSTRAINT object_to_category_fkey FOREIGN KEY (category_id) REFERENCES object_category(category_id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: object_to_picture_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fstrub
--

ALTER TABLE ONLY object
    ADD CONSTRAINT object_to_picture_fkey FOREIGN KEY (picture_id) REFERENCES picture(picture_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: question_to_dialogue_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fstrub
--

ALTER TABLE ONLY question
    ADD CONSTRAINT question_to_dialogue_fkey FOREIGN KEY (dialogue_id) REFERENCES dialogue(dialogue_id);


--
-- Name: question_to_hit_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fstrub
--

ALTER TABLE ONLY question
    ADD CONSTRAINT question_to_hit_fkey FOREIGN KEY (hit_id) REFERENCES hit(hit_id) ON UPDATE CASCADE;


--
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

