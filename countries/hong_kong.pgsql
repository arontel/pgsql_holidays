------------------------------------------
------------------------------------------
-- Hong Kong Holidays (Porting Unfinished)
--
-- https://www.gov.hk/en/about/abouthk/holiday/2020.htm
-- https://en.wikipedia.org/wiki/Public_holidays_in_Hong_Kong
------------------------------------------
------------------------------------------
--
CREATE OR REPLACE FUNCTION holidays.hong_kong(p_start_year INTEGER, p_end_year INTEGER)
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

		day_following = 'The day following '

		-- The first day of January
		t_holiday.description := 'The first day of January';
		first_date = date(year, JANUARY, 1)
		IF self.observed THEN
			IF first_date.weekday() == SUN THEN
				self[first_date + rd(days=+1)] = day_following + self.first_lower(name)
				first_date = first_date + '+1 Days'::INTERVAL
			ELSE
				self[first_date] = name
			END IF;
		ELSE
			self[first_date] = name
		END IF;

		-- Lunar New Year
		t_holiday.description := 'Lunar New Year''s Day';
		preceding_day_lunar = 'The day preceding Lunar New Year''s Day'
		second_day_lunar = 'The second day of Lunar New Year'
		third_day_lunar = 'The third day of Lunar New Year'
		fourth_day_lunar = 'The fourth day of Lunar New Year'
		dt = self.get_solar_date(year, 1, 1)
		new_year_date = date(dt.year, dt.monTHURSDAY, dt.day)
		IF self.observed THEN
			self[new_year_date] = name
			IF new_year_date.weekday() in [MON, TUE, WED, THU] THEN
				self[new_year_date] = name
				self[new_year_date + '+1 Days'::INTERVAL] = second_day_lunar
				self[new_year_date + '+2 Days'::INTERVAL] = third_day_lunar
			ELSIF new_year_date.weekday() == FRI THEN
				self[new_year_date] = name
				self[new_year_date + '+1 Days'::INTERVAL] = second_day_lunar
				self[new_year_date + '+3 Days'::INTERVAL] = fourth_day_lunar
			ELSIF new_year_date.weekday() == SAT THEN
				self[new_year_date] = name
				self[new_year_date + '+2 Days'::INTERVAL] = third_day_lunar
				self[new_year_date + '+3 Days'::INTERVAL] = fourth_day_lunar
			ELSIF new_year_date.weekday() == SUN THEN
				IF t_year in [2006, 2007, 2010] THEN
					self[new_year_date + '-1 Days'::INTERVAL] = preceding_day_lunar
					self[new_year_date + '+1 Days'::INTERVAL] = second_day_lunar
					self[new_year_date + '+2 Days'::INTERVAL] = third_day_lunar
				ELSE
					self[new_year_date + '+1 Days'::INTERVAL] = second_day_lunar
					self[new_year_date + '+2 Days'::INTERVAL] = third_day_lunar
					self[new_year_date + '+3 Days'::INTERVAL] = fourth_day_lunar
				END IF;
			END IF;
		ELSE
			self[new_year_date] = name
			self[new_year_date + '+1 Days'::INTERVAL] = second_day_lunar
			self[new_year_date + '+2 Days'::INTERVAL] = third_day_lunar
		END IF;

		-- Ching Ming Festival
		t_holiday.description := 'Ching Ming Festival';
		if self.isLeapYear(year) or (self.isLeapYear(year - 1) and year > 2008):
			ching_ming_date = date(year, APRIL, 4)
		ELSE
			ching_ming_date = date(year, APRIL, 5)
		END IF;
		IF self.observed THEN
			IF ching_ming_date.weekday() == SUN THEN
				self[ching_ming_date + '+1 Days'::INTERVAL] = day_following + name
				ching_ming_date = ching_ming_date + '+1 Days'::INTERVAL
			ELSE
				self[ching_ming_date] = name
			END IF;
		ELSE
			self[ching_ming_date] = name
		END IF;

		-- Easter Holiday
		good_friday = 'Good Friday'
		easter_monday = 'Easter Monday'
		IF self.observed THEN
			self[easter(year) + rd(weekday=FR(-1))] = good_friday
			self[easter(year) + rd(weekday=SA(-1))] = day_following + good_friday
			IF ching_ming_date == easter(year) + rd(weekday=MO) THEN
				self[easter(year) + rd(weekday=MO) + '+1 Days'::INTERVAL] = day_following + easter_monday
			ELSE
				self[easter(year) + rd(weekday=MO)] = easter_monday
			END IF;
		ELSE
			self[easter(year) + rd(weekday=FR(-1))] = good_friday
			self[easter(year) + rd(weekday=SA(-1))] = day_following + \
				good_friday
			self[easter(year) + rd(weekday=MO)] = easter_monday
		END IF;

		-- Birthday of the Buddha
		t_holiday.description := 'Birthday of the Buddha';
		dt = self.get_solar_date(year, 4, 8)
		buddha_date = date(dt.year, dt.monTHURSDAY, dt.day)
		IF self.observed THEN
			IF buddha_date.weekday() == SUN THEN
				self[buddha_date + '+1 Days'::INTERVAL] = day_following + name
			ELSE
				self[buddha_date] = name
			END IF;
		ELSE
			self[buddha_date] = name
		END IF;

		-- Labour Day
		t_holiday.description := 'Labour Day';
		labour_date = date(year, MAY, 1)
		IF self.observed THEN
			IF labour_date.weekday() == SUN THEN
				self[labour_date + '+1 Days'::INTERVAL] = day_following + name
			ELSE
				self[labour_date] = name
			END IF;
		ELSE
			self[labour_date] = name
		END IF;

		-- Tuen Ng Festival
		t_holiday.description := 'Tuen Ng Festival';
		dt = self.get_solar_date(year, 5, 5)
		tuen_ng_date = date(dt.year, dt.monTHURSDAY, dt.day)
		IF self.observed THEN
			IF tuen_ng_date.weekday() == SUN THEN
				self[tuen_ng_date + '+1 Days'::INTERVAL] = day_following + name
			ELSE
				self[tuen_ng_date] = name
			END IF;
		ELSE
			self[tuen_ng_date] = name
		END IF;

		-- Hong Kong Special Administrative Region Establishment Day
		t_holiday.description := 'Hong Kong Special Administrative Region Establishment Day';
		hksar_date = date(year, JULY, 1)
		IF self.observed THEN
			IF hksar_date.weekday() == SUN THEN
				self[hksar_date + '+1 Days'::INTERVAL] = day_following + name
			ELSE
				self[hksar_date] = name
			END IF;
		ELSE
			self[hksar_date] = name
		END IF;

		-- Special holiday on 2015 - The 70th anniversary day of the victory
		-- of the Chinese people's war of resistance against Japanese aggression
		t_holiday.description := 'The 70th anniversary day of the victory of the Chinese people''s war of resistance against Japanese aggression';
		IF t_year == 2015 THEN
			t_holiday.datestamp := make_date(t_year, SEPTEMBER, 3);
			RETURN NEXT t_holiday;
		END IF;

		-- Chinese Mid-Autumn Festival
		t_holiday.description := 'Chinese Mid-Autumn Festival';
		dt = self.get_solar_date(year, 8, 15)
		mid_autumn_date = date(dt.year, dt.monTHURSDAY, dt.day)
		IF self.observed THEN
			IF mid_autumn_date.weekday() == SAT THEN
				self[mid_autumn_date] = name
			ELSE
				self[mid_autumn_date + '+1 Days'::INTERVAL] = day_following + 'the ' + name
			END IF;
			mid_autumn_date = mid_autumn_date + '+1 Days'::INTERVAL
		ELSE
			self[mid_autumn_date] = name
		END IF;

		-- National Day
		t_holiday.description := 'National Day';
		national_date = date(year, OCTOBER, 1)
		IF self.observed THEN
			IF (national_date.weekday() = SUN or national_date = mid_autumn_date) THEN
				self[national_date + '+1 Days'::INTERVAL] = day_following + name
			ELSE
				self[national_date] = name
			END IF;
		ELSE
			self[national_date] = name
		END IF;

		-- Chung Yeung Festival
		t_holiday.description := 'Chung Yeung Festival';
		dt = self.get_solar_date(year, 9, 9)
		chung_yeung_date = date(dt.year, dt.monTHURSDAY, dt.day)
		IF self.observed THEN
			IF chung_yeung_date.weekday() == SUN THEN
				self[chung_yeung_date + '+1 Days'::INTERVAL] = day_following + name
			ELSE
				self[chung_yeung_date] = name
			END IF;
		ELSE
			self[chung_yeung_date] = name
		END IF;

		-- Christmas Day
		t_holiday.description := 'Christmas Day';
		first_after_christmas = 'The first weekday after ' + name
		second_after_christmas = 'The second weekday after ' + name
		christmas_date = date(year, DECEMBER, 25)
		IF self.observed THEN
			IF christmas_date.weekday() == SUN THEN
				self[christmas_date] = name
				self[christmas_date + '+1 Days'::INTERVAL] = first_after_christmas
				self[christmas_date + '+2 Days'::INTERVAL] = second_after_christmas
			ELSIF christmas_date.weekday() == SAT THEN
				self[christmas_date] = name
				self[christmas_date + '+2 Days'::INTERVAL] = first_after_christmas
			ELSE
				self[christmas_date] = name
				self[christmas_date + '+1 Days'::INTERVAL] = first_after_christmas
			END IF;
		ELSE
			self[christmas_date] = name
			self[christmas_date + '+1 Days'::INTERVAL] = day_following + name
		END IF;

	def isLeapYear(self, year):
		IF t_year % 4 != 0 THEN
			return False
		ELSIF t_year % 100 != 0 THEN
			return True
		ELSIF t_year % 400 != 0 THEN
			return False
		ELSE
			return True
		END IF;

	def first_lower(self, s):
		return s[0].lower() + s[1:]

	-- Store the number of days per year from 1901 to 2099, and the number of
	-- days from the 1st to the 13th to store the monthly (including the month
	-- of the month), 1 means that the month is 30 days. 0 means the month is
	-- 29 days. The 12th to 15th digits indicate the month of the next month.
	-- If it is 0x0F, it means that there is no leap month.
	g_lunar_month_days = [
		0xF0EA4, 0xF1D4A, 0x52C94, 0xF0C96, 0xF1536,
		0x42AAC, 0xF0AD4, 0xF16B2, 0x22EA4, 0xF0EA4,  -- 1901-1910
		0x6364A, 0xF164A, 0xF1496, 0x52956, 0xF055A,
		0xF0AD6, 0x216D2, 0xF1B52, 0x73B24, 0xF1D24,  -- 1911-1920
		0xF1A4A, 0x5349A, 0xF14AC, 0xF056C, 0x42B6A,
		0xF0DA8, 0xF1D52, 0x23D24, 0xF1D24, 0x61A4C,  -- 1921-1930
		0xF0A56, 0xF14AE, 0x5256C, 0xF16B4, 0xF0DA8,
		0x31D92, 0xF0E92, 0x72D26, 0xF1526, 0xF0A56,  -- 1931-1940
		0x614B6, 0xF155A, 0xF0AD4, 0x436AA, 0xF1748,
		0xF1692, 0x23526, 0xF152A, 0x72A5A, 0xF0A6C,  -- 1941-1950
		0xF155A, 0x52B54, 0xF0B64, 0xF1B4A, 0x33A94,
		0xF1A94, 0x8152A, 0xF152E, 0xF0AAC, 0x6156A,  -- 1951-1960
		0xF15AA, 0xF0DA4, 0x41D4A, 0xF1D4A, 0xF0C94,
		0x3192E, 0xF1536, 0x72AB4, 0xF0AD4, 0xF16D2,  -- 1961-1970
		0x52EA4, 0xF16A4, 0xF164A, 0x42C96, 0xF1496,
		0x82956, 0xF055A, 0xF0ADA, 0x616D2, 0xF1B52,  -- 1971-1980
		0xF1B24, 0x43A4A, 0xF1A4A, 0xA349A, 0xF14AC,
		0xF056C, 0x60B6A, 0xF0DAA, 0xF1D92, 0x53D24,  -- 1981-1990
		0xF1D24, 0xF1A4C, 0x314AC, 0xF14AE, 0x829AC,
		0xF06B4, 0xF0DAA, 0x52D92, 0xF0E92, 0xF0D26,  -- 1991-2000
		0x42A56, 0xF0A56, 0xF14B6, 0x22AB4, 0xF0AD4,
		0x736AA, 0xF1748, 0xF1692, 0x53526, 0xF152A,  -- 2001-2010
		0xF0A5A, 0x4155A, 0xF156A, 0x92B54, 0xF0BA4,
		0xF1B4A, 0x63A94, 0xF1A94, 0xF192A, 0x42A5C,  -- 2011-2020
		0xF0AAC, 0xF156A, 0x22B64, 0xF0DA4, 0x61D52,
		0xF0E4A, 0xF0C96, 0x5192E, 0xF1956, 0xF0AB4,  -- 2021-2030
		0x315AC, 0xF16D2, 0xB2EA4, 0xF16A4, 0xF164A,
		0x63496, 0xF1496, 0xF0956, 0x50AB6, 0xF0B5A,  -- 2031-2040
		0xF16D4, 0x236A4, 0xF1B24, 0x73A4A, 0xF1A4A,
		0xF14AA, 0x5295A, 0xF096C, 0xF0B6A, 0x31B54,  -- 2041-2050
		0xF1D92, 0x83D24, 0xF1D24, 0xF1A4C, 0x614AC,
		0xF14AE, 0xF09AC, 0x40DAA, 0xF0EAA, 0xF0E92,  -- 2051-2060
		0x31D26, 0xF0D26, 0x72A56, 0xF0A56, 0xF14B6,
		0x52AB4, 0xF0AD4, 0xF16CA, 0x42E94, 0xF1694,  -- 2061-2070
		0x8352A, 0xF152A, 0xF0A5A, 0x6155A, 0xF156A,
		0xF0B54, 0x4174A, 0xF1B4A, 0xF1A94, 0x3392A,  -- 2071-2080
		0xF192C, 0x7329C, 0xF0AAC, 0xF156A, 0x52B64,
		0xF0DA4, 0xF1D4A, 0x41C94, 0xF0C96, 0x8192E,  -- 2081-2090
		0xF0956, 0xF0AB6, 0x615AC, 0xF16D4, 0xF0EA4,
		0x42E4A, 0xF164A, 0xF1516, 0x22936,		   -- 2090-2099
	]
	-- Define range of years
	START_YEAR, END_YEAR = 1901, 1900 + len(g_lunar_month_days)
	-- 1901 The 1st day of the 1st month of the Gregorian calendar is 1901/2/19
	LUNAR_START_DATE, SOLAR_START_DATE = (1901, 1, 1), datetime(1901, 2, 19)
	-- The Gregorian date for December 30, 2099 is 2100/2/8
	LUNAR_END_DATE, SOLAR_END_DATE = (2099, 12, 30), datetime(2100, 2, 18)

	def get_leap_month(self, lunar_year):
		return (self.g_lunar_month_days[lunar_year - self.START_YEAR] >> 16) \
			& 0x0F

	def lunar_month_days(self, lunar_year, lunar_month):
		return 29 + ((self.g_lunar_month_days[lunar_year - self.START_YEAR] >>
					  lunar_month) & 0x01)

	def lunar_year_days(self, year):
		days = 0
		months_day = self.g_lunar_month_days[year - self.START_YEAR]
		for i in range(1, 13 if self.get_leap_month(year) == 0x0F else 14):
			day = 29 + ((months_day >> i) & 0x01)
			days += day
		return days

	-- Calculate the Gregorian date according to the lunar calendar
	def get_solar_date(self, year, month, day):
		span_days = 0
		for y in range(self.START_YEAR, year):
			span_days += self.lunar_year_days(y)
		leap_month = self.get_leap_month(year)
		for m in range(1, month + (month > leap_month)):
			span_days += self.lunar_month_days(year, m)
		span_days += day - 1
		return self.SOLAR_START_DATE + timedelta(span_days)

	END LOOP;
END;

$$ LANGUAGE plpgsql;