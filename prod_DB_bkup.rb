#!/usr/bin/env ruby -w
# Derek B. Smith 10/2009

require 'date'
require 'ftools'
require 'fileutils'

ENV['PATH'] = '/usr/bin:/usr/sbin:/sbin:/bin:/usr/local/bin:/usr/local/vrep'
VERSIONS    = 5.to_i
DB_DIR      = "/usr/local/vrep/prod/db"
DB_BKUP1    = Dir.glob("/backups/prod*.bz2")
DB_BKUP     = "/backups/prod_db_bkup_"
RUNLOG      = "/var/log/prod_db_bkup.log"
DBF         = Dir.glob("#{DB_DIR}/*.sqlite3")


d = Date.today
t = Time.now
h = Hash.new
    h["Sun"] = 0
    h["Mon"] = 1
    h["Tue"] = 2
    h["Wed"] = 3
    h["Thr"] = 4
    h["Fri"] = 5
    h["Sat"] = 6


#########################################
=begin
This is a log method using data passed 
in arg
=end
#########################################

def log_mtd(arg)
    File.open(RUNLOG, "a") do |file|
        file.puts(arg)
    end
end


##############################################
=begin
This is the backup method passing data to arg
onto the log method.  Calls sqlite3 for the
backup.
=end
##############################################

def db_bkup(arg)
    begin
        Dir.chdir("#{DB_DIR}") 
    rescue 
        log_mtd "Change_Dir_Failed_To_#{DB_DIR}_Dump_Will_Fail_#{arg}"
    end    
    if DBF.length.to_i < 1
        log_mtd "#{DBF}_File_Is_Missing_Dump_Will_Not_Run_#{arg}"
    else
        %x(echo ".dump"|sqlite3 development.sqlite3 |bzip2 -c > #{DB_BKUP}#{arg} )
        unless $?.success?
            log_mtd "SQL_Dump_Cmd_Failed_#{arg}: status #{$?.exitstatus}"
        else
            log_mtd "SQL_Dump_Cmd_Succeeded_#{arg}: status #{$?.exitstatus}"
            log_mtd %x(ls -lrt /backups)
        end
    end
end


##################################
=begin
This is the DB backup sort method
=end
##################################

def sort_clean

    stats = Hash.new
    stats = DB_BKUP1.map do |dbfile|
        [dbfile, File.stat(dbfile)]
    end

    stats = stats.sort_by do |dbfile,stat|
        stat.mtime
    end


################################
=begin
This is cleanup, sweep sweep.
=end
################################

    oldestfile = "#{stats.first[0]}"
    if File.exists?(oldestfile)
        File.unlink(oldestfile)
    end

    onemb = 1048600.to_i
    if File.size(RUNLOG) > onemb
        File.truncate( "#{RUNLOG}", 0 )
    end
end


#############################################
=begin MAIN:

This is the main program. Checks if there are
more than 3 versions of either file, if there
is proceed to remove oldest if there is not
get day-of-week and match this to the hash
above then log run-time information to 
/var/log/prod_db_bkup.log.  Finally call
method db_bkup with 1 argument appended as 
one string.
=end
#############################################


File.open(RUNLOG, "a") do |file|

if DB_BKUP1.length.to_i <= VERSIONS 
    h.each_pair do |key, value|
        if d.wday == value
            file.puts '+'
            65.times do file.print "=" end    
            file.puts "\nBeginning day: #{key} DB backup at #{d.to_s} #{t.hour}:#{t.min}\n"
            file.puts "Executing command echo .dump|sqlite3 development.sqlite3 |bzip2 -c","\n"
            65.times do file.print "=" end
            file.puts "\n",'+'
            db_bkup(key .+(d.to_s) .+(t.hour.to_s) .+(t.min.to_s).+(".bz2"))
        end
    end
else
    file.puts "\n",'+'
    65.times do file.print "=" end
    file.puts "\nRetention is 5d for DB backups, now rolling 5th dump file\n" \
    "#{d.to_s} #{t.hour}:#{t.min}\n"
    file.puts DB_BKUP1.length.to_i
    65.times do file.print "=" end
    file.puts
    sort_clean()
end
end
