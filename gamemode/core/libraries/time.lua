lia.time = {}
function lia.time.GetFormattedDate( StartingMessage, includeWeekDay, includeDay, includeMonth, includeYear, includeTime )
	local currentTime = os.date( "*t" )
	if StartingMessage then
		output = StartingMessage
	else
		output = ""
	end

	if includeWeekDay then
		local daysOfWeek = { "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday" }
		output = output .. " " .. daysOfWeek[ currentTime.wday ] .. ", "
	end

	local day, month, year
	if lia.config.get( "AmericanDates" ) then
		month, day, year = currentTime.month, currentTime.day, currentTime.year
	else
		day, month, year = currentTime.day, currentTime.month, currentTime.year
	end

	if includeDay then output = output .. " " .. day end
	if includeMonth then
		local months = { "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December" }
		output = output .. " " .. months[ month ]
	end

	if includeYear then output = output .. ", " .. year end
	local hourFormat = lia.config.get( "AmericanTimeStamp" ) and 12 or 24
	local ampm = ""
	local hour = currentTime.hour
	if includeTime then
		if hourFormat == 12 then
			if currentTime.hour >= 12 then
				ampm = " PM"
				if currentTime.hour > 12 then hour = currentTime.hour - 12 end
			else
				ampm = " AM"
			end
		end

		output = output .. string.format( " %02d:%02d:%02d%s", hour, currentTime.min, currentTime.sec, ampm )
	end
	return output
end

function lia.time.GetFormattedDateInGame( StartingMessage, includeWeekDay, includeDay, includeMonth, includeYear, includeTime )
	local currentTime = os.date( "*t" )
	if StartingMessage then
		output = StartingMessage
	else
		output = ""
	end

	if includeWeekDay then
		local daysOfWeek = { "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday" }
		output = output .. " " .. daysOfWeek[ currentTime.wday ] .. ", "
	end

	local day, month, year
	if lia.config.get( "AmericanDates" ) then
		month, day, year = currentTime.month, currentTime.day, lia.config.get( "SchemaYear" ) or currentTime.year
	else
		day, month, year = currentTime.day, currentTime.month, lia.config.get( "SchemaYear" ) or currentTime.year
	end

	if includeDay then output = output .. " " .. day end
	if includeMonth then
		local months = { "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December" }
		output = output .. " " .. months[ month ]
	end

	if includeYear then output = output .. ", " .. year end
	local hourFormat = lia.config.get( "AmericanTimeStamp" ) and 12 or 24
	local ampm = ""
	local hour = currentTime.hour
	if includeTime then
		if hourFormat == 12 then
			if currentTime.hour >= 12 then
				ampm = " PM"
				if currentTime.hour > 12 then hour = currentTime.hour - 12 end
			else
				ampm = " AM"
			end
		end

		output = output .. string.format( " %02d:%02d:%02d%s", hour, currentTime.min, currentTime.sec, ampm )
	end
	return output
end

function lia.time.GetPreFormattedDate( StartingMessage, timeToFormat, includeWeekDay, includeDay, includeMonth, includeYear, includeTime )
	local currentTime = tostring( timeToFormat )
	if StartingMessage then
		output = StartingMessage
	else
		output = ""
	end

	if includeWeekDay then
		local daysOfWeek = { "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday" }
		output = output .. " " .. daysOfWeek[ currentTime.wday ] .. ", "
	end

	local day, month, year
	if lia.config.get( "AmericanDates" ) then
		month, day, year = currentTime.month, currentTime.day, currentTime.year
	else
		day, month, year = currentTime.day, currentTime.month, currentTime.year
	end

	if includeDay then output = output .. " " .. day end
	if includeMonth then
		local months = { "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December" }
		output = output .. " " .. months[ month ]
	end

	if includeYear then output = output .. ", " .. year end
	local hourFormat = lia.config.get( "AmericanTimeStamp" ) and 12 or 24
	local ampm = ""
	local hour = currentTime.hour
	if includeTime then
		if hourFormat == 12 then
			if currentTime.hour >= 12 then
				ampm = " PM"
				if currentTime.hour > 12 then hour = currentTime.hour - 12 end
			else
				ampm = " AM"
			end
		end

		output = output .. string.format( " %02d:%02d:%02d%s", hour, currentTime.min, currentTime.sec, ampm )
	end
	return output
