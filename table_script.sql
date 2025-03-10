do $$
begin

/*
 1. Удаляем старые элементы
 ======================================
 */

raise notice 'Запускаем создание новой структуры базы данных meteo'; 
begin

	-- Связи
	alter table if exists public.measurment_input_params
	drop constraint if exists measurment_type_id_fk;

	alter table if exists public.employees
	drop constraint if exists military_rank_id_fk;

	alter table if exists public.measurment_baths
	drop constraint if exists measurment_input_param_id_fk;

	alter table if exists public.measurment_baths
	drop constraint if exists emploee_id_fk;

	alter table if exists public.log_events
	drop constraint if exists log_type_id_fk;

	-- Таблицы
	drop table if exists public.measurment_input_params CASCADE;
	drop table if exists public.measurment_baths;
	drop table if exists public.employees;
	drop table if exists public.measurment_types cascade;
	drop table if exists public.military_ranks;
	drop table if exists public.calc_temperature_air;
	drop table if exists public.calc_air_table_correction;
	DROP TABLE IF EXISTS public.log_types;
	DROP TABLE IF EXISTS public.log_events;
	DROP TABLE IF EXISTS public.calc_wind_correction;
	drop table if exists public.calc_wind_table_correction;
	drop TABLE IF NOT EXISTS public.table_header;
	drop TABLE IF NOT EXISTS public.table_heghts;
	drop TABLE IF NOT EXISTS public.table_values;
	-- Константы
	drop table if exists public.measure_settings;

	-- Нумераторы
	drop sequence if exists public.measurment_input_params_seq;
	drop sequence if exists public.measurment_baths_seq;
	drop sequence if exists public.employees_seq;
	drop sequence if exists public.military_ranks_seq;
	drop sequence if exists public.measurment_types_seq;
	drop sequence if exists public.calc_temperature_air_seq;
	drop sequence if exists public.log_types_seq;
	drop sequence if exists public.log_events_seq;
	drop sequence if exists public.table_heghts_seq;
	drop sequence if exists public.table_header_seq;
	-- Типы данных
	DROP TYPE IF EXISTS public.input_parameters CASCADE;


	DROP PROCEDURE public.sp_get_temperature_air(numeric, numeric[]);
end;

raise notice 'Удаление старых данных выполнено успешно';

/*
 2. Добавляем структуры данных 
 ================================================
 */

-- Справочник должностей
create table military_ranks
(
	id integer primary key not null,
	description character varying(255)
);

insert into military_ranks(id, description)
values(1,'Рядовой'),(2,'Лейтенант');

create sequence military_ranks_seq start 3;

alter table military_ranks alter column id set default nextval('public.military_ranks_seq');

-- Пользователя
create table employees
(
    id integer primary key not null,
	name text,
	birthday timestamp ,
	military_rank_id integer not null
);

insert into employees(id, name, birthday,military_rank_id )  
values(1, 'Воловиков Александр Сергеевич','1978-06-24', 2);

create sequence employees_seq start 2;

alter table employees alter column id set default nextval('public.employees_seq');


-- Устройства для измерения
create table measurment_types
(
   id integer primary key not null,
   short_name  character varying(50),
   description text 
);

insert into measurment_types(id, short_name, description)
values(1, 'ДМК', 'Десантный метео комплекс'),
(2,'ВР','Ветровое ружье');

create sequence measurment_types_seq start 3;

alter table measurment_types alter column id set default nextval('public.measurment_types_seq');

-- Таблица с параметрами
create table measurment_input_params
(
    id integer primary key not null,
	measurment_type_id integer not null,
	height numeric(8,2) default 0,
	temperature numeric(8,2) default 0,
	pressure numeric(8,2) default 0,
	wind_direction numeric(8,2) default 0,
	wind_speed numeric(8,2) default null,
	bullet_demolition_range numeric(8,2) default null
);

insert into measurment_input_params(id, measurment_type_id, height, temperature, pressure, wind_direction,wind_speed )
values(1, 1, 100,12,34,0.2,45);

create sequence measurment_input_params_seq start 2;

alter table measurment_input_params alter column id set default nextval('public.measurment_input_params_seq');

-- Таблица с историей
create sequence public.calc_temperature_air_seq;
create table measurment_baths
(
		id integer primary key not null,
		emploee_id integer not null,
		measurment_input_param_id integer not null,
		started timestamp default now()
);


