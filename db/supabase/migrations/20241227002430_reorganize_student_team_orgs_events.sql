drop policy "Admins can do anything" on "public"."student_events";

drop policy "Students can select their own rows" on "public"."student_events";

drop policy "Students can update their own rows" on "public"."student_events";

drop policy "Students can select their own team" on "public"."teams";

revoke delete on table "public"."student_events" from "anon";

revoke insert on table "public"."student_events" from "anon";

revoke references on table "public"."student_events" from "anon";

revoke select on table "public"."student_events" from "anon";

revoke trigger on table "public"."student_events" from "anon";

revoke truncate on table "public"."student_events" from "anon";

revoke update on table "public"."student_events" from "anon";

revoke delete on table "public"."student_events" from "authenticated";

revoke insert on table "public"."student_events" from "authenticated";

revoke references on table "public"."student_events" from "authenticated";

revoke select on table "public"."student_events" from "authenticated";

revoke trigger on table "public"."student_events" from "authenticated";

revoke truncate on table "public"."student_events" from "authenticated";

revoke update on table "public"."student_events" from "authenticated";

revoke delete on table "public"."student_events" from "service_role";

revoke insert on table "public"."student_events" from "service_role";

revoke references on table "public"."student_events" from "service_role";

revoke select on table "public"."student_events" from "service_role";

revoke trigger on table "public"."student_events" from "service_role";

revoke truncate on table "public"."student_events" from "service_role";

revoke update on table "public"."student_events" from "service_role";

alter table "public"."student_events" drop constraint "student_events_student_id_fkey";

alter table "public"."student_events" drop constraint "student_events_team_id_fkey";

drop view if exists "public"."student_events_detailed";

drop view if exists "public"."test_takers_detailed";

alter table "public"."student_events" drop constraint "student_events_pkey";

drop index if exists "public"."student_events_pkey";

drop table "public"."student_events";

create table "public"."student_org_events" (
    "student_id" uuid not null,
    "org_event_id" bigint not null,
    "joined_at" timestamp with time zone not null default now()
);


alter table "public"."student_org_events" enable row level security;

create table "public"."student_teams" (
    "relation_id" bigint generated by default as identity not null,
    "student_id" uuid not null,
    "team_id" bigint,
    "front_id" text,
    "division" text,
    "ticket_order_id" bigint not null
);


alter table "public"."student_teams" enable row level security;

create table "public"."ticket_orders" (
    "id" bigint generated by default as identity not null,
    "event_id" bigint not null,
    "student_id" uuid,
    "org_id" bigint,
    "quantity" bigint not null,
    "created_at" timestamp with time zone not null default now()
);


alter table "public"."ticket_orders" enable row level security;

alter table "public"."org_events" add column "organizer_pays" boolean not null;

CREATE UNIQUE INDEX single_org_event_entry ON public.org_events USING btree (event_id, org_id);

CREATE UNIQUE INDEX student_org_events_pkey ON public.student_org_events USING btree (student_id, org_event_id);

CREATE UNIQUE INDEX ticket_orders_pkey ON public.ticket_orders USING btree (id);

CREATE UNIQUE INDEX student_events_pkey ON public.student_teams USING btree (relation_id);

alter table "public"."student_org_events" add constraint "student_org_events_pkey" PRIMARY KEY using index "student_org_events_pkey";

alter table "public"."student_teams" add constraint "student_events_pkey" PRIMARY KEY using index "student_events_pkey";

alter table "public"."ticket_orders" add constraint "ticket_orders_pkey" PRIMARY KEY using index "ticket_orders_pkey";

alter table "public"."org_events" add constraint "single_org_event_entry" UNIQUE using index "single_org_event_entry";

alter table "public"."student_org_events" add constraint "student_event_orgs_event_id_fkey" FOREIGN KEY (org_event_id) REFERENCES org_events(id) not valid;
-- alter table "public"."student_org_events" add constraint "student_event_orgs_event_id_fkey" FOREIGN KEY (org_event_id) REFERENCES org_events(event_id) not valid

alter table "public"."student_org_events" validate constraint "student_event_orgs_event_id_fkey";

