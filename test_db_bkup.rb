#!/usr/bin/env ruby -w
# Derek B. Smith 10/2009

require 'date'
require 'ftools'
require 'fileutils'

ENV['PATH'] = '/usr/bin:/usr/sbin:/sbin:/bin:/usr/local/bin:/usr/local/vrep'
VERSIONS    = 4.to_i
DB_DIR      = "/usr/local/vrep/prod/db"
DB_DIRT     = "/usr/local/vrep/test/db"
DB_BKUP1    = Dir.glob("/usr/local/vrep/prod*.gz")
SYS_BKUP    = "/backups/system_bkup.tar_"
DB_BKUP     = "/backups/prod_db_bkup_"
RUNLOG      = "/var/log/prod_db_bkup.log"
DBFT        = Dir.glob("#{DB_DIRT}/*.sqlite3")
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


def log_mtd(arg)
    File.open(RUNLOG, "a") do |file|
        file.puts(arg)
    end
end

def db_bkup(arg)
    begin
        Dir.chdir("#{DB_DIR}") 
    rescue 
        log_mtd "Change_Dir_Failed_To_#{DB_DIR}_Dump_Will_Fail_#{arg}"
    end    
    if DBF.length.to_i < 1
        log_mtd "#{DBF}_File_Is_Missing_Dump_Will_Not_Run_#{arg}"
    else
        %x(echo ".dump"|sqlite3 development.sqlite3 |gzip -c > #{DB_BKUP}#{arg} )
        unless $?.success?
            log_mtd "SQL_Dump_Cmd_Failed_#{arg}: status #{$?.exitstatus}"
        else
            %x(tar --exclude "#{DBF}" --exclude "#{DBFT}" -czf "#{SYS_BKUP}"#{arg} /)
            unless $?.success?
                log_mtd "OS_Tar_Backup_Failed_#{arg}: status #{$?.exitstatus}"
            end
        end
    end
end

if DB_BKUP1.length.to_i >= 1
    File.open(RUNLOG, "a") do |file|
        h.each_pair do |key, value|
            if d.wday == value
                file.puts '+'
                65.times do file.print "=" end    
                file.puts "\nBeginning day: #{key} DB backup at #{d.to_s} #{t.hour}:#{t.min}\n"
                file.puts "Executing command echo .dump|sqlite3 development.sqlite3 |gzip -c","\n"
                65.times do file.print "=" end
                file.puts "\n",'+'
                #db_bkup(key .+(d.to_s) .+(t.hour.to_s) .+(t.min.to_s).+(".gz"))
            end
        end
    end
end

if DB_BKUP1.length.to_i > VERSIONS
    File.open(RUNLOG, "a") do |file|
        file.puts "\n",'+'
        65.times do file.print "=" end
        file.puts "Retention is 4d for DB backups, now rolling 4th dump file\n" \
        "#{d.to_s} #{t.hour}:#{t.min}\n"
        65.times do file.print "=" end
    end

    require 'time'
    stats = Hash.new
    DB_BKUP1.each do |dbfile|
        stats[dbfile] = [File.stat(dbfile).mtime]
    end

    oldest = oldestfile = ''
    stats.each_pair do |k,v|
        oldest = v
        if #{v} < #{oldest}
            oldest = v
            oldestfile = stats.index(oldest)
        end
    end
    if File.exists?(oldestfile)
        File.unlink(oldestfile)
    end
end 