insert into measurment_baths(id, emploee_id, measurment_input_param_id)
values(1, 1, 1);

create sequence measurment_baths_seq start 2;

alter table measurment_baths alter column id set default nextval('public.measurment_baths_seq');

raise notice 'Создание общих справочников и наполнение выполнено успешно'; 

-- Таблица для проверки входных данных
create table public.measure_settings(
	setting_name character varying(100) primary key not null,
	setting_value character varying(100)  not null
);


insert into public.measure_settings(setting_name,setting_value) values ('temperature_const','15.9');
insert into public.measure_settings(setting_name,setting_value) values ('pressure_const','750');
insert into public.measure_settings(setting_name,setting_value) values ('temperature_min','-58');
insert into public.measure_settings(setting_name,setting_value) values ('temperature_max','58');
insert into public.measure_settings(setting_name,setting_value) values ('pressure_min','500');
insert into public.measure_settings(setting_name,setting_value) values ('pressure_max','900');
insert into public.measure_settings(setting_name,setting_value) values ('wind_direction_min','0');
insert into public.measure_settings(setting_name,setting_value) values ('wind_direction_max','59');
insert into public.measure_settings(setting_name,setting_value) values ('wind_speed_min','0');
insert into public.measure_settings(setting_name,setting_value) values ('wind_speed_max','15');
insert into public.measure_settings(setting_name,setting_value) values ('bullet_demolition_min','0');
insert into public.measure_settings(setting_name,setting_value) values ('bullet_demolition_max','150');



-- ===таблицы для расчета===

-- таблица заголовков
CREATE TABLE IF NOT EXISTS public.table_header
(
    id integer NOT NULL,
    measure_type integer NOT NULL,
	table_type integer NOT NULL,
    header_values integer[] NOT NULL,
	description character varying(100),
    CONSTRAINT table_header_pkey PRIMARY KEY (id)
);

create sequence table_header_seq start 1;

alter table table_header alter column id set default nextval('public.table_header_seq');

insert into public.table_header(measure_type,table_type,header_values,description)
values(1,1,array[1,2,3,4,5,6,7,8,9,10,20,30,40,50],' ДМК и ВР таблица 2');
insert into public.table_header(measure_type,table_type,header_values,description)
values(2,2,array[40,50,60,70,80,90,100,110,120,130,140,150],' ВР таблица 3');


-- высоты
CREATE TABLE IF NOT EXISTS public.table_heghts
(
    id integer NOT NULL,
    height integer NOT NULL,
	measure_type integer NOT NULL,
    CONSTRAINT table_heghts_pkey PRIMARY KEY (id)
);

create sequence table_heghts_seq start 1;

alter table table_heghts alter column id set default nextval('public.table_heghts_seq');

insert into table_heghts(height,measure_type)
values (200,1),(400,1),(800,1),(1200,1),(1600,1),(2000,1),(2400,1),(3000,1),(4000,1),
(200,2),(400,2),(800,2),(1200,2),(1600,2),(2000,2),(2400,2),(3000,2),(4000,2);

-- таблица значений
CREATE TABLE IF NOT EXISTS public.table_values
(
	id integer not null,
    id_height integer NOT NULL,
    data_positive integer[],
	data_negative integer[],
    delta integer,
	constraint table_values_pkey PRIMARY KEY (id)
);

