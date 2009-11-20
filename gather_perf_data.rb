#!/usr/bin/env ruby -w
# Derek B. Smith 08/2009

require 'ftools'
require 'fileutils'

=begin
#-----------------------------
File::LOCK_SH     # shared lock (for reading)
File::LOCK_EX     # exclusive lock (for writing)
File::LOCK_NB     # non-blocking request
File::LOCK_UN     # free lock
#-----------------------------
=end


###-- 10 files at 2Mb (approx. 30k lines) before rolling begins ---###

ENV['PATH'] = '/usr/bin:/usr/sbin:/sbin:/bin:/usr/local/bin'
ROLLSIZE    = 2097200.to_i
LOGDIR      = "/var/log"
LOGFILE     = "/var/log/gather_perf_data.log"

begin
    Dir.chdir( "#{LOGDIR}" ) 
rescue
    "Change dir failed to #{LOGDIR} !"
end

FileUtils.touch( "#{LOGFILE}" ) \
    or raise StandardError, "Touch file failed #{LOGFILE} !"

File.open( "#{LOGFILE}", "a" ) do |file|
    18.times do file.print "=" end
    file.puts
    file.puts `date +%D" "%T`
    18.times do file.print "=" end
    file.puts
    file.puts `top -b`
    file.puts
    sleep 1
    file.puts `ps auxwww`
    file.puts
    sleep 1
    file.puts `vmstat 5 10`
    file.puts
    sleep 1
    file.puts `free`
    file.puts 
    sleep 1
    file.puts `iostat -K 5 10`
    file.puts
end

FILESIZE = File.size(LOGFILE).to_i

if FILESIZE >= ROLLSIZE
    File.open( "#{LOGFILE}", "r" ) do |f|
        if (f.flock(File::LOCK_SH)) == 0
            FileUtils.cp( "#{LOGFILE}", "#{LOGFILE}.copied" )
            `/usr/bin/gzip "#{LOGFILE}.copied"`
            File.truncate( "#{LOGFILE}", 0 )
        end
        f.flock(File::LOCK_UN)
    end

    array1_1 = Dir["#{LOGDIR}/gather*.gz"]

    if (array1_1.length >= 1)
        if File.exists?("gather*.copied.11.gz")
            FileUtils.rm_r Dir.glob("gather*.copied.11.gz")
        end
        if File.exists?("gather_perf_data.log.copied.10.gz")
            File.rename("gather_perf_data.log.copied.10.gz", "gather_perf_data.log.copied.11.gz")
        end
        if File.exists?("gather_perf_data.log.copied.9.gz")
            File.rename("gather_perf_data.log.copied.9.gz", "gather_perf_data.log.copied.10.gz")
        end
        if File.exists?("gather_perf_data.log.copied.8.gz")
            File.rename("gather_perf_data.log.copied.8.gz", "gather_perf_data.log.copied.9.gz")
        end
        if File.exists?("gather_perf_data.log.copied.7.gz")
            File.rename("gather_perf_data.log.copied.7.gz", "gather_perf_data.log.copied.8.gz")
        end
        if File.exists?("gather_perf_data.log.copied.6.gz")
            File.rename("gather_perf_data.log.copied.6.gz", "gather_perf_data.log.copied.7.gz")
        end
        if File.exists?("gather_perf_data.log.copied.5.gz")
            File.rename("gather_perf_data.log.copied.5.gz", "gather_perf_data.log.copied.6.gz")
        end
        if File.exists?("gather_perf_data.log.copied.4.gz")
            File.rename("gather_perf_data.log.copied.4.gz", "gather_perf_data.log.copied.5.gz")
        end
        if File.exists?("gather_perf_data.log.copied.3.gz")
            File.rename("gather_perf_data.log.copied.3.gz", "gather_perf_data.log.copied.4.gz")
        end
        if File.exists?("gather_perf_data.log.copied.2.gz")
            File.rename("gather_perf_data.log.copied.2.gz", "gather_perf_data.log.copied.3.gz")
        end
        if File.exists?("gather_perf_data.log.copied.1.gz")
            File.rename("gather_perf_data.log.copied.1.gz", "gather_perf_data.log.copied.2.gz")
        end
        if File.exists?("gather_perf_data.log.copied.gz")
            File.rename("gather_perf_data.log.copied.gz", "gather_perf_data.log.copied.1.gz")
        end
    end
end
