--
-- PostgreSQL database dump
--

-- Dumped from database version 15.4
-- Dumped by pg_dump version 16.2

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: awsdms_intercept_ddl(); Type: FUNCTION; Schema: public; Owner: service_dms
--

CREATE FUNCTION public.awsdms_intercept_ddl() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
  declare _qry text;
BEGIN
  if (tg_tag='CREATE TABLE' or tg_tag='ALTER TABLE' or tg_tag='DROP TABLE' or tg_tag = 'CREATE TABLE AS') then
      SELECT current_query() into _qry;
      insert into public.awsdms_ddl_audit
      values
      (
      default,current_timestamp,current_user,cast(TXID_CURRENT()as varchar(16)),tg_tag,0,'',current_schema,_qry
      );
      delete from public.awsdms_ddl_audit;
 end if;
END;
$$;


ALTER FUNCTION public.awsdms_intercept_ddl() OWNER TO service_dms;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: awsdms_ddl_audit; Type: TABLE; Schema: public; Owner: service_dms
--

CREATE TABLE public.awsdms_ddl_audit (
    c_key bigint NOT NULL,
    c_time timestamp without time zone,
    c_user character varying(64),
    c_txn character varying(16),
    c_tag character varying(24),
    c_oid integer,
    c_name character varying(64),
    c_schema character varying(64),
    c_ddlqry text
);


ALTER TABLE public.awsdms_ddl_audit OWNER TO service_dms;

--
-- Name: awsdms_ddl_audit_c_key_seq; Type: SEQUENCE; Schema: public; Owner: service_dms
--

CREATE SEQUENCE public.awsdms_ddl_audit_c_key_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.awsdms_ddl_audit_c_key_seq OWNER TO service_dms;

--
-- Name: awsdms_ddl_audit_c_key_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: service_dms
--

ALTER SEQUENCE public.awsdms_ddl_audit_c_key_seq OWNED BY public.awsdms_ddl_audit.c_key;


--
-- Name: bets; Type: TABLE; Schema: public; Owner: service_game_client
--

CREATE TABLE public.bets (
    id character varying(36) NOT NULL,
    brand_id character varying(36) NOT NULL,
    player_id character varying(36) NOT NULL,
    game_id character varying(36) NOT NULL,
    currency character varying(8) NOT NULL,
    bet_amount numeric NOT NULL,
    win_amount numeric NOT NULL,
    type character varying(24) NOT NULL,
    status character varying(24) NOT NULL,
    created timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    version bigint DEFAULT 0 NOT NULL,
    profit numeric DEFAULT '0'::numeric NOT NULL,
    bet_size numeric DEFAULT '0'::numeric NOT NULL,
    bet_level numeric DEFAULT '0'::numeric NOT NULL,
    starting_balance numeric DEFAULT '0'::numeric NOT NULL,
    ending_balance numeric DEFAULT '0'::numeric NOT NULL,
    win_free_spins integer DEFAULT 0 NOT NULL,
    parent_bet_id character varying(36),
    is_end_round boolean DEFAULT false
);


ALTER TABLE public.bets OWNER TO service_game_client;

--
-- Name: features; Type: TABLE; Schema: public; Owner: service_game_client
--

