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

	-- Таблицы
	drop table if exists public.measurment_input_params;
	drop table if exists public.measurment_baths;
	drop table if exists public.employees;
	drop table if exists public.measurment_types;
	drop table if exists public.military_ranks;
	drop table if exists public.calc_temperature_air;
	-- Константы
	drop table if exists public.measure_settings;

	-- Нумераторы
	drop sequence if exists public.measurment_input_params_seq;
	drop sequence if exists public.measurment_baths_seq;
	drop sequence if exists public.employees_seq;
	drop sequence if exists public.military_ranks_seq;
	drop sequence if exists public.measurment_types_seq;
	drop sequence if exists public.calc_temperature_air_seq;

	-- Типы данных
	DROP TYPE IF EXISTS public.input_parameters CASCADE;
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
	military_rank_id integer
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

-- Таблица для расчета поправки температуры
CREATE TABLE public.calc_temperature_air 
(
	id integer not null default nextval('public.calc_temperature_air_seq'),
	measurment_types_id integer not null,
	height integer not null,
	is_positive boolean not null,
	data integer[] not null
);

-- 200
insert into public.calc_temperature_air (height,measurment_types_id,is_positive,data)
values (200,1,True,array[1,2,3,4,5,6,7,8,9,10,20,30]);
insert into public.calc_temperature_air (height,measurment_types_id,is_positive,data)
values (200,1,False,array[-1,-2,-3,-4,-5,-6,-7,-8,-9,-20,-29,-39,-49]);

-- 400
insert into public.calc_temperature_air (height,measurment_types_id,is_positive,data)
values (400,1,True,array[1,2,3,4,5,6,7,8,9,10,20,30]);
insert into public.calc_temperature_air (height,measurment_types_id,is_positive,data)
values (400,1,False,array[-1,-2,-3,-4,-5,-6,-6,-7,-8,-9,-19,-20,-38,-48]);

-- 800
insert into public.calc_temperature_air (height,measurment_types_id,is_positive,data)
values (800,1,True,array[1,2,3,4,5,6,7,8,9,10,20,30]);
insert into public.calc_temperature_air (height,measurment_types_id,is_positive,data)
values (800,1,False,array[-1,-2,-3,-4,-5,-6,-6,-7,-7,-8,-18,-28,-37,-46]);

-- 1200
insert into public.calc_temperature_air (height,measurment_types_id,is_positive,data)
values (1200,1,True,array[1,2,3,4,5,6,7,8,9,10,20,30]);
insert into public.calc_temperature_air (height,measurment_types_id,is_positive,data)
values (1200,1,False,array[-1,-2,-3,-4,-4,-5,-5,-6,-7,-8,-17,-26,-35,-44]);

-- 1600
insert into public.calc_temperature_air (height,measurment_types_id,is_positive,data)
values (1600,1,True,array[1,2,3,4,5,6,7,8,9,10,20,30]);
insert into public.calc_temperature_air (height,measurment_types_id,is_positive,data)
values (1600,1,False,array[-1,-2,-3,-3,-4,-4,-5,-6,-7,-7,-17,-25,-34,-42]);

-- 2000
insert into public.calc_temperature_air (height,measurment_types_id,is_positive,data)
values (2000,1,True,array[1,2,3,4,5,6,7,8,9,10,20,30]);
insert into public.calc_temperature_air (height,measurment_types_id,is_positive,data)
values (2000,1,False,array[-1,-2,-3,-3,-4,-4,-5,-6,-6,-7,-16,-24,-32,-40]);

-- 2400
insert into public.calc_temperature_air (height,measurment_types_id,is_positive,data)
values (2400,1,True,array[1,2,3,4,5,6,7,8,9,10,20,30]);
insert into public.calc_temperature_air (height,measurment_types_id,is_positive,data)
values (2400,1,False,array[-1,-2,-2,-3,-4,-4,-5,-5,-6,-7,-15,-23,-31,-38]);

-- 3000
insert into public.calc_temperature_air (height,measurment_types_id,is_positive,data)
values (400,1,True,array[1,2,3,4,5,6,7,8,9,10,20,30]);
insert into public.calc_temperature_air (height,measurment_types_id,is_positive,data)
values (400,1,False,array[-1,-2,-2,-3,-4,-4,-4,-5,-5,-6,-15,-22,-30,-37]);

-- 4000
insert into public.calc_temperature_air (height,measurment_types_id,is_positive,data)
values (400,1,True,array[1,2,3,4,5,6,7,8,9,10,20,30]);
insert into public.calc_temperature_air (height,measurment_types_id,is_positive,data)
values (400,1,False,array[-1,-2,-2,-3,-4,-4,-4,-4,-5,-6,-14,-20,-27,-34]);


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
		wind_speed numeric(8,2)
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



	-- получить тип из параметров
	CREATE OR REPLACE FUNCTION public.get_input_params(
		height numeric(8,2),
		temperature numeric(8,2),
		pressure numeric(8,2),
		wind_direction numeric(8,2),
		wind_speed numeric(8,2))
		RETURNS input_parameters
		LANGUAGE 'plpgsql'
		COST 100
		VOLATILE PARALLEL UNSAFE
	AS $BODY$
	declare 
		res public.input_parameters;
	begin
		if NOT public.verify(temperature,pressure,wind_direction) then
			raise exception 'Неправельно введены данные';
		end if;
		res.height:=height;
		res.temperature:=temperature;
		res.pressure:=pressure;
		res.wind_direction:=wind_direction;
		res.wind_speed:=wind_speed;
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

		
		raise notice 'h: %, temp: %, pres: %, wind_dir: %, dependent: %',height_param,temp_param,pressure_param,wind_param,dependent_param;
	end;
	end loop;
	-- raise notice 'тестовые данные готовы';
	
end$$;


-- TODO : 
-- 1 переделать verify чтобы она могла говорить какая конкретно переменная передана некорректно
-- 2 сделать проверку на null при verify
-- 3 добавить проверок при остуствии константы в таблицах
-- Доделлать