-- вставляем данные таблицы для таблицы 2 
insert into public.table_values(id_height,data_positive,data_negative,delta)
values(1,array[1,2,3,4,5,6,7,8,9,10,20,30],array[-1,-2,-3,-4,-5,-6,-7,-8,-9,-20,-29,-39,-49],null),
(2,array[1,2,3,4,5,6,7,8,9,10,20,30],array[-1,-2,-3,-4,-5,-6,-6,-7,-8,-9,-19,-20,-38,-48],null),
(3,array[1,2,3,4,5,6,7,8,9,10,20,30],array[-1,-2,-3,-4,-5,-6,-6,-7,-7,-8,-18,-28,-37,-46],null),
(4,array[1,2,3,4,5,6,7,8,9,10,20,30],array[-1,-2,-3,-4,-4,-5,-5,-6,-7,-8,-17,-26,-35,-44],null),
(5,array[1,2,3,4,5,6,7,8,9,10,20,30],array[-1,-2,-3,-3,-4,-4,-5,-6,-7,-7,-17,-25,-34,-42],null),
(6,array[1,2,3,4,5,6,7,8,9,10,20,30],array[-1,-2,-3,-3,-4,-4,-5,-6,-6,-7,-16,-24,-32,-40],null),
(7,array[1,2,3,4,5,6,7,8,9,10,20,30],array[-1,-2,-2,-3,-4,-4,-5,-5,-6,-7,-15,-23,-31,-38],null),
(8,array[1,2,3,4,5,6,7,8,9,10,20,30],array[-1,-2,-2,-3,-4,-4,-4,-5,-5,-6,-15,-22,-30,-37],null),
(9,array[1,2,3,4,5,6,7,8,9,10,20,30],array[-1,-2,-2,-3,-4,-4,-4,-4,-5,-6,-14,-20,-27,-34],null);


-- вставляем данные для таблицы 3
insert into public.table_values(id_height,data_positive,data_negative,delta)
values (10,array[3,4,5,6,7,7,8,9,10,11,12,12],null,0),(11,array[4,5,6,7,8,9,10,11,12,13,14,15],null,1),
(12,array[4,5,6,7,8,9,10,11,13,14,15,16],null,2),(13,array[4,5,7,8,8,9,11,12,13,15,15,16],null,2),
(14,array[4,6,7,8,9,10,11,13,14,15,17,17],null,3),(15,array[4,6,7,8,9,10,11,13,14,16,17,18],null,3),
(16,array[4,6,8,9,9,10,12,14,15,16,18,19],null,3),(17,array[5,6,8,9,10,11,12,14,15,17,18,19],null,4),
(18,array[5,6,8,9,10,11,12,14,16,18,19,20],null,4);

-- ===================================================================================================================



-- Типы логов
CREATE TABLE IF NOT EXISTS public.log_types
(
    id integer NOT NULL,
    name character varying(100) COLLATE pg_catalog."default",
    CONSTRAINT log_types_pkey PRIMARY KEY (id)
);

create sequence log_types_seq start 1;

alter table public.log_types alter column id set default nextval('public.log_types_seq');

insert into public.log_types(name) values('input');
insert into public.log_types(name) values('error');

-- Логи
CREATE TABLE IF NOT EXISTS public.log_events
(
    id integer NOT NULL DEFAULT nextval('log_types_seq'::regclass),
    log_type_id integer NOT NULL,
    event_log json,
    event_time timestamp without time zone DEFAULT now(),
    CONSTRAINT log_events_pkey PRIMARY KEY (id)
);

create sequence log_events_seq start 1;


alter table public.log_events alter column id set default nextval('public.log_types_seq');

-- индексы

create index ix_measurment_baths_emploee_id 
on public.measurment_baths(emploee_id);

create index ix_employees_military_rank_id 
on public.employees(military_rank_id );

create index ix_log_type_id 
on public.log_events(log_type_id);




raise notice 'Создание общих констант для рассчетов выполнено успешно';


/*
 3. Подготовка расчетных структур
 ==========================================
 */

drop table if exists calc_temperatures_correction;
create table calc_temperatures_correction
(
   temperature numeric(8,2) primary key,
   correction numeric(8,2)
);

insert into public.calc_temperatures_correction(temperature, correction)
Values(0, 0.5),(5, 0.5),(10, 1), (20,1), (25, 2), (30, 3.5), (40, 4.5);

drop type  if exists interpolation_type;
create type interpolation_type as
(
	x0 numeric(8,2),
	x1 numeric(8,2),
	y0 numeric(8,2),
	y1 numeric(8,2)
);

raise notice 'Расчетные структуры сформированы';

/*
 4. Создание связей
 ==========================================
 */

begin 
	
	alter table public.measurment_baths
	add constraint emploee_id_fk 
	foreign key (emploee_id)
	references public.employees (id);
	
	alter table public.measurment_baths
	add constraint measurment_input_param_id_fk 
	foreign key(measurment_input_param_id)
	references public.measurment_input_params(id);
	
	alter table public.measurment_input_params
	add constraint measurment_type_id_fk
	foreign key(measurment_type_id)
	references public.measurment_types (id);
	
	alter table public.employees
	add constraint military_rank_id_fk
	foreign key(military_rank_id)
	references public.military_ranks (id);

	alter table public.log_events
	add constraint log_type_id_fk
	foreign key(log_type_id)
	references public.log_types (id);
