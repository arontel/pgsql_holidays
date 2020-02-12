------------------------------------------
------------------------------------------
-- Kenya Holidays
--
-- https://en.wikipedia.org/wiki/Public_holidays_in_Kenya
-- http://kenyaembassyberlin.de/Public-Holidays-in-Kenya.48.0.html
------------------------------------------
------------------------------------------
--
CREATE OR REPLACE FUNCTION holidays.kenya(p_start_year INTEGER, p_end_year INTEGER)
RETURNS SETOF holidays.holiday
AS $$

DECLARE
	-- Month Constants
	JANUARY INTEGER := 1;
	FEBRUARY INTEGER := 2;
	MARCH INTEGER := 3;
	APRIL INTEGER := 4;
	MAY INTEGER := 5;
	JUNE INTEGER := 6;
	JULY INTEGER := 7;
	AUGUST INTEGER := 8;
	SEPTEMBER INTEGER := 9;
	OCTOBER INTEGER := 10;
	NOVEMBER INTEGER := 11;
	DECEMBER INTEGER := 12;
	-- Weekday Constants
	SUNDAY INTEGER := 0;
	MONDAY INTEGER := 1;
	TUESDAY INTEGER := 2;
	WEDNESDAY INTEGER := 3;
	THURSDAY INTEGER := 4;
	FRIDAY INTEGER := 5;
	SATURDAY INTEGER := 6;
	WEEKEND INTEGER[] := ARRAY[0, 6];
	-- Primary Loop
	t_years INTEGER[] := (SELECT ARRAY(SELECT generate_series(p_start_year, p_end_year)));
	-- Holding Variables
	t_year INTEGER;
	t_datestamp DATE;
	t_dt1 DATE;
	t_dt2 DATE;
	t_holiday holidays.holiday%rowtype;

BEGIN
	FOREACH t_year IN ARRAY t_years
	LOOP
		-- Defaults for additional attributes
		t_holiday.authority := 'national';
		t_holiday.day_off := TRUE;
		t_holiday.observation_shifted := FALSE;
		
		-- Public holidays
		t_datestamp := make_date(t_year, JANUARY, 1);
		t_holiday.datestamp := t_datestamp;
		t_holiday.description := 'New Year''s Day';
		RETURN NEXT t_holiday;
		IF DATE_PART('dow', t_datestamp) = SUNDAY THEN
			t_holiday.datestamp := t_datestamp + '1 Day'::INTERVAL;
			t_holiday.description := 'New Year''s Day (Observed)';
			t_holiday.observation_shifted := TRUE;
			RETURN NEXT t_holiday;
			t_holiday.observation_shifted := FALSE;
		END IF;

		t_datestamp := make_date(t_year, MAY, 1);
		t_holiday.datestamp := t_datestamp;
		t_holiday.description := 'Labour Day';
		RETURN NEXT t_holiday;
		IF DATE_PART('dow', t_datestamp) = SUNDAY THEN
			t_holiday.datestamp := t_datestamp + '1 Day'::INTERVAL;
			t_holiday.description := 'Labour Day (Observed)';
			t_holiday.observation_shifted := TRUE;
			RETURN NEXT t_holiday;
			t_holiday.observation_shifted := FALSE;
		END IF;

		t_datestamp := make_date(t_year, JUNE, 1);
		t_holiday.datestamp := t_datestamp;
		t_holiday.description := 'Madaraka Day';
		RETURN NEXT t_holiday;
		IF DATE_PART('dow', t_datestamp) = SUNDAY THEN
			t_holiday.datestamp := t_datestamp + '1 Day'::INTERVAL;
			t_holiday.description := 'Madaraka Day (Observed)';
			t_holiday.observation_shifted := TRUE;
			RETURN NEXT t_holiday;
			t_holiday.observation_shifted := FALSE;
		END IF;

		t_datestamp := make_date(t_year, OCTOBER, 20);
		t_holiday.datestamp := t_datestamp;
		t_holiday.description := 'Mashujaa Day';
		RETURN NEXT t_holiday;
		IF DATE_PART('dow', t_datestamp) = SUNDAY THEN
			t_holiday.datestamp := t_datestamp + '1 Day'::INTERVAL;
			t_holiday.description := 'Mashujaa Day (Observed)';
			t_holiday.observation_shifted := TRUE;
			RETURN NEXT t_holiday;
			t_holiday.observation_shifted := FALSE;
		END IF;

		t_datestamp := make_date(t_year, DECEMBER, 12);
		t_holiday.datestamp := t_datestamp;
		t_holiday.description := 'Jamhuri (Independence) Day';
		RETURN NEXT t_holiday;
		IF DATE_PART('dow', t_datestamp) = SUNDAY THEN
			t_holiday.datestamp := t_datestamp + '1 Day'::INTERVAL;
			t_holiday.description := 'Jamhuri (Independence) Day (Observed)';
			t_holiday.observation_shifted := TRUE;
			RETURN NEXT t_holiday;
			t_holiday.observation_shifted := FALSE;
		END IF;

		t_datestamp := make_date(t_year, DECEMBER, 25);
		t_holiday.datestamp := t_datestamp;
		t_holiday.description := 'Christmas Day';
		RETURN NEXT t_holiday;
		IF DATE_PART('dow', t_datestamp) = SUNDAY THEN
			t_holiday.datestamp := t_datestamp + '1 Day'::INTERVAL;
			t_holiday.description := 'Christmas Day (Observed)';
			t_holiday.observation_shifted := TRUE;
			RETURN NEXT t_holiday;
			t_holiday.observation_shifted := FALSE;
		END IF;

		t_datestamp := make_date(t_year, DECEMBER, 26);
		t_holiday.datestamp := t_datestamp;
		t_holiday.description := 'Boxing Day';
		RETURN NEXT t_holiday;
		IF DATE_PART('dow', t_datestamp) = SUNDAY THEN
			t_holiday.datestamp := t_datestamp + '1 Day'::INTERVAL;
			t_holiday.description := 'Boxing Day (Observed)';
			t_holiday.observation_shifted := TRUE;
			RETURN NEXT t_holiday;
			t_holiday.observation_shifted := FALSE;
		END IF;

		t_datestamp := holidays.easter(t_year);
		t_holiday.datestamp := holidays.find_nth_weekday_date(t_datestamp, FRIDAY, -1);
		t_holiday.description := 'Good Friday';
		RETURN NEXT t_holiday;

		t_holiday.datestamp := holidays.find_nth_weekday_date(t_datestamp, MONDAY, +1);
		t_holiday.description := 'Easter Monday';
		RETURN NEXT t_holiday;

	END LOOP;
END;

$$ LANGUAGE plpgsql;