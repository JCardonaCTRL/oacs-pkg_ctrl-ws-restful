--
-- /packages/ctrl-ws-restful/sql/oracle/aegis-mqol-create.sql
-- This contains the creation definition to aegis_mqol table this to store WS data
--
-- @cvs-id $Id$
-- @author Elias (elias@viaro.net)
-- @creation-date 11-04-2014


create table aegis_mqol (
	session_id integer,
	gi_symptoms_flare varchar2(100),
	burden varchar2(100),
	avoiding_social_activities varchar2(100),
	feel_anxious_about_trips varchar2(100),
	avoiding_physical_activities varchar2(100),
	careful_about_eating varchar2(100),
	important_near_bathroom varchar2(100),
	worried_symptoms_worsen varchar2(100),
	assume_worst varchar2(100),
	not_equipped varchar2(100),
	ongoing_gi_symptoms varchar2(100),
	worry_lose_control varchar2(100),
	wrong_with_body varchar2(100),
	cannot_focus varchar2(100),
	talking_moving_slowly varchar2(100),
	irritated_today varchar2(100),
	trouble_sleeping varchar2(100),
	not_enjoying_things varchar2(100),
	fidgety_restless varchar2(100),
	cannot_concentrate varchar2(100),
	feel_weak varchar2(100),
	losing_energy varchar2(100),
	feel_tired varchar2(100),
	friends_family_effect varchar2(100),
	body_working_against varchar2(100),
	caused_forces_outside varchar2(100),
	doctor_says varchar2(100),
	feel_sick varchar2(100),
	fate_playing_role varchar2(100),
	gi_sym_not_taken_seriously varchar2(100),
	hide_gi_sym varchar2(100),
	mental_not_physical varchar2(100),
	people_judging varchar2(100),
	constantly_aware varchar2(100),
	feel_anxious_frightened varchar2(100),
	worse_when_stressed varchar2(100),
	woke_up_worried varchar2(100),
	muscles_tense varchar2(100),
	worrying_about_many_things varchar2(100),
	hard_to_control_worries varchar2(100),
	depression varchar2(100),
	fatigue varchar2(100),
	general_anxiety varchar2(100),
	visual_anxiety varchar2(100),
	anticipation varchar2(100),
	catastrophizing varchar2(100),
	loc varchar2(100),
	stigma varchar2(100)
);