end;

raise notice 'Связи сформированы';
raise notice 'Структура сформирована успешно';


/*
 5. Создание типов данных
=======================================
*/
begin
	CREATE TYPE public.input_parameters AS
	(
		height numeric(8,2),
		temperature numeric(8,2),
		pressure numeric(8,2),
		wind_direction numeric(8,2),
		wind_speed numeric(8,2),
		is_counted boolean
	);
end;


/*
 6. Создание функций
=======================================
*/
begin 
	CREATE OR REPLACE FUNCTION public.get_setting(
		input_setting_name character varying)
		RETURNS  character varying(100)
		LANGUAGE 'plpgsql'
		COST 100
		VOLATILE PARALLEL UNSAFE
	AS $BODY$
	declare 
		ret numeric;
	begin
	select setting_value from public.measure_settings where setting_name = input_setting_name limit 1 into ret;
	if ret is null then
		raise exception 'name % was not found',input_setting_name;
	end if;
	return ret;

	end;
	$BODY$;


	-- получить константу
	CREATE OR REPLACE FUNCTION public.get_setting_num(
		input_setting_name character varying)
		RETURNS numeric
		LANGUAGE 'plpgsql'
		COST 100
		VOLATILE PARALLEL UNSAFE
	AS $BODY$
	declare 
		ret character varying(100);
	begin
	ret:=public.get_setting(input_setting_name);
	return ret::numeric(8,2);

	end;
	$BODY$;


	-- проверить конкретный параметр
	CREATE OR REPLACE FUNCTION public.verify_param(
		parameter numeric(8,2),
		parameter_name character varying(100),
		lower_border numeric(8,2),
		upper_border numeric(8,2)
		)
		RETURNS boolean
		LANGUAGE 'plpgsql'
		COST 100
		VOLATILE PARALLEL UNSAFE
	AS $BODY$
	declare 
		ret boolean;
	begin
		if parameter is null then
			raise exception 'parameter % is null',parameter_name;
		end if;
		ret:=parameter>=lower_border AND parameter<=upper_border;
		if NOT ret then
			raise exception 'parameter % was written wrong',parameter_name;
		end if;
		return ret;
	end;
	$BODY$;



	-- проверить данные
	CREATE OR REPLACE FUNCTION public.verify(
		temperature numeric(8,2),
		pressure numeric(8,2),
		wind_direction numeric(8,2))
		RETURNS boolean
		LANGUAGE 'plpgsql'
		COST 100
		VOLATILE PARALLEL UNSAFE
	AS $BODY$
	begin
		return public.verify_param(temperature,'temperature',public.get_setting_num('temperature_min'),public.get_setting_num('temperature_max')) AND  public.verify_param(pressure,'pressure',public.get_setting_num('pressure_min'),public.get_setting_num('pressure_max')) AND  public.verify_param(temperature,'wind_direction',public.get_setting_num('wind_direction_min'),public.get_setting_num('wind_direction_max'));
	end;
	$BODY$;

	-- проверить данные без исключений
	CREATE OR REPLACE FUNCTION public.verify_without_bool(
		temperature numeric(8,2),
		pressure numeric(8,2),
		wind_direction numeric(8,2))
		RETURNS boolean
		LANGUAGE 'plpgsql'
		COST 100
		VOLATILE PARALLEL UNSAFE
	AS $BODY$
	begin
		return public.verify_param(temperature,'temperature',public.get_setting_num('temperature_min'),public.get_setting_num('temperature_max')) AND  public.verify_param(pressure,'pressure',public.get_setting_num('pressure_min'),public.get_setting_num('pressure_max')) AND  public.verify_param(temperature,'wind_direction',public.get_setting_num('wind_direction_min'),public.get_setting_num('wind_direction_max'));
		exception when others then begin
		-- {user,error_type,error_code}
		return 0;
		end;
	end;
	$BODY$;


	-- получить тип из параметров
	CREATE OR REPLACE FUNCTION public.get_input_params(
		height_inp numeric(8,2),
		temperature_inp numeric(8,2),
		pressure_inp numeric(8,2),
		wind_direction_inp numeric(8,2),
		wind_speed_inp numeric(8,2))
		RETURNS input_parameters
		LANGUAGE 'plpgsql'
		COST 100
		VOLATILE PARALLEL UNSAFE
	AS $BODY$
	declare 
		res public.input_parameters;
		counted_id integer;
	begin
		if NOT public.verify(temperature_inp,pressure_inp,wind_direction_inp) then
			raise exception 'Неправельно введены данные';
		end if;
		res.height:=height_inp;
		res.temperature:=temperature_inp;
		res.pressure:=pressure_inp;
		res.wind_direction:=wind_direction_inp;
		res.wind_speed:=wind_speed_inp;
		select id from public.measurment_input_params order by id desc limit 1 into counted_id;

		res.is_counted:=(counted_id is NOT null);

		if not res.is_counted then 
			call public.sp_make_log_inp(row_to_json(res));
		end if;

		return res;

	end;
	$BODY$;


	-- посчитать отклонение давления
	CREATE OR REPLACE FUNCTION public.get_delta_pressure(
		pressure numeric(8,2))
		RETURNS numeric
		LANGUAGE 'plpgsql'
		COST 100
		VOLATILE PARALLEL UNSAFE
	AS $BODY$
	declare 
		tmp_pressure numeric(8,2);
	begin
		tmp_pressure:= pressure-public.get_setting_num('pressure_const');
		if tmp_pressure < 0 then
			tmp_pressure:=tmp_pressure*(-1)+500;
		end if;
		return tmp_pressure;
	
	end;
	$BODY$;

	-- посчитать температуру
	CREATE OR REPLACE FUNCTION public.get_temperature_interpolation(temperature_inp numeric(8,2)
		)
		RETURNS numeric
		LANGUAGE 'plpgsql'
		COST 100
		VOLATILE PARALLEL UNSAFE
	AS $BODY$
	declare 
		borders public.interpolation_type;
		t_delta numeric(8,2);
	begin
		select temperature,correction from public.calc_temperatures_correction where temperature <= temperature_inp order by temperature desc limit 1 into borders.x0,borders.y0;
		select temperature,correction from public.calc_temperatures_correction where temperature > temperature_inp order by temperature limit 1 into borders.x1,borders.y1;
		t_delta:=temperature_inp+((temperature_inp-borders.x0)*(borders.y1-borders.y0)/(borders.x1-borders.x0)+borders.y0);
		return round(t_delta-public.get_setting_num('temperature_const'));
	end;
	$BODY$;

	-- красивый вывод 
	CREATE OR REPLACE FUNCTION public.get_output_row(inp public.input_parameters, date timestamp with time zone
		)
		RETURNS  TABLE(ddhhm character(5), hhhh character(4), ppptt text)
		LANGUAGE 'plpgsql'
		COST 100
		VOLATILE PARALLEL UNSAFE
	AS $BODY$
	begin
		return query select substring(to_char(date, 'DDHHMI'), 1, 5)::character(5), lpad(round(inp.height)::text, 4, '0')::character(4), lpad(public.get_delta_pressure(inp.pressure)::text, 3, '0') || lpad(public.get_temperature_interpolation(inp.temperature)::text, 2, '0');
	end;
	$BODY$;







	-- операции

	-- табличный расчет температуры
	CREATE OR REPLACE PROCEDURE public.sp_get_temperature_air(
		IN inp_temp numeric,
		INOUT ret numeric[] default array[]::numeric[]) 
	LANGUAGE 'plpgsql'
	AS $BODY$
	declare 
		abs_temp numeric;
		diff_temp numeric;
		border_initial numeric;
		border_addit numeric;
		line integer[];
		cur_height integer;
		heights integer[];
	begin
		inp_temp:=floor(inp_temp);
		abs_temp:=abs(inp_temp);
		if abs_temp>10 then
		begin
			select index,temperature from public.calc_air_table_correction as t1 where t1.temperature<abs_temp order by t1.temperature desc limit 1 into border_initial,diff_temp;
			select index from public.calc_air_table_correction as t1 where t1.temperature=abs_temp-diff_temp limit 1 into border_addit;
		end;
		else
			select index from public.calc_air_table_correction as t1 where t1.temperature=abs_temp order by t1.temperature desc limit 1 into border_initial;
		end if;


		-- проверки
		if border_initial is null or diff_temp is null then
			raise exception 'parameters for temperature % are not found',abs_temp;
		end if;



		-- берем высоты
		select array_agg(h_arr) from (select distinct height as h_arr from public.calc_temperature_air order by height) into heights;

		raise notice '%',heights;
		foreach cur_height in array heights loop
		begin
			select data from public.calc_temperature_air where public.calc_temperature_air.height = cur_height and public.calc_temperature_air.is_positive=(inp_temp>0) into line;
			if abs_temp>10 then
				ret:=ret|| (line[border_initial-1]+line[border_addit-1]);
			else
				ret:=ret|| (line[border_initial]);
			end if;

		end;
		end loop;
		raise notice '%',ret;

	end;
	$BODY$;


	-- табличный расчет ветра
	CREATE OR REPLACE PROCEDURE public.sp_get_wind_correction(
		IN dem_range integer,
		IN wind_alph integer,
		INOUT ret_speed numeric[] default array[]::numeric[],
		INOUT ret_alph  numeric[] default array[]::numeric[])
	LANGUAGE 'plpgsql'
	AS $BODY$
	declare
			cur_height integer;
			speed numeric(8,2);
			heights integer[];
			line numeric[];
			line_index integer;
			line_alpha integer;
	begin
		-- берем индекс для массива
		select index from public.calc_wind_table_correction 
		where dem_range>demolition order by demolition desc limit 1 into line_index;

		-- берем высоты
		select array_agg(h_arr) from 
			(select distinct height as h_arr 
			from  public.calc_wind_correction
			order by height) into heights;
		if line_index=12 then
				raise exception 'demolition range is out of range';
		end if;


		foreach cur_height in array heights loop
		begin
			select bullet_demolition,alpha from public.calc_wind_correction
			where height=cur_height into line,line_alpha;
			if line_index is null then 
			begin
				raise notice 'speed=%; alpha=%',0,alpha;
				ret_speed:=ret_speed|| 0;
				ret_alph:=ret_alph||alpha;
			end;
			else
				begin
					speed:=line[line_index]+(line[line_index+1]-line[line_index])*0.1;
					raise notice 'speed=%; alpha=%',speed,line_alpha;
					ret_speed:=ret_speed|| speed::numeric;
					ret_alph:=ret_alph||line_alpha::numeric;
				end;
			end if;
		end;
		end loop;
	end;
	$BODY$;




	-- логирование
	CREATE OR REPLACE PROCEDURE public.sp_make_log(
	IN log_type integer,
	IN log_data json)
	LANGUAGE 'plpgsql'
	AS $BODY$
	declare
		check_log_type integer;
	begin
		select id from public.log_types where id=log_type into check_log_type;
		if check_log_type is null then
			raise exception 'no such log type: %',log_type;
		end if;

		insert into public.log_events(log_type_id,event_log) 
		values (log_type,log_data);
	end;
	$BODY$;


	--логирование входа
	CREATE OR REPLACE PROCEDURE public.sp_make_log_inp(
		IN log_data json)
	LANGUAGE 'plpgsql'
	AS $BODY$
	begin
	call sp_make_log(1,log_data);
	end;
	$BODY$;

	-- error 
	CREATE OR REPLACE PROCEDURE public.sp_make_log_inp(
		IN log_data json)
	LANGUAGE 'plpgsql'
	AS $BODY$
	begin
	call sp_make_log(2,log_data);
	end;
	$BODY$;

	