end

function lia.time.GetPreFormattedDateInGame( StartingMessage, timeToFormat, includeWeekDay, includeDay, includeMonth, includeYear, includeTime )
	local currentTime = tostring( timeToFormat )
	if StartingMessage then
		output = StartingMessage
	else
		output = ""
	end

	if includeWeekDay then
		local daysOfWeek = { "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday" }
		output = output .. " " .. daysOfWeek[ currentTime.wday ] .. ", "
	end

	local day, month, year
	if lia.config.get( "AmericanDates" ) then
		month, day, year = currentTime.month, currentTime.day, lia.config.get( "SchemaYear" ) or currentTime.year
	else
		day, month, year = currentTime.day, currentTime.month, lia.config.get( "SchemaYear" ) or currentTime.year
	end

	if includeDay then output = output .. " " .. day end
	if includeMonth then
		local months = { "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December" }
		output = output .. " " .. months[ month ]
	end

	if includeYear then output = output .. ", " .. year end
	local hourFormat = lia.config.get( "AmericanTimeStamp" ) and 12 or 24
	local ampm = ""
	local hour = currentTime.hour
	if includeTime then
		if hourFormat == 12 then
			if currentTime.hour >= 12 then
				ampm = " PM"
				if currentTime.hour > 12 then hour = currentTime.hour - 12 end
			else
				ampm = " AM"
			end
		end

		output = output .. string.format( " %02d:%02d:%02d%s", hour, currentTime.min, currentTime.sec, ampm )
	end
	return output
end

function lia.time.toNumber( str )
	str = str or os.date( "%Y-%m-%d %H:%M:%S", os.time() )
	return {
		year = tonumber( str:sub( 1, 4 ) ),
		month = tonumber( str:sub( 6, 7 ) ),
		day = tonumber( str:sub( 9, 10 ) ),
		hour = tonumber( str:sub( 12, 13 ) ),
		min = tonumber( str:sub( 15, 16 ) ),
		sec = tonumber( str:sub( 18, 19 ) ),
	}
end

function lia.time.TimeSince( strTime )
	local timestamp
	if isnumber( strTime ) then
		timestamp = strTime
	elseif isstring( strTime ) then
		local year, month, day = lia.time.ParseTime( strTime )
		if not ( year and month and day ) then return "Invalid date" end
		timestamp = os.time( {
			year = year,
			month = month,
			day = day,
			hour = 0,
			min = 0,
			sec = 0
		} )
	else
		return "Invalid input"
	end

	local diff = os.time() - timestamp
	if diff < 60 then
		return diff .. " seconds ago"
	elseif diff < 3600 then
		return math.floor( diff / 60 ) .. " minutes ago"
	elseif diff < 86400 then
		return math.floor( diff / 3600 ) .. " hours ago"
	else
		return math.floor( diff / 86400 ) .. " days ago"
	end
end

function lia.time.TimeUntil( strTime )
	local pattern = "(%d+):(%d+):(%d+)%s*%-%s*(%d+)/(%d+)/(%d+)"
	local hour, minute, second, day, month, year = strTime:match( pattern )
	if not ( hour and minute and second and day and month and year ) then return "Invalid time format. Expected 'HH:MM:SS - DD/MM/YYYY'." end
	hour, minute, second, day, month, year = tonumber( hour ), tonumber( minute ), tonumber( second ), tonumber( day ), tonumber( month ), tonumber( year )
	if hour < 0 or hour > 23 or minute < 0 or minute > 59 or second < 0 or second > 59 or day < 1 or day > 31 or month < 1 or month > 12 or year < 1970 then return "Invalid time values." end
	local inputTimestamp = os.time( {
		year = year,
		month = month,
		day = day,
		hour = hour,
		min = minute,
		sec = second
	} )

	local currentTimestamp = os.time()
	if inputTimestamp <= currentTimestamp then return "The specified time is in the past." end
	local diffSeconds = inputTimestamp - currentTimestamp
	local years = math.floor( diffSeconds / ( 365.25 * 24 * 3600 ) )
	diffSeconds = diffSeconds % ( 365.25 * 24 * 3600 )
	local months = math.floor( diffSeconds / ( 30.44 * 24 * 3600 ) )
	diffSeconds = diffSeconds % ( 30.44 * 24 * 3600 )
	local days = math.floor( diffSeconds / ( 24 * 3600 ) )
	diffSeconds = diffSeconds % ( 24 * 3600 )
	local hours = math.floor( diffSeconds / 3600 )
	diffSeconds = diffSeconds % 3600
	local minutes = math.floor( diffSeconds / 60 )
	local seconds = diffSeconds % 60
	return string.format( "%d years, %d months, %d days, %d hours, %d minutes, %d seconds", years, months, days, hours, minutes, seconds )