alter table "public"."student_org_events" add constraint "student_event_orgs_student_id_fkey" FOREIGN KEY (student_id) REFERENCES students(student_id) not valid;

alter table "public"."student_org_events" validate constraint "student_event_orgs_student_id_fkey";

alter table "public"."student_teams" add constraint "student_events_student_id_fkey" FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE not valid;

alter table "public"."student_teams" validate constraint "student_events_student_id_fkey";

alter table "public"."student_teams" add constraint "student_events_team_id_fkey" FOREIGN KEY (team_id) REFERENCES teams(team_id) ON DELETE CASCADE not valid;

alter table "public"."student_teams" validate constraint "student_events_team_id_fkey";

alter table "public"."student_teams" add constraint "student_teams_order_id_fkey" FOREIGN KEY (ticket_order_id) REFERENCES ticket_orders(id) not valid;

alter table "public"."student_teams" validate constraint "student_teams_order_id_fkey";

alter table "public"."ticket_orders" add constraint "has_student_or_org_id" CHECK ((((student_id IS NOT NULL) AND (org_id IS NULL)) OR ((student_id IS NULL) AND (org_id IS NOT NULL)))) not valid;

alter table "public"."ticket_orders" validate constraint "has_student_or_org_id";

alter table "public"."ticket_orders" add constraint "ticket_orders_event_id_fkey" FOREIGN KEY (event_id) REFERENCES events(event_id) not valid;

alter table "public"."ticket_orders" validate constraint "ticket_orders_event_id_fkey";

alter table "public"."ticket_orders" add constraint "ticket_orders_org_id_fkey" FOREIGN KEY (org_id) REFERENCES orgs(org_id) not valid;

alter table "public"."ticket_orders" validate constraint "ticket_orders_org_id_fkey";

alter table "public"."ticket_orders" add constraint "ticket_orders_student_id_fkey" FOREIGN KEY (student_id) REFERENCES students(student_id) not valid;

alter table "public"."ticket_orders" validate constraint "ticket_orders_student_id_fkey";

create or replace view "public"."student_events_detailed" as  SELECT se.relation_id,
    se.student_id,
    se.team_id,
    se.front_id,
    t.event_id,
    se.division,
    s.first_name,
    s.last_name,
    (u.email)::text AS email
   FROM (((student_teams se
     JOIN students s ON ((se.student_id = s.student_id)))
     JOIN teams t ON ((se.team_id = t.team_id)))
     JOIN auth.users u ON ((u.id = s.student_id)));


create or replace view "public"."test_takers_detailed" as  SELECT tt.test_taker_id,
    tt.student_id,
    tt.team_id,
    tt.test_id,
    tt.start_time,
    tt.end_time,
    tt.page_number,
        CASE
            WHEN (tt.student_id IS NOT NULL) THEN concat(s.first_name, ' ', s.last_name)
            WHEN (tt.team_id IS NOT NULL) THEN t.team_name
            ELSE 'Unknown'::text
        END AS taker_name,
        CASE
            WHEN (tt.team_id IS NOT NULL) THEN t.front_id
            WHEN (tt.student_id IS NOT NULL) THEN se.front_id
            ELSE NULL::text
        END AS front_id,
    te.test_name,
    te.division,
    e.event_name
   FROM (((((test_takers tt
     LEFT JOIN students s ON ((tt.student_id = s.student_id)))
     LEFT JOIN teams t ON ((tt.team_id = t.team_id)))
     LEFT JOIN tests te ON ((tt.test_id = te.test_id)))
     LEFT JOIN events e ON ((t.event_id = e.event_id)))
     LEFT JOIN student_teams se ON (((te.event_id = t.event_id) AND (s.student_id = se.student_id))));


grant delete on table "public"."student_org_events" to "anon";

grant insert on table "public"."student_org_events" to "anon";

grant references on table "public"."student_org_events" to "anon";

grant select on table "public"."student_org_events" to "anon";

grant trigger on table "public"."student_org_events" to "anon";

grant truncate on table "public"."student_org_events" to "anon";