end;




end $$;










-- вставить тестовые данные
--  height, temperature, pressure, wind_direction, wind_speed
do $$
declare 
	height_param numeric(8,2);
	temp_param numeric(8,2);
	pressure_param numeric(8,2);
	wind_param numeric(8,2);
	dependent_param numeric (8,2);
	emploeeid  numeric;
	u_id integer;
	device boolean;
begin


	insert into employees(id, name, birthday,military_rank_id )  values(2, 'Антонов Антон Антонович','1978-06-24', 1);

	insert into employees(id, name, birthday,military_rank_id )  values(3, 'Сергеев Петр Николаевич','1938-06-14', 2);

	insert into employees(id, name, birthday,military_rank_id )  values(4, 'Сергеев Петр Анатольевич','1958-03-4', 1);
	for var_index in 1..100 loop
	begin
		height_param:=floor(random()*(100+100)-100);
		temp_param:=floor(random()*(58+58)-58);
		pressure_param:=floor(random()*(900-500)+500);
		wind_param:=floor(random()*(59-0)+0);
		
		emploeeid :=floor(random()*(4-1)+1);
		device:=random()>0.5;

		if device then
			begin 
				dependent_param:=floor(random()*(15-0)+0);
				insert into public.measurment_input_params(measurment_type_id,height,temperature,pressure,wind_direction,wind_speed) values(1,height_param,temp_param,pressure_param,wind_param,dependent_param);
			end;
		else
			begin
				dependent_param:=floor(random()*(150-0)+0);
				insert into public.measurment_input_params(measurment_type_id,height,temperature,pressure,wind_direction,bullet_demolition_range) values(1,height_param,temp_param,pressure_param,wind_param,dependent_param);
			end;
		end if;
		select id,height,temperature,pressure,wind_direction,wind_speed from public.measurment_input_params limit 1 offset var_index into u_id,height_param,temp_param,pressure_param,wind_param,dependent_param;

		insert into public.measurment_baths(emploee_id, measurment_input_param_id, started) values(emploeeid ,u_id,now());

		
		-- raise notice 'h: %, temp: %, pres: %, wind_dir: %, dependent: %',height_param,temp_param,pressure_param,wind_param,dependent_param;
	end;
	end loop;
	raise notice 'тестовые данные готовы';
	