end

function lia.time.CurrentLocalTime()
	local now = os.time()
	local t = os.date( "*t", now )
	return string.format( "%02d:%02d:%02d - %02d/%02d/%04d", t.hour, t.min, t.sec, t.day, t.month, t.year )
end

function lia.time.SecondsToDHMS( seconds )
	local days = math.floor( seconds / 86400 )
	seconds = seconds % 86400
	local hours = math.floor( seconds / 3600 )
	seconds = seconds % 3600
	local minutes = math.floor( seconds / 60 )
	local secs = seconds % 60
	return days, hours, minutes, secs
end

function lia.time.HMSToSeconds( hour, minute, second )
	return hour * 3600 + minute * 60 + second
end

function lia.time.FormatTimestamp( timestamp )
	local t = os.date( "*t", timestamp )
	return string.format( "%02d:%02d:%02d - %02d/%02d/%04d", t.hour, t.min, t.sec, t.day, t.month, t.year )
end

function lia.time.ParseTime( strTime )
	local pattern = "(%d+):(%d+):(%d+)%s*%-%s*(%d+)/(%d+)/(%d+)"
	local hour, minute, second, d, m, y = strTime:match( pattern )
	if not ( hour and minute and second and d and m and y ) then return nil end
	hour, minute, second, d, m, y = tonumber( hour ), tonumber( minute ), tonumber( second ), tonumber( d ), tonumber( m ), tonumber( y )
	if hour < 0 or hour > 23 then return nil end
	if minute < 0 or minute > 59 then return nil end
	if second < 0 or second > 59 then return nil end
	if m < 1 or m > 12 then return nil end
	local maxDay = lia.time.DaysInMonth( m, y )
	if not maxDay or d < 1 or d > maxDay then return nil end
	if y < 1970 then return nil end
	return y, m, d, hour, minute, second
end

function lia.time.DaysBetween( strTime1, strTime2 )
	local y1, mo1, d1 = lia.time.ParseTime( strTime1 )
	local y2, mo2, d2 = lia.time.ParseTime( strTime2 )
	if not ( y1 and y2 ) then return "Invalid dates" end
	local t1 = os.time( {
		year = y1,
		month = mo1,
		day = d1,
		hour = 0,
		min = 0,
		sec = 0
	} )

	local t2 = os.time( {
		year = y2,
		month = mo2,
		day = d2,
		hour = 0,
		min = 0,
		sec = 0
	} )

	local diff = os.difftime( t2, t1 )
	return math.floor( diff / 86400 )
end

function lia.time.WeekdayName( strTime )
	local y, mo, d, h, mi, s = lia.time.ParseTime( strTime )
	if not y then return "Invalid date" end
	local t = os.time( {
		year = y,
		month = mo,
		day = d,
		hour = h,
		min = mi,
		sec = s
	} )
	return os.date( "%A", t )
end

function lia.time.TimeDifference( strTime )
	local pattern = "(%d+):(%d+):(%d+)%s*-%s*(%d+)/(%d+)/(%d+)"
	local hour, minute, second, day, month, year = strTime:match( pattern )
	if not ( hour and minute and second and day and month and year ) then return nil end
	hour, minute, second, day, month, year = tonumber( hour ), tonumber( minute ), tonumber( second ), tonumber( day ), tonumber( month ), tonumber( year )
	local targetDate = os.time( {
		year = year,
		month = month,
		day = day,
		hour = hour,
		min = minute,
		sec = second
	} )

	local currentDate = os.time()
	local differenceInDays = math.floor( os.difftime( targetDate, currentDate ) / ( 24 * 60 * 60 ) )
	return differenceInDays
end