grant update on table "public"."student_org_events" to "anon";

grant delete on table "public"."student_org_events" to "authenticated";

grant insert on table "public"."student_org_events" to "authenticated";

grant references on table "public"."student_org_events" to "authenticated";

grant select on table "public"."student_org_events" to "authenticated";

grant trigger on table "public"."student_org_events" to "authenticated";

grant truncate on table "public"."student_org_events" to "authenticated";

grant update on table "public"."student_org_events" to "authenticated";

grant delete on table "public"."student_org_events" to "service_role";

grant insert on table "public"."student_org_events" to "service_role";

grant references on table "public"."student_org_events" to "service_role";

grant select on table "public"."student_org_events" to "service_role";

grant trigger on table "public"."student_org_events" to "service_role";

grant truncate on table "public"."student_org_events" to "service_role";

grant update on table "public"."student_org_events" to "service_role";

grant delete on table "public"."student_teams" to "anon";

grant insert on table "public"."student_teams" to "anon";

grant references on table "public"."student_teams" to "anon";

grant select on table "public"."student_teams" to "anon";

grant trigger on table "public"."student_teams" to "anon";

grant truncate on table "public"."student_teams" to "anon";

grant update on table "public"."student_teams" to "anon";

grant delete on table "public"."student_teams" to "authenticated";

grant insert on table "public"."student_teams" to "authenticated";

grant references on table "public"."student_teams" to "authenticated";

grant select on table "public"."student_teams" to "authenticated";

grant trigger on table "public"."student_teams" to "authenticated";

grant truncate on table "public"."student_teams" to "authenticated";

grant update on table "public"."student_teams" to "authenticated";

grant delete on table "public"."student_teams" to "service_role";

grant insert on table "public"."student_teams" to "service_role";

grant references on table "public"."student_teams" to "service_role";

grant select on table "public"."student_teams" to "service_role";

grant trigger on table "public"."student_teams" to "service_role";

grant truncate on table "public"."student_teams" to "service_role";

grant update on table "public"."student_teams" to "service_role";

grant delete on table "public"."ticket_orders" to "anon";

grant insert on table "public"."ticket_orders" to "anon";

grant references on table "public"."ticket_orders" to "anon";

grant select on table "public"."ticket_orders" to "anon";

grant trigger on table "public"."ticket_orders" to "anon";

grant truncate on table "public"."ticket_orders" to "anon";

grant update on table "public"."ticket_orders" to "anon";

grant delete on table "public"."ticket_orders" to "authenticated";

grant insert on table "public"."ticket_orders" to "authenticated";

grant references on table "public"."ticket_orders" to "authenticated";

grant select on table "public"."ticket_orders" to "authenticated";

grant trigger on table "public"."ticket_orders" to "authenticated";

grant truncate on table "public"."ticket_orders" to "authenticated";

grant update on table "public"."ticket_orders" to "authenticated";

grant delete on table "public"."ticket_orders" to "service_role";

grant insert on table "public"."ticket_orders" to "service_role";

grant references on table "public"."ticket_orders" to "service_role";

grant select on table "public"."ticket_orders" to "service_role";

grant trigger on table "public"."ticket_orders" to "service_role";

grant truncate on table "public"."ticket_orders" to "service_role";

grant update on table "public"."ticket_orders" to "service_role";

create policy "Admins can do anything"
on "public"."student_teams"
as permissive
for all
to public
using ((( SELECT count(admins.admin_id) AS count
   FROM admins
  WHERE (admins.admin_id = auth.uid())) >= 1));


create policy "Students can select their own rows"
on "public"."student_teams"
as permissive
for select
to public
using ((student_id = auth.uid()));


create policy "Students can update their own rows"
on "public"."student_teams"
as permissive
for update
to public
using ((student_id = auth.uid()))
with check ((student_id = auth.uid()));


create policy "Students can select their own team"
on "public"."teams"
as permissive
for select
to public
using ((( SELECT count(student_teams.*) AS count
   FROM student_teams
  WHERE ((student_teams.student_id = auth.uid()) AND (student_teams.team_id = teams.team_id))) >= 1));