end$$;








-- Отчеты
do $$
begin
	-- создать отчет cte
	CREATE OR REPLACE VIEW public.view_original
	AS
	with get_measure_verified as ( SELECT t1_1.emploee_id,t3.name,
						t4.description,
						count(*) AS all_measures,
						sum(verify_without_bool(t2.temperature, t2.pressure, t2.wind_direction)::integer) AS true_measures
					FROM measurment_baths t1_1
						JOIN measurment_input_params t2 ON t1_1.measurment_input_param_id = t2.id
						JOIN employees t3 ON t3.id = t1_1.emploee_id
						JOIN military_ranks t4 ON t3.military_rank_id = t4.id
					GROUP BY t3.name, t4.description, t1_1.emploee_id
	)
	SELECT emploee_id,
		name,
		description,
		all_measures,
		all_measures-true_measures as false_measure
	FROM get_measure_verified order by all_measures-true_measures desc;




	-- отчет минимум 10 ошибок
	CREATE OR REPLACE VIEW public.view_best_height
	AS
	with get_measure_verified as ( SELECT t1_1.emploee_id,t3.name,
						t4.description,
						count(*) AS all_measures,
						sum(verify_without_bool(t2.temperature, t2.pressure, t2.wind_direction)::integer) AS true_measures
					FROM measurment_baths t1_1
						JOIN measurment_input_params t2 ON t1_1.measurment_input_param_id = t2.id
						JOIN employees t3 ON t3.id = t1_1.emploee_id
						JOIN military_ranks t4 ON t3.military_rank_id = t4.id
					GROUP BY t3.name, t4.description, t1_1.emploee_id
	),
	get_height as (select t2.emploee_id,min(t1.height) as min_h,max(t1.height) as max_h
		from measurment_input_params t1 inner join
		measurment_baths t2 on t2.measurment_input_param_id=t1.id 
		group by t2.emploee_id
	)
	SELECT 
		t1.name,
		t1.description,
		t2.min_h,
		t2.max_h,
		t1.all_measures,
		t1.all_measures-t1.true_measures as false_measure
	FROM get_measure_verified t1 inner join
	get_height t2 on t2.emploee_id=t1.emploee_id
	where t1.all_measures>5 and t1.all_measures-t1.true_measures<10;


end$$;






-- демонстрация 
do $$
declare 
	a numeric[];
	b numeric[];
begin
	-- расчет ветра 
	call public.sp_get_wind_correction(56,5,a,b);
end $$;

-- TODO 28.02.2025:
-- 1. в отчете вынести вычесляемое поле из order by - (думать)
-- 2. проверка на отсутствие ранга (поменять inner join на left join или сделать запрет not null в military ranks) - СДЕЛАНО 78 строка
-- 3. переделать отчет под cte
-- 4. формата последний в должности|неверные измерения