CREATE TABLE public.features (
    id text NOT NULL,
    game_id text NOT NULL,
    type text NOT NULL,
    price numeric(20,2) NOT NULL,
    free_spins numeric(20,2) NOT NULL,
    created timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.features OWNER TO service_game_client;

--
-- Name: jobrunr_backgroundjobservers; Type: TABLE; Schema: public; Owner: service_game_client
--

CREATE TABLE public.jobrunr_backgroundjobservers (
    id character(36) NOT NULL,
    workerpoolsize integer NOT NULL,
    pollintervalinseconds integer NOT NULL,
    firstheartbeat timestamp(6) without time zone NOT NULL,
    lastheartbeat timestamp(6) without time zone NOT NULL,
    running integer NOT NULL,
    systemtotalmemory bigint NOT NULL,
    systemfreememory bigint NOT NULL,
    systemcpuload numeric(3,2) NOT NULL,
    processmaxmemory bigint NOT NULL,
    processfreememory bigint NOT NULL,
    processallocatedmemory bigint NOT NULL,
    processcpuload numeric(3,2) NOT NULL,
    deletesucceededjobsafter character varying(32),
    permanentlydeletejobsafter character varying(32),
    name character varying(128)
);


ALTER TABLE public.jobrunr_backgroundjobservers OWNER TO service_game_client;

--
-- Name: jobrunr_jobs; Type: TABLE; Schema: public; Owner: service_game_client
--

CREATE TABLE public.jobrunr_jobs (
    id character(36) NOT NULL,
    version integer NOT NULL,
    jobasjson text NOT NULL,
    jobsignature character varying(512) NOT NULL,
    state character varying(36) NOT NULL,
    createdat timestamp without time zone NOT NULL,
    updatedat timestamp without time zone NOT NULL,
    scheduledat timestamp without time zone,
    recurringjobid character varying(128)
);


ALTER TABLE public.jobrunr_jobs OWNER TO service_game_client;

--
-- Name: jobrunr_metadata; Type: TABLE; Schema: public; Owner: service_game_client
--

CREATE TABLE public.jobrunr_metadata (
    id character varying(156) NOT NULL,
    name character varying(92) NOT NULL,
    owner character varying(64) NOT NULL,
    value text NOT NULL,
    createdat timestamp without time zone NOT NULL,
    updatedat timestamp without time zone NOT NULL
);


ALTER TABLE public.jobrunr_metadata OWNER TO service_game_client;

--
-- Name: jobrunr_recurring_jobs; Type: TABLE; Schema: public; Owner: service_game_client
--

CREATE TABLE public.jobrunr_recurring_jobs (
    id character(128) NOT NULL,
    version integer NOT NULL,
    jobasjson text NOT NULL,
    createdat bigint DEFAULT '0'::bigint NOT NULL
);


ALTER TABLE public.jobrunr_recurring_jobs OWNER TO service_game_client;

--
-- Name: jobrunr_jobs_stats; Type: VIEW; Schema: public; Owner: service_game_client
--

CREATE VIEW public.jobrunr_jobs_stats AS
 WITH job_stat_results AS (
         SELECT jobrunr_jobs.state,
            count(*) AS count
           FROM public.jobrunr_jobs
          GROUP BY ROLLUP(jobrunr_jobs.state)
        )
 SELECT COALESCE(( SELECT job_stat_results.count
           FROM job_stat_results
          WHERE (job_stat_results.state IS NULL)), (0)::bigint) AS total,
    COALESCE(( SELECT job_stat_results.count
           FROM job_stat_results
          WHERE ((job_stat_results.state)::text = 'SCHEDULED'::text)), (0)::bigint) AS scheduled,
    COALESCE(( SELECT job_stat_results.count
           FROM job_stat_results
          WHERE ((job_stat_results.state)::text = 'ENQUEUED'::text)), (0)::bigint) AS enqueued,
    COALESCE(( SELECT job_stat_results.count
           FROM job_stat_results
          WHERE ((job_stat_results.state)::text = 'PROCESSING'::text)), (0)::bigint) AS processing,
    COALESCE(( SELECT job_stat_results.count
           FROM job_stat_results
          WHERE ((job_stat_results.state)::text = 'FAILED'::text)), (0)::bigint) AS failed,
    COALESCE(( SELECT job_stat_results.count
           FROM job_stat_results
          WHERE ((job_stat_results.state)::text = 'SUCCEEDED'::text)), (0)::bigint) AS succeeded,
    COALESCE(( SELECT ((jm.value)::character(10))::numeric(10,0) AS value
           FROM public.jobrunr_metadata jm
          WHERE ((jm.id)::text = 'succeeded-jobs-counter-cluster'::text)), (0)::numeric) AS alltimesucceeded,
    COALESCE(( SELECT job_stat_results.count
           FROM job_stat_results
          WHERE ((job_stat_results.state)::text = 'DELETED'::text)), (0)::bigint) AS deleted,
    ( SELECT count(*) AS count
           FROM public.jobrunr_backgroundjobservers) AS nbrofbackgroundjobservers,
    ( SELECT count(*) AS count
           FROM public.jobrunr_recurring_jobs) AS nbrofrecurringjobs;


ALTER VIEW public.jobrunr_jobs_stats OWNER TO service_game_client;

--
-- Name: jobrunr_migrations; Type: TABLE; Schema: public; Owner: service_game_client
--

CREATE TABLE public.jobrunr_migrations (
    id character(36) NOT NULL,
    script character varying(64) NOT NULL,
    installedon character varying(29) NOT NULL
);


ALTER TABLE public.jobrunr_migrations OWNER TO service_game_client;

--
-- Name: migrations; Type: TABLE; Schema: public; Owner: service_game_client
--

CREATE TABLE public.migrations (
    id bigint NOT NULL,
    description text
);


ALTER TABLE public.migrations OWNER TO service_game_client;

--
-- Name: player_states; Type: TABLE; Schema: public; Owner: service_game_client
--

CREATE TABLE public.player_states (
    id text NOT NULL,
    player_id text NOT NULL,
    game_id text NOT NULL,
    value jsonb,
    free_spins integer DEFAULT 0,
    created timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    version bigint DEFAULT 0 NOT NULL,
    last_bet_id text,
    free_spins_win_amount numeric DEFAULT 0 NOT NULL,
    is_in_gamble boolean DEFAULT true NOT NULL,
    is_gamble_fs boolean DEFAULT true NOT NULL,
    last_bet_result jsonb
);


ALTER TABLE public.player_states OWNER TO service_game_client;

--
-- Name: players; Type: TABLE; Schema: public; Owner: service_game_client
--

CREATE TABLE public.players (
    id character varying(36) NOT NULL,
    brand_id character varying(36) NOT NULL,
    ref character varying(512) NOT NULL,
    token text NOT NULL,
    created timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    version bigint DEFAULT 0 NOT NULL,
    language character varying(8)
);


ALTER TABLE public.players OWNER TO service_game_client;

--
-- Name: wallets; Type: TABLE; Schema: public; Owner: service_game_client
--

CREATE TABLE public.wallets (
    id text NOT NULL,
    player_id text NOT NULL,
    currency text NOT NULL,
    balance numeric NOT NULL,
    created timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.wallets OWNER TO service_game_client;

--
-- Name: awsdms_ddl_audit c_key; Type: DEFAULT; Schema: public; Owner: service_dms
--

ALTER TABLE ONLY public.awsdms_ddl_audit ALTER COLUMN c_key SET DEFAULT nextval('public.awsdms_ddl_audit_c_key_seq'::regclass);


--
-- Name: awsdms_ddl_audit awsdms_ddl_audit_pkey; Type: CONSTRAINT; Schema: public; Owner: service_dms
--

ALTER TABLE ONLY public.awsdms_ddl_audit
    ADD CONSTRAINT awsdms_ddl_audit_pkey PRIMARY KEY (c_key);


--
-- Name: bets bets_pkey; Type: CONSTRAINT; Schema: public; Owner: service_game_client
--

ALTER TABLE ONLY public.bets
    ADD CONSTRAINT bets_pkey PRIMARY KEY (id);


--
-- Name: features features_pkey; Type: CONSTRAINT; Schema: public; Owner: service_game_client
--

ALTER TABLE ONLY public.features
    ADD CONSTRAINT features_pkey PRIMARY KEY (id);


--
-- Name: jobrunr_backgroundjobservers jobrunr_backgroundjobservers_pkey; Type: CONSTRAINT; Schema: public; Owner: service_game_client
--

ALTER TABLE ONLY public.jobrunr_backgroundjobservers
    ADD CONSTRAINT jobrunr_backgroundjobservers_pkey PRIMARY KEY (id);


--
-- Name: jobrunr_jobs jobrunr_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: service_game_client
--

ALTER TABLE ONLY public.jobrunr_jobs
    ADD CONSTRAINT jobrunr_jobs_pkey PRIMARY KEY (id);


--
-- Name: jobrunr_metadata jobrunr_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: service_game_client
--

ALTER TABLE ONLY public.jobrunr_metadata
    ADD CONSTRAINT jobrunr_metadata_pkey PRIMARY KEY (id);


--
-- Name: jobrunr_migrations jobrunr_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: service_game_client
--

ALTER TABLE ONLY public.jobrunr_migrations
    ADD CONSTRAINT jobrunr_migrations_pkey PRIMARY KEY (id);


--
-- Name: jobrunr_recurring_jobs jobrunr_recurring_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: service_game_client
--

ALTER TABLE ONLY public.jobrunr_recurring_jobs
    ADD CONSTRAINT jobrunr_recurring_jobs_pkey PRIMARY KEY (id);


--
-- Name: migrations migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: service_game_client
--

ALTER TABLE ONLY public.migrations
    ADD CONSTRAINT migrations_pkey PRIMARY KEY (id);


--
-- Name: player_states player_states_pkey; Type: CONSTRAINT; Schema: public; Owner: service_game_client
--

ALTER TABLE ONLY public.player_states
    ADD CONSTRAINT player_states_pkey PRIMARY KEY (id);


--
-- Name: player_states player_states_player_id_game_id_key; Type: CONSTRAINT; Schema: public; Owner: service_game_client
--

ALTER TABLE ONLY public.player_states
    ADD CONSTRAINT player_states_player_id_game_id_key UNIQUE (player_id, game_id);


--
-- Name: players players_brand_ref_key; Type: CONSTRAINT; Schema: public; Owner: service_game_client
--

ALTER TABLE ONLY public.players
    ADD CONSTRAINT players_brand_ref_key UNIQUE (brand_id, ref);


--
-- Name: players players_pkey; Type: CONSTRAINT; Schema: public; Owner: service_game_client
--

ALTER TABLE ONLY public.players
    ADD CONSTRAINT players_pkey PRIMARY KEY (id);


--
-- Name: wallets wallets_pkey; Type: CONSTRAINT; Schema: public; Owner: service_game_client
--

ALTER TABLE ONLY public.wallets
    ADD CONSTRAINT wallets_pkey PRIMARY KEY (id);


--
-- Name: wallets wallets_player_id_currency_key; Type: CONSTRAINT; Schema: public; Owner: service_game_client
--

ALTER TABLE ONLY public.wallets
    ADD CONSTRAINT wallets_player_id_currency_key UNIQUE (player_id, currency);


--
-- Name: bets_brand_id_idx; Type: INDEX; Schema: public; Owner: service_game_client
--

CREATE INDEX bets_brand_id_idx ON public.bets USING btree (brand_id);


--
-- Name: bets_game_id_idx; Type: INDEX; Schema: public; Owner: service_game_client
--

CREATE INDEX bets_game_id_idx ON public.bets USING btree (game_id);


--
-- Name: bets_parent_bet_id_idx; Type: INDEX; Schema: public; Owner: service_game_client
--

CREATE INDEX bets_parent_bet_id_idx ON public.bets USING btree (parent_bet_id);


--
-- Name: bets_player_id_idx; Type: INDEX; Schema: public; Owner: service_game_client
--

CREATE INDEX bets_player_id_idx ON public.bets USING btree (player_id);


--
-- Name: jobrunr_bgjobsrvrs_fsthb_idx; Type: INDEX; Schema: public; Owner: service_game_client
--

CREATE INDEX jobrunr_bgjobsrvrs_fsthb_idx ON public.jobrunr_backgroundjobservers USING btree (firstheartbeat);


--
-- Name: jobrunr_bgjobsrvrs_lsthb_idx; Type: INDEX; Schema: public; Owner: service_game_client
--

CREATE INDEX jobrunr_bgjobsrvrs_lsthb_idx ON public.jobrunr_backgroundjobservers USING btree (lastheartbeat);


--
-- Name: jobrunr_job_created_at_idx; Type: INDEX; Schema: public; Owner: service_game_client
--

CREATE INDEX jobrunr_job_created_at_idx ON public.jobrunr_jobs USING btree (createdat);


--
-- Name: jobrunr_job_rci_idx; Type: INDEX; Schema: public; Owner: service_game_client
--

CREATE INDEX jobrunr_job_rci_idx ON public.jobrunr_jobs USING btree (recurringjobid);


--
-- Name: jobrunr_job_scheduled_at_idx; Type: INDEX; Schema: public; Owner: service_game_client
--

CREATE INDEX jobrunr_job_scheduled_at_idx ON public.jobrunr_jobs USING btree (scheduledat);


--
-- Name: jobrunr_job_signature_idx; Type: INDEX; Schema: public; Owner: service_game_client
--

CREATE INDEX jobrunr_job_signature_idx ON public.jobrunr_jobs USING btree (jobsignature);


--
-- Name: jobrunr_jobs_state_updated_idx; Type: INDEX; Schema: public; Owner: service_game_client
--

CREATE INDEX jobrunr_jobs_state_updated_idx ON public.jobrunr_jobs USING btree (state, updatedat);


--
-- Name: jobrunr_recurring_job_created_at_idx; Type: INDEX; Schema: public; Owner: service_game_client
--

CREATE INDEX jobrunr_recurring_job_created_at_idx ON public.jobrunr_recurring_jobs USING btree (createdat);


--
-- Name: jobrunr_state_idx; Type: INDEX; Schema: public; Owner: service_game_client
--

CREATE INDEX jobrunr_state_idx ON public.jobrunr_jobs USING btree (state);


--
-- Name: players_token; Type: INDEX; Schema: public; Owner: service_game_client
--

CREATE INDEX players_token ON public.players USING btree (brand_id, token);


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: pg_database_owner
--

GRANT ALL ON SCHEMA public TO service_game_client;


--
-- Name: TABLE awsdms_ddl_audit; Type: ACL; Schema: public; Owner: service_dms
--

GRANT ALL ON TABLE public.awsdms_ddl_audit TO service_game_client;


--
-- Name: SEQUENCE awsdms_ddl_audit_c_key_seq; Type: ACL; Schema: public; Owner: service_dms
--

GRANT ALL ON SEQUENCE public.awsdms_ddl_audit_c_key_seq TO service_game_client;


--
-- Name: awsdms_intercept_ddl; Type: EVENT TRIGGER; Schema: -; Owner: rdsadmin
--

CREATE EVENT TRIGGER awsdms_intercept_ddl ON ddl_command_end
   EXECUTE FUNCTION public.awsdms_intercept_ddl();


ALTER EVENT TRIGGER awsdms_intercept_ddl OWNER TO rdsadmin;


INSERT INTO public.migrations (id, description) VALUES (1, 'create initial schemas');
INSERT INTO public.migrations (id, description) VALUES (2, 'create operator schemas');
INSERT INTO public.migrations (id, description) VALUES (3, 'create players table');
INSERT INTO public.migrations (id, description) VALUES (4, 'create bet settings table');
INSERT INTO public.migrations (id, description) VALUES (5, 'create bet table');
INSERT INTO public.migrations (id, description) VALUES (6, 'insert currencies');
INSERT INTO public.migrations (id, description) VALUES (7, 'insert game god-of-fortune');
INSERT INTO public.migrations (id, description) VALUES (8, 'insert dev brand');
INSERT INTO public.migrations (id, description) VALUES (9, 'insert game wild-west-saloon');
INSERT INTO public.migrations (id, description) VALUES (10, 'add brand endpoint');
INSERT INTO public.migrations (id, description) VALUES (11, 'create player state table');
INSERT INTO public.migrations (id, description) VALUES (12, 'insert languages');
INSERT INTO public.migrations (id, description) VALUES (13, 'insert game amazing-circus');
INSERT INTO public.migrations (id, description) VALUES (14, 'create features table');
INSERT INTO public.migrations (id, description) VALUES (15, 'insert features amazing-circus');
INSERT INTO public.migrations (id, description) VALUES (16, 'add player state version');
INSERT INTO public.migrations (id, description) VALUES (17, 'add player state version');
INSERT INTO public.migrations (id, description) VALUES (18, 'add bet version');
INSERT INTO public.migrations (id, description) VALUES (19, 'change bet amount');
INSERT INTO public.migrations (id, description) VALUES (20, 'change game details language code');
INSERT INTO public.migrations (id, description) VALUES (21, 'insert game aphrodite');
INSERT INTO public.migrations (id, description) VALUES (22, 'change player states table');
INSERT INTO public.migrations (id, description) VALUES (23, 'insert games');
INSERT INTO public.migrations (id, description) VALUES (24, 'insert game details');
INSERT INTO public.migrations (id, description) VALUES (25, 'insert game features');
INSERT INTO public.migrations (id, description) VALUES (26, 'add bet flow');
INSERT INTO public.migrations (id, description) VALUES (27, 'insert bet settings');
INSERT INTO public.migrations (id, description) VALUES (28, 'insert bierfest-delight bet settings');
INSERT INTO public.migrations (id, description) VALUES (29, 'insert empress-of-the-black-seas bet settings');
INSERT INTO public.migrations (id, description) VALUES (30, 'insert mayan-gold-hunt bet settings');
INSERT INTO public.migrations (id, description) VALUES (31, 'change myan game code');
INSERT INTO public.migrations (id, description) VALUES (32, 'add bet profit');
INSERT INTO public.migrations (id, description) VALUES (33, 'add bet balance');
INSERT INTO public.migrations (id, description) VALUES (34, 'add bet size bet level');
INSERT INTO public.migrations (id, description) VALUES (35, 'add bet starting and ending balance');
INSERT INTO public.migrations (id, description) VALUES (36, 'insert pumpkin-night bet settings');
INSERT INTO public.migrations (id, description) VALUES (37, 'add bet win free spins');
INSERT INTO public.migrations (id, description) VALUES (38, 'insert pumpkin-night feature');
INSERT INTO public.migrations (id, description) VALUES (39, 'cleanup');
INSERT INTO public.migrations (id, description) VALUES (40, 'add parent bet id');
INSERT INTO public.migrations (id, description) VALUES (41, 'add player state total win free spins');
INSERT INTO public.migrations (id, description) VALUES (42, 'add run-pug-run bet settings');
INSERT INTO public.migrations (id, description) VALUES (43, 'add player language');
INSERT INTO public.migrations (id, description) VALUES (44, 'add missing-bet-setting');
INSERT INTO public.migrations (id, description) VALUES (45, 'add missing-bet-setting');
INSERT INTO public.migrations (id, description) VALUES (46, 'insert game details 2');
INSERT INTO public.migrations (id, description) VALUES (47, 'add player state gamble');
INSERT INTO public.migrations (id, description) VALUES (48, 'change bet id player id');
INSERT INTO public.migrations (id, description) VALUES (49, 'remove unused tables');
INSERT INTO public.migrations (id, description) VALUES (50, 'add player last bet result');
INSERT INTO public.migrations (id, description) VALUES (51, 'add player token index');
INSERT INTO public.migrations (id, description) VALUES (52, 'add bet isEndRound');

INSERT INTO public.jobrunr_migrations (id, script, installedon) VALUES ('a532797f-3b39-4145-b2bb-52f0dbed6c51', 'v000__create_migrations_table.sql', '2024-05-05T16:45:41.544265150');
INSERT INTO public.jobrunr_migrations (id, script, installedon) VALUES ('dc09ba3f-6ca3-4b1f-97fa-6bd7867be978', 'v001__create_job_table.sql', '2024-05-05T16:45:41.972605252');
INSERT INTO public.jobrunr_migrations (id, script, installedon) VALUES ('09281965-8641-4723-9c18-7a4674d353c3', 'v002__create_recurring_job_table.sql', '2024-05-05T16:45:42.354157886');
INSERT INTO public.jobrunr_migrations (id, script, installedon) VALUES ('79f983b0-7bb1-4367-b24a-e2d0a1c714f5', 'v003__create_background_job_server_table.sql', '2024-05-05T16:45:42.784562788');
INSERT INTO public.jobrunr_migrations (id, script, installedon) VALUES ('ab12f207-e11f-424b-ae72-be8cb6655243', 'v004__create_job_stats_view.sql', '2024-05-05T16:45:43.200855237');
INSERT INTO public.jobrunr_migrations (id, script, installedon) VALUES ('e82d11e5-4f14-47d1-b95e-94ae4718a358', 'v005__update_job_stats_view.sql', '2024-05-05T16:45:43.554285493');
INSERT INTO public.jobrunr_migrations (id, script, installedon) VALUES ('e0b0a955-0202-47fc-9855-5c76b991a472', 'v006__alter_table_jobs_add_recurringjob.sql', '2024-05-05T16:45:43.783715925');
INSERT INTO public.jobrunr_migrations (id, script, installedon) VALUES ('d329da11-7c25-4345-a3d1-b2178cf1523b', 'v007__alter_table_backgroundjobserver_add_delete_config.sql', '2024-05-05T16:45:43.984111521');
INSERT INTO public.jobrunr_migrations (id, script, installedon) VALUES ('42ce201c-4cc9-4378-aaf4-8df0677faf2f', 'v008__alter_table_jobs_increase_jobAsJson_size.sql', '2024-05-05T16:45:44.273007699');
INSERT INTO public.jobrunr_migrations (id, script, installedon) VALUES ('370aa496-593a-41ba-9079-617de8e14c2b', 'v009__change_jobrunr_job_counters_to_jobrunr_metadata.sql', '2024-05-05T16:45:44.562547841');
INSERT INTO public.jobrunr_migrations (id, script, installedon) VALUES ('eb6192fa-c8d1-4c08-9122-12cec107ff4f', 'v010__change_job_stats.sql', '2024-05-05T16:45:44.782408340');
INSERT INTO public.jobrunr_migrations (id, script, installedon) VALUES ('0af8b999-22d0-45c9-9669-888443ecdb23', 'v011__change_sqlserver_text_to_varchar.sql', '2024-05-05T16:45:44.890014501');
INSERT INTO public.jobrunr_migrations (id, script, installedon) VALUES ('36275555-1f55-4b73-8894-756d477c7567', 'v012__change_oracle_alter_jobrunr_metadata_column_size.sql', '2024-05-05T16:45:45.160299741');
INSERT INTO public.jobrunr_migrations (id, script, installedon) VALUES ('90d65e3a-72d8-47af-b237-b646ef34dfd4', 'v013__alter_table_recurring_job_add_createdAt.sql', '2024-05-05T16:45:45.391594738');
INSERT INTO public.jobrunr_migrations (id, script, installedon) VALUES ('e03ec6bb-7c85-4f63-9aae-084c803f5efb', 'v014__improve_job_stats.sql', '2024-05-05T16:45:45.691041550');
INSERT INTO public.jobrunr_migrations (id, script, installedon) VALUES ('31bf751e-9b0a-4261-8d3b-05d868208495', 'v015__alter_table_backgroundjobserver_add_name.sql', '2024-05-05T16:45:45.968596488');

INSERT INTO public.jobrunr_metadata (id, name, owner, value, createdat, updatedat) VALUES ('id-cluster', 'id', 'cluster', '4aeff4fa-f4c3-485b-9b41-33c63ae48dd4', '2024-05-05 16:45:50.774709', '2024-05-05 16:45:51.070605');
INSERT INTO public.jobrunr_metadata (id, name, owner, value, createdat, updatedat) VALUES ('database_version-cluster', 'database_version', 'cluster', '6.0.0', '2024-05-05 16:45:51.154468', '2024-05-05 16:45:51.362552');
INSERT INTO public.jobrunr_metadata (id, name, owner, value, createdat, updatedat) VALUES ('succeeded-jobs-counter-cluster', 'succeeded-jobs-counter', 'cluster', '188', '2024-05-05 16:45:44.468569', '2024-05-05 16:45:44.468569');

--
-- PostgreSQL database dump complete
--